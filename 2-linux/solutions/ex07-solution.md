# Exercise 7 Solution: Pipes & Filters

## Objective
Chain commands with pipes and process text with filters.

---

## Common Filters

- **grep**: Search/filter text
- **awk**: Field extraction and processing
- **cut**: Extract columns
- **sort**: Sort lines
- **tr**: Translate characters
- **wc**: Count words/lines/characters
- **head/tail**: First/last N lines

---

## Examples

### Extract fields from /etc/passwd
```bash
head -3 /etc/passwd | awk -F: '{print $1,$3}'
```

### Count directories
```bash
ls -lR | cut -c1 | grep d -c
```

### Find 3 largest files
```bash
ls -l | tail -n +2 | sort -gk5 -r | head -3
```

### Get disk usage percentage
```bash
df | grep -w / | awk '{print $(NF-1)}' | tr -d %
```

### Sort by UID
```bash
tail -n +11 /etc/passwd | head | sort -gk3 -t:
```

---

## Key Learning Points

1. **Pipes** connect stdout to stdin
2. **awk** is powerful for field extraction
3. **sort -gk5**: Sort numerically by field 5
4. **tail -n +2**: Skip first line
5. **tr -d %**: Delete character

---
