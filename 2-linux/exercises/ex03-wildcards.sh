#!/bin/bash

# Interactive Tutorial: Exercise 3 - Wildcards
# Master pattern matching with *, ?, and [abc] by solving problems

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

WORK_DIR="$HOME/linux-exercises/ex03"
# Clean up previous runs
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

TASKS_COMPLETED=0
TOTAL_TASKS=6

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


# Setup test files
mkdir -p Dir Folder
touch Dir/{file1,file2,file3,file_a,file_b}.txt
touch Dir/{data1,data2}.csv
touch Dir/{script1,script2}.sh
touch Dir/{my_file,your_file,their_file}.log
touch Dir/{readme,README,ReadMe}.md
touch Folder/{config10,backup10,config.bak}
touch Folder/{test20,prod20,test.tmp}

clear

echo "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo "${BLUE}║${NC}      ${BOLD}Exercise 3: Wildcards - Interactive Tutorial${NC}            ${BLUE}║${NC}"
echo "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "${GREEN}Welcome!${NC} In this exercise, you'll discover pattern matching by solving challenges."
echo "The shell can expand special characters (wildcards) to match filenames."
echo ""
echo "${BOLD}How this works:${NC}"
echo "  • Each task gives you a goal."
echo "  • You must figure out the correct pattern to achieve it."
echo "  • Type ${CYAN}'hint'${NC} if you need help."
echo ""
echo "Working directory: ${YELLOW}$WORK_DIR${NC}"
echo ""
read -p "Press Enter to begin..."

clear

# ============================================================
# TASK 1: The 'Match Everything' Wildcard
# ============================================================

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 1/$TOTAL_TASKS: Matching File Extensions${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  The 'Dir/' directory is full of different file types (.txt, .csv, .sh, .log, .md)."
echo "  You ONLY want to see the files that end with the '.txt' extension."
echo ""
echo "Files in Dir/:"
ls Dir/ | sort | xargs
echo ""
echo "${BOLD}YOUR GOAL:${NC} Use 'ls' with a wildcard to list ONLY the files ending with .txt in the 'Dir/' directory."
echo ""
echo "Type ${CYAN}'hint'${NC} for help, or try a command:"
echo ""

hint_count=0
while true; do
    read -p "> " user_cmd

    if [[ "$user_cmd" == "hint" ]]; then
        hint_count=$((hint_count + 1))
        case $hint_count in
            1) echo "${CYAN}HINT 1:${NC} There is a special character '*' that matches any number of characters.";;
            2) echo "${CYAN}HINT 2:${NC} You can use it like this: 'ls Dir/*.txt'";;
        esac
    elif handle_help "$user_cmd" "ls"; then
        continue
    elif [[ "$user_cmd" =~ ^ls.*Dir/?\*\.txt ]]; then
        output=$(eval "$user_cmd" 2>&1)
        if echo "$output" | grep -q "\.txt" && ! echo "$output" | grep -qE "\.(csv|sh|log|md)"; then
            echo ""
            eval "$user_cmd"
            echo ""
            echo "${GREEN}✓ Perfect!${NC} You isolated the .txt files."
            TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
            echo ""
            read -p "Press Enter to continue..."
            break
        else
            echo "${YELLOW}Not quite. Your command should only list files ending in .txt.${NC}"
        fi
    elif [[ "$user_cmd" =~ ^ls.*Dir ]]; then
        echo "${YELLOW}You're listing the directory. Now, how can you filter that list to show only files ending in .txt?${NC}"
    else
        echo "${YELLOW}Use the 'ls' command and a wildcard pattern. Type 'hint' if you need help.${NC}"
    fi
done

clear

