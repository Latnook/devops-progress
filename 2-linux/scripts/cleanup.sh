#!/bin/bash

# cleanup.sh - Remove all Linux exercise working directories
# Part of the 2-linux module

set -e

EXERCISE_DIR="$HOME/linux-exercises"

echo "============================================"
echo "Linux Exercises - Cleanup Utility"
echo "============================================"
echo ""

# Check if exercise directory exists
if [ ! -d "$EXERCISE_DIR" ]; then
    echo "✓ No exercise directories found."
    echo "  Location checked: $EXERCISE_DIR"
    exit 0
fi

# Show what will be deleted
echo "This will permanently delete the following directory and ALL its contents:"
echo "  → $EXERCISE_DIR"
echo ""

# Count subdirectories
exercise_count=$(find "$EXERCISE_DIR" -maxdepth 1 -type d | wc -l)
exercise_count=$((exercise_count - 1))  # Subtract the parent directory

if [ $exercise_count -gt 0 ]; then
    echo "Found $exercise_count exercise directory/directories"
    echo ""
    ls -ld "$EXERCISE_DIR"/*/
    echo ""
fi

# Confirm deletion
read -p "Are you sure you want to delete ALL exercises? [y/N]: " confirm

if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
    echo ""
    echo "Removing $EXERCISE_DIR..."
    rm -rf "$EXERCISE_DIR"

    if [ -d "$EXERCISE_DIR" ]; then
        echo "✗ Failed to remove directory. You may need elevated permissions."
        exit 1
    else
        echo "✓ Successfully removed all exercise directories"
        echo ""
        echo "To start fresh, run any exercise script again:"
        echo "  cd ~/devops-progress/2-linux/exercises"
        echo "  ./ex01-command-structure.sh"
    fi
else
    echo ""
    echo "Cleanup cancelled. No files were deleted."
fi

echo ""
