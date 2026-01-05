#!/bin/bash

# Interactive Tutorial: Exercise 2 - Filesystem Commands
# Learn essential directory and file operations

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
    # Fallback to no colors if tput not available
    GREEN=""
    BLUE=""
    YELLOW=""
    RED=""
    CYAN=""
    BOLD=""
    NC=""
fi

WORK_DIR="$HOME/linux-exercises/ex02"
# Clean up previous runs
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

TASKS_COMPLETED=0
TOTAL_TASKS=7

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

clear

echo "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo "${BLUE}║${NC}   ${BOLD}Exercise 2: Filesystem Commands - Interactive Tutorial${NC}      ${BLUE}║${NC}"
echo "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "${GREEN}Welcome!${NC} You'll master filesystem operations by solving real challenges."
echo "This time, there are no instructions. Use your knowledge from Exercise 1!"
echo ""
echo "${BOLD}How this works:${NC}"
echo "  • Each task presents a real scenario."
echo "  • Figure out the command to solve it. Use '--help' or 'man'!"
echo "  • Type ${CYAN}'hint'${NC} if you're truly stuck."
echo "  • We check if you achieved the goal."
echo ""
echo "Working directory: ${YELLOW}$WORK_DIR${NC}"
echo ""
read -p "Press Enter to begin..."

clear

# ============================================================
# TASK 1: Creating Directories
# ============================================================

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 1/$TOTAL_TASKS: Creating a Directory${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  You need a place to store your important documents."
echo ""
echo "${BOLD}YOUR GOAL:${NC} Create a directory in your current location named 'documents'."
echo ""
echo "Type ${CYAN}'hint'${NC} for help, or try a command:"
echo ""

hint_count=0
while true; do
    read -p "> " user_cmd

    if [[ "$user_cmd" == "hint" ]]; then
        hint_count=$((hint_count + 1))
        case $hint_count in
            1) echo "${CYAN}HINT 1:${NC} What command would you use to 'make' a directory?";;
            2) echo "${CYAN}HINT 2:${NC} The command is 'mkdir'.";;
            3) echo "${CYAN}HINT 3:${NC} Try: mkdir documents";;
        esac
    elif handle_help "$user_cmd" "mkdir"; then
        continue
    elif [[ "$user_cmd" =~ ^mkdir.*documents ]]; then
        if eval "$user_cmd" &>/dev/null; then
            if [ -d "documents" ]; then
                echo ""
                echo "${GREEN}✓ Success!${NC} You created the 'documents' directory."
                ls -ld documents
                TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
                echo ""
                read -p "Press Enter to continue..."
                break
            fi
        else
            echo "${RED}That command had an error. Try again!${NC}"
        fi
    elif [[ "$user_cmd" =~ ^mkdir ]]; then
        echo "${YELLOW}Correct command, but you need to name the directory 'documents'.${NC}"
    else
        echo "${YELLOW}Not quite. What command makes a new directory? Type 'hint' if you need help.${NC}"
    fi
done

clear

# ============================================================
# TASK 2: Creating Nested Directories
# ============================================================

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 2/$TOTAL_TASKS: Creating a Deep Directory Structure${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  You're starting a new software project and need a standard directory layout."
echo "  The structure needs to be 'project/src/main', but the 'project' and 'src'"
echo "  directories don't exist yet."
echo ""
echo "${BOLD}YOUR GOAL:${NC} Create the entire nested directory structure 'project/src/main' with a single command."
echo ""
echo "Type ${CYAN}'hint'${NC} for help, or try a command:"
echo ""

hint_count=0
while true; do
    read -p "> " user_cmd

    if [[ "$user_cmd" == "hint" ]]; then
        hint_count=$((hint_count + 1))
        case $hint_count in
            1) echo "${CYAN}HINT 1:${NC} A normal 'mkdir' will fail. Check its '--help' or 'man' page for an option to create 'parent' directories automatically.";;
            2) echo "${CYAN}HINT 2:${NC} The option is '-p'.";;
            3) echo "${CYAN}HINT 3:${NC} Try: mkdir -p project/src/main";;
        esac
    elif handle_help "$user_cmd" "mkdir"; then
        continue
    elif [[ "$user_cmd" =~ ^mkdir.*-p.*project/src/main ]] || [[ "$user_cmd" =~ ^mkdir.*project/src/main.*-p ]]; then
        if eval "$user_cmd" &>/dev/null; then
            if [ -d "project/src/main" ]; then
                echo ""
                echo "${GREEN}✓ Excellent!${NC} You created the nested structure in one step."
                ls -lR project
                TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
                echo ""
                read -p "Press Enter to continue..."
                break
            fi
        else
            echo "${RED}That command had an error. Try again!${NC}"
        fi
    elif [[ "$user_cmd" =~ ^mkdir.*project ]]; then
        echo "${YELLOW}Good start, but that will fail because the parent directories don't exist. You need a special option for that.${NC}"
    else
        echo "${YELLOW}Use 'mkdir'. You'll need to find an option to handle the missing parent directories. Type 'hint' if stuck.${NC}"
    fi
