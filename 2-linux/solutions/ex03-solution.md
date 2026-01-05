# Exercise 3 Solution: Wildcards (Filename Generation)

## Objective
Master wildcard patterns for flexible and efficient file selection and manipulation.

---

## Wildcard Pattern Reference

| Pattern | Matches | Example |
|---------|---------|---------|
| `*` | Zero or more characters | `file*` matches file, file1, filename |
| `?` | Exactly one character | `file?` matches file1, fileA |
| `[abc]` | One character from set | `[ft]est` matches fest, test |
| `[a-z]` | One character in range | `[0-9]` matches any digit |
| `[!abc]` | One character NOT in set | `[!0-9]*` matches non-numeric starts |

---

## Part 1: Basic Wildcards

### Task 1: List all files in Dir/
```bash
ls Dir/
```

### Task 2: List all .txt files
```bash
ls Dir/*.txt
```
Matches: file1.txt, file_a.txt, file_b.txt

### Task 3: Files starting with 'file'
```bash
ls Dir/file*
```
Matches: file1.txt, file2.log, file_a.txt, file_b.txt, file_c.log, fileABC

### Task 4: Exactly 5-character names
```bash
ls Dir/?????
```
Each `?` matches one character, so `?????` matches exactly 5 characters.

---

## Part 2: Character Classes

### Task 5: Copy files starting with letter
```bash
mkdir files
cp Dir/[a-zA-Z]* files/
```

**What it matches**:
- `[a-zA-Z]` matches one letter (uppercase or lowercase)
- `*` matches rest of filename
- Excludes: 123file (starts with digit)
- Includes: file1.txt, script.sh, readme.md, etc.

---

### Task 6: Files ending with digit
```bash
ls -ld Folder/*[0-9]
```

**What it matches**:
- `*` matches anything
- `[0-9]` requires last character to be a digit
- Matches: folder1, folder2, folder10, folder20, config10, data99

---

### Task 7: Files containing underscore
```bash
ls -ld Dir/*_*
```

**What it matches**:
- First `*` matches anything before underscore
- Second `*` matches anything after underscore
- Matches: my_file1, my_file2, temp_test, test_temp, file_a.txt, file_b.txt

---

### Task 8: Files with extensions
```bash
ls -ld Dir/*.?*
```

**What it matches**:
- `*` matches filename
- `.` matches literal dot
- `?` requires at least one character after dot
- `*` matches rest of extension
- Matches: file1.txt, file2.log, readme.md, config.conf

---

## Part 3: Advanced Patterns

### Task 9: Files in F or D subdirs
```bash
ls -ld [FD]*/[a-zA-Z]*[0-9]
```

**Breakdown**:
- `[FD]*` matches directories starting with F or D
- `/` path separator
- `[a-zA-Z]*` matches files starting with letter
- `[0-9]` requires ending with digit
- Matches: Folder/folder1, Folder/folder2, Folder/config10, Dir/test1, Dir/test2

---

### Task 10: Files starting with My or my
```bash
ls -ld ~/*/[Mm]y*
```

**Breakdown**:
- `~/*` matches subdirectories in home
- `[Mm]` matches M or m (case insensitive)
- `y*` matches 'y' followed by anything
- Matches: my_file1, My_Document, mytest

---

### Task 11: Files NOT starting with 't'
```bash
ls Dir/[!t]*
```

**What it does**:
- `[!t]` matches any character except 't'
- `*` matches rest of filename
- Excludes: test_temp, temp_test (if temp_test starts with t)

---

### Task 12: Exactly 4-letter names
```bash
ls Dir/????
```

Or to exclude files with extensions:
```bash
ls Dir/[a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z]
```

---

## Practice Exercises Solutions

### 1. Create test files
```bash
touch test{1..10}
```

Brace expansion creates: test1, test2, test3, ... test10

---

### 2. List only test1-5
```bash
ls test[1-5]
```

---

### 3. List double-digit test files
```bash
ls test[0-9][0-9]
```

Or specifically:
```bash
ls test10
```

---

### 4. Copy .txt and .log files
```bash
cp Dir/*.txt Dir/*.log files/
```

Or using brace expansion:
```bash
cp Dir/*.{txt,log} files/
```

---

### 5. Count files starting with vowel
```bash
ls Dir/[aeiouAEIOU]* | wc -l
```

---

## Key Learning Points

1. **Wildcards vs Regex**: Wildcards are simpler, used by shell for filename matching
2. **Shell Expansion**: Shell expands wildcards before passing to command
3. **Safety**: Always test with `ls` before using `rm`
4. **Case Sensitivity**: Linux is case-sensitive; use [Aa] for both cases
5. **Hidden Files**: * doesn't match files starting with dot by default

---

## Common Patterns Cheat Sheet

```bash
# All files
*

# Files with extension
*.txt

# Files without extension
*[!.]*

# Hidden files
.*

# Backup files
*~ *.bak

# Temporary files
*.tmp *.temp

# Files starting with letter
[a-zA-Z]*

# Files starting with digit
[0-9]*

# Files ending with digit
*[0-9]

# Three-letter extensions
*.???

# C source and header files
*.[ch]

# Image files
*.{jpg,png,gif}

# Case-insensitive match
[Ff]ile*
```

---

**Congratulations!** You've mastered wildcard patterns. Move on to Exercise 4 for file permissions.
