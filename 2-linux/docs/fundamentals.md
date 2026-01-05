# Linux Learning Module - Comprehensive Summary

## Source Material
- **Linux Fundamentals**: Complete theoretical foundation and core concepts
- **Exercise Solutions**: 13 comprehensive exercises with hands-on commands

---

## Table of Contents
1. [Core Topics from Fundamentals](#core-topics-from-fundamentals)
2. [Exercises Overview](#exercises-overview)
3. [Detailed Exercise Solutions](#detailed-exercise-solutions)
4. [Command Reference Guide](#command-reference-guide)

---

## Core Topics from Fundamentals

### 1. Introduction & History

**Linux Heritage:**
- **MULTICS** (1967): MULTiplexed Information and Computing Services
- **Unix** (1970s, 1972): Foundation for all modern Unix-like systems
- **Linux Distributions**: Red Hat, CentOS, RHEL, Fedora, SUSE, OpenSUSE, Debian, Kali
- **Available Learning Resource**: https://tinyurl.com/linux-fundamentals

---

### 2. Connecting to Linux - Login Process

**Key Concepts:**
- Authentication and user login mechanisms
- Shadow files for secure password storage
- User credentials and permission system

---

### 3. Using Commands - Basic Structure

**Command Syntax:**
```bash
$ Command [options] [arguments]
```

**Examples:**
```bash
$ ls --help                    # Get help for a command
$ ls -l -a /boot             # Multiple options (separate)
$ ls -la /boot               # Combined options (same result)
$ ls -al /boot               # Option order doesn't matter
```

**Key Principle**: Options can be combined with single hyphen (e.g., `-la`) or separate (`-l -a`)

---

### 4. Help Mechanisms

**Available Help Tools:**
- `man <command>` - Manual page with detailed documentation
- `apropos <keyword>` - Search for commands by keyword
- `command --help` - Quick built-in help

---

### 5. Basic Filesystem Commands

**File Types in Linux:**
```
-    Regular file
d    Directory
l    Symbolic link
p    Pipe (FIFO - First In, First Out)
s    Socket
c    Character device
b    Block device
```

**Reading File Content:**
```bash
cat [file1...]              # Concatenate and display entire file
less [file1...]             # Paginated view (advanced more tool)
more [file1...]             # Simple paginated view
head [-number] [file1...]   # Display first N lines
tail [-f -number] [file1...]  # Display last N lines (live with -f)
```

**Directory Operations:**
```bash
mkdir [-p] [newdirs...]     # Create directories (-p for parent dirs)
rmdir [empty-dirs...]       # Remove empty directories
```

**File Content Example:**
```bash
$ ls file.txt
=> file.txt

$ cat file.txt
=> date
   echo "Hi"
   Happy Birthday

$ bash file.txt
=> 20112025
   Hi
   bash: Happy: command not found...
```

---

### 6. The Linux File Tree (Directory Structure)

**Root Filesystem Hierarchy:**
- `/boot` - Boot files and kernels
- `/etc` - Configuration files
- `/home` - User home directories
- `/tmp` - Temporary files
- `/usr` - User programs and libraries
- `/var` - Variable data
- `/dev` - Device files
- `/proc` - Process information
- `/sys` - System information

---

### 7. Wildcards (Filename Generation - FNG)

**Wildcard Patterns:**
- `*` - Matches zero or more characters
- `?` - Matches exactly one character
- `[abc]` - Matches any character in bracket set
- `[a-z]` - Matches range of characters
- `[0-9]` - Matches any digit
- `[!abc]` - Matches any character NOT in set

**Examples in Exercise 3:**
```bash
cp Dir/[a-zA-Z]* files           # Copy files starting with letter
ls -ld Folder/*[0-9]             # List directories ending with digit
ls -ld Dir/*_*                   # List files containing underscore
ls -ld Dir/*.?*                  # List files with extension
```

---

### 8. File Permissions

**Permission Structure:**
```
-rw-r--r--
^ ^  ^  ^
| |  |  +-- Others (o): read=4, write=2, execute=1
| |  +------ Group (g): read=4, write=2, execute=1
| +--------- Owner (u): read=4, write=2, execute=1
+----------- File type (-, d, l, p, s, etc.)
```

**Basic Permission Commands:**
```bash
chmod 754 file.name             # Numeric format: owner=7, group=5, others=4
chmod u+x file                  # Add execute to owner
chmod go-w file                 # Remove write from group and others
chmod u=rwx,g=rx,o=rx file      # Set exact permissions
```

**Permission Flags:**
- `r` (read) = 4
- `w` (write) = 2
- `x` (execute) = 1

**Common Permissions:**
```bash
755 - rwxr-xr-x  (standard executable)
644 - rw-r--r--  (standard file)
700 - rwx------  (private to user)
777 - rwxrwxrwx  (full access - rarely used)
```

**File Removal Options:**
- `-i` - Interactive (ask before removing)
- `-f` - Force (never ask, never print errors)
- `-r` - Recursive (apply to subdirectories)

---

### 9. Special Permissions

**SUID (Set User ID) - Setuid bit (u+s):**
- Files execute with UID of file's owner (not executor)
- Example: `/usr/bin/passwd` runs as root even when user executes
- Syntax: `chmod u+s file` or `chmod 4755 file`

**SGID (Set Group ID) - Setgid bit (g+s):**
- Files execute with GID of file's group
- Directories: New files created inherit directory's group
- Syntax: `chmod g+s file` or `chmod 2755 file`

**Sticky Bit (o+t):**
- Only owner can delete his own files in directory
- Prevents users from deleting others' files
- Common on `/tmp`
- Syntax: `chmod o+t dir` or `chmod 1755 dir`

**Full Special Permission Example:**
```bash
chmod 4755 file      # SUID + rwxr-xr-x
chmod 2755 file      # SGID + rwxr-xr-x
chmod 1755 dir       # Sticky bit + rwxr-xr-x
chmod 7755 file      # All three + rwxr-xr-x
```

---

### 10. Links

**Hard Links:**
```bash
ln /source/file /dest/link
```
- Creates direct inode reference (same file)
- Multiple names pointing to same data
- `ls -li` shows same inode number
- **Not allowed for directories**
- Share same content - changes in one affect all

**Soft (Symbolic) Links:**
```bash
ln -s /source/file /dest/link
```
- Creates shortcut/pointer to original file
- Can point across filesystems
- Can link to directories
- Shows `->` in `ls -l` output
- Breaks if original is deleted

**Key Difference Example:**
```bash
$ ln original pseudo-original     # Hard link
$ ln -s original link2original    # Soft link
$ ls -li
4521 -rw-r--r-- 2 user group    original
4521 -rw-r--r-- 2 user group    pseudo-original  (same inode)
4522 lrwxrwxrwx 1 user group    link2original -> original
```

**Link Behavior:**
- Hard link: If original deleted, hard link still contains data (same inode)
- Soft link: If original deleted, soft link broken (points to nothing)

---

### 11. Input/Output Redirection

**Output Redirection:**
```bash
>      # Redirect stdout (overwrite file)
>>     # Append stdout (append to file)
2>     # Redirect stderr
2>>    # Append stderr
&>     # Redirect both stdout and stderr
```

**Input Redirection:**
```bash
<      # Read input from file
```

**Examples:**
```bash
ls -l ~/Dir Nothing > output.only           # Save output only
ls -l ~/Dir Nothing 2> errors.only          # Save errors only
ls -l ~/Dir Nothing &> err-n-out.both       # Save both
cat output.only errors.only > err-n-out.both  # Combine multiple
rm -i * < file.answers                      # Use answers file for interactive
```

**Clobbering Prevention:**
```bash
set -o noclobber    # Prevent accidental file overwrite
echo Oops > file    # Error: cannot overwrite existing file
echo Oops >> file   # OK: append works
echo Oops >| file   # Force overwrite with >|
set +o noclobber    # Re-enable overwriting
```

---

### 12. Pipes & Filters

**Pipe Operator:**
```bash
CMD1 | CMD2 | CMD3
```
- Connects stdout of CMD1 to stdin of CMD2
- Processes commands sequentially, passing data

**Common Filter Commands:**
- `grep` - Filter by pattern
- `awk` - Text processing and field extraction
- `sed` - Stream editor
- `cut` - Extract columns
- `sort` - Sort lines
- `wc` - Count words/lines
- `head` - First N lines
- `tail` - Last N lines
- `tr` - Translate/transform characters

**Nested Commands:**
```bash
CMD1 $(CMD2...$(CMD3...)...)   # Command substitution
```

---

### 13. Regular Expressions (Regex)

**Regex Metacharacters:**
- `.` (period) - Matches any single character (except newline)
- `^` - Anchor to start of line
- `$` - Anchor to end of line
- `*` - Zero or more of preceding character
- `+` - One or more of preceding character (egrep only)
- `?` - Zero or one of preceding character
- `[abc]` - Character class (any of a, b, or c)
- `[a-z]` - Range (any character from a to z)
- `[^abc]` - Negated class (anything except a, b, c)
- `(a|b)` - Alternation (a or b) (egrep only)
- `\` - Escape metacharacter (required in grep, not in egrep)

**Examples:**
```bash
^[0-9]$                    # Lines containing only digits
^$                         # Empty lines
^[a-zA-Z]*[0-9]$          # Letters followed by single digit
^vi(able)*$                # 'vi' optionally followed by 'able'
```

---

### 14. Vi/Vim Editor

**What is Vi:**
- Visual editor (vs `sed` = stream editor)
- `vim` = Vi Improved
- Learning resource: `vimtutor`

---

### 15. Software Management

**RPM Package Queries:**
```bash
rpm -qf /path/to/file       # Find package containing file
rpm -qc package-name        # List config files of package
rpm -qc $(rpm -qf /etc/ssh/sshd_config)  # Config files example
```

---

### 16. Service and Process Management

**Systemd Architecture:**
- Boot process driven by `systemd` (RHEL >7, Ubuntu >15.6, SUSE >12)
- Services organized by targets (multi-user, graphical, etc.)
- Managed via `systemctl` command

**Systemctl Commands:**
```bash
systemctl sub-command unit
systemctl status service         # Check service status
systemctl start service          # Start service
systemctl stop service           # Stop service
systemctl enable service         # Enable at boot
systemctl disable service        # Disable at boot
systemctl is-active service      # Check if running
systemctl isolate graphical.target    # Switch to graphical mode
systemctl isolate multi-user.target   # Switch to multi-user mode
```

**Process Management:**
```bash
ps -e                       # List all processes
ps -l                       # List with priority info
kill <pid>                  # Terminate process
killall <process-name>      # Kill all instances
pkill <process-name>        # Kill by pattern
```

**Process Control:**
```bash
sleep 1000 &                # Start in background
CTRL+Z                      # Suspend foreground process
bg                          # Resume suspended in background
fg                          # Bring to foreground
nice -n <priority>          # Start with priority level
renice -n <priority> <pid>  # Change priority of running process
```

**Priority Levels:**
- Negative (high): -20 to -1 (higher priority)
- Default: 0
- Positive (low): 1 to 19 (lower priority)

---

### 17. Bash Scripts

**Script Structure:**
```bash
#!/bin/bash          # Shebang line (must be first)
# Comments with #
command1
command2
```

**Variables and Parameters:**
```bash
$1, $2, $3...       # Command line arguments
$@                  # All arguments
$#                  # Number of arguments
size=$(ls -l $1 | awk '{print $5}')  # Command substitution
```

**Conditional Statements:**
```bash
if [ condition ]
then
    commands
elif [ condition ]
then
    commands
else
    commands
fi
```

**Comparison Operators:**
- `-n "string"` - String is not empty
- `-z "string"` - String is empty
- `-eq` - Equal (numbers)
- `-ne` - Not equal (numbers)
- `-le` - Less than or equal (numbers)
- `-ge` - Greater than or equal (numbers)
- `-lt` - Less than (numbers)
- `-gt` - Greater than (numbers)
- `=` - String equality
- `!=` - String inequality

**Loops:**
```bash
for var in list-of-values
do
    commands-to-execute
done

for var
do
    # Process $var
done
```

**User Input:**
```bash
read -p "Prompt: " variable
```

---

### 18. Sed & Awk

**Sed (Stream Editor):**
- Line-based text processing
- Pattern matching and replacement

**Awk:**
- Field-based text processing
- Field separator: `-F` option
- Field reference: `$1`, `$2`, `$NF` (last field)
- Special blocks: `BEGIN`, `END`
- Variables: `sum`, `count`, etc.

**Examples:**
```bash
awk -F: '{print $1,$3}'     # Print fields 1 and 3 (colon-delimited)
awk '{print $1, $NF}'       # Print first and last field (space-delimited)
awk 'BEGIN{"whoami" | getline user}'  # Execute command for variable
awk '/^[^d]/ {sum++; size+=$5} END {print sum, size}'  # Count and sum
```

---

## Exercises Overview

### Exercise Summary Table

| # | Topic | Key Focus | Commands Taught |
|---|-------|-----------|-----------------|
| 1 | Command Structure | Options, arguments, command syntax | `ls`, `date` |
| 2 | Basic Filesystem | Directory creation and removal | `mkdir`, `rmdir` |
| 3 | Wildcards | Pattern matching and filename generation | `cp`, `ls` with wildcards |
| 4 | Permissions | File permissions, SUID, SGID, sticky bit | `chmod`, `umask`, `touch` |
| 5 | Links | Hard and soft links, link management | `ln`, `ln -s` |
| 6 | I/O Redirection | Output, error, and input redirection | `>`, `>>`, `2>`, `&>`, `<` |
| 7 | Pipes & Filters | Text processing with pipes | `grep`, `awk`, `cut`, `sort`, `tr`, `wc` |
| 8 | Regular Expressions | Pattern matching | `grep`, `egrep` |
| 9 | Find | File searching and batch operations | `find`, `exec` |
| 10 | Advanced Bash | Aliases, history, environment variables | `alias`, `PS1`, `HISTSIZE` |
| 11 | Services & Processes | Service management and process control | `systemctl`, `nice`, `renice`, `ps`, `kill` |
| 12 | Bash Scripts | Scripting with parameters, conditions, loops | Variables, conditionals, loops, `read` |
| 13 | Sed & Awk | Advanced text processing | `awk`, `sed` |

---

## Detailed Exercise Solutions

### Exercise 1: Command Structure

**Objective**: Master command syntax, options, and arguments

**Commands:**
```bash
cd                              # Change to home directory
ls /boot                        # List boot directory contents
ls -al /boot                    # Long format, all files (including hidden)
ls -alt /boot                   # Long format, all files, sorted by time
ls -R /boot                     # Recursive listing
date +%H_%M_%S                  # Show time as HH_MM_SS
date +%d%m%Y                    # Show date as DDMMYYYY
date -d "last friday" +%d%m%Y   # Date of last Friday
date -d "127 hours ago"         # Date 127 hours ago
date -d "2 days ago" +%s        # Unix timestamp from 2 days ago
```

**Key Learnings:**
- Multiple options can be combined: `-al` = `-a -l`
- Options and arguments follow command: `command [options] [arguments]`
- Format strings with `date`: `+%H` (hours), `%M` (minutes), `%d` (day), etc.
- Relative dates: `-d "last friday"`, `-d "2 days ago"`, etc.

---

### Exercise 2: Basic Filesystem Commands

**Objective**: Create, manage, and view directories

**Commands:**
```bash
mkdir files                     # Create 'files' directory
cp Dir/[a-zA-Z]* files         # Copy files starting with letter
ls -ld Folder/*[0-9]           # List files ending with digit
```

**Key Learnings:**
- `mkdir` creates single or multiple directories
- Wildcards: `[a-zA-Z]*` matches letter followed by anything
- `ls -d` shows directory itself, not contents
- Pattern matching for file selection

---

### Exercise 3: Wildcards (FNG - Filename Generation)

**Objective**: Use wildcards for flexible file pattern matching

**Commands:**
```bash
mkdir files
cp Dir/[a-zA-Z]* files                    # Files starting with letter
ls -ld Folder/*[0-9]                      # Files ending with digit
ls -ld Dir/*_*                            # Files containing underscore
ls -ld Dir/*.?*                           # Files with extension (any length)
ls -ld [FD]*/[a-zA-Z]*[0-9]              # Subdirs F or D, file starts letter ends digit
ls -ld ~/*/[Mm]y*                         # Home subdirs, files starting with My or my
```

**Wildcard Patterns Taught:**
- `[a-zA-Z]*` - Letters followed by anything
- `*[0-9]` - Anything ending with digit
- `*_*` - Anything containing underscore
- `*.?*` - Files with any single-char extension
- `[FD]*` - Names starting with F or D
- `[Mm]` - Case-insensitive single character

---

### Exercise 4: File Permissions

**Objective**: Understand and manage file permissions, special bits

**Commands:**

**Part 1: Basic Permissions**
```bash
ls -l Dir                       # View current permissions
chmod a+x Dir/*                 # Add execute to all
chmod go-w Dir/*                # Remove write from group and others
chmod u=rwx,g=rx,o=rx Folder/* # Set explicit permissions
chmod 755 files/*               # Numeric: rwxr-xr-x
```

**Part 2: Umask and New Files**
```bash
cd ~/scripts
touch script{1,2}.sh            # Create script1.sh and script2.sh
umask 22                        # Set default file creation mask
mkdir python; ls -ld python     # Create and view directory
touch python/script.py; ls -l python/script.py  # Create file and view
```

**Part 3: Special Permissions**
```bash
chmod a+w,g+s python            # Add write to all, SGID to group
su -c "touch python/root.file" ; rm python/root.file  # SGID test
su -c "touch /tmp/nobody_can_delete"  # Sticky bit test
ls -ld /tmp                     # Verify sticky bit on /tmp
rm /tmp/nobody_can_delete       # Should fail due to sticky bit
chmod 4755 ~/scripts/python/script.py  # SUID: rwxr-xr-x
```

**Key Permission Learnings:**
- `chmod a+x` adds execute to user, group, others
- `chmod go-w` removes write from group and others
- `chmod 755` = rwxr-xr-x (standard executable)
- `chmod 644` = rw-r--r-- (standard file)
- Special bits: SUID (4xxx), SGID (2xxx), Sticky (1xxx)

**Umask Concept:**
- `umask 22` means "subtract 022 from default permissions"
- Default file: 666 - 022 = 644 (rw-r--r--)
- Default directory: 777 - 022 = 755 (rwxr-xr-x)

---

### Exercise 5: Links

**Objective**: Understand hard and soft links, create and manage them

**Commands:**

**Setup:**
```bash
mkdir links; cd links
echo "This is the original file" > original  # Create original file
ln original pseudo-original; ls -li          # Hard link (same inode)
cd ~
ln -s original links/link2original           # Soft link (different inode)
cd links
cat *                                        # View all files
```

**Hard Link Behavior:**
```bash
rm original                     # Delete original
cat *                          # Hard link still works (same inode)
ln pseudo-original original    # Restore from hard link
cat link2original              # Now soft link works again
```

**Permissions and Deletion:**
```bash
chmod 700 link2original        # Change permissions of soft link
ls -l                          # View properties
rm original                    # Delete again
echo "This is not the original file" > original  # Create different content
ls -li                         # Compare hard link vs soft link
chmod 640 link2original; ls -l # Hard link affected, soft link metadata only
```

**Key Learnings:**
- Hard links: same inode, share content (not allowed for directories)
- Soft links: different inode, point to filename (can cross filesystems)
- `ls -i` shows inode numbers
- When original deleted: hard link survives, soft link breaks
- Permissions: changing hard link affects original (same inode)
- Directory hard links not allowed

---

### Exercise 6: Input/Output Redirection

**Objective**: Master output, error, and input redirection

**Commands:**

**Part 1: Output Redirection**
```bash
mkdir iored; cd iored
ls -l ~/Dir Nothing > output.only       # Stdout only
ls -l ~/Dir Nothing 2> errors.only      # Stderr only
ls -l ~/Dir Nothing &> err-n-out.both   # Both stdout and stderr
echo Oops > err-n-out.both              # Overwrite (clobber)
cat output.only errors.only > err-n-out.both  # Combine files
```

**Part 2: Clobbering Prevention**
```bash
set -o noclobber                        # Prevent accidental overwrite
echo Oops > err-n-out.both              # Error: cannot overwrite
echo "Well done" >> err-n-out.both      # Append still works
echo Oops >| err-n-out.both             # Force overwrite with >|
set +o noclobber                        # Re-enable overwriting
cat output.only errors.only > err-n-out.both  # Now works
```

**Part 3: Input Redirection**
```bash
touch {a..d}.temp                       # Create 4 temporary files
echo -e "y\nn\ny\nn\ny" > file.answers  # Create answer file
rm -i * < file.answers                  # Use answers for interactive rm
```

**Redirection Operators:**
- `>` - Redirect stdout (overwrite)
- `>>` - Append stdout
- `2>` - Redirect stderr (overwrite)
- `2>>` - Append stderr
- `&>` - Redirect both stdout and stderr
- `<` - Read stdin from file
- `>|` - Force overwrite when noclobber is set

---

### Exercise 7: Pipes & Filters

**Objective**: Chain commands with pipes, process text with filters

**Commands:**

**Text Extraction and Processing:**
```bash
head -3 /etc/passwd | awk -F: '{print $1,$3}'
head -2 /etc/passwd | tail -1 | awk -F: '{print $1,$3}'
grep $(whoami) /etc/passwd
```

**Combining ls with filters:**
```bash
ls -l | awk '{print $1, $NF}'           # Permissions and filename
ls -lR | cut -c1 | grep d -c            # Count directories
ls -l | cut -c1,9 | grep -ce "-w"       # Count write permissions
```

**Complex Filtering:**
```bash
ls -l | awk '{print $6$7}' | grep -c $(date | awk '{print $2$3}')
df | grep -w / | awk '{print $(NF-1)}' | tr -d %  # Disk usage
ls -l | tail -n +2 | sort -gk5 -r | tail -3  # 3 largest files
tail -n +11 /etc/passwd | head | sort -gk3 -t:  # Sort by UID
ls -l *[0-9] | cut -c2,5,8 | grep rrr -c  # Count write perms
```

**Key Commands:**
- `awk -F: '{print $1,$3}'` - Print fields 1,3 with colon delimiter
- `cut -c1 file` - Extract character 1
- `sort -gk5 -r` - Sort by field 5 numerically, reverse
- `tail -n +2` - Skip first line
- `tr -d %` - Delete percent signs
- `wc -l` - Count lines
- `grep -c` - Count matches

---

### Exercise 8: Regular Expressions

**Objective**: Use regex patterns for advanced filtering

**Commands:**

**Basic Pattern Matching:**
```bash
ls -lR | grep ^d                   # Lines starting with 'd' (directories)
ls -lR | grep c$                   # Lines ending with 'c'
ls -lR | grep "^-.*f"              # Files (start with -) containing f
ls -lR | grep "^d.*[0-9]$"         # Directories ending with digit
```

**Complex Permissions Patterns:**
```bash
# Match full permission string (no special perms, all r/w/x/-)
ls -lR | grep "^[-dlspbc][^-ST]\{9\}"
# OR using egrep with alternation
ls -lR | egrep "^[-dlspbc](rw[xst]){3}"
```

**Counting and Matching:**
```bash
ls -lR | grep ^$ -c                    # Count empty lines
ls -lR | grep . -c                     # Count non-empty lines (or: grep -v ^$ -c)
ls -lR | egrep "^.{1,10}$"            # Lines 1-10 chars long
ls -lR | egrep "^[^.]{7}$"            # Exactly 7 chars, no dots
grep "^t.*[0-9]$" *[0-9]              # In digit-named files, lines starting with t, ending with digit
```

**Regex Metacharacters:**
- `^` - Start of line
- `$` - End of line
- `.` - Any character
- `*` - Zero or more
- `[0-9]` - Character class
- `[^abc]` - Negated class
- `\{9\}` - Exactly 9 occurrences
- `(abc)` - Grouping in egrep
- `|` - OR in egrep

---

### Exercise 9: Find

**Objective**: Locate files and execute batch operations

**Commands:**

**File Finding:**
```bash
find ~ -type f | wc -l                  # Count all files in home
find /tmp -user $(whoami) -type d 2>/dev/null | wc -l  # Count dirs owned by user
find ~ -mmin -480 | wc -l               # Modified in last 8 hours
find ~ -size +1M -exec du -h {} \;      # Show size of files over 1MB
```

**Finding by Name:**
```bash
find -name "*.c"                        # Find C source files
find -name "*temp" ! -type d -exec rm -f {} \;  # Delete temp files, not dirs
```

**Complex Operations:**
```bash
dd if=/dev/zero of=~/large.log bs=1M count=32  # Create 32MB test file
find ~ -size +20M -name "*.log" -exec gzip {} \;  # Compress large logs
```

**Advanced Batch Processing:**
```bash
# Total size of all non-dir files owned by user
grep -l total $(find -type d -user $(whoami) -exec find {} -maxdepth 1 -type f \;) 2>/dev/null

# Size of all dirs owned by user with files >2MB
du -h $(find -type d -user $(whoami) -exec find {} -maxdepth 1 -size +2M \;) 2>/dev/null
```

**Find Options:**
- `-type f` - Regular files
- `-type d` - Directories
- `-user username` - Files owned by user
- `-mmin -480` - Modified in last 480 minutes
- `-size +1M` - Larger than 1 megabyte
- `-name pattern` - Filename matching
- `! -type d` - NOT directories (negation)
- `-exec command {} \;` - Execute command on each result
- `-maxdepth 1` - Only this level, not subdirs

---

### Exercise 10: Advanced Bash Mechanisms

**Objective**: Use aliases, history, environment variables

**Commands:**

**Aliases:**
```bash
alias run='chmod a+x'                   # Make executable
alias links='ls -lR | grep ^l'          # Find symbolic links
alias large='find -size +2M -exec du -h {} \;'  # Find large files
mkdir ~/.recycle && alias del='mv -t ~/.recycle'  # Safe delete
alias disk='df | grep /$ | awk "{print \$(NF-1)}" | tr -d %'  # Disk usage %
alias >> ~/.bashrc                      # Save aliases to config
```

**History Management:**
```bash
echo $HISTFILE                          # Show history file location
tail !$                                 # Show last command's output
HISTSIZE=2000                           # Set history size for session
echo "export HISTSIZE=2000" >> ~/.bash_profile  # Make permanent
```

**Prompt Customization:**
```bash
PS1='[$(whoami)@$(pwd)]$ '              # Custom prompt showing user and dir
```

**Key Features:**
- Aliases: shortcuts for complex commands
- `~/.bashrc` - Shell configuration file
- `~/.bash_profile` - Login shell configuration
- `$HISTFILE` - Location of command history
- `HISTSIZE` - Number of commands to keep
- `PS1` - Primary prompt string
- `$(command)` - Command substitution in prompt

---

### Exercise 11: Service & Process Management

**Objective**: Manage systemd services and monitor processes

**Commands:**

**Part 1: Service Management**
```bash
# Check where crond runs by default
cat /usr/lib/systemd/system/crond.service | grep -iA1 install

# Configure crond for graphical target only
sed -i s/multi-user/graphical/ /usr/lib/systemd/system/crond.service

# Verify in systemd directories
ls -l /etc/systemd/system/multi-user.target.wants/*crond*

# Switch between targets
systemctl isolate multi-user.target
systemctl isolate graphical.target

# Check service status and stop if active
systemctl isolate graphical.target
systemctl is-active crond.service && systemctl stop crond.service
```

**Part 2: Process Management**
```bash
ls -lR /                               # Start command (CTRL+Z to suspend)
bg                                     # Move to background

# Background processes with specific priorities
sleep 1001 &                           # Standard background
sleep 1002 &                           # Standard background
nice -n 3 sleep 1003 &                 # Start with priority 3

# Change priority of running processes (needs sudo/su)
su -c "renice -n 1 <pid of sleep 1001>"
su -c "renice -n 2 <pid of sleep 1002>"

# View process priority
ps -l

# Kill all sleep processes
pkill sleep                            # (can also use killall)
```

**Systemctl Subcommands:**
- `status` - Check if running
- `start` - Start service
- `stop` - Stop service
- `enable` - Enable at boot
- `disable` - Disable at boot
- `is-active` - Check if running (exit code only)
- `isolate target` - Switch to different target

**Process Commands:**
- `ps -e` - List all processes
- `ps -l` - List with priority information
- `kill <pid>` - Terminate process by ID
- `killall <name>` - Kill all by name
- `pkill <pattern>` - Kill by pattern
- `nice -n <value>` - Start with priority (-20 to 19)
- `renice -n <value> <pid>` - Change priority of running process
- `&` - Start in background
- `CTRL+Z` - Suspend foreground
- `bg` - Resume in background
- `fg` - Bring to foreground

---

### Exercise 12: Bash Scripts

**Objective**: Write bash scripts with parameters, conditionals, and loops

**Commands & Script Examples:**

**Script 1: Parameters - Print File Size**
```bash
#!/bin/bash
# Prints the size of a specified file
size=$(ls -l $1 | awk '{print $5}')
echo "The size of $1 is $size bytes"
```

**Script 2: Parameters - Change Ownership Recursively**
```bash
#!/bin/bash
# Changes owner of dir content to dir's owner up to chosen depth
user=$(ls -ld "$1" | awk '{print $3}')
read -p "Please enter depth: " depth
find "$1" -maxdepth $depth ! -user "$user" -exec chown "$user" {} \;
```

**Script 3: Conditionals - Check Process Instances**
```bash
#!/bin/bash
# Checks the number of instances for a specified process
if [ -n "$1" ]
then
    num=$(ps -e | grep -w "$1" -c)
    if [ $num -eq 0 ]
    then
        echo "$1 isn't running"
    elif [ $num -ge 1 ] && [ $num -le 10 ]
    then
        echo "$1 is running $num times"
    else
        read -p "$1 is running too many times. Terminate? [y/n]:" ans
        if [ "$ans" = "y" ]
        then
            killall "$1"
        else
            echo "Over 10 instances of $1 are running, please check."
        fi
    fi
else
    echo "No process mentioned"
fi
```

**Script 4: Loops - Copy to Home Dirs**
```bash
#!/bin/bash
# Copies file to home dirs if user exists, logs if doesn't
cat "$1" | while read user
do
    if awk -F: '{print $1}' /etc/passwd | grep $user &>/dev/null
    then
        cp "$2" $(grep ^"$user" /etc/passwd | awk -F: '{print $6}')
    else
        echo "$(date):$user doesn't exist" >> absent_users.log
    fi
done
```

**Script 5: Loops - Rename Gzip Files**
```bash
#!/bin/bash
# Rename gzip files to have .gz extension
for file in "$1"/*
do
    if [ -f "$file" ] && file $file | grep gzip &>/dev/null
    then
        echo "$file" | grep ".gz" &>/dev/null || mv -T "$file" "${file}.gz"
    fi
done
```

**Bash Features Taught:**
- `#!/bin/bash` - Shebang line (interpreter)
- `$1, $2` - Command line arguments
- `$(command)` - Command substitution
- `[ condition ]` - Test/conditional
- `if/elif/else/fi` - Conditional statement
- `for var in list; do..done` - Loop construct
- `read -p "prompt" var` - User input
- `-n "string"` - Test if string not empty
- `-eq, -le, -ge` - Numeric comparisons
- `=` - String comparison
- `&>/dev/null` - Redirect both outputs to null
- `awk '{print $3}'` - Extract field 3
- `grep -c` - Count matches

---

### Exercise 13: Sed & Awk

**Objective**: Advanced text processing with sed and awk

**Commands:**

**Awk: Counting and Summing**
```bash
# Find all .gz files and sum their sizes
find / -name "*.gz" -exec ls -l {} \; 2>/dev/null | awk '{sum++;size+=$5}END{print sum,"Files,",size,"Bytes total"}'

# Count user-owned files and sum sizes
ls -lR 2>/dev/null | awk 'BEGIN{"whoami" | getline user}/^[^d]/{if($3==user){print $0;sum++;size+=$5}}END{print sum,"Files,",size,"Bytes total"}'
```

**Sed: Pattern Extraction**
```bash
# Extract text between two patterns
sed -n /"$(grep -B1 ERROR file | head -1)"/,/"$(grep -A1 END file | tail -1)"/p file
```

**Key Awk Features:**
- `BEGIN {}` - Execute before processing
- `END {}` - Execute after processing
- `$1, $2, $NF` - Field references
- `-F:` - Field separator specification
- `getline` - Read next line
- `{cmd} | getline var` - Execute command and get result
- `/pattern/ {}` - Pattern matching
- `sum++, size+=$5` - Accumulation
- `print` - Output

**Key Sed Features:**
- `-n` - Suppress default printing
- `/pattern1/,/pattern2/p` - Print lines between patterns

---

## Command Reference Guide

### Command Categories

#### Filesystem Navigation & Manipulation
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
mkdir [-p] dirs             # Create directories
rmdir empty-dirs            # Remove empty directories
rm [-i -f -r] files         # Remove files/directories
cp [-r] source dest         # Copy files/directories
mv source dest              # Move/rename
touch files                 # Create empty files or update timestamp
file filename               # Determine file type
```

#### File Content Viewing
```bash
cat filename                # Display entire file
less filename               # Paginated view (advanced more)
more filename               # Simple paginated view
head [-n number] file       # First N lines
tail [-n number] [-f] file  # Last N lines (live with -f)
```

#### Permissions & Ownership
```bash
ls -l                       # View permissions
chmod [options] files       # Change permissions
chmod 755 file              # rwxr-xr-x
chmod u+x file              # Add execute to owner
chmod go-w file             # Remove write from group and others
umask value                 # Set default permissions for new files
chown [user] [files]        # Change owner
chgrp [group] [files]       # Change group
```

#### Links
```bash
ln source link              # Hard link
ln -s source link           # Symbolic (soft) link
ls -i                       # Show inode numbers
ls -L                       # Follow symbolic links
```

#### Searching & Filtering
```bash
grep [options] pattern file # Search for pattern
egrep pattern file          # Extended grep (supports +, ?, |)
grep -c pattern file        # Count matches
grep -l pattern files       # Show filenames only
grep -w pattern file        # Whole word only
find [path] [options]       # Find files/directories
find -type f                # Files only
find -type d                # Directories only
find -name pattern          # Filename matching
find -user username         # Files owned by user
find -size +1M              # Files larger than 1MB
find -mmin -480             # Modified in last 480 minutes
find -exec command {} \;    # Execute command on results
```

#### Text Processing
```bash
cut -c columns file         # Extract columns by character
cut -d: -f fields file      # Extract fields by delimiter
sort [options] file         # Sort lines
sort -n                     # Numeric sort
sort -r                     # Reverse sort
sort -k field               # Sort by field
uniq [options] file         # Remove duplicate lines
sed command file            # Stream editor
awk options program file    # Text processing
awk -F: '{print $1}'       # Specify field separator and extract fields
wc [options] file           # Count words, lines, characters
wc -l                       # Count lines
tr 'a-z' 'A-Z' file        # Translate characters
```

#### Redirection & Pipes
```bash
command > file              # Stdout to file (overwrite)
command >> file             # Stdout to file (append)
command 2> file             # Stderr to file
command &> file             # Both stdout and stderr to file
command < file              # Stdin from file
command1 | command2         # Pipe stdout to stdin
```

#### Users & Groups
```bash
whoami                      # Current user
id                          # User and group info
groups                      # List groups
su username                 # Switch user
su -                        # Switch to root
sudo command                # Execute as root
passwd                      # Change password
```

#### Process Management
```bash
ps                          # List processes
ps -e                       # All processes
ps -l                       # Long format with priority
ps -aux                     # Detailed format
kill pid                    # Send SIGTERM
kill -9 pid                 # Send SIGKILL (force)
killall name                # Kill by process name
pkill pattern               # Kill by pattern
top                         # Interactive process monitor
htop                        # Enhanced process monitor
jobs                        # List background jobs
bg                          # Resume background job
fg                          # Bring to foreground
nice -n value command       # Start with priority
renice -n value pid         # Change priority of running process
```

#### System Information
```bash
uname -a                    # System information
uname -r                    # Kernel version
hostname                    # System hostname
uptime                      # System uptime
df                          # Disk usage
df -h                       # Human-readable format
du directory                # Directory space usage
du -h                       # Human-readable format
du -sh                      # Total only, human-readable
free                        # Memory usage
free -h                     # Human-readable format
whoami                      # Current user
date                        # Current date/time
date +format                # Custom date format
date +%Y-%m-%d             # YYYY-MM-DD format
```

#### Archive & Compression
```bash
tar -cf archive.tar files   # Create tar archive
tar -xf archive.tar         # Extract tar archive
tar -czf archive.tar.gz files  # Create compressed tar
tar -xzf archive.tar.gz     # Extract compressed tar
gzip file                   # Compress with gzip
gunzip file.gz              # Decompress gzip
zip -r archive.zip files    # Create zip archive
unzip archive.zip           # Extract zip archive
```

#### Services & Boot
```bash
systemctl status service    # Check service status
systemctl start service     # Start service
systemctl stop service      # Stop service
systemctl restart service   # Restart service
systemctl enable service    # Enable at boot
systemctl disable service   # Disable at boot
systemctl is-active service # Check if running
systemctl list-units        # List all units
systemctl isolate target    # Switch target (graphical, multi-user, etc.)
```

#### Network
```bash
ping host                   # Test connectivity
ping -c count host          # Ping N times
ifconfig                    # Network interface config
ip addr                     # IP address info
netstat -tuln               # Network statistics
ss -tuln                    # Socket statistics
ssh user@host               # Secure shell login
scp file user@host:path     # Secure copy
sftp user@host              # Secure FTP
curl url                    # Download/test URL
wget url                    # Download file
```

#### Disk Operations
```bash
dd if=source of=dest bs=1M  # Disk/file copy with block size
dd if=/dev/zero of=file bs=1M count=32  # Create 32MB test file
mount device path           # Mount filesystem
umount path                 # Unmount filesystem
mkdir -p path               # Create path recursively
```

#### Bash Scripting
```bash
#!/bin/bash                 # Shebang line
$1, $2, $3                  # Command line arguments
$@                          # All arguments
$#                          # Number of arguments
$(command)                  # Command substitution
${variable}                 # Variable reference
"string"                    # Quoted string (allows expansion)
'string'                    # Single quoted string (no expansion)
[ condition ]               # Test/conditional
if/elif/else/fi             # Conditional statement
for var in list; do..done   # Loop
while condition; do..done   # Loop
read -p "prompt" var        # User input
echo "text"                 # Output
printf "format" args        # Formatted output
```

#### Environment Variables
```bash
export VAR=value            # Set environment variable
echo $VAR                   # Reference variable
$HOME                       # Home directory
$PATH                       # Command search path
$SHELL                      # Login shell
$PS1                        # Primary prompt
$HISTFILE                   # History file location
$HISTSIZE                   # History size
source ~/.bashrc            # Load configuration
```

#### Text Substitution & Aliases
```bash
alias name='command'        # Create alias
alias                       # List all aliases
unalias name                # Remove alias
alias >> ~/.bashrc          # Save alias to config
sed 's/old/new/' file       # Substitute first on each line
sed 's/old/new/g' file      # Substitute all on each line
sed -n 's/old/new/p' file   # Print only changed lines
```

---

## Summary Statistics

- **Total Topics Covered**: 18 main concepts
- **Total Exercises**: 13 hands-on exercises
- **Total Commands Taught**: 100+ Linux commands
- **Special Permission Types**: 3 (SUID, SGID, Sticky Bit)
- **Regex Metacharacters**: 10+ patterns
- **Wildcard Patterns**: 5+ types

---

## Key Concepts Overview

### File System Hierarchy
```
/ (root)
├── /boot           - Boot files
├── /etc            - Configuration
├── /home           - User home directories
├── /tmp            - Temporary files
├── /usr            - User programs
├── /var            - Variable data
├── /dev            - Device files
├── /proc           - Process info
└── /sys            - System info
```

### Permission Model
- **User (u)**: Owner of file
- **Group (g)**: Group of file
- **Others (o)**: Everyone else
- **All (a)**: User, group, and others

### Special Permissions
- **SUID (4xxx)**: Execute as owner
- **SGID (2xxx)**: Execute as group / inherit group
- **Sticky (1xxx)**: Only owner can delete

### Process States
- Foreground: Running in terminal
- Background: Running without terminal control
- Suspended: Paused by CTRL+Z

### Regular Expression Anchors
- `^` - Start of line
- `$` - End of line
- `.` - Any character
- `*` - Zero or more
- `+` - One or more (egrep)
- `?` - Zero or one (egrep)

---

**Created**: Linux Learning Module for DevOps Project
**Last Updated**: 2026-01-05
**Source**: Linux Fundamentals and Exercise Solutions MHT Files