done

clear

# ============================================================
# TASK 3: Creating Files
# ============================================================

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 3/$TOTAL_TASKS: Creating an Empty File${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  Your new project needs a README file. You don't need to write anything in it yet,"
echo "  but the file itself must exist."
echo ""
echo "${BOLD}YOUR GOAL:${NC} Create a single, empty file named 'README.md' inside the 'project' directory."
echo ""
echo "Type ${CYAN}'hint'${NC} for help, or try a command:"
echo ""

hint_count=0
while true; do
    read -p "> " user_cmd

    if [[ "$user_cmd" == "hint" ]]; then
        hint_count=$((hint_count + 1))
        case $hint_count in
            1) echo "${CYAN}HINT 1:${NC} There's a command that can 'touch' a file into existence.";;
            2) echo "${CYAN}HINT 2:${NC} The command is 'touch'.";;
            3) echo "${CYAN}HINT 3:${NC} Try: touch project/README.md";;
        esac
    elif handle_help "$user_cmd" "touch"; then
        continue
    elif [[ "$user_cmd" =~ ^touch.*project/README.md ]]; then
        if eval "$user_cmd" &>/dev/null; then
            if [ -f "project/README.md" ]; then
                echo ""
                echo "${GREEN}✓ Perfect!${NC} You created the empty file."
                ls -l project/README.md
                TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
                echo ""
                read -p "Press Enter to continue..."
                break
            fi
        else
            echo "${RED}That command had an error. Does the 'project' directory exist?${NC}"
        fi
    elif [[ "$user_cmd" =~ ^touch ]]; then
        echo "${YELLOW}Correct command. Now specify the correct path and filename.${NC}"
    else
        echo "${YELLOW}Not quite. What command creates a new, empty file? Type 'hint' if you need help.${NC}"
    fi
done

clear

# ============================================================
# TASK 4: Copying Files
# ============================================================

mkdir -p source_files backup_files
touch source_files/report-2024-01.txt source_files/report-2024-02.txt source_files/archive.zip

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 4/$TOTAL_TASKS: Copying Multiple Files${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  You have several report files in the 'source_files' directory. You need to"
echo "  make a backup of all the reports (but not other file types) into the"
echo "  'backup_files' directory."
echo ""
echo "Current files in 'source_files/':"
ls -1 source_files/
echo ""
echo "${BOLD}YOUR GOAL:${NC} Copy ONLY the .txt files from 'source_files/' to 'backup_files/'."
echo ""
echo "Type ${CYAN}'hint'${NC} for help, or try a command:"
echo ""

hint_count=0
while true; do
    read -p "> " user_cmd

    if [[ "$user_cmd" == "hint" ]]; then
        hint_count=$((hint_count + 1))
        case $hint_count in
            1) echo "${CYAN}HINT 1:${NC} The command to 'copy' is 'cp'. You'll need a wildcard to select only the .txt files.";;
            2) echo "${CYAN}HINT 2:${NC} A wildcard like '*.txt' matches any file ending with .txt.";;
            3) echo "${CYAN}HINT 3:${NC} Try: cp source_files/*.txt backup_files/";;
        esac
    elif handle_help "$user_cmd" "cp"; then
        continue
    elif [[ "$user_cmd" =~ ^cp ]]; then
        if [[ ! "$user_cmd" =~ [*] ]]; then
            echo "${YELLOW}You're on the right track with 'cp', but how can you select MULTIPLE files at once?${NC}"
            continue
        fi
        if eval "$user_cmd" &>/dev/null; then
            txt_count=$(find backup_files/ -name "*.txt" -type f 2>/dev/null | wc -l)
            zip_count=$(find backup_files/ -name "*.zip" -type f 2>/dev/null | wc -l)
            if [ "$txt_count" -ge 2 ] && [ "$zip_count" -eq 0 ]; then
                echo ""
                echo "${GREEN}✓ Great work!${NC} Only the report files were copied."
                ls -1 backup_files/
                TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
                echo ""
                read -p "Press Enter to continue..."
                break
            elif [ "$txt_count" -lt 2 ]; then
                 echo "${YELLOW}It seems the .txt files didn't get copied. Check your source path and pattern.${NC}"
            else
                 echo "${YELLOW}You copied the text files, but you also copied other files. The goal is to only copy .txt files.${NC}"
            fi
        else
            echo "${RED}That command had an error. Check your paths and syntax.${NC}"
        fi
    else
        echo "${YELLOW}What command is used for copying files? Type 'hint' if stuck.${NC}"
    fi
