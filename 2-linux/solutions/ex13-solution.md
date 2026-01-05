# Exercise 13 Solution: Sed & Awk

## Objective
Advanced text processing with sed and awk.

---

## Awk Examples

### Basic Field Extraction
```bash
# Print username and UID from /etc/passwd
awk -F: '{print $1,$3}' /etc/passwd

# Print first and last field
awk '{print $1, $NF}' file
```

### Count and Sum File Sizes
```bash
# Find .gz files and sum sizes
find / -name "*.gz" -exec ls -l {} \; 2>/dev/null | \
  awk '{sum++; size+=$5} END{print sum, "Files,", size, "Bytes total"}'
```

### Count User's Files
```bash
# Count files owned by current user
ls -lR 2>/dev/null | \
  awk 'BEGIN{"whoami" | getline user} /^[^d]/ {if($3==user){print $0; sum++; size+=$5}} END{print sum, "Files,", size, "Bytes total"}'
```

---

## Awk Structure

### BEGIN and END Blocks
```bash
awk 'BEGIN {
    # Executed before processing
    "whoami" | getline user
}
/pattern/ {
    # Executed for matching lines
    sum++
    size += $5
}
END {
    # Executed after processing
    print sum, size
}' file
```

### Special Variables
- `$1, $2, $3` - Fields 1, 2, 3
- `$NF` - Last field
- `NR` - Current record number
- `NF` - Number of fields
- `-F:` - Field separator (colon)

---

## Sed Examples

### Substitution
```bash
sed 's/old/new/'        # Replace first occurrence per line
sed 's/old/new/g'       # Replace all occurrences
sed 's/old/new/2'       # Replace 2nd occurrence
sed -n 's/old/new/p'    # Print only changed lines
```

### Line Selection
```bash
sed -n '1,5p' file      # Print lines 1-5
sed -n '/pattern/p'     # Print matching lines
sed '1,3d' file         # Delete lines 1-3
```

### Pattern Range
```bash
# Extract text between two patterns
sed -n '/START/,/END/p' file

# Complex example from exercise
sed -n /"$(grep -B1 ERROR file | head -1)"/,/"$(grep -A1 END file | tail -1)"/p file
```

---

## Key Learning Points

1. **Awk**: Field-based processing, great for structured data
2. **BEGIN block**: Initialize variables, execute commands
3. **END block**: Print summaries, totals
4. **Field separator**: Use -F to specify delimiter
5. **Sed**: Stream editor for find/replace and line selection
6. **Pattern ranges**: Process text between two patterns

---

## Common Awk Patterns

```bash
# Sum column 5
awk '{sum+=$5} END{print sum}'

# Count lines matching pattern
awk '/pattern/{count++} END{print count}'

# Print if field 3 is greater than 100
awk '$3 > 100 {print $0}'

# Calculate average
awk '{sum+=$1; count++} END{print sum/count}'

# Multiple field separators
awk -F'[:,]' '{print $1, $3}'
```

---
