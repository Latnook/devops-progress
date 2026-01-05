#!/bin/bash

# Interactive Tutorial: Exercise 7 - Pipes and Filters
# Learn to chain commands together to perform complex data processing

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

WORK_DIR="$HOME/linux-exercises/ex07"
# Clean up previous runs
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

TASKS_COMPLETED=0
TOTAL_TASKS=4

# Function to handle help commands
handle_help() {
    local cmd="$1"
    # Allow help for any of the commands used in this exercise
    for main_cmd in cat grep wc sort awk uniq; do
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
    done
    return 1
}


# Setup test files
cat > data.txt << EOF
INFO:user_id=101,action=login,status=success
WARN:user_id=102,action=login,status=failure
INFO:user_id=103,action=view_page,status=success
DEBUG:user_id=101,action=heartbeat,status=pending
INFO:user_id=102,action=logout,status=success
ERROR:user_id=104,action=delete,status=failure
WARN:user_id=101,action=edit,status=success
EOF

clear

echo "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo "${BLUE}║${NC}      ${BOLD}Exercise 7: Pipes and Filters - Interactive Tutorial${NC}      ${BLUE}║${NC}"
echo "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "${GREEN}Welcome!${NC} You will now learn to connect commands, sending the output of one"
echo "command to the input of another. This is called 'piping'."
echo ""
echo "${BOLD}How this works:${NC}"
echo "  • Each task requires you to chain two or more commands together."
echo "  • You will discover common 'filter' commands like 'grep', 'sort', and 'wc'."
echo "  • The pipe operator is '${BOLD}|${NC}'."
echo "  • Type ${CYAN}'hint'${NC} if you get stuck."
echo ""
echo "We will be working with this sample 'data.txt' file:"
cat data.txt
echo ""
read -p "Press Enter to begin..."

clear

# ============================================================
# TASK 1: Filtering with 'grep'
# ============================================================

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 1/$TOTAL_TASKS: Filtering Lines with 'grep'${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  The 'data.txt' file contains log entries of different levels (INFO, WARN, DEBUG, ERROR)."
echo "  You are only interested in the 'WARN' messages."
echo ""
echo "${BOLD}YOUR GOAL:${NC} Display only the lines from 'data.txt' that contain the word 'WARN'."
echo "  (Hint: You need to send the file's content into a filtering command)."
echo ""
echo "Type ${CYAN}'hint'${NC} for help, or try a command:"
echo ""

hint_count=0
while true; do
    read -p "> " user_cmd

    if [[ "$user_cmd" == "hint" ]]; then
        hint_count=$((hint_count + 1))
        case $hint_count in
            1) echo "${CYAN}HINT 1:${NC} The 'grep' command is used to find text patterns in input.";;
            2) echo "${CYAN}HINT 2:${NC} You need to pipe the output of 'cat data.txt' into 'grep'.";;
            3) echo "${CYAN}HINT 3:${NC} Try: cat data.txt | grep WARN";;
        esac
    elif handle_help "$user_cmd"; then
        continue
    elif [[ "$user_cmd" == *"cat data.txt"* && "$user_cmd" == *"|"* && "$user_cmd" == *"grep"* && "$user_cmd" == *"WARN"* ]]; then
        output=$(eval "$user_cmd")
        line_count=$(echo "$output" | wc -l)
        if [ "$line_count" -eq 2 ] && echo "$output" | grep -q "WARN"; then
            echo ""
            echo "${GREEN}✓ Success!${NC} You filtered the output."
            echo "Your output:"
            echo "${CYAN}$output${NC}"
            TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
            echo ""
            read -p "Press Enter to continue..."
            break
        else
            echo "${RED}That didn't produce the correct output. It should only show the two 'WARN' lines.${NC}"
        fi
    else
        echo "${YELLOW}You need to use 'cat', the pipe '|', and 'grep'. Type 'hint' if you need help.${NC}"
    fi
done

clear

