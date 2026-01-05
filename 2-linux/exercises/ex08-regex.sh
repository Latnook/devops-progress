#!/bin/bash

# Interactive Tutorial: Exercise 8 - Regular Expressions (Regex)
# Master advanced text matching with regex patterns

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

WORK_DIR="$HOME/linux-exercises/ex08"
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

# Setup test file
cat > "logs.txt" << EOF
[INFO] Request processed successfully.
[ERROR] Failed to connect to database.
[INFO] User logged in.
[DEBUG] Caching data for user_id: 123.
[WARN] Disk space is running low.
[ERROR] Null pointer exception at line 42.
EOF

clear

echo "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo "${BLUE}║${NC}     ${BOLD}Exercise 8: Regular Expressions - Interactive Tutorial${NC}     ${BLUE}║${NC}"
echo "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "${GREEN}Welcome!${NC} You'll now learn Regular Expressions (regex), a powerful way to describe"
echo "and match complex text patterns. You'll use them with 'grep'."
echo ""
echo "${BOLD}How this works:${NC}"
echo "  • Each task requires you to write a regex pattern to find specific lines."
echo "  • We'll be using the 'grep' command to apply these patterns."
echo "  • Type ${CYAN}'hint'${NC} if you get stuck."
echo ""
echo "We'll be working with this 'logs.txt' file:"
cat logs.txt
echo ""
read -p "Press Enter to begin..."

clear

# ============================================================
# TASK 1: Matching the Start of a Line
# ============================================================

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 1/$TOTAL_TASKS: Anchoring to the Start of a Line${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  You need to find all the log entries that are of the 'INFO' level."
echo "  A simple 'grep INFO' would also match a line that contained the word 'INFORMATION',"
echo "  which is not what you want. You need to match only the lines that *start with* '[INFO]'."
echo ""
echo "${BOLD}YOUR GOAL:${NC} Use 'grep' with a regex pattern to find all lines in 'logs.txt' that begin with the literal text '[INFO]'."
echo ""
echo "Type ${CYAN}'hint'${NC} for help, or try a command:"
echo ""

hint_count=0
while true; do
    read -p "> " user_cmd

    if [[ "$user_cmd" == "hint" ]]; then
        hint_count=$((hint_count + 1))
        case $hint_count in
            1) echo "${CYAN}HINT 1:${NC} In regex, the caret symbol '^' is an 'anchor' that matches the beginning of a line.";;
            2) echo "${CYAN}HINT 2:${NC} You need to put the anchor before the text you want to match at the start.";;
            3) echo "${CYAN}HINT 3:${NC} Try: grep '^[INFO]' logs.txt";;
        esac
    elif handle_help "$user_cmd" "grep"; then
        continue
    elif [[ "$user_cmd" == *"grep"* && "$user_cmd" == *"^"* && "$user_cmd" == *"[INFO]"* && "$user_cmd" == *"logs.txt"* ]]; then
        output=$(eval "$user_cmd" 2>/dev/null)
        line_count=$(echo "$output" | wc -l)
        if [ "$line_count" -eq 2 ] && echo "$output" | grep -q "Request" && echo "$output" | grep -q "logged in"; then
            echo ""
            echo "${GREEN}✓ Success!${NC} You've anchored your search to the start of the line."
            echo "Your output:"
            echo "${CYAN}$output${NC}"
            TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
            echo ""
            read -p "Press Enter to continue..."
            break
        else
            echo "${RED}That didn't produce the correct output. It should only show the two lines that start with '[INFO]'.${NC}"
        fi
    else
        echo "${YELLOW}Use 'grep' with a pattern. You need a special character to match the start of the line. Type 'hint' if you need help.${NC}"
    fi
done

clear

