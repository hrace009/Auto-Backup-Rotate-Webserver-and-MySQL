#!/bin/bash
#
# A simple script to dump and rotate Webserver and MySQL backups
#
# Copyright (c) 2018 Harris Marfel
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#

## set default variables
backup_root="/srv/backups"				                       # root directory for all backups
backup_target="/home"					                           # target directory to backup
backup_file="public_html_"				                       # backup file name
v=true							                                     # verbose output
keep=1							                                     # number of old backups to keep
hash=sha256						                                   # crypto hash to use for checksums
GDrive_Folder_ID="Enter your gdrive folder here"	       # gdrive folder ID

# set mysqldump options
dumpopts='--single-transaction --flush-logs --flush-privileges'

## don't edit below this line

# get our options
while getopts qk:h: opt; do
  case $opt in
  q)
      v=false
      ;;
  k)
      keep=$OPTARG 
      ;;
  h)
      hash=$OPTARG 
      ;;
  esac
done
shift $((OPTIND - 1))

# set a righteous mask
umask 0027

# create backup path
stamp=`date +%Y-%m-%d.%H%M%S`
backup_dir=${backup_root}/${stamp}
mkdir -p ${backup_dir}
$v && printf 'Keeping %s backups.\n' $keep
$v && printf 'Backup location: %s\n' $backup_dir

## set some functions

# get a list of databases to backup (strip out garbage and internal databases)
_get_db_list () {
  mysqlshow | \
    sed -r '/Databases|information_schema|mysql|performance_schema/d' | \
    awk '{ print $2 }'
}

_get_dir_list () {
	ls -l $backup_target | egrep '^d' | sed -r '/centos/d' | awk '{print$9}'
}

# get a list of backups in the backup directory, ignore files and links
# make this a pattern match later
_get_backups () {
  (cd $backup_root && find ./* -maxdepth 1 -type d -exec basename {} \;)
}

# dump database
_dump_db () {
	nice -n 19 mysqldump $1 | nice -n 19 gzip
}

# create checksums
_checksum () {
  sum=`openssl $hash $1 | cut -d' ' -f2`
  printf '%s %s\n' $sum `basename $1`
}

# get the database list and remove garbage
db_list=`_get_db_list`
dir_list=`_get_dir_list`

# run the backup
for db in $db_list; do
   $v && printf 'Backing up "%s" database...' $db
   _dump_db $db > ${backup_dir}/${db}.sql.gz
   _checksum ${backup_dir}/${db}.sql.gz >> ${backup_dir}/${hash^^}SUMS
   $v &&printf ' done.\n'
done
sync; echo 3 > /proc/sys/vm/drop_caches
echo ""
sleep 5
#_backup_Web_data
for dir in $dir_list; do
	$v && printf 'Backing up public_html_%s website data...' $dir
	nice -n 19 /usr/bin/7za a ${backup_dir}/${backup_file}_${dir}.7z ${backup_target}/${dir}
		find ${backup_target}/${dir}/logs -type f -print | while read ilogs
		do
			cat /dev/null > "$ilogs"
		done
	_checksum ${backup_dir}/${backup_file}_${dir}.7z >> ${backup_dir}/${hash^^}SUMS
	$v &&printf ' done.\n'
done
sleep 5
sync; echo 3 > /proc/sys/vm/drop_caches

# create a link to current backup
(cd $backup_root && rm -f latest && ln -s ${stamp} latest)

# find out how many backup directories are in the root
dirnum=`_get_backups | wc -l`
diff=$(expr $dirnum - $keep)

# figure out if we need to delete any old backups
if [ "$diff" -gt "0" ]; then
  $v && printf 'Removing %s old backup(s):\n' $diff
  for d in `_get_backups | sort | head -n $diff`; do
    $v && printf '  %s\n' $d
    rm -rf ${backup_root}/${d}
  done
else
  $v && printf 'No old backups to remove (found %s).\n' $dirnum
fi
# chmod folder and files
find $backup_root -type d -exec chmod 700 {} \;
find $backup_root -type f -exec chmod 600 {} \;
sleep 10
sync; echo 3 > /proc/sys/vm/drop_caches
sleep 3
/usr/local/bin/gdrive sync upload --keep-remote $backup_root $GDrive_Folder_ID
sleep 5
/usr/bin/yum -y update
sleep 5
shutdown -r now