# ============================================================
# TASK 2: Counting Lines with 'wc'
# ============================================================

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 2/$TOTAL_TASKS: Counting Filtered Lines with 'wc'${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  You've successfully filtered the 'WARN' messages. Now, your manager"
echo "  doesn't want to see the messages themselves, they just want to know"
echo "  HOW MANY 'INFO' messages there are."
echo ""
echo "${BOLD}YOUR GOAL:${NC} Produce a single number: the count of lines containing 'INFO'."
echo "  (Hint: You will need a three-command pipeline)."
echo ""
echo "Type ${CYAN}'hint'${NC} for help, or try a command:"
echo ""

hint_count=0
while true; do
    read -p "> " user_cmd

    if [[ "$user_cmd" == "hint" ]]; then
        hint_count=$((hint_count + 1))
        case $hint_count in
            1) echo "${CYAN}HINT 1:${NC} Start by filtering for 'INFO' lines just like you did in the last step.";;
            2) echo "${CYAN}HINT 2:${NC} The 'wc' (word count) command can count lines if given the '-l' option.";;
            3) echo "${CYAN}HINT 3:${NC} Chain them together: cat data.txt | grep INFO | wc -l";;
        esac
    elif handle_help "$user_cmd"; then
        continue
    elif [[ "$user_cmd" == *"cat"* && "$user_cmd" == *"grep"* && "$user_cmd" == *"INFO"* && "$user_cmd" == *"wc"* && "$user_cmd" == *"-l"* ]]; then
        output=$(eval "$user_cmd" | tr -d '[:space:]')
        if [[ "$output" == "3" ]]; then
            echo ""
            echo "${GREEN}✓ Perfect!${NC} You've built a data processing pipeline."
            echo "Your final output was: ${CYAN}$output${NC}"
            TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
            echo ""
            read -p "Press Enter to continue..."
            break
        else
            echo "${RED}The final output should be the number 3. Check your pipeline.${NC}"
        fi
    else
        echo "${YELLOW}You need a three-command pipe: 'cat', then 'grep', then 'wc'. Type 'hint' if stuck.${NC}"
    fi
done

clear

# ============================================================
# TASK 3: Sorting Data with 'sort'
# ============================================================

cat > fruit.txt << EOF
banana
apple
orange
grape
cherry
EOF

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 3/$TOTAL_TASKS: Sorting Data${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  You have a file 'fruit.txt' with a list of fruits, but they are not in"
echo "  alphabetical order. You need to display the list, sorted."
echo ""
echo "Current content of 'fruit.txt':"
cat fruit.txt
echo ""
echo "${BOLD}YOUR GOAL:${NC} Display the contents of 'fruit.txt' in alphabetical order."
echo ""
echo "Type ${CYAN}'hint'${NC} for help, or try a command:"
echo ""

hint_count=0
while true; do
    read -p "> " user_cmd

    if [[ "$user_cmd" == "hint" ]]; then
        hint_count=$((hint_count + 1))
        case $hint_count in
            1) echo "${CYAN}HINT 1:${NC} The 'sort' command sorts lines of text.";;
            2) echo "${CYAN}HINT 2:${NC} You can pipe the output of 'cat fruit.txt' into the 'sort' command.";;
            3) echo "${CYAN}HINT 3:${NC} Try: cat fruit.txt | sort";;
        esac
    elif handle_help "$user_cmd"; then
        continue
    elif [[ "$user_cmd" == *"cat fruit.txt"* && "$user_cmd" == *"|"* && "$user_cmd" == *"sort"* ]]; then
        output=$(eval "$user_cmd")
        first_line=$(echo "$output" | head -n 1)
        last_line=$(echo "$output" | tail -n 1)
        if [[ "$first_line" == "apple" ]] && [[ "$last_line" == "orange" ]]; then
            echo ""
            echo "${GREEN}✓ Success!${NC} The list is now sorted."
            echo "Your sorted output:"
            echo "${CYAN}$output${NC}"
            TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
            echo ""
            read -p "Press Enter to continue..."
            break
        else
            echo "${RED}That's not sorted correctly. 'apple' should be first. Did you pipe the cat command into sort?${NC}"
        fi
    else
        echo "${YELLOW}You need to pipe the contents of 'fruit.txt' into the 'sort' command. Type 'hint' if you need help.${NC}"
    fi
done

clear

# ============================================================
# TASK 4: Challenge - Complex Pipeline
# ============================================================

