#!/bin/bash

# reset.sh - Reset a specific Linux exercise
# Part of the 2-linux module
# Usage: ./reset.sh <exercise_number>

set -e

EXERCISE_DIR="$HOME/linux-exercises"

echo "============================================"
echo "Linux Exercises - Reset Utility"
echo "============================================"
echo ""

# Check if exercise number provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <exercise_number>"
    echo ""
    echo "Example: $0 4       # Reset exercise 4 (permissions)"
    echo ""
    echo "Available exercises:"
    echo "  1  - Command Structure"
    echo "  2  - Filesystem Commands"
    echo "  3  - Wildcards"
    echo "  4  - Permissions"
    echo "  5  - Links"
    echo "  6  - I/O Redirection"
    echo "  7  - Pipes & Filters"
    echo "  8  - Regular Expressions"
    echo "  9  - Find Command"
    echo "  10 - Advanced Bash"
    echo "  11 - Services & Processes"
    echo "  12 - Bash Scripting"
    echo "  13 - Sed & Awk"
    exit 1
fi

# Get exercise number
EX_NUM=$(printf "%02d" "$1")

# Exercise directory path
EX_PATH="$EXERCISE_DIR/ex$EX_NUM"

# Check if exercise directory exists
if [ ! -d "$EX_PATH" ]; then
    echo "✗ Exercise $1 directory not found"
    echo "  Expected location: $EX_PATH"
    echo ""
    echo "This exercise may not have been started yet."
    echo "Run the exercise script to create it:"
    echo "  ./exercises/ex$EX_NUM-*.sh"
    exit 1
fi

# Show what will be deleted
echo "This will permanently delete the exercise $1 directory:"
echo "  → $EX_PATH"
echo ""
ls -lh "$EX_PATH" 2>/dev/null | head -20
echo ""

# Confirm deletion
read -p "Reset exercise $1? This will delete all your work. [y/N]: " confirm

if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
    echo ""
    echo "Removing $EX_PATH..."
    rm -rf "$EX_PATH"

    if [ -d "$EX_PATH" ]; then
        echo "✗ Failed to remove directory. You may need elevated permissions."
        exit 1
    else
        echo "✓ Successfully reset exercise $1"
        echo ""
        echo "To start this exercise again, run:"
        echo "  cd ~/devops-progress/2-linux/exercises"
        echo "  ./ex$EX_NUM-*.sh"
    fi
else
    echo ""
    echo "Reset cancelled. No files were deleted."
fi

echo ""
