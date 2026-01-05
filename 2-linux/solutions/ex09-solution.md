# Exercise 9 Solution: Find Command

## Objective
Locate files and execute batch operations with find.

---

## Basic Syntax
```bash
find [path] [options] [actions]
```

---

## Common Options

| Option | Purpose |
|--------|---------|
| `-type f` | Regular files |
| `-type d` | Directories |
| `-name pattern` | Filename matching |
| `-user name` | Files owned by user |
| `-size +1M` | Larger than 1MB |
| `-mmin -480` | Modified in last 480 minutes |
| `-exec cmd {} \;` | Execute command on each |
| `-maxdepth N` | Limit search depth |

---

## Examples

### Count all files in home
```bash
find ~ -type f | wc -l
```

### Count directories owned by user
```bash
find /tmp -user $(whoami) -type d 2>/dev/null | wc -l
```

### Files modified in last 8 hours
```bash
find ~ -mmin -480 | wc -l
```

### Files larger than 1MB with sizes
```bash
find ~ -size +1M -exec du -h {} \;
```

### Find and delete temp files
```bash
find -name "*temp" ! -type d -exec rm -f {} \;
```

### Compress large log files
```bash
dd if=/dev/zero of=~/large.log bs=1M count=32  # Create test file
find ~ -size +20M -name "*.log" -exec gzip {} \;
```

### Complex: Size of dirs with large files
```bash
du -h $(find -type d -user $(whoami) -exec find {} -maxdepth 1 -size +2M \;) 2>/dev/null
```

---

## Key Learning Points

1. **-exec** runs command on each found file
2. **{}** is placeholder for filename
3. **\;** terminates -exec command
4. **! -type d** negates (NOT directories)
5. **2>/dev/null** suppresses error messages

---