cat > access.log << EOF
192.168.1.10 - user1 [10/Mar/2023:13:55:36] "GET /index.html HTTP/1.1" 200
192.168.1.12 - user2 [10/Mar/2023:13:56:12] "GET /index.html HTTP/1.1" 200
192.168.1.10 - user1 [10/Mar/2023:13:57:01] "POST /login HTTP/1.1" 302
192.168.1.13 - user3 [10/Mar/2023:13:58:45] "GET /data.json HTTP/1.1" 200
192.168.1.10 - user1 [10/Mar/2023:13:59:00] "GET /index.html HTTP/1.1" 200
192.168.1.12 - user2 [10/Mar/2023:13:59:30] "GET /about.html HTTP/1.1" 200
EOF

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 4/$TOTAL_TASKS: CHALLENGE - Who Accessed a File Most?${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  You have a web server log file, 'access.log'. You need to find out which"
echo "  IP address accessed the file '/index.html' the most times."
echo ""
echo "${BOLD}YOUR GOAL:${NC} Process 'access.log' to produce a single line of output showing the count and the IP address that accessed '/index.html' most often."
echo "  (e.g. '3 192.168.1.10'). This requires a complex pipeline."
echo ""
echo "Type ${CYAN}'hint'${NC} for help, or try a command:"
echo ""

hint_count=0
while true; do
    read -p "> " user_cmd

    if [[ "$user_cmd" == "hint" ]]; then
        hint_count=$((hint_count + 1))
        case $hint_count in
            1) echo "${CYAN}HINT 1:${NC} First, 'grep' for '/index.html' to get only the relevant lines.";;
            2) echo "${CYAN}HINT 2:${NC} Next, you need to extract just the first column (the IP address). The 'awk' command is great for this: 'awk '{print \$1}''.";;
            3) echo "${CYAN}HINT 3:${NC} Now you have a list of IPs. How do you count the occurrences of each? Pipe it to 'sort', then to 'uniq -c'.";;
            4) echo "${CYAN}HINT 4:${NC} Finally, sort the result numerically ('sort -nr') and get the top line ('head -n 1').";;
            5) echo "${CYAN}HINT 5:${NC} Full pipeline: cat access.log | grep "/index.html" | awk '{print \$1}' | sort | uniq -c | sort -nr | head -n 1";;
        esac
    elif handle_help "$user_cmd"; then
        continue
    elif [[ "$user_cmd" == *"cat"* && "$user_cmd" == *"grep"* && "$user_cmd" == *"awk"* && "$user_cmd" == *"sort"* && "$user_cmd" == *"uniq"* ]]; then
        output=$(eval "$user_cmd" 2>/dev/null | tr -s ' ' | sed 's/^[[:space:]]*//')
        if [[ "$output" == "3 192.168.1.10" ]]; then
            echo ""
            echo "${GREEN}✓ OUTSTANDING!${NC} You built a masterful data pipeline."
            echo "Final Result: ${CYAN}$output${NC}"
            TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
            echo ""
            read -p "Press Enter to continue..."
            break
        else
            echo "${RED}That's not the right answer. The final output should be a count and an IP address. Keep building your pipeline!${NC}"
        fi
    else
        echo "${YELLOW}This is a multi-step pipeline. Start with 'grep' and add more commands with '|'. Type 'hint' if you're stuck.${NC}"
    fi
done

clear

# ============================================================
# COMPLETION
# ============================================================

cd ..
rm -rf "$WORK_DIR"

echo "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo "${GREEN}║${NC}                ${BOLD}🎉 EXERCISE 7 COMPLETE! 🎉${NC}                     ${GREEN}║${NC}"
echo "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "${BOLD}Outstanding work!${NC} You've mastered one of the most fundamental concepts in Linux."
echo ""
echo "${BOLD}Pipes and Filters You Discovered:${NC}"
echo "  ✓ The Pipe Operator (${BOLD}|${NC}): Chains commands together."
echo "  ✓ ${BOLD}grep${NC}: A filter that finds lines matching a pattern."
echo "  ✓ ${BOLD}wc${NC}: A filter that counts lines, words, and characters."
echo "  ✓ ${BOLD}sort${NC}: A filter that sorts lines of text."
echo "  ✓ ${BOLD}uniq${NC}: A filter that reports or removes repeated lines."
echo "  ✓ ${BOLD}awk${NC}: A powerful filter for processing columns of text."
echo ""
echo "${BOLD}Next Exercise:${NC}"
echo "  Exercise 8 will introduce you to the complex but powerful world of Regular Expressions (regex)."
echo ""
echo "${GREEN}Run:${NC} cd ~/devops-progress/2-linux/exercises && ./ex08-regex.sh"
echo ""