# ============================================================
# TASK 2: Matching the End of a Line
# ============================================================

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 2/$TOTAL_TASKS: Anchoring to the End of a Line${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  Some log entries end with a period '.', indicating a complete sentence."
echo "  You need to find all of these 'complete' log entries."
echo ""
echo "${BOLD}YOUR GOAL:${NC} Use 'grep' to find all lines in 'logs.txt' that *end with* a period '.'."
echo ""
echo "Type ${CYAN}'hint'${NC} for help, or try a command:"
echo ""

hint_count=0
while true; do
    read -p "> " user_cmd

    if [[ "$user_cmd" == "hint" ]]; then
        hint_count=$((hint_count + 1))
        case $hint_count in
            1) echo "${CYAN}HINT 1:${NC} Just as '^' anchors to the start, the dollar sign '$' anchors to the end of a line.";;
            2) echo "${CYAN}HINT 2:${NC} The '.' is also a regex metacharacter (meaning 'any character'). To match a literal dot, you must 'escape' it with a backslash: '\.'." ;;
            3) echo "${CYAN}HINT 3:${NC} Combine them: grep '\.$' logs.txt";;
        esac
    elif handle_help "$user_cmd" "grep"; then
        continue
    elif [[ "$user_cmd" == *"grep"* && "$user_cmd" == *"\."* && "$user_cmd" == *"\$"* && "$user_cmd" == *"logs.txt"* ]]; then
        output=$(eval "$user_cmd" 2>/dev/null)
        line_count=$(echo "$output" | wc -l)
        if [ "$line_count" -eq 4 ]; then
            echo ""
            echo "${GREEN}✓ Perfect!${NC} You've anchored your search to the end."
            echo "Your output:"
            echo "${CYAN}$output${NC}"
            TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
            echo ""
            read -p "Press Enter to continue..."
            break
        else
            echo "${RED}The output isn't quite right. It should show the 4 lines that end with a period.${NC}"
        fi
    else
        echo "${YELLOW}Use 'grep' with a pattern. You need an anchor for the end of the line and a way to match a literal dot. Type 'hint' if stuck.${NC}"
    fi
done

clear

# ============================================================
# TASK 3: Character Classes
# ============================================================

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 3/$TOTAL_TASKS: Matching a Set of Characters${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  You need to find all critical and semi-critical log entries, which are"
echo "  'ERROR' and 'WARN'."
echo ""
echo "${BOLD}YOUR GOAL:${NC} Use a single 'grep' command to find all lines that start with either '[ERROR]' or '[WARN]'."
echo ""
echo "Type ${CYAN}'hint'${NC} for help, or try a command:"
echo ""

hint_count=0
while true; do
    read -p "> " user_cmd

    if [[ "$user_cmd" == "hint" ]]; then
        hint_count=$((hint_count + 1))
        case $hint_count in
            1) echo "${CYAN}HINT 1:${NC} You can use square brackets '[]' to define a 'character class'. For example, 'gr[ae]y' matches 'gray' and 'grey'.";;
            2) echo "${CYAN}HINT 2:${NC} You can apply this to a whole word. 'grep -E '^(ERROR|WARN)'' is the common way to do this.";;
            3) echo "${CYAN}HINT 3:${NC} Try using 'grep -E' for extended regex: grep -E '^\[(ERROR|WARN)\]' logs.txt ";;
        esac
    elif handle_help "$user_cmd" "grep"; then
        continue
    elif [[ "$user_cmd" == *"grep"* && ("$user_cmd" == *"ERROR|WARN"* || "$user_cmd" == *"WARN|ERROR"*) && "$user_cmd" == *"logs.txt"* ]]; then
        if [[ ! "$user_cmd" == *"-E"* ]]; then
            echo "${YELLOW}Almost! The '|' (OR) operator requires extended regex. Try adding the '-E' flag to your grep command.${NC}"
            continue
        fi
        output=$(eval "$user_cmd" 2>/dev/null)
        line_count=$(echo "$output" | wc -l)
        if [ "$line_count" -eq 3 ] && echo "$output" | grep -q "ERROR" && echo "$output" | grep -q "WARN"; then
            echo ""
            echo "${GREEN}✓ Success!${NC} You've matched multiple patterns at once."
            echo "Your output:"
            echo "${CYAN}$output${NC}"
            TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
            echo ""
            read -p "Press Enter to continue..."
            break
        else
            echo "${RED}That's not quite right. The output should be the three ERROR and WARN lines.${NC}"
        fi
    else
        echo "${YELLOW}You need to use 'grep' to find lines matching one of two words. Type 'hint' if you get stuck.${NC}"
    fi
