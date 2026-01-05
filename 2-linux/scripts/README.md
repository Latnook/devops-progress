# Utility Scripts Guide

This directory contains three utility scripts to help you manage your Linux learning exercises.

## Available Scripts

### verify.sh - Check Your Work
Verifies that you've completed an exercise correctly.

**Usage:**
```bash
./scripts/verify.sh <exercise_number>
```

**Example:**
```bash
./scripts/verify.sh 2    # Check exercise 2
```

### reset.sh - Start an Exercise Over
Deletes a specific exercise directory so you can practice again.

**Usage:**
```bash
./scripts/reset.sh <exercise_number>
```

**Example:**
```bash
./scripts/reset.sh 4     # Reset exercise 4
```

### cleanup.sh - Remove All Exercises
Deletes all exercise directories at once.

**Usage:**
```bash
./scripts/cleanup.sh
```

## Typical Workflow

1. Run an exercise: `./exercises/ex01-command-structure.sh`
2. Complete the tasks in `~/linux-exercises/ex01/`
3. Verify your work: `./scripts/verify.sh 1`
4. Review solution: `less solutions/ex01-solution.md`
5. Practice again if needed: `./scripts/reset.sh 1`

All scripts ask for confirmation before deleting anything.