# ============================================================
# TASK 2: Matching Specific Characters
# ============================================================

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 2/$TOTAL_TASKS: Matching a Set of Characters${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  You want to find all log files, but they have different names: "
echo "  'my_file.log', 'your_file.log', 'their_file.log'."
echo "  You need a pattern that matches files starting with 'm', 'y', or 't'."
echo ""
echo "Relevant files in Dir/:"
ls -1 Dir/ | grep "file.log"
echo ""
echo "${BOLD}YOUR GOAL:${NC} List all files from 'Dir/' that start with either 'm', 'y', or 't' and end in '.log'."
echo ""
echo "Type ${CYAN}'hint'${NC} for help, or try a command:"
echo ""

hint_count=0
while true; do
    read -p "> " user_cmd

    if [[ "$user_cmd" == "hint" ]]; then
        hint_count=$((hint_count + 1))
        case $hint_count in
            1) echo "${CYAN}HINT 1:${NC} You can use square brackets [] to define a set of characters to match. For example, '[ab]*.txt' would match 'a.txt' and 'b.txt'.";;
            2) echo "${CYAN}HINT 2:${NC} You need to match 'm', 'y', or 't' at the beginning.";;
            3) echo "${CYAN}HINT 3:${NC} Try: ls Dir/[myt]*.log";;
        esac
    elif handle_help "$user_cmd" "ls"; then
        continue
    elif [[ "$user_cmd" =~ ^ls.*Dir/?\[.*m.*y.*t.*\].*\.log ]]; then
        output=$(eval "$user_cmd" 2>&1)
        if echo "$output" | grep -q "my_file.log" && echo "$output" | grep -q "your_file.log" && echo "$output" | grep -q "their_file.log"; then
            echo ""
            eval "$user_cmd"
            echo ""
            echo "${GREEN}✓ Excellent!${NC} You matched the specific set of files."
            TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
            echo ""
            read -p "Press Enter to continue..."
            break
        else
            echo "${YELLOW}Your pattern didn't match all three log files. It must start with m, y, or t.${NC}"
        fi
    elif [[ "$user_cmd" =~ ^ls.*Dir ]]; then
        echo "${YELLOW}You're listing the directory. Use a character set [...] to match the first letter.${NC}"
    else
        echo "${YELLOW}Use 'ls'. You'll need a wildcard that matches a specific set of characters. Type 'hint' if stuck.${NC}"
    fi
done

clear

# ============================================================
# TASK 3: Matching a Single Character
# ============================================================

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 3/$TOTAL_TASKS: Matching a Single Character${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  You have files named 'file1.txt', 'file2.txt', and 'file_a.txt'. "
echo "  You want to match files that start with 'file', are followed by exactly ONE"
echo "  character, and end with '.txt'."
echo "  A pattern like 'file*.txt' is too broad, as it would also match 'file_long_name.txt'."
echo ""
echo "Files in Dir/:"
ls -1 Dir/ | grep "file"
echo ""
echo "${BOLD}YOUR GOAL:${NC} List files that match the pattern 'file<ANY_SINGLE_CHAR>.txt'."
echo ""
echo "Type ${CYAN}'hint'${NC} for help, or try a command:"
echo ""

hint_count=0
while true; do
    read -p "> " user_cmd

    if [[ "$user_cmd" == "hint" ]]; then
        hint_count=$((hint_count + 1))
        case $hint_count in
            1) echo "${CYAN}HINT 1:${NC} There is a wildcard character that matches exactly one character. It's not '*'." ;;
            2) echo "${CYAN}HINT 2:${NC} The wildcard is the question mark, '?'." ;;
            3) echo "${CYAN}HINT 3:${NC} Try: ls Dir/file?.txt";;
        esac
    elif handle_help "$user_cmd" "ls"; then
        continue
    elif [[ "$user_cmd" =~ ^ls.*Dir/?file\?\.txt ]]; then
        output=$(eval "$user_cmd" 2>&1)
        if echo "$output" | grep -q "file1.txt" && echo "$output" | grep -q "file_a.txt"; then
             echo ""
            eval "$user_cmd"
            echo ""
            echo "${GREEN}✓ Great!${NC} You matched files with exactly one character difference."
            TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
            echo ""
            read -p "Press Enter to continue..."
            break
        else
            echo "${YELLOW}Your pattern isn't quite right. It should match 'file' plus one character, then '.txt'.${NC}"
        fi
    elif [[ "$user_cmd" =~ ^ls.*Dir.*file ]]; then
        echo "${YELLOW}You're on the right track. You need a wildcard for a *single* character, not many.${NC}"
    else
        echo "${YELLOW}Use 'ls'. You need a wildcard that matches exactly one character. Type 'hint' if stuck.${NC}"
    fi
done

clear

# ============================================================
# TASK 4: Combining Wildcards
# ============================================================