done

clear

# ============================================================
# TASK 4: Challenge - Matching a Complex Pattern
# ============================================================

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 4/$TOTAL_TASKS: CHALLENGE - Finding a Number${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  You need to find any log entry that contains a number. Specifically, you're"
echo "  looking for the lines containing 'user_id: 123' and 'line 42'."
echo ""
echo "${BOLD}YOUR GOAL:${NC} Write a regex that finds any line containing one or more digits (0-9)."
echo ""
echo "Type ${CYAN}'hint'${NC} for help, or try a command:"
echo ""

hint_count=0
while true; do
    read -p "> " user_cmd

    if [[ "$user_cmd" == "hint" ]]; then
        hint_count=$((hint_count + 1))
        case $hint_count in
            1) echo "${CYAN}HINT 1:${NC} You can use a character class to define a range of characters, like '[a-z]' for any lowercase letter.";;
            2) echo "${CYAN}HINT 2:${NC} The character class for any digit is '[0-9]'.";;
            3) echo "${CYAN}HINT 3:${NC} Try: grep '[0-9]' logs.txt";;
        esac
    elif handle_help "$user_cmd" "grep"; then
        continue
    elif [[ "$user_cmd" == *"grep"* && "$user_cmd" == *"[0-9]"* && "$user_cmd" == *"logs.txt"* ]]; then
        output=$(eval "$user_cmd" 2>/dev/null)
        line_count=$(echo "$output" | wc -l)
        if [ "$line_count" -eq 2 ] && echo "$output" | grep -q "user_id: 123" && echo "$output" | grep -q "line 42"; then
            echo ""
            echo "${GREEN}✓ OUTSTANDING!${NC} You've found the lines with numbers."
            echo "Your output:"
            echo "${CYAN}$output${NC}"
            TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
            echo ""
            read -p "Press Enter to continue..."
            break
        else
            echo "${RED}Not quite. The output should be the two lines that contain numbers.${NC}"
        fi
    else
        echo "${YELLOW}Use 'grep'. You need a pattern that matches any digit from 0 to 9. Type 'hint' if you're stuck.${NC}"
    fi
done

clear

# ============================================================
# COMPLETION
# ============================================================

cd ..
rm -rf "$WORK_DIR"

echo "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo "${GREEN}║${NC}                ${BOLD}🎉 EXERCISE 8 COMPLETE! 🎉${NC}                     ${GREEN}║${NC}"
echo "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "${BOLD}Fantastic work!${NC} You've completed the regex challenges."
echo ""
echo "${BOLD}Regex Concepts You Discovered:${NC}"
echo "  ✓ ${BOLD}^${NC}         - Anchor: Matches the start of a line."
echo "  ✓ ${BOLD}\$${NC}        - Anchor: Matches the end of a line."
echo "  ✓ ${BOLD}\\.${NC}       - Escaping: Matching a literal character that has a special meaning."
echo "  ✓ ${BOLD}|${NC}         - OR (in extended mode '-E'): Matches the pattern on its left OR its right."
echo "  ✓ ${BOLD}[0-9]${NC}    - Character Class: Matches any single character within the set or range."
echo ""
echo "${BOLD}Next Exercise:${NC}"
echo "  Exercise 9 will challenge you to find files based on complex criteria using the 'find' command."
echo ""
echo "${GREEN}Run:${NC} cd ~/devops-progress/2-linux/exercises && ./ex09-find.sh"
echo ""
