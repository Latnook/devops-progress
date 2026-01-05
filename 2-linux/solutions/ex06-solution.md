# Exercise 6 Solution: I/O Redirection

## Objective
Master stdout, stderr, and stdin redirection.

---

## Redirection Operators

| Operator | Purpose |
|----------|---------|
| `>` | Redirect stdout (overwrite) |
| `>>` | Append stdout |
| `2>` | Redirect stderr |
| `2>>` | Append stderr |
| `&>` | Redirect both stdout and stderr |
| `<` | Read stdin from file |
| `>|` | Force overwrite (noclobber) |

---

## Examples

### Separate Output and Errors
```bash
ls -l ~/Dir Nothing > output.only     # Stdout only
ls -l ~/Dir Nothing 2> errors.only    # Stderr only
ls -l ~/Dir Nothing &> both.log       # Both together
```

### Combine Files
```bash
cat output.only errors.only > combined.txt
```

### Noclobber Protection
```bash
set -o noclobber        # Enable protection
echo "test" > file      # Error if file exists
echo "test" >> file     # Append works
echo "test" >| file     # Force overwrite
set +o noclobber        # Disable protection
```

### Input Redirection
```bash
echo -e "y\nn\ny" > answers
rm -i *.temp < answers  # Use answers for prompts
```

---

## Key Learning Points

1. **Stdout (1)** and **Stderr (2)** are separate streams
2. **&>** captures both streams
3. **Noclobber** prevents accidental overwrites
4. **Input redirection** automates interactive commands

---