mkdir -p output_dir

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 4/$TOTAL_TASKS: Combining Wildcards for Complex Patterns${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  You need to copy all configuration files from 'Folder/' to 'output_dir/'."
echo "  The configuration files are named 'config10', 'backup10', 'config.bak'."
echo "  Essentially, you want any file that CONTAINS the number '10' OR has the '.bak' extension."
echo ""
echo "Files in Folder/:"
ls -1 Folder/
echo ""
echo "${BOLD}YOUR GOAL:${NC} Use a single 'cp' command to copy 'config10', 'backup10', and 'config.bak' to 'output_dir/'."
echo ""
echo "Type ${CYAN}'hint'${NC} for help, or try a command:"
echo ""

hint_count=0
while true; do
    read -p "> " user_cmd

    if [[ "$user_cmd" == "hint" ]]; then
        hint_count=$((hint_count + 1))
        case $hint_count in
            1) echo "${CYAN}HINT 1:${NC} You can give a command multiple patterns at once. For example 'ls *.txt *.csv'.";;
            2) echo "${CYAN}HINT 2:${NC} You need one pattern for files containing '10' and another for files ending in '.bak'.";;
            3) echo "${CYAN}HINT 3:${NC} Try: cp Folder/*10 Folder/*.bak output_dir/";;
        esac
    elif handle_help "$user_cmd" "cp"; then
        continue
    elif [[ "$user_cmd" =~ ^cp.*Folder/.*10.*Folder/.*\.bak.*output_dir ]] || [[ "$user_cmd" =~ ^cp.*Folder/.*\.bak.*Folder/.*10.*output_dir ]]; then
        if eval "$user_cmd" &>/dev/null; then
            count=$(ls output_dir/ 2>/dev/null | wc -l)
            if [ -f "output_dir/config10" ] && [ -f "output_dir/backup10" ] && [ -f "output_dir/config.bak" ] && [ "$count" -eq 3 ]; then
                echo ""
                echo "${GREEN}✓ Perfect!${NC} You copied files using multiple patterns."
                ls -1 output_dir/
                TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
                echo ""
                read -p "Press Enter to continue..."
                break
            else
                echo "${YELLOW}The files weren't copied correctly. Check that you have two patterns: one for '*10' and one for '*.bak'.${NC}"
            fi
        else
            echo "${RED}That command had an error. Check your syntax and paths.${NC}"
        fi
    elif [[ "$user_cmd" =~ ^cp.*Folder ]]; then
        echo "${YELLOW}You're using 'cp' correctly. Now you need to provide the two different patterns to match the required files.${NC}"
    else
        echo "${YELLOW}Use the 'cp' command. You'll need multiple wildcard patterns. Type 'hint' if you need help.${NC}"
    fi
done

clear

# ============================================================
# TASK 5: Case-Insensitive Matching
# ============================================================

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 5/$TOTAL_TASKS: Case-Insensitive Matching${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  Someone created README files but was inconsistent with the capitalization."
echo "  You have 'readme.md', 'README.md', and 'ReadMe.md'."
echo ""
echo "Files in Dir/:"
ls -1 Dir/ | grep -i "readme"
echo ""
echo "${BOLD}YOUR GOAL:${NC} List all three 'readme' files from 'Dir/' with a single 'ls' command, regardless of case."
echo ""
echo "Type ${CYAN}'hint'${NC} for help, or try a command:"
echo ""

hint_count=0
while true; do
    read -p "> " user_cmd

    if [[ "$user_cmd" == "hint" ]]; then
        hint_count=$((hint_count + 1))
        case $hint_count in
            1) echo "${CYAN}HINT 1:${NC} You can use character sets for each letter. For example: '[Rr]eadme.md'.";;
            2) echo "${CYAN}HINT 2:${NC} A more elegant way is to use a range inside the brackets that includes both upper and lower case.";;
            3) echo "${CYAN}HINT 3:${NC} Try: ls Dir/[Rr][Ee][Aa][Dd][Mm][Ee].md";;
        esac
    elif handle_help "$user_cmd" "ls"; then
        continue
    elif [[ "$user_cmd" =~ ^ls.*Dir/?\[.*R.*r.*\].*\[.*E.*e.*\].*md ]]; then
        output=$(eval "$user_cmd" 2>&1)
        count=$(echo "$output" | wc -w)
        if [ "$count" -ge 3 ]; then
            echo ""
            eval "$user_cmd"
            echo ""
            echo "${GREEN}✓ Excellent!${NC} You matched all case variations."
            TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
            echo ""
            read -p "Press Enter to continue..."
            break
        else
            echo "${YELLOW}Your pattern should match all three variations of the readme file. Did you account for all letters?${NC}"
        fi
    elif [[ "$user_cmd" =~ ^ls.*Dir ]]; then
        echo "${YELLOW}You're on the right track. How can you make a pattern that matches 'R' or 'r', then 'E' or 'e', and so on?${NC}"
    else
        echo "${YELLOW}Use 'ls' with a character set pattern for each letter of the filename. Type 'hint' if stuck.${NC}"
    fi
