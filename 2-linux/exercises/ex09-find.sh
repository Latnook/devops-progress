#!/bin/bash

# Interactive Tutorial: Exercise 9 - The 'find' Command
# Master finding files based on complex criteria

set -e

# Colors using tput (more reliable than escape codes)
if command -v tput &> /dev/null && [ -t 1 ]; then
    GREEN=$(tput setaf 2)
    BLUE=$(tput setaf 4)
    YELLOW=$(tput setaf 3)
    RED=$(tput setaf 1)
    CYAN=$(tput setaf 6)
    BOLD=$(tput bold)
    NC=$(tput sgr0)
else
    GREEN=""
    BLUE=""
    YELLOW=""
    RED=""
    CYAN=""
    BOLD=""
    NC=""
fi

WORK_DIR="$HOME/linux-exercises/ex09"
# Clean up previous runs
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

TASKS_COMPLETED=0
TOTAL_TASKS=4

# Function to handle help commands
handle_help() {
    local cmd="$1"
    local main_cmd="$2"
    if [[ "$cmd" == "$main_cmd --help" ]]; then
        echo ""
        $main_cmd --help | head -n 20
        echo "..."
        echo "${CYAN}Help page displayed. Now try to construct the command.${NC}"
        return 0
    elif [[ "$cmd" == "man $main_cmd" ]]; then
        echo ""
        man $main_cmd
        echo "${CYAN}Man page closed. Now try to construct the command.${NC}"
        return 0
    fi
    return 1
}

# Setup test file structure
mkdir -p project/src project/docs
touch project/src/main.c project/src/utils.h
touch project/docs/README.md project/docs/manual.pdf
mkdir -p project/build/artefacts
touch project/build/app.o project/build/artefacts/app.bin
touch project/config.tmp
touch project/data.bak

clear

echo "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo "${BLUE}║${NC}     ${BOLD}Exercise 9: The 'find' Command - Interactive Tutorial${NC}      ${BLUE}║${NC}"
echo "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "${GREEN}Welcome!${NC} Wildcards are great, but they can't search subdirectories."
echo "You'll now learn the powerful '${BOLD}find${NC}' command to locate files anywhere."
echo ""
echo "${BOLD}How this works:${NC}"
echo "  • Each task requires you to find files or directories based on criteria."
echo "  • You'll need to discover the options for 'find' using its 'man' page."
echo "  • Type ${CYAN}'hint'${NC} if you get stuck."
echo ""
echo "We've created a sample directory structure for you in ${YELLOW}$WORK_DIR${NC}"
ls -R
echo ""
read -p "Press Enter to begin..."

clear

# ============================================================
# TASK 1: Finding Files by Name
# ============================================================

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 1/$TOTAL_TASKS: Finding Files by Name${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  Somewhere inside the 'project' directory, there is a C source file"
echo "  named 'main.c'. You need to find its exact location without manually"
echo "  searching through all the subdirectories."
echo ""
echo "${BOLD}YOUR GOAL:${NC} Use the 'find' command to search inside the 'project' directory and locate the file named 'main.c'."
echo ""
echo "Type ${CYAN}'hint'${NC} for help, or try a command:"
echo ""

hint_count=0
while true; do
    read -p "> " user_cmd

    if [[ "$user_cmd" == "hint" ]]; then
        hint_count=$((hint_count + 1))
        case $hint_count in
            1) echo "${CYAN}HINT 1:${NC} The basic syntax is 'find <path_to_search> -name <filename>'.";;
            2) echo "${CYAN}HINT 2:${NC} You are searching in the 'project' directory for a file with the name 'main.c'.";;
            3) echo "${CYAN}HINT 3:${NC} Try: find project -name main.c";;
        esac
    elif handle_help "$user_cmd" "find"; then
        continue
    elif [[ "$user_cmd" == *"find"* && "$user_cmd" == *"project"* && "$user_cmd" == *"-name"* && "$user_cmd" == *"main.c"* ]]; then
        output=$(eval "$user_cmd" 2>/dev/null)
        if [[ "$output" == "project/src/main.c" ]]; then
            echo ""
            echo "${GREEN}✓ Success!${NC} You found the file."
            echo "Your output:"
            echo "${CYAN}$output${NC}"
            TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
            echo ""
            read -p "Press Enter to continue..."
            break
        else
            echo "${RED}That didn't produce the correct output. The result should be 'project/src/main.c'.${NC}"
        fi
    else
        echo "${YELLOW}Use the 'find' command. You need to specify where to search and what name to search for. Type 'hint' if you need help.${NC}"
    fi
