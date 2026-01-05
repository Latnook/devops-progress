# Linux Commands Quick Reference

A comprehensive quick-reference guide for 100+ essential Linux commands, organized by category for easy lookup.

## Table of Contents

1. [Filesystem Navigation & Manipulation](#filesystem-navigation--manipulation)
2. [File Content Viewing](#file-content-viewing)
3. [Permissions & Ownership](#permissions--ownership)
4. [Links](#links)
5. [Searching & Filtering](#searching--filtering)
6. [Text Processing](#text-processing)
7. [Redirection & Pipes](#redirection--pipes)
8. [Users & Groups](#users--groups)
9. [Process Management](#process-management)
10. [System Information](#system-information)
11. [Archive & Compression](#archive--compression)
12. [Services & Boot](#services--boot)
13. [Network](#network)
14. [Disk Operations](#disk-operations)
15. [Bash Scripting](#bash-scripting)
16. [Environment Variables](#environment-variables)
17. [Text Substitution & Aliases](#text-substitution--aliases)

---

## Filesystem Navigation & Manipulation

```bash
pwd                         # Print working directory
cd directory                # Change directory
cd ~                        # Change to home
cd -                        # Change to previous directory
ls [options] [path]         # List files
ls -l                       # Long format (permissions, size, date)
ls -a                       # Show hidden files
ls -R                       # Recursive listing
ls -ld directory            # Show directory itself, not contents
ls -lt                      # Sort by modification time
mkdir [-p] dirs             # Create directories
rmdir empty-dirs            # Remove empty directories
rm [-i -f -r] files         # Remove files/directories
  -i                        # Interactive (ask before removing)
  -f                        # Force (no prompts)
  -r                        # Recursive
cp [-r] source dest         # Copy files/directories
mv source dest              # Move/rename
touch files                 # Create empty files or update timestamp
file filename               # Determine file type
```

---

## File Content Viewing

```bash
cat filename                # Display entire file
cat file1 file2             # Concatenate multiple files
less filename               # Paginated view (advanced more)
  Space                     # Next page
  b                         # Previous page
  /pattern                  # Search forward
  ?pattern                  # Search backward
  q                         # Quit
more filename               # Simple paginated view
head [-n number] file       # First N lines (default 10)
tail [-n number] [-f] file  # Last N lines (live with -f)
  -f                        # Follow (live updates)
  -n 20                     # Last 20 lines
```

---

## Permissions & Ownership

```bash
ls -l                       # View permissions
chmod [options] files       # Change permissions
chmod 755 file              # rwxr-xr-x
chmod 644 file              # rw-r--r--
chmod u+x file              # Add execute to owner
chmod go-w file             # Remove write from group and others
chmod a+r file              # Add read to all
chmod u=rwx,g=rx,o=rx file  # Set exact permissions
chmod 4755 file             # rwsr-xr-x (with SUID)
chmod 2755 file             # rwxr-sr-x (with SGID)
chmod 1777 file             # rwxrwxrwt (with sticky bit)
umask value                 # Set default permissions for new files
umask 022                   # Default: 755 dirs, 644 files
chown [user] [files]        # Change owner
chown user:group file       # Change owner and group
chgrp [group] [files]       # Change group
```

**Permission Values:**
- `r` (read) = 4
- `w` (write) = 2
- `x` (execute) = 1

**Common Permission Patterns:**
```bash
755 - rwxr-xr-x             # Standard executable/directory
644 - rw-r--r--             # Standard file
700 - rwx------             # Private to user
777 - rwxrwxrwx             # Full access (rarely recommended)
600 - rw-------             # Private file
```

---

## Links

```bash
ln source link              # Create hard link
ln -s source link           # Create symbolic (soft) link
ls -i                       # Show inode numbers
ls -L                       # Follow symbolic links
readlink link               # Show where symbolic link points
```

**Hard vs Soft Links:**
- **Hard Link**: Same inode, both point to same data
- **Soft Link**: Different inode, points to filename (can break)

---

## Searching & Filtering

```bash
grep [options] pattern file # Search for pattern in file
grep -i pattern file        # Case insensitive
grep -c pattern file        # Count matches
grep -l pattern files       # Show filenames only
grep -v pattern file        # Invert match (non-matching lines)
grep -w pattern file        # Whole word only
grep -r pattern directory   # Recursive search
grep -A 5 pattern file      # 5 lines after match
grep -B 5 pattern file      # 5 lines before match
grep -C 5 pattern file      # 5 lines before and after
egrep pattern file          # Extended grep (supports +, ?, |)

find [path] [options]       # Find files/directories
find . -name "*.txt"        # Find by filename
find . -type f              # Files only
find . -type d              # Directories only
find . -user username       # Files owned by user
find . -size +1M            # Files larger than 1MB
find . -size -100k          # Files smaller than 100KB
find . -mmin -480           # Modified in last 480 minutes
find . -mtime -7            # Modified in last 7 days
find . -perm 755            # Files with exact permissions
find . -exec command {} \;  # Execute command on results
find . -exec rm {} \;       # Delete found files
find . -empty               # Empty files/directories

locate filename             # Quick search using database
updatedb                    # Update locate database
```

---

## Text Processing

```bash
cut -c columns file         # Extract columns by character
cut -c1-5 file              # Characters 1-5
cut -d: -f fields file      # Extract fields by delimiter
cut -d: -f1,3 /etc/passwd   # Fields 1 and 3

sort [options] file         # Sort lines
sort -n                     # Numeric sort
sort -r                     # Reverse sort
sort -k field               # Sort by field number
sort -u                     # Unique (remove duplicates)

uniq [options] file         # Remove duplicate adjacent lines
uniq -c                     # Count occurrences
uniq -d                     # Show only duplicates
uniq -u                     # Show only unique lines

sed 's/old/new/' file       # Substitute first on each line
sed 's/old/new/g' file      # Substitute all on each line
sed -i 's/old/new/g' file   # In-place edit
sed -n 's/old/new/p' file   # Print only changed lines
sed '/pattern/d' file       # Delete lines matching pattern

awk options program file    # Text processing language
awk -F: '{print $1}' file   # Specify field separator, extract field
awk '{print $1,$3}' file    # Print fields 1 and 3
awk '/pattern/ {print}' file # Print matching lines
awk 'BEGIN{} {} END{}' file # Begin, process, end blocks

wc [options] file           # Count words, lines, characters
wc -l                       # Count lines
wc -w                       # Count words
wc -c                       # Count bytes
wc -m                       # Count characters

tr 'set1' 'set2'            # Translate characters
tr 'a-z' 'A-Z'              # Convert lowercase to uppercase
tr -d 'chars'               # Delete characters
tr -s ' '                   # Squeeze repeated spaces
```

---

## Redirection & Pipes

```bash
command > file              # Stdout to file (overwrite)
command >> file             # Stdout to file (append)
command 2> file             # Stderr to file
command 2>&1                # Stderr to stdout
command &> file             # Both stdout and stderr to file
command &>> file            # Both append
command < file              # Stdin from file
command1 | command2         # Pipe stdout to stdin
command | tee file          # Save and display output
set -o noclobber            # Prevent overwriting files with >
set +o noclobber            # Allow overwriting
```

**File Descriptors:**
- `0` - Standard Input (stdin)
- `1` - Standard Output (stdout)
- `2` - Standard Error (stderr)

---

## Users & Groups

```bash
whoami                      # Current user
id                          # User and group info
id username                 # Info for specific user
groups                      # List current user's groups
groups username             # List user's groups
su username                 # Switch user
su -                        # Switch to root with environment
sudo command                # Execute command as root
passwd                      # Change your password
passwd username             # Change user's password (as root)
useradd username            # Create user
userdel username            # Delete user
usermod -aG group username  # Add user to group
```

---

## Process Management

```bash
ps                          # List your processes
ps -e                       # All processes
ps -ef                      # Full format
ps -l                       # Long format with priority
ps -aux                     # Detailed format (BSD style)
ps -u username              # Processes for user

kill pid                    # Send SIGTERM (graceful)
kill -9 pid                 # Send SIGKILL (force)
kill -l                     # List all signals
killall name                # Kill all by process name
pkill pattern               # Kill by pattern
pkill -u username           # Kill all user's processes

top                         # Interactive process monitor
  k                         # Kill process
  r                         # Renice process
  q                         # Quit
htop                        # Enhanced process monitor

jobs                        # List background jobs
bg                          # Resume background job
fg                          # Bring to foreground
bg %1                       # Resume job 1
fg %1                       # Foreground job 1

command &                   # Run in background
CTRL+Z                      # Suspend foreground process
CTRL+C                      # Kill foreground process

nice -n value command       # Start with priority (-20 to 19)
nice -n 10 command          # Lower priority
renice -n value pid         # Change priority of running process
```

**Process Priority:**
- `-20` - Highest priority
- `0` - Default priority
- `19` - Lowest priority

---

## System Information

```bash
uname -a                    # All system information
uname -r                    # Kernel version
uname -m                    # Machine architecture
hostname                    # System hostname
uptime                      # System uptime and load
whoami                      # Current user

df                          # Disk usage
df -h                       # Human-readable format
df -T                       # Show filesystem type

du directory                # Directory space usage
du -h                       # Human-readable format
du -sh directory            # Total only, human-readable
du -h --max-depth=1         # One level deep

free                        # Memory usage
free -h                     # Human-readable format
free -m                     # In megabytes

date                        # Current date/time
date +%Y-%m-%d              # YYYY-MM-DD format
date +%H:%M:%S              # Time only
date -d "last friday"       # Relative date
date -d "127 hours ago"     # Relative date

cal                         # Calendar for current month
cal 2026                    # Year calendar
```

---

## Archive & Compression

```bash
tar -cf archive.tar files   # Create tar archive
tar -xf archive.tar         # Extract tar archive
tar -tf archive.tar         # List contents
tar -czf archive.tar.gz files   # Create compressed (gzip) tar
tar -xzf archive.tar.gz     # Extract compressed tar
tar -cjf archive.tar.bz2 files  # Create bzip2 compressed tar
tar -xjf archive.tar.bz2    # Extract bzip2 tar

gzip file                   # Compress with gzip
gunzip file.gz              # Decompress gzip
gzip -k file                # Keep original file

bzip2 file                  # Compress with bzip2
bunzip2 file.bz2            # Decompress bzip2

zip -r archive.zip files    # Create zip archive
unzip archive.zip           # Extract zip archive
unzip -l archive.zip        # List contents
```

**Tar Options:**
- `c` - Create
- `x` - Extract
- `t` - List
- `f` - File
- `z` - Gzip
- `j` - Bzip2
- `v` - Verbose

---

## Services & Boot

```bash
systemctl status service    # Check service status
systemctl start service     # Start service
systemctl stop service      # Stop service
systemctl restart service   # Restart service
systemctl reload service    # Reload configuration
systemctl enable service    # Enable at boot
systemctl disable service   # Disable at boot
systemctl is-active service # Check if running
systemctl is-enabled service # Check if enabled at boot
systemctl list-units        # List all units
systemctl list-unit-files   # List all unit files
systemctl isolate target    # Switch target
systemctl isolate multi-user.target     # Text mode
systemctl isolate graphical.target      # GUI mode
```

---

## Network

```bash
ping host                   # Test connectivity
ping -c count host          # Ping N times
ping -i interval host       # Ping interval

ifconfig                    # Network interface config
ifconfig eth0               # Specific interface
ip addr                     # IP address info
ip addr show                # Show all IPs
ip route                    # Show routing table

netstat -tuln               # Network statistics
netstat -a                  # All connections
ss -tuln                    # Socket statistics (faster)
ss -s                       # Summary statistics

ssh user@host               # Secure shell login
ssh -p port user@host       # Specify port
scp file user@host:path     # Secure copy to remote
scp user@host:file local    # Secure copy from remote
sftp user@host              # Secure FTP

curl url                    # Download/test URL
curl -o file url            # Save to file
curl -I url                 # Headers only
wget url                    # Download file
wget -O file url            # Save with custom name
```

---

## Disk Operations

```bash
dd if=source of=dest        # Disk/file copy
dd if=/dev/sda of=/dev/sdb bs=1M    # Clone disk
dd if=/dev/zero of=file bs=1M count=32  # Create 32MB test file

mount device mountpoint     # Mount filesystem
mount /dev/sdb1 /mnt        # Mount device
umount mountpoint           # Unmount filesystem
umount /mnt                 # Unmount

lsblk                       # List block devices
fdisk -l                    # List partitions
```

---

## Bash Scripting

```bash
#!/bin/bash                 # Shebang line (interpreter)

# Variables
variable=value              # Set variable (no spaces around =)
echo $variable              # Reference variable
echo ${variable}            # Reference with braces

# Arguments
$0                          # Script name
$1, $2, $3, ...             # Command line arguments
$@                          # All arguments as separate words
$*                          # All arguments as single word
$#                          # Number of arguments
$?                          # Exit status of last command

# Command Substitution
$(command)                  # Execute command, return output
result=$(ls -l)             # Store command output

# Conditionals
if [ condition ]; then
    commands
elif [ condition ]; then
    commands
else
    commands
fi

# Test Operators
[ -f file ]                 # File exists
[ -d directory ]            # Directory exists
[ -n "string" ]             # String not empty
[ -z "string" ]             # String empty
[ $a -eq $b ]               # Numeric equal
[ $a -ne $b ]               # Numeric not equal
[ $a -lt $b ]               # Less than
[ $a -le $b ]               # Less than or equal
[ $a -gt $b ]               # Greater than
[ $a -ge $b ]               # Greater than or equal
[ "$a" = "$b" ]             # String equal
[ "$a" != "$b" ]            # String not equal

# Loops
for var in list; do
    commands
done

while [ condition ]; do
    commands
done

# User Input
read -p "Enter value: " variable
read variable               # Read from stdin

# Output
echo "text"                 # Output with newline
printf "format" args        # Formatted output
```

---

## Environment Variables

```bash
export VAR=value            # Set environment variable
echo $VAR                   # Reference variable
env                         # List all environment variables
printenv VAR                # Print specific variable

# Common Variables
$HOME                       # Home directory
$PATH                       # Command search path
$SHELL                      # Login shell
$USER                       # Current user
$PWD                        # Current directory
$OLDPWD                     # Previous directory
$PS1                        # Primary prompt
$HISTFILE                   # History file location (~/.bash_history)
$HISTSIZE                   # History size in memory
$HISTFILESIZE               # History file size

# Configuration Files
~/.bashrc                   # Bash configuration
~/.bash_profile             # Login shell configuration
~/.profile                  # Generic shell configuration
source ~/.bashrc            # Reload configuration
. ~/.bashrc                 # Reload configuration (alternative)
```

---

## Text Substitution & Aliases

```bash
# Aliases
alias name='command'        # Create alias
alias ll='ls -lah'          # Example alias
alias                       # List all aliases
unalias name                # Remove alias

# Make Permanent
echo "alias ll='ls -lah'" >> ~/.bashrc
source ~/.bashrc

# Sed Substitution
sed 's/old/new/' file       # Substitute first on each line
sed 's/old/new/g' file      # Substitute all on each line
sed 's/old/new/gi' file     # Case insensitive
sed -n 's/old/new/p' file   # Print only changed lines
sed -i 's/old/new/g' file   # In-place edit
sed -i.bak 's/old/new/g' file  # In-place with backup
```

---

## Keyboard Shortcuts

```bash
CTRL+C                      # Kill foreground process
CTRL+Z                      # Suspend foreground process
CTRL+D                      # Exit shell (EOF)
CTRL+L                      # Clear screen
CTRL+A                      # Move to beginning of line
CTRL+E                      # Move to end of line
CTRL+U                      # Delete from cursor to beginning
CTRL+K                      # Delete from cursor to end
CTRL+R                      # Search command history
CTRL+W                      # Delete word before cursor
TAB                         # Autocomplete
TAB TAB                     # Show all completions
```

---

## Wildcard Patterns

```bash
*                           # Matches zero or more characters
?                           # Matches exactly one character
[abc]                       # Matches any character in set
[a-z]                       # Matches range of characters
[0-9]                       # Matches any digit
[!abc]                      # Matches any character NOT in set
{a,b,c}                     # Brace expansion

# Examples
ls *.txt                    # All .txt files
ls file?.txt                # file1.txt, file2.txt, etc.
ls file[1-3].txt            # file1.txt, file2.txt, file3.txt
ls [A-Z]*                   # Files starting with uppercase
```

---

## Regular Expression Patterns

```bash
^                           # Start of line
$                           # End of line
.                           # Any single character
*                           # Zero or more of previous
+                           # One or more of previous (egrep)
?                           # Zero or one of previous (egrep)
[abc]                       # Any character in set
[^abc]                      # Any character NOT in set
[a-z]                       # Character range
\                           # Escape special character
|                           # OR (egrep)
(pattern)                   # Grouping (egrep)

# Examples
grep '^#' file              # Lines starting with #
grep 'error$' file          # Lines ending with error
grep 'a.c' file             # abc, adc, a*c, etc.
egrep 'ab+c' file           # abc, abbc, abbbc, etc.
egrep '(cat|dog)' file      # Lines with cat or dog
```

---

## Quick Reference Summary

**File Operations**: `ls`, `cd`, `pwd`, `cp`, `mv`, `rm`, `mkdir`, `touch`
**Viewing**: `cat`, `less`, `head`, `tail`
**Permissions**: `chmod`, `chown`, `umask`
**Searching**: `find`, `grep`, `locate`
**Text Processing**: `sed`, `awk`, `cut`, `sort`, `tr`, `wc`
**Process**: `ps`, `kill`, `top`, `nice`
**System**: `df`, `du`, `free`, `uname`, `date`
**Network**: `ping`, `ssh`, `curl`, `wget`
**Archives**: `tar`, `gzip`, `zip`

---

**Last Updated**: 2026-01-05
**Source**: Linux Fundamentals Learning Module
