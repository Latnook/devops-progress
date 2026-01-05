# Linux Exercises - Quick Start Guide

## Get Started in 3 Steps

### 1. Navigate to Exercises
```bash
cd /home/latnook/devops-progress/2-linux/exercises
```

### 2. Run Your First Exercise
```bash
./ex01-command-structure.sh
```

### 3. Follow the Instructions
Read the objectives, try the tasks, then check the solution:
```bash
cat ../solutions/ex01-solution.md
```

## Exercise Overview

| # | Topic | Difficulty | Time |
|---|-------|------------|------|
| 01 | Command Structure | ⭐ Beginner | 15 min |
| 02 | Filesystem Commands | ⭐ Beginner | 20 min |
| 03 | Wildcards | ⭐ Beginner | 20 min |
| 04 | Permissions | ⭐⭐ Beginner | 25 min |
| 05 | Links | ⭐⭐ Intermediate | 15 min |
| 06 | I/O Redirection | ⭐⭐ Intermediate | 20 min |
| 07 | Pipes & Filters | ⭐⭐ Intermediate | 25 min |
| 08 | Regular Expressions | ⭐⭐⭐ Intermediate | 30 min |
| 09 | Find | ⭐⭐⭐ Advanced | 25 min |
| 10 | Advanced Bash | ⭐⭐⭐ Advanced | 20 min |
| 11 | Services & Processes | ⭐⭐⭐ Advanced | 30 min |
| 12 | Bash Scripting | ⭐⭐⭐⭐ Advanced | 40 min |
| 13 | Sed & Awk | ⭐⭐⭐⭐ Advanced | 35 min |

**Total Learning Time**: ~5-6 hours

## Quick Commands

### Run an Exercise
```bash
cd /home/latnook/devops-progress/2-linux/exercises
./ex01-command-structure.sh
```

### View Solution
```bash
cd /home/latnook/devops-progress/2-linux/solutions
cat ex01-solution.md
less ex01-solution.md  # For paginated viewing
```

### List All Exercises
```bash
cd /home/latnook/devops-progress/2-linux/exercises
ls -1 ex*.sh
```

### Get Help
```bash
# Read the exercise guide
cat README.md

# View theory documentation
cat ../docs/fundamentals.md

# Command reference
cat ../docs/commands-reference.md
```

## Learning Paths

### Path 1: Complete Beginner (Start Here!)
1. Ex 01 - Command Structure
2. Ex 02 - Filesystem Commands
3. Ex 03 - Wildcards
4. Ex 04 - Permissions

**Next**: Take a break, practice what you learned

### Path 2: Intermediate User
5. Ex 05 - Links
6. Ex 06 - I/O Redirection
7. Ex 07 - Pipes & Filters
8. Ex 08 - Regular Expressions

**Next**: Build small projects using these skills

### Path 3: Advanced Topics
9. Ex 09 - Find
10. Ex 10 - Advanced Bash
11. Ex 11 - Services & Processes
12. Ex 12 - Bash Scripting
13. Ex 13 - Sed & Awk

**Next**: Apply to real-world DevOps scenarios

## Tips for Success

1. **Go in Order**: Each exercise builds on previous concepts
2. **Practice**: Try commands before looking at solutions
3. **Experiment**: Modify commands to see what happens
4. **Be Safe**: Use `-i` flags, test with `ls` before `rm`
5. **Take Notes**: Keep a command cheatsheet
6. **Review**: Revisit exercises to reinforce learning

## What Each Exercise Does

All exercises:
- ✅ Create safe practice environments
- ✅ Provide clear instructions
- ✅ Include helpful hints
- ✅ Are completely self-contained
- ✅ Can be run multiple times

## Practice Directories

Exercises create directories in `~/linux-exercises/`:
```bash
ls -l ~/linux-exercises/
```

Safe to delete when done:
```bash
rm -rf ~/linux-exercises/
```

## Need Help?

1. Check hints in the exercise script
2. Review the solution file
3. Read `man <command>` for detailed help
4. Consult `docs/fundamentals.md` for theory

## File Locations

```
2-linux/
├── exercises/          ← Exercise scripts (start here)
│   ├── ex01-*.sh
│   ├── ex02-*.sh
│   └── ...
├── solutions/          ← Solutions (check after trying)
│   ├── ex01-*.md
│   ├── ex02-*.md
│   └── ...
└── docs/              ← Theory and reference
    ├── fundamentals.md
    └── commands-reference.md
```

## Example Session

```bash
# Start learning
cd /home/latnook/devops-progress/2-linux/exercises

# Run exercise 1
./ex01-command-structure.sh

# Practice the commands shown
ls -l /boot
date +%H_%M_%S

# Check your work
cat ../solutions/ex01-solution.md

# Move to next exercise
./ex02-filesystem-commands.sh
```

## Progress Tracking

Create a simple checklist:
```bash
# Mark exercises as you complete them
echo "✅ Exercise 01 - Command Structure" >> ~/linux-progress.txt
echo "✅ Exercise 02 - Filesystem Commands" >> ~/linux-progress.txt
```

---

## Ready to Start?

```bash
cd /home/latnook/devops-progress/2-linux/exercises
./ex01-command-structure.sh
```

**Happy Learning!** 🚀

For more details, see `exercises/README.md` or `EXERCISES_SUMMARY.md`
