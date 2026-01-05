# Exercise 1 Solution: Command Structure

## Objective
Master the fundamentals of Linux command syntax, including options, arguments, and command combinations. Learn to use the `ls` command for directory listings and the `date` command for time/date formatting and calculations.

---

## Part 1: Basic Command Syntax

### Command Structure
```
$ command [options] [arguments]
```

### Key Concepts
- **Command**: The program to execute (e.g., `ls`, `date`)
- **Options**: Modifiers that change command behavior (e.g., `-l`, `-a`)
- **Arguments**: Inputs for the command to operate on (e.g., `/boot`)

### Option Combinations
Options can be combined in multiple ways:
```bash
$ ls -l -a /boot        # Separate options
$ ls -la /boot          # Combined options
$ ls -al /boot          # Order doesn't matter
```

---

## Part 2: The 'ls' Command Solutions

### Task 1: List /boot directory
```bash
$ ls /boot
```

**What it does**: Lists the contents of the `/boot` directory in basic format.

**Output example**: Shows filenames only (e.g., `vmlinuz`, `initramfs`, `grub`)

---

### Task 2: List /boot in long format with all files
```bash
$ ls -al /boot
```
or
```bash
$ ls -la /boot
```

**What it does**:
- `-a`: Shows all files including hidden ones (starting with `.`)
- `-l`: Long format showing permissions, links, owner, group, size, date, name

**Output format**:
```
-rw-r--r-- 1 root root 8388608 Jan 01 12:00 vmlinuz-5.x.x
drwxr-xr-x 3 root root    4096 Jan 01 12:00 grub
```

---

### Task 3: List /boot with all files, long format, sorted by time
```bash
$ ls -alt /boot
```
or
```bash
$ ls -lat /boot
```

**What it does**:
- `-a`: All files (including hidden)
- `-l`: Long format
- `-t`: Sort by modification time (newest first)

**Use case**: Helpful to see which files were recently modified.

---

### Task 4: Recursive listing of /boot
```bash
$ ls -R /boot
```

**What it does**: Lists `/boot` and all its subdirectories recursively.

**Output**: Shows directory tree structure with contents of each subdirectory.

---

## Part 3: The 'date' Command Solutions

### Task 1: Show current time as HH_MM_SS
```bash
$ date +%H_%M_%S
```

**What it does**:
- `+%H`: Hour (00-23)
- `_`: Literal underscore separator
- `+%M`: Minute (00-59)
- `+%S`: Second (00-59)

**Example output**: `14_35_22` (2:35:22 PM)

---

### Task 2: Show current date as DDMMYYYY
```bash
$ date +%d%m%Y
```

**What it does**:
- `+%d`: Day of month (01-31)
- `+%m`: Month (01-12)
- `+%Y`: 4-digit year

**Example output**: `05012026` (January 5, 2026)

---

### Task 3: Show last Friday's date in DDMMYYYY format
```bash
$ date -d "last friday" +%d%m%Y
```

**What it does**:
- `-d "last friday"`: Calculates the date of the most recent Friday
- `+%d%m%Y`: Formats output as DDMMYYYY

**Example output**: `03012026` (if today is Sunday January 5, 2026)

---

### Task 4: Show the date from 127 hours ago
```bash
$ date -d "127 hours ago"
```

**What it does**: Calculates and displays the date and time 127 hours before now.

**Example output**: `Sun Dec 29 19:35:22 UTC 2025`

---

### Task 5: Show Unix timestamp from 2 days ago
```bash
$ date -d "2 days ago" +%s
```

**What it does**:
- `-d "2 days ago"`: Calculates date 2 days before now
- `+%s`: Formats as Unix timestamp (seconds since Jan 1, 1970)

**Example output**: `1735689322`

---

## Key Learning Points

1. **Option Flexibility**: Linux commands allow options to be combined (`-la` instead of `-l -a`)

2. **Order Independence**: Option order typically doesn't matter (`-lat` = `-alt` = `-tla`)

3. **Format Strings**: The `date` command uses format specifiers starting with `%`
   - `%H`, `%M`, `%S` - Time components
   - `%d`, `%m`, `%Y` - Date components
   - `%s` - Unix timestamp

4. **Relative Dates**: The `-d` option accepts human-readable date descriptions:
   - "last friday", "next monday"
   - "2 days ago", "3 weeks ago"
   - "127 hours ago", "45 minutes ago"

5. **Command Help**: Use `--help` or `man command` to learn more:
   ```bash
   $ ls --help
   $ man date
   ```

---

## Additional Practice

Try these variations to deepen your understanding:

```bash
# List your home directory with human-readable sizes
$ ls -lah ~

# Show files sorted by size (largest first)
$ ls -lhS /boot

# Display date in ISO 8601 format
$ date -I

# Calculate date 1 year from now
$ date -d "1 year"

# Show day of week for a specific date
$ date -d "2026-12-25" +%A
```

---

## Common Mistakes to Avoid

1. Forgetting the `+` in date format strings: `date %H` (wrong) vs `date +%H` (correct)

2. Using uppercase when lowercase is needed: `date +%m` (month) vs `date +%M` (minute)

3. Not quoting relative date strings: `date -d last friday` (wrong) vs `date -d "last friday"` (correct)

4. Confusing `ls -R` (recursive) with `ls -r` (reverse order)

---

**Congratulations!** You've mastered the basics of Linux command structure. Move on to Exercise 2 to learn filesystem operations.