done

clear

# ============================================================
# TASK 2: Finding Files by Type
# ============================================================

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 2/$TOTAL_TASKS: Finding by Type and Name Pattern${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  You need to find all the temporary and backup files in the 'project' directory"
echo "  so you can delete them. These files end with '.tmp' or '.bak'."
echo "  You only want to find files, not directories."
echo ""
echo "${BOLD}YOUR GOAL:${NC} Find all regular files (not directories) in 'project' whose names end in either '.tmp' or '.bak'."
echo ""
echo "Type ${CYAN}'hint'${NC} for help, or try a command:"
echo ""

hint_count=0
while true; do
    read -p "> " user_cmd

    if [[ "$user_cmd" == "hint" ]]; then
        hint_count=$((hint_count + 1))
        case $hint_count in
            1) echo "${CYAN}HINT 1:${NC} You can specify the type of thing to find with '-type'. Use '-type f' for regular files.";;
            2) echo "${CYAN}HINT 2:${NC} You can use wildcards with '-name', but you must quote them to prevent the shell from expanding them too early: '-name \"*.tmp\"'.";;
            3) echo "${CYAN}HINT 3:${NC} You can specify an 'OR' condition with '-o'. For example: 'find . -name \"*.a\" -o -name \"*.b\"'.";;
            4) echo "${CYAN}HINT 4:${NC} Try: find project -type f \( -name \"*.tmp\" -o -name \"*.bak\" \)";;
        esac
    elif handle_help "$user_cmd" "find"; then
        continue
    elif [[ "$user_cmd" == *"find"* && "$user_cmd" == *"project"* && "$user_cmd" == *"-type f"* && "$user_cmd" == *"-name"* && ("$user_cmd" == *"\*.tmp"* || "$user_cmd" == *"\*.bak"*) ]]; then
        output=$(eval "$user_cmd" 2>/dev/null | sort)
        expected_output="project/config.tmp"$'\n'"project/data.bak"
        if [[ "$output" == "$expected_output" ]]; then
            echo ""
            echo "${GREEN}✓ Perfect!${NC} You've found the temporary files."
            echo "Your output:"
            echo "${CYAN}$output${NC}"
            TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
            echo ""
            read -p "Press Enter to continue..."
            break
        else
            echo "${RED}The output isn't quite right. It should be the '.tmp' and '.bak' files. Did you use an OR condition?${NC}"
        fi
    else
        echo "${YELLOW}Use 'find'. You need to specify a type and two name patterns. Type 'hint' if stuck.${NC}"
    fi
done

clear

# ============================================================
# TASK 3: Executing a Command on Found Files
# ============================================================

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 3/$TOTAL_TASKS: Executing Commands on Found Files${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  You need to see the permissions of all the directories (and only the directories)"
echo "  inside the 'project' directory. Running 'ls -l' on every single one would be tedious."
echo ""
echo "${BOLD}YOUR GOAL:${NC} Use 'find' to locate all directories within 'project' and then run the command 'ls -ld' on each one."
echo ""
echo "Type ${CYAN}'hint'${NC} for help, or try a command:"
echo ""

hint_count=0
while true; do
    read -p "> " user_cmd

    if [[ "$user_cmd" == "hint" ]]; then
        hint_count=$((hint_count + 1))
        case $hint_count in
            1) echo "${CYAN}HINT 1:${NC} You can execute a command on each found item with the '-exec' action.";;
            2) echo "${CYAN}HINT 2:${NC} The placeholder '{}' represents the found file path. The command must end with a semicolon, which needs to be escaped from the shell: '\;'.";;
            3) echo "${CYAN}HINT 3:${NC} First, find only directories with '-type d'.";;
            4) echo "${CYAN}HINT 4:${NC} Try: find project -type d -exec ls -ld {} \;";;
        esac
    elif handle_help "$user_cmd" "find"; then
        continue
    elif [[ "$user_cmd" == *"find"* && "$user_cmd" == *"project"* && "$user_cmd" == *"-type d"* && "$user_cmd" == *"-exec ls -ld"* && "$user_cmd" == *"{}"* && "$user_cmd" == *"\;"* ]]; then
        output=$(eval "$user_cmd" 2>/dev/null)
        line_count=$(echo "$output" | wc -l)
        if [ "$line_count" -eq 4 ] && echo "$output" | grep -q "project/src" && echo "$output" | grep -q "project/docs"; then
            echo ""
            echo "${GREEN}✓ Success!${NC} You've executed a command on your search results."
            echo "Your output:"
            echo "${CYAN}$output${NC}"
            TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
            echo ""
            read -p "Press Enter to continue..."
            break
        else
            echo "${RED}That's not quite right. It should have run 'ls -ld' on the 4 directories inside 'project'.${NC}"
        fi
    else
        echo "${YELLOW}Use 'find'. You need to find directories ('-type d') and then use the '-exec' action. Type 'hint' if you get stuck.${NC}"
    fi