done

clear

# ============================================================
# TASK 5: Moving and Renaming Files
# ============================================================

touch temporary_file.log

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 5/$TOTAL_TASKS: Moving and Renaming${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  You created a file named 'temporary_file.log', but it should have been named"
echo "  'final_report.log' and placed inside the 'documents' directory."
echo ""
echo "${BOLD}YOUR GOAL:${NC} Move 'temporary_file.log' to 'documents/' AND rename it to 'final_report.log' in a single command."
echo ""
echo "Type ${CYAN}'hint'${NC} for help, or try a command:"
echo ""

hint_count=0
while true; do
    read -p "> " user_cmd

    if [[ "$user_cmd" == "hint" ]]; then
        hint_count=$((hint_count + 1))
        case $hint_count in
            1) echo "${CYAN}HINT 1:${NC} The command to 'move' or rename is 'mv'.";;
            2) echo "${CYAN}HINT 2:${NC} The syntax is: mv <source> <destination_path/new_name>";;
            3) echo "${CYAN}HINT 3:${NC} Try: mv temporary_file.log documents/final_report.log";;
        esac
    elif handle_help "$user_cmd" "mv"; then
        continue
    elif [[ "$user_cmd" =~ ^mv ]]; then
        if eval "$user_cmd" &>/dev/null; then
            if [ -f "documents/final_report.log" ] && [ ! -f "temporary_file.log" ]; then
                echo ""
                echo "${GREEN}✓ Excellent!${NC} The file was moved and renamed."
                ls -1 documents/
                TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
                echo ""
                read -p "Press Enter to continue..."
                break
            elif [ -f "temporary_file.log" ]; then
                echo "${YELLOW}The original file still exists. 'mv' should remove the original.${NC}"
            else
                echo "${YELLOW}The file was moved, but not renamed correctly. Check the destination path.${NC}"
            fi
        else
            echo "${RED}That command had an error. Did you type the paths correctly?${NC}"
        fi
    else
        echo "${YELLOW}What command is used to move or rename files? Type 'hint' if help is needed.${NC}"
    fi
done

clear

# ============================================================
# TASK 6: Viewing File Contents
# ============================================================

echo "Line 1: CONFIG_START" > very_long_log.txt
for i in {2..99}; do echo "Line $i: Data..." >> very_long_log.txt; done
echo "Line 100: CONFIG_END" >> very_long_log.txt

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 6/$TOTAL_TASKS: Viewing Parts of Files${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  You have a very long log file, 'very_long_log.txt' (100 lines)."
echo "  Opening it in an editor would be slow. You only need to see the last few"
echo "  lines to check if the process finished correctly."
echo ""
echo "${BOLD}YOUR GOAL:${NC} Display only the last 3 lines of 'very_long_log.txt'."
echo ""
echo "Type ${CYAN}'hint'${NC} for help, or try a command:"
echo ""

hint_count=0
while true; do
    read -p "> " user_cmd

    if [[ "$user_cmd" == "hint" ]]; then
        hint_count=$((hint_count + 1))
        case $hint_count in
            1) echo "${CYAN}HINT 1:${NC} There are commands to see the 'head' (start) or 'tail' (end) of a file.";;
            2) echo "${CYAN}HINT 2:${NC} The 'tail' command is what you need. Check its help page for how to specify the number of lines.";;
            3) echo "${CYAN}HINT 3:${NC} Try: tail -n 3 very_long_log.txt";;
        esac
    elif handle_help "$user_cmd" "tail"; then
        continue
    elif [[ "$user_cmd" =~ ^tail.*very_long_log.txt ]]; then
        output=$(eval "$user_cmd" 2>&1)
        line_count=$(echo "$output" | wc -l)
        if [ "$line_count" -eq 3 ] && [[ "$output" == *"CONFIG_END"* ]]; then
            echo ""
            eval "$user_cmd"
            echo ""
            echo "${GREEN}✓ Perfect!${NC} You displayed the end of the file."
            TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
            echo ""
            read -p "Press Enter to continue..."
            break
        else
            echo "${YELLOW}You're using the right command, but you're not showing exactly 3 lines from the end. Check the options.${NC}"
        fi
    else
        echo "${YELLOW}What command would show you the 'tail end' of a file? Type 'hint' if stuck.${NC}"
    fi
