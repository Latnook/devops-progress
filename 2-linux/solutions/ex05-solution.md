# Exercise 5 Solution: Links

## Objective
Understand hard links and symbolic (soft) links.

---

## Key Differences

| Feature | Hard Link | Soft Link |
|---------|-----------|-----------|
| Inode | Same as original | Different |
| Command | `ln source dest` | `ln -s source dest` |
| Survives deletion | Yes | No (breaks) |
| Works on directories | No | Yes |
| Cross filesystem | No | Yes |

---

## Creating Links

### Hard Link
```bash
ln original pseudo-original
ls -li  # Same inode number
```

### Soft Link
```bash
ln -s original link2original
ls -li  # Different inode, shows -> arrow
```

---

## Testing Link Behavior

### Hard Link Survives
```bash
rm original
cat pseudo-original  # Still works! Same data
ln pseudo-original original  # Restore
```

### Soft Link Breaks
```bash
rm original
cat link2original  # Broken! Points to nothing
```

---

## Key Learning Points

1. **Hard links**: Multiple names for same data (same inode)
2. **Soft links**: Pointers/shortcuts (different inode)
3. **Deletion**: Hard link survives, soft link breaks
4. **Usage**: Soft links more flexible, hard links more robust

---