done

clear

# ============================================================
# TASK 4: Challenge - Finding and Deleting
# ============================================================

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 4/$TOTAL_TASKS: CHALLENGE - Find and Delete${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  The 'project/build' directory contains compiled object files that end in '.o' and '.bin'."
echo "  These are intermediate files and are safe to delete. You need to clean them up."
echo ""
echo "Files to be deleted:"
find project/build -type f
echo ""
echo "${BOLD}YOUR GOAL:${NC} Use a single 'find' command to find all files (not directories) inside 'project/build' and delete them."
echo ""
echo "${CYAN}This is a destructive action! Be careful. The safest action for '-exec' is '-exec rm -i {} \;', which prompts you.${NC}"
echo ""

hint_count=0
while true; do
    read -p "> " user_cmd

    if [[ "$user_cmd" == "hint" ]]; then
        hint_count=$((hint_count + 1))
        case $hint_count in
            1) echo "${CYAN}HINT 1:${NC} You need to search in 'project/build' for items of '-type f'.";;
            2) echo "${CYAN}HINT 2:${NC} You can use the '-delete' action, which is often safer and more efficient than '-exec rm {} \;'. ";;
            3) echo "${CYAN}HINT 3:${NC} Try: find project/build -type f -delete";;
        esac
    elif handle_help "$user_cmd" "find"; then
        continue
    elif [[ "$user_cmd" == *"find"* && "$user_cmd" == *"project/build"* && "$user_cmd" == *"-type f"* && ("$user_cmd" == *"-delete"* || "$user_cmd" == *"-exec rm") ]]; then
        find project/build -type f -delete
        remaining_files=$(find project/build -type f | wc -l)
        if [ "$remaining_files" -eq 0 ]; then
            echo ""
            echo "${GREEN}✓ OUTSTANDING!${NC} The build directory has been cleaned."
            echo "Current contents of 'project/build':"
            ls -R project/build
            TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
            echo ""
            read -p "Press Enter to continue..."
            break
        else
            echo "${RED}The files were not deleted. Check your command's syntax.${NC}"
            touch project/build/app.o project/build/artefacts/app.bin
        fi
    else
        echo "${YELLOW}Use 'find' to search in 'project/build' for files, then use an action to delete them. Type 'hint' if you are stuck.${NC}"
    fi
done

clear

# ============================================================
# COMPLETION
# ============================================================

cd ..
rm -rf "$WORK_DIR"

echo "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo "${GREEN}║${NC}                ${BOLD}🎉 EXERCISE 9 COMPLETE! 🎉${NC}                     ${GREEN}║${NC}"
echo "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "${BOLD}Excellent work!${NC} You've mastered the 'find' command."
echo ""
echo "${BOLD}'find' Tests You Discovered:${NC}"
echo "  ✓ ${BOLD}-name${NC}: Find files by exact name (wildcards must be quoted)."
echo "  ✓ ${BOLD}-type${NC}: Filter by type ('f' for file, 'd' for directory)."
echo "  ✓ ${BOLD}-o${NC}: An 'OR' condition to combine tests."
echo ""
echo "${BOLD}'find' Actions You Discovered:${NC}"
echo "  ✓ ${BOLD}-exec cmd {} \\;${NC}: Execute an arbitrary command on each found file."
echo "  ✓ ${BOLD}-delete${NC}: A built-in action to safely and efficiently delete found files."
echo ""
echo "${BOLD}Next Exercise:${NC}"
echo "  Exercise 10 will dive into advanced Bash features."
echo ""
echo "${GREEN}Run:${NC} cd ~/devops-progress/2-linux/exercises && ./ex10-advanced-bash.sh"
echo ""