done

clear

# ============================================================
# TASK 7: Challenge - Complete Cleanup
# ============================================================

mkdir -p stuff/nested_dir
touch stuff/important.dat stuff/nested_dir/other.txt a_file.tmp

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 7/$TOTAL_TASKS: CHALLENGE - Risky Removal${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  You are finished with this exercise and need to clean up."
echo "  You need to remove the 'stuff' directory and everything inside it."
echo "  However, a simple command won't work because it's not empty."
echo ""
echo "Current structure:"
ls -R
echo ""
echo "${BOLD}YOUR GOAL:${NC} Remove the 'stuff' directory and all its contents with one command."
echo ""
echo "${CYAN}Be careful! This is a destructive command. Get it wrong in the real world and you could wipe out important data.${NC}"
echo ""

hint_count=0
while true; do
    read -p "> " user_cmd

    if [[ "$user_cmd" == "hint" ]]; then
        hint_count=$((hint_count + 1))
        case $hint_count in
            1) echo "${CYAN}HINT 1:${NC} The command to 'remove' is 'rm'. It needs a special option to handle directories.";;
            2) echo "${CYAN}HINT 2:${NC} The option for 'recursive' deletion is '-r'. This tells it to delete a directory and everything in it.";;
            3) echo "${CYAN}HINT 3:${NC} Try: rm -r stuff";;
        esac
    elif handle_help "$user_cmd" "rm"; then
        continue
    elif [[ "$user_cmd" =~ ^rm.*r.*stuff ]]; then
        if eval "$user_cmd" &>/dev/null; then
            if [ ! -d "stuff" ]; then
                echo ""
                echo "${GREEN}✓ EXCELLENT!${NC} The directory was removed recursively."
                echo ""
                echo "Remaining items in directory:"
                ls -A1
                echo ""
                TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
                echo ""
                read -p "Press Enter to continue..."
                break
            fi
        else
            echo "${RED}That command had an error. Are you sure the directory was named 'stuff'?${NC}"
        fi
    elif [[ "$user_cmd" =~ ^rm.*stuff ]]; then
        echo "${YELLOW}Almost. 'rm stuff' fails on non-empty directories. You need an option to force it.${NC}"
    else
        echo "${YELLOW}Use the 'rm' command. You need to find the option that allows it to remove entire directories. Type 'hint' if stuck.${NC}"
    fi
done

clear

# ============================================================
# COMPLETION
# ============================================================

cd ..
rm -rf "$WORK_DIR"

echo "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo "${GREEN}║${NC}                ${BOLD}🎉 EXERCISE 2 COMPLETE! 🎉${NC}                     ${GREEN}║${NC}"
echo "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "${BOLD}Outstanding work!${NC} You completed all $TASKS_COMPLETED/$TOTAL_TASKS tasks."
echo ""
echo "${BOLD}Skills You Mastered by Discovery:${NC}"
echo "  ✓ Creating directories, including nested ones ('mkdir', '-p')"
echo "  ✓ Creating empty placeholder files ('touch')"
echo "  ✓ Copying files with patterns ('cp', '*')"
echo "  ✓ Moving AND renaming files in one step ('mv')"
echo "  ✓ Viewing the beginning or end of large files ('head', 'tail', '-n')"
echo "  ✓ Recursively and forcefully removing directories ('rm', '-r')"
echo ""
echo "${BOLD}Next Exercise:${NC}"
echo "  Exercise 3 will focus on mastering wildcards for powerful file selection."
echo ""
echo "${GREEN}Run:${NC} cd ~/devops-progress/2-linux/exercises && ./ex03-wildcards.sh"
echo ""
