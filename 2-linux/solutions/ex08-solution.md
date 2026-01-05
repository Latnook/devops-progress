# Exercise 8 Solution: Regular Expressions

## Objective
Master regex patterns for advanced text matching.

---

## Regex Metacharacters

- `^` - Start of line
- `$` - End of line
- `.` - Any character
- `*` - Zero or more of preceding
- `[abc]` - Character class
- `[^abc]` - Negated class
- `\{n\}` - Exactly n occurrences (grep)
- `+` - One or more (egrep)
- `|` - OR (egrep)

---

## Examples

### Lines starting with 'd' (directories)
```bash
ls -lR | grep ^d
```

### Lines ending with 'c'
```bash
ls -lR | grep c$
```

### Files containing 'f'
```bash
ls -lR | grep "^-.*f"
```

### Directories ending with digit
```bash
ls -lR | grep "^d.*[0-9]$"
```

### Count empty lines
```bash
ls -lR | grep ^$ -c
```

### Count non-empty lines
```bash
ls -lR | grep . -c
# OR
ls -lR | grep -v ^$ -c
```

### Lines 1-10 characters long
```bash
ls -lR | egrep "^.{1,10}$"
```

### Permission patterns
```bash
# Full permission string (no special bits)
ls -lR | grep "^[-dlspbc][^-ST]\{9\}"

# Using egrep with alternation
ls -lR | egrep "^[-dlspbc](rw[xst]){3}"
```

---

## Key Learning Points

1. **grep vs egrep**: grep requires escaping, egrep doesn't
2. **Anchors**: ^ for start, $ for end
3. **Character classes**: [abc] for options, [^abc] for negation
4. **Quantifiers**: * (zero or more), + (one or more), {n} (exactly n)

---
