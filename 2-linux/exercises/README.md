# Linux Fundamentals - Interactive Exercises

This directory contains 13 interactive exercise scripts designed to teach Linux fundamentals through hands-on practice.

## Quick Start

All exercise scripts are executable and self-contained. Simply run any exercise:

```bash
cd /home/latnook/devops-progress/2-linux/exercises
./ex01-command-structure.sh
```

## 🎉 NEW: Fully Interactive Exercises!

**Exercises 01-03 have been upgraded to fully interactive tutorials** following the pattern of ex01:
- ✓ **Interactive validation**: Type commands and get instant feedback
- ✓ **Progressive hints**: 3-level hint system when you're stuck
- ✓ **Result-based checking**: Multiple solutions accepted!
- ✓ **Clear structure**: CONCEPT → SCENARIO → YOUR GOAL → What you know
- ✓ **Progress tracking**: See your completion status
- ✓ **Educational feedback**: Learn WHY commands work

**Status**:
- ✅ ex01-command-structure.sh (502 lines, 6 tasks)
- ✅ ex02-filesystem-commands.sh (610 lines, 7 tasks)
- ✅ ex03-wildcards.sh (553 lines, 6 tasks)
- ⏳ ex04-ex13 (Planned - see IMPLEMENTATION_STATUS.md)

## Exercise List

| # | Exercise | Focus | Key Commands |
|---|----------|-------|--------------|
| 01 | [Command Structure](ex01-command-structure.sh) | Basic command syntax, options | `ls`, `date` |
| 02 | [Filesystem Commands](ex02-filesystem-commands.sh) | Creating, moving, copying files | `mkdir`, `cp`, `mv`, `rm`, `touch` |
| 03 | [Wildcards](ex03-wildcards.sh) | Pattern matching | `*`, `?`, `[abc]`, `[a-z]` |
| 04 | [Permissions](ex04-permissions.sh) | File permissions, SUID, SGID | `chmod`, `umask` |
| 05 | [Links](ex05-links.sh) | Hard and symbolic links | `ln`, `ln -s` |
| 06 | [I/O Redirection](ex06-io-redirection.sh) | Redirecting input/output/errors | `>`, `>>`, `2>`, `&>`, `<` |
| 07 | [Pipes & Filters](ex07-pipes-filters.sh) | Command chaining and text processing | `grep`, `awk`, `cut`, `sort` |
| 08 | [Regular Expressions](ex08-regex.sh) | Pattern matching with regex | `grep`, `egrep` |
| 09 | [Find](ex09-find.sh) | Advanced file searching | `find`, `-exec` |
| 10 | [Advanced Bash](ex10-advanced-bash.sh) | Aliases, history, environment | `alias`, `PS1`, `$PATH` |
| 11 | [Services & Processes](ex11-services-processes.sh) | Process and service management | `systemctl`, `ps`, `kill`, `nice` |
| 12 | [Bash Scripting](ex12-bash-scripting.sh) | Writing shell scripts | Variables, conditionals, loops |
| 13 | [Sed & Awk](ex13-sed-awk.sh) | Advanced text processing | `sed`, `awk` |

## How to Use

### 1. Run an Exercise

Each exercise script provides:
- Clear objectives
- Setup instructions
- Sample data (created automatically)
- Step-by-step tasks
- Hints and tips
- Reference to solution file

```bash
# Make executable (already done)
chmod +x ex01-command-structure.sh

# Run the exercise
./ex01-command-structure.sh
```

### 2. Follow the Instructions

Each exercise will:
1. Create a working directory (`~/linux-exercises/exNN/`)
2. Set up sample files and directories
3. Present tasks with hints
4. Guide you through the concepts

### 3. Practice the Commands

Work through the exercises at your own pace. Try the commands in the terminal as suggested.

### 4. Check Solutions

After attempting each exercise, review the solution file:

```bash
cat ../solutions/ex01-solution.md
# or open in your favorite editor/viewer
```

Solution files contain:
- Complete command-by-command solutions
- Explanations of what each command does
- Key learning points
- Common mistakes to avoid
- Additional practice suggestions

## Learning Path

### Beginner (Start Here)
1. Exercise 01 - Command Structure
2. Exercise 02 - Filesystem Commands
3. Exercise 03 - Wildcards
4. Exercise 04 - Permissions

### Intermediate
5. Exercise 05 - Links
6. Exercise 06 - I/O Redirection
7. Exercise 07 - Pipes & Filters
8. Exercise 08 - Regular Expressions

### Advanced
9. Exercise 09 - Find
10. Exercise 10 - Advanced Bash
11. Exercise 11 - Services & Processes
12. Exercise 12 - Bash Scripting
13. Exercise 13 - Sed & Awk

## Tips for Success

1. **Work in Order**: Exercises build on previous concepts
2. **Try Before Looking**: Attempt tasks before checking solutions
3. **Experiment**: Modify commands to see what happens
4. **Practice Safety**: Use `-i` flag with `rm`, test with `ls` first
5. **Use Help**: `man command`, `command --help`, `apropos keyword`
6. **Take Notes**: Document commands you find useful

## Working Directories

Each exercise creates its own directory under `~/linux-exercises/`:

```
~/linux-exercises/
├── ex01/    # Command structure practice
├── ex02/    # Filesystem operations
├── ex03/    # Wildcard practice
├── ex04/    # Permission management
├── ex05/    # Links practice
└── ...
```

These directories are safe to experiment in and can be deleted when done:

```bash
rm -rf ~/linux-exercises
```

## Additional Resources

- **Fundamentals Guide**: `../docs/fundamentals.md` - Complete theory
- **Command Reference**: `../docs/commands-reference.md` - Quick lookup
- **Learning Path**: `../docs/learning-path.md` - Structured curriculum

## Getting Help

If you get stuck:

1. Review the hints in the exercise script
2. Check the solution file for that exercise
3. Read the man page: `man <command>`
4. Consult the fundamentals guide: `../docs/fundamentals.md`

## Troubleshooting

### Exercise won't run
```bash
# Make sure it's executable
chmod +x ex01-command-structure.sh

# Run with bash explicitly
bash ex01-command-structure.sh
```

### Working directory issues
```bash
# Exercises create directories in your home
cd ~
ls -ld linux-exercises/

# Clean up if needed
rm -rf ~/linux-exercises
```

### Permission denied errors
Some exercises (especially 11) may require sudo for certain tasks. These are clearly marked in the exercise.

## Contributing

Found an issue or have a suggestion? The exercises are designed to be:
- Self-contained
- Educational
- Safe to run
- Progressive in difficulty

## License

These exercises are part of the DevOps learning repository.

---

**Ready to start?** Run `./ex01-command-structure.sh` and begin your Linux journey!
