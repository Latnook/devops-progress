# Exercise 12 Solution: Bash Scripting

## Objective
Write bash scripts with variables, conditionals, and loops.

---

## Script 1: Print File Size

```bash
#!/bin/bash
# Prints the size of a specified file
size=$(ls -l $1 | awk '{print $5}')
echo "The size of $1 is $size bytes"
```

**Usage**: `./script.sh filename`

---

## Script 2: Change Ownership Recursively

```bash
#!/bin/bash
# Changes owner of directory contents to directory's owner
user=$(ls -ld "$1" | awk '{print $3}')
read -p "Please enter depth: " depth
find "$1" -maxdepth $depth ! -user "$user" -exec chown "$user" {} \;
```

**Usage**: `./script.sh /path/to/dir`

---

## Script 3: Check Process Instances

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
        read -p "$1 is running too many times. Terminate? [y/n]: " ans
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

---

## Script 4: Copy to Home Directories

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

**Usage**: `./script.sh userlist.txt file-to-copy`

---

## Script 5: Rename Gzip Files

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

---

## Key Bash Concepts

### Variables
```bash
VAR=value           # Set variable
$VAR or ${VAR}      # Reference variable
$1, $2, $3          # Positional parameters
$@                  # All parameters
$#                  # Number of parameters
```

### Conditionals
```bash
[ -n "string" ]     # String not empty
[ -z "string" ]     # String empty
[ $a -eq $b ]       # Equal (numeric)
[ $a -ne $b ]       # Not equal
[ $a -lt $b ]       # Less than
[ $a -gt $b ]       # Greater than
[ -f file ]         # File exists
[ -d dir ]          # Directory exists
```

### Loops
```bash
for var in list; do
    commands
done

while [ condition ]; do
    commands
done

cat file | while read line; do
    commands
done
```

---
