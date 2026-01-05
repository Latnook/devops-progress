# Exercise 2 Solution: Basic Filesystem Commands

## Objective
Master fundamental filesystem operations including creating, copying, moving, and removing files and directories safely and efficiently.

---

## Part 1: Directory Operations

### Task 1: Create a directory called 'files'
```bash
mkdir files
```

**What it does**: Creates a new directory named 'files' in the current directory.

---

### Task 2: Create multiple directories at once
```bash
mkdir docs scripts logs
```

**What it does**: Creates three directories simultaneously: docs, scripts, and logs.

---

### Task 3: Create nested directory structure
```bash
mkdir -p project/src/main
```

**What it does**: 
- Creates 'project' directory
- Creates 'src' inside 'project'
- Creates 'main' inside 'src'
- The `-p` flag creates parent directories as needed

**Without -p**: `mkdir project/src/main` would fail if project or src don't exist.

---

### Task 4: Try to remove non-empty directory
```bash
rmdir Dir
# Output: rmdir: failed to remove 'Dir': Directory not empty
```

**What it does**: Demonstrates that `rmdir` only removes empty directories.

**Solution for non-empty**: Use `rm -r Dir` instead (covered later).

---

## Part 2: File Creation and Viewing

### Task 1: Create empty file
```bash
touch test.txt
```

**What it does**: Creates an empty file called 'test.txt' or updates timestamp if it exists.

---

### Task 2: Create multiple files
```bash
touch note1.txt note2.txt note3.txt
```

**Alternative shorthand**:
```bash
touch note{1,2,3}.txt
```

**What it does**: Creates three empty files simultaneously.

---

### Task 3: Add text to a file
```bash
echo "This is my first line" > test.txt
```

**What it does**: 
- Creates or overwrites test.txt
- Writes the text to the file
- `>` redirects output to file (overwrites existing content)

---

### Task 4: Append text to file
```bash
echo "This is my second line" >> test.txt
```

**What it does**:
- `>>` appends to file instead of overwriting
- Adds text on a new line

---

### Task 5: View file contents
```bash
cat test.txt
```

**Output**:
```
This is my first line
This is my second line
```

---

### Task 6: View with head and tail
```bash
head -n 2 test.txt    # First 2 lines
tail -n 2 test.txt    # Last 2 lines
```

**What it does**:
- `head -n 2`: Shows first 2 lines
- `tail -n 2`: Shows last 2 lines
- Useful for large files

---

## Part 3: Copying Files

### Task 1: Copy files starting with letters
```bash
cp Dir/[a-zA-Z]* files/
```

**What it does**:
- `[a-zA-Z]*` matches files starting with any letter (upper or lowercase)
- Copies all matching files from Dir/ to files/
- Excludes files starting with numbers or special characters

**Files copied**: file1.txt, file2.log, script.sh, data1.csv, etc.

---

### Task 2: Copy all .txt files
```bash
cp Dir/*.txt files/
```

**What it does**:
- `*.txt` matches all files ending with .txt
- Copies only text files

---

### Task 3: Copy directory recursively
```bash
cp -r Dir backup-dir
```

**What it does**:
- `-r` (recursive) copies directory and all contents
- Creates 'backup-dir' with identical structure to 'Dir'

---

### Task 4: Copy preserving permissions
```bash
cp -p Dir/file1.txt files/
```

**What it does**:
- `-p` preserves:
  - File permissions (read/write/execute)
  - Timestamps (modification time, access time)
  - Ownership (if possible)

---

## Part 4: Moving and Renaming

### Task 1: Rename a file
```bash
mv test.txt mytest.txt
```

**What it does**: Renames test.txt to mytest.txt (same directory).

**Key insight**: In Linux, moving and renaming are the same operation!

---

### Task 2: Move multiple files
```bash
mv note1.txt note2.txt note3.txt docs/
```

**What it does**: Moves all three files into the docs/ directory.

**Important**: The last argument must be a directory when moving multiple files.

---

### Task 3: Move and rename simultaneously
```bash
mv docs/note1.txt scripts/important-note.txt
```

**What it does**: Moves note1.txt from docs/ to scripts/ AND renames it.

---

## Part 5: Removing Files and Directories

### Task 1: Remove single file
```bash
rm test.txt
```

**What it does**: Permanently deletes test.txt.

**Warning**: No recycle bin in Linux! File is gone forever.

---

### Task 2: Remove files with pattern
```bash
rm note*.txt
```

**What it does**: Removes all files starting with 'note' and ending with '.txt'.

**Example**: Removes note1.txt, note2.txt, note3.txt

---

### Task 3: Remove directory and contents
```bash
rm -r backup-dir
```

**What it does**:
- `-r` (recursive) removes directory and all contents
- Works on both files and subdirectories

**Caution**: This is permanent! Use carefully.

---

### Task 4: Interactive removal
```bash
rm -i *.txt
```

**What it does**:
- `-i` asks for confirmation before each deletion
- Safer for beginners

**Example interaction**:
```
rm: remove regular file 'file1.txt'? y
rm: remove regular file 'file2.txt'? n
```

---

### Task 5: Force removal
```bash
rm -f protected-file.txt
```

**What it does**:
- `-f` forces removal without prompts
- Overrides write-protection
- Use with extreme caution!

---

## Part 6: Practice Exercise Solution

### Create project structure
```bash
# Create all directories
mkdir -p my-project/{src,tests,docs}

# Create Python files
touch my-project/src/main.py
touch my-project/src/utils.py
touch my-project/tests/test_main.py

# Create documentation
touch my-project/docs/README.md

# Create config file
touch my-project/config.yaml
```

**Brace expansion**: `{src,tests,docs}` creates three directories at once.

---

### Copy .py files
```bash
cp my-project/src/*.py my-project/tests/
```

**What it does**: Copies all Python files from src/ to tests/.

---

### Move README.md
```bash
mv my-project/docs/README.md my-project/
```

**What it does**: Moves README.md from docs/ to project root.

---

### Backup entire project
```bash
cp -r my-project my-project-backup
```

**What it does**: Creates complete backup of the project directory.

---

## Key Learning Points

1. **Directory vs File Operations**: mkdir creates directories, touch creates files
2. **Wildcards for Efficiency**: Use *, ?, [a-z] for pattern matching
3. **Safety Practices**: Use -i when learning, test with ls before rm
4. **Moving vs Copying**: cp duplicates, mv relocates
5. **Options Matter**: -r for directories, -p preserves metadata

---

## Common Mistakes to Avoid

1. Forgetting -r with directories when copying
2. Using rmdir on non-empty directories
3. Overwriting with > instead of >>
4. Moving multiple files without directory destination

---

**Congratulations!** You've mastered basic filesystem operations.
