#!/bin/bash

# verify.sh - Verify Linux exercise completion
# Part of the 2-linux module
# Usage: ./verify.sh <exercise_number>

set -e

EXERCISE_DIR="$HOME/linux-exercises"

echo "============================================"
echo "Linux Exercises - Verification Utility"
echo "============================================"
echo ""

# Check if exercise number provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <exercise_number>"
    echo ""
    echo "Example: $0 2       # Verify exercise 2 (filesystem commands)"
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
EX_PATH="$EXERCISE_DIR/ex$EX_NUM"

echo "Verifying Exercise $1..."
echo ""

# Check if exercise directory exists
if [ ! -d "$EX_PATH" ]; then
    echo "✗ Exercise $1 not started yet"
    echo "  Expected location: $EX_PATH"
    echo ""
    echo "Run the exercise script first:"
    echo "  ./exercises/ex$EX_NUM-*.sh"
    exit 1
fi

# Basic verification - check if directory exists and has content
cd "$EX_PATH" 2>/dev/null || {
    echo "✗ Cannot access exercise directory"
    exit 1
}

file_count=$(find . -type f 2>/dev/null | wc -l)
dir_count=$(find . -mindepth 1 -type d 2>/dev/null | wc -l)

echo "Exercise $1 Status:"
echo "  Directory: $EX_PATH"
echo "  Files created: $file_count"
echo "  Directories created: $dir_count"
echo ""

if [ $file_count -eq 0 ] && [ $dir_count -eq 0 ]; then
    echo "⚠ Warning: Exercise directory is empty"
    echo "  Make sure you've completed the exercise tasks"
    exit 1
fi

# Exercise-specific checks
case "$1" in
    2)
        # Exercise 2: Filesystem Commands
        if [ -d "Dir" ] && [ -d "Folder" ]; then
            echo "✓ Basic directory structure created"
        else
            echo "⚠ Missing expected directories (Dir, Folder)"
        fi
        ;;
    3)
        # Exercise 3: Wildcards
        if [ -d "files" ]; then
            echo "✓ Files directory created"
        fi
        ;;
    4)
        # Exercise 4: Permissions
        if [ -d "scripts" ]; then
            echo "✓ Scripts directory found"
        fi
        ;;
    5)
        # Exercise 5: Links
        if [ -d "links" ]; then
            echo "✓ Links directory created"
            link_count=$(find links -type l 2>/dev/null | wc -l)
            if [ $link_count -gt 0 ]; then
                echo "✓ Found $link_count symbolic link(s)"
            fi
        fi
        ;;
esac

echo ""
echo "Verification complete!"
echo ""
echo "To review the solution:"
echo "  less ~/devops-progress/2-linux/solutions/ex$EX_NUM-solution.md"
echo ""
