# Exercise 4 Solution: File Permissions

## Objective
Master file permissions, umask, and special permission bits (SUID, SGID, Sticky).

---

## Permission Basics

### Permission Format
```
-rwxr-xr-x
^---^--^--
| |  |  +-- Others (o): r=4, w=2, x=1
| |  +------ Group (g): r=4, w=2, x=1
| +--------- Owner (u): r=4, w=2, x=1
+----------- File type
```

### Common Numeric Permissions
- **755** (rwxr-xr-x): Standard executable
- **644** (rw-r--r--): Standard file
- **700** (rwx------): Private to owner
- **777** (rwxrwxrwx): Full access (avoid!)

---

## Part 1: Basic Permissions

### Add execute for all
```bash
chmod a+x Dir/*
```

### Remove write from group/others
```bash
chmod go-w Dir/*
```

### Set exact permissions (symbolic)
```bash
chmod u=rwx,g=rx,o=rx Folder/*
```

### Set exact permissions (numeric)
```bash
chmod 755 files/*
```

---

## Part 2: Umask

### How Umask Works
- Default file: 666 - umask = final permissions
- Default directory: 777 - umask = final permissions
- Umask 022: Files get 644, Directories get 755

### Commands
```bash
umask          # Check current
umask 022      # Set to 022
mkdir test     # Creates dir with 755
touch file     # Creates file with 644
```

---

## Part 3: Special Permissions

### SUID (Set User ID) - 4000
```bash
chmod u+s file      # Symbolic
chmod 4755 file     # Numeric
```
**Use**: File executes with owner's privileges (e.g., /usr/bin/passwd)

### SGID (Set Group ID) - 2000
```bash
chmod g+s dir       # Symbolic
chmod 2755 dir      # Numeric
```
**Use**: Files created in directory inherit directory's group

### Sticky Bit - 1000
```bash
chmod o+t dir       # Symbolic
chmod 1755 dir      # Numeric
```
**Use**: Only file owner can delete their files (e.g., /tmp)

### Combined
```bash
chmod 7755 file     # All three special bits
```

---

## Key Learning Points

1. **Symbolic vs Numeric**: chmod u+x vs chmod 755
2. **Umask**: Controls default permissions for new files
3. **Special Bits**: SUID (4), SGID (2), Sticky (1)
4. **Security**: Avoid 777, be careful with SUID

---
