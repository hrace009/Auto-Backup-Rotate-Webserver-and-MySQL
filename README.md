# Auto Backup Rotate Webserver and MySQL

A simple script to dump and rotate Webserver and MySQL backups

## Important Parameter
<ul>
<li><code>backup_root="/srv/backups"</code> #Enter your backup destination</li>
<li><code>backup_target="/home"</code> #Enter folder you wish to backup</li>
<li><code>backup_file="public_html_"</code> #Enter backup file name</li>
<li><code>keep=1</code> #Enter how much you wish backup to rotate</li>
<li><code>GDrive_Folder_ID=""</code> #Enter gDrive folder ID</li>
</ul>

How to use it? Just run like a regular shell script!

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.