done

clear

# ============================================================
# TASK 6: Challenge - Complex Cleanup
# ============================================================

mkdir -p challenge_dir
touch challenge_dir/{log,err,out}.tmp
touch challenge_dir/{data,info,meta}.log
touch challenge_dir/final_report.txt

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 6/$TOTAL_TASKS: CHALLENGE - Clean Up Unwanted Files${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  The 'challenge_dir' is cluttered with temporary (.tmp) and log (.log) files."
echo "  You need to delete ALL files with the '.tmp' or '.log' extension, but leave"
echo "  'final_report.txt' untouched."
echo ""
echo "Files in challenge_dir/:"
ls -1 challenge_dir/
echo ""
echo "${BOLD}YOUR GOAL:${NC} In a single command, remove all '.tmp' and '.log' files from 'challenge_dir/'."
echo ""
echo "${CYAN}This is a destructive operation! Combine your knowledge carefully.${NC}"
echo ""

hint_count=0
while true; do
    read -p "> " user_cmd

    if [[ "$user_cmd" == "hint" ]]; then
        hint_count=$((hint_count + 1))
        case $hint_count in
            1) echo "${CYAN}HINT 1:${NC} You can use brace expansion '{...}' to create multiple patterns from a single expression.";;
            2) echo "${CYAN}HINT 2:${NC} The pattern '*.{log,tmp}' will expand to '*.log' and '*.tmp'.";;
            3) echo "${CYAN}HINT 3:${NC} Try: rm challenge_dir/*.{log,tmp}";;
        esac
    elif handle_help "$user_cmd" "rm"; then
        continue
    elif [[ "$user_cmd" =~ ^rm.*challenge_dir/.*\.(log|tmp) ]] || [[ "$user_cmd" =~ ^rm.*challenge_dir/.*\{.*log.*tmp.*\} ]]; then
        (eval "$user_cmd")
        remaining=$(ls challenge_dir/ 2>/dev/null)
        if [[ "$remaining" == "final_report.txt" ]]; then
            echo ""
            echo "${GREEN}✓ OUTSTANDING!${NC} You cleaned the directory perfectly!"
            echo "Remaining file in challenge_dir/:"
            ls challenge_dir/
            TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
            echo ""
            read -p "Press Enter to continue..."
            break
        else
            echo "${YELLOW}Some files were left behind or too many were deleted. Your command should only remove .log and .tmp files.${NC}"
            rm -f challenge_dir/*
            touch challenge_dir/{log,err,out}.tmp challenge_dir/{data,info,meta}.log challenge_dir/final_report.txt
        fi
    elif [[ "$user_cmd" =~ ^rm ]]; then
        echo "${YELLOW}You're using the right command. How can you specify multiple extensions to delete?${NC}"
    else
        echo "${YELLOW}Use the 'rm' command. You'll need a way to match multiple different extensions. Type 'hint' if stuck.${NC}"
    fi
done

clear

# ============================================================
# COMPLETION
# ============================================================

cd ..
rm -rf "$WORK_DIR"

echo "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo "${GREEN}║${NC}                ${BOLD}🎉 EXERCISE 3 COMPLETE! 🎉${NC}                     ${GREEN}║${NC}"
echo "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "${BOLD}Outstanding work!${NC} You completed all $TASKS_COMPLETED/$TOTAL_TASKS tasks."
echo ""
echo "${BOLD}Wildcards You Discovered:${NC}"
echo "  ✓ ${BOLD}*${NC}        - Matches any number of characters (the 'everything' wildcard)."
echo "  ✓ ${BOLD}?${NC}        - Matches exactly one of any character."
echo "  ✓ ${BOLD}[abc]${NC}    - Matches a single character: 'a', 'b', or 'c'."
echo "  ✓ ${BOLD}[a-z]${NC}    - Matches any single character in a range."
echo "  ✓ ${BOLD}{a,b}${NC}     - Brace Expansion: Creates multiple patterns from one expression (e.g., *.{txt,log})."
echo ""
echo "${BOLD}Next Exercise:${NC}"
echo "  Exercise 4 will challenge you to understand and manage Linux file permissions."
echo ""
echo "${GREEN}Run:${NC} cd ~/devops-progress/2-linux/exercises && ./ex04-permissions.sh"
echo ""
