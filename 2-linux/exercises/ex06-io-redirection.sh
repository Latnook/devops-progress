#!/bin/bash

# Interactive Tutorial: Exercise 6 - I/O Redirection
# Master stdout, stderr, and stdin redirection by solving problems

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

WORK_DIR="$HOME/linux-exercises/ex06"
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

clear

echo "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo "${BLUE}║${NC}       ${BOLD}Exercise 6: I/O Redirection - Interactive Tutorial${NC}      ${BLUE}║${NC}"
echo "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "${GREEN}Welcome!${NC} You'll learn how to control the input and output of commands."
echo "This is one of the most powerful features of the command line."
echo ""
echo "${BOLD}How this works:${NC}"
echo "  • Each task presents a problem that requires redirecting I/O."
echo "  • You'll need to discover the redirection operators: >, >>, 2>, <"
echo "  • Type ${CYAN}'hint'${NC} if you get stuck."
echo ""
echo "Working directory: ${YELLOW}$WORK_DIR${NC}"
echo ""
read -p "Press Enter to begin..."

clear

# ============================================================
# TASK 1: Redirecting Standard Output
# ============================================================

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 1/$TOTAL_TASKS: Saving Command Output to a File${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  The 'ls -l /etc' command produces a long list of files. This is too much"
echo "  to view in the terminal. You need to save this output into a file named"
echo "  'etc_listing.txt' so you can review it later."
echo ""
echo "${BOLD}YOUR GOAL:${NC} Run 'ls -l /etc' so that its output is written to 'etc_listing.txt' instead of the screen."
echo ""
echo "Type ${CYAN}'hint'${NC} for help, or try a command:"
echo ""

hint_count=0
while true; do
    read -p "> " user_cmd

    if [[ "$user_cmd" == "hint" ]]; then
        hint_count=$((hint_count + 1))
        case $hint_count in
            1) echo "${CYAN}HINT 1:${NC} The '>' character redirects the standard output of a command to a file.";;
            2) echo "${CYAN}HINT 2:${NC} The syntax is: command > filename";;
            3) echo "${CYAN}HINT 3:${NC} Try: ls -l /etc > etc_listing.txt";;
        esac
    elif handle_help "$user_cmd" "ls"; then
        continue
    elif [[ "$user_cmd" =~ ^ls.*-l.*\/etc.*>.*etc_listing\.txt ]]; then
        term_output=$(eval "$user_cmd" 2>&1)
        if [ -f "etc_listing.txt" ] && [ -s "etc_listing.txt" ] && [ -z "$term_output" ]; then
            echo ""
            echo "${GREEN}✓ Success!${NC} The output was redirected."
            echo "The file 'etc_listing.txt' has been created and contains the directory listing."
            echo ""
            echo "First 5 lines of the new file:"
            head -n 5 etc_listing.txt
            TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
            echo ""
            read -p "Press Enter to continue..."
            break
        else
            echo "${RED}That didn't quite work. Make sure the file 'etc_listing.txt' is created and not empty, and that the command output doesn't appear on screen.${NC}"
        fi
    else
        echo "${YELLOW}Use 'ls -l /etc'. You need to use a special character to redirect its output. Type 'hint' if you need help.${NC}"
    fi
done

clear

# ============================================================
# TASK 2: Redirecting Standard Error
# ============================================================

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 2/$TOTAL_TASKS: Separating Errors from Successes${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  You are running a command that will produce both successful output and error"
echo "  messages: 'ls -l /etc/shadow /etc/hosts'. You can't access '/etc/shadow',"
echo "  so that part will fail. You want to capture ONLY the error message in a"
echo "  file named 'errors.log' and let the successful output still appear on screen."
echo ""
echo "${BOLD}YOUR GOAL:${NC} Redirect only the 'standard error' (stderr) stream to the file 'errors.log'."
echo ""
echo "Type ${CYAN}'hint'${NC} for help, or try a command:"
echo ""

hint_count=0
while true; do
    read -p "> " user_cmd

    if [[ "$user_cmd" == "hint" ]]; then
        hint_count=$((hint_count + 1))
        case $hint_count in
            1) echo "${CYAN}HINT 1:${NC} Standard output is stream '1' and standard error is stream '2'. You can redirect a specific stream by number.";;
            2) echo "${CYAN}HINT 2:${NC} The operator '2>' redirects standard error.";;
            3) echo "${CYAN}HINT 3:${NC} Try: ls -l /etc/shadow /etc/hosts 2> errors.log";;
        esac
    elif handle_help "$user_cmd" "ls"; then
        continue
    elif [[ "$user_cmd" =~ ^ls.*shadow.*hosts.*2>.*errors\.log ]]; then
        term_output=$(eval "$user_cmd")
        if [ -f "errors.log" ] && grep -q "Permission denied" errors.log && [[ "$term_output" == *"/etc/hosts"* ]]; then
            echo ""
            echo "${GREEN}✓ Perfect!${NC} You separated errors from output."
            echo "This appeared on your screen (stdout):"
            echo "${CYAN}$term_output${NC}"
            echo "This was saved to the error log (stderr):"
            echo "${RED}$(cat errors.log)${NC}"
            TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
            echo ""
            read -p "Press Enter to continue..."
            break
        else
            echo "${RED}Not quite. The 'errors.log' file should contain the 'Permission denied' message, and the info for '/etc/hosts' should have appeared on your screen.${NC}"
        fi
    else
        echo "${YELLOW}You need to run the 'ls' command on both files, but use a special operator to redirect the errors. Type 'hint' if stuck.${NC}"
    fi
done

clear

# ============================================================
# TASK 3: Appending to a File
# ============================================================

echo "Initial log entry." > system.log

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 3/$TOTAL_TASKS: Appending Output to a Log File${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  You have an existing log file, 'system.log'. You want to add a new"
echo "  log entry from the 'date' command to the END of the file without"
echo "  deleting the content that's already there."
echo ""
echo "Current content of 'system.log':"
cat system.log
echo ""
echo "${BOLD}YOUR GOAL:${NC} Add the output of the 'date' command to the end of 'system.log'."
echo ""
echo "Type ${CYAN}'hint'${NC} for help, or try a command:"
echo ""

hint_count=0
while true; do
    read -p "> " user_cmd

    if [[ "$user_cmd" == "hint" ]]; then
        hint_count=$((hint_count + 1))
        case $hint_count in
            1) echo "${CYAN}HINT 1:${NC} Using a single '>' will overwrite the file. You need a different operator to append.";;
            2) echo "${CYAN}HINT 2:${NC} The '>>' operator appends output to a file instead of overwriting it.";;
            3) echo "${CYAN}HINT 3:${NC} Try: date >> system.log";;
        esac
    elif handle_help "$user_cmd" "date"; then
        continue
    elif [[ "$user_cmd" =~ ^date.*>>.*system\.log ]]; then
        eval "$user_cmd"
        line_count=$(cat system.log | wc -l)
        if [ "$line_count" -ge 2 ] && grep -q "Initial log entry." system.log; then
            echo ""
            echo "${GREEN}✓ Success!${NC} You appended to the file."
            echo "New content of 'system.log':"
            cat system.log
            TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
            echo ""
            read -p "Press Enter to continue..."
            break
        else
            echo "${RED}That didn't work. The 'system.log' file should now have two lines. Did you use '>>' to append?${NC}"
        fi
    else
        echo "${YELLOW}Use the 'date' command. You need to use a special operator to *append* its output to 'system.log'. Type 'hint' if stuck.${NC}"
    fi
done

clear

# ============================================================
# TASK 4: Challenge - Redirecting Input
# ============================================================

echo "jane.doe" > answers.txt
echo "Marketing" >> answers.txt
echo "New York" >> answers.txt

cat > "survey.sh" << 'EOF'
#!/bin/bash
echo "Please enter your username:"
read USERNAME
echo "Please enter your department:"
read DEPARTMENT
echo "Please enter your location:"
read LOCATION
echo "---"
echo "Survey Results:"
echo "User: $USERNAME, Dept: $DEPARTMENT, Loc: $LOCATION"
EOF
chmod +x survey.sh

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 4/$TOTAL_TASKS: CHALLENGE - Redirecting Input${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  You have a script, './survey.sh', that interactively asks you for three"
echo "  pieces of information (username, department, location). You also have a"
echo "  file, 'answers.txt', that contains the answers, each on a new line."
echo ""
echo "${BOLD}YOUR GOAL:${NC} Run the './survey.sh' script, but instead of typing the answers in manually,"
echo "  make the script read its input directly from the 'answers.txt' file."
echo ""
echo "Content of 'answers.txt':"
cat answers.txt
echo ""
echo "Type ${CYAN}'hint'${NC} for help, or try a command:"
echo ""

hint_count=0
while true; do
    read -p "> " user_cmd

    if [[ "$user_cmd" == "hint" ]]; then
        hint_count=$((hint_count + 1))
        case $hint_count in
            1) echo "${CYAN}HINT 1:${NC} Just as '>' redirects output, a different character redirects input.";;
            2) echo "${CYAN}HINT 2:${NC} The '<' character redirects 'standard input' (stdin) from a file.";;
            3) echo "${CYAN}HINT 3:${NC} Try: ./survey.sh < answers.txt";;
        esac
    elif handle_help "$user_cmd" "./survey.sh"; then
        continue
    elif [[ "$user_cmd" =~ \./survey.sh.*<.*answers.txt ]]; then
        output=$(eval "$user_cmd" 2>&1)
        if echo "$output" | grep -q "User: jane.doe, Dept: Marketing, Loc: New York"; then
            echo ""
            echo "${GREEN}✓ OUTSTANDING!${NC} You've automated the script!"
            echo "Full output of the script:"
            echo "${CYAN}$output${NC}"
            TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
            echo ""
            read -p "Press Enter to continue..."
            break
        else
            echo "${RED}The script didn't produce the expected output. Make sure you are redirecting the input correctly.${NC}"
        fi
    else
        echo "${YELLOW}You need to run './survey.sh', but use a redirection operator to feed it input from 'answers.txt'. Type 'hint' if stuck.${NC}"
    fi
done

clear

# ============================================================
# COMPLETION
# ============================================================

cd ..
rm -rf "$WORK_DIR"

echo "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo "${GREEN}║${NC}                ${BOLD}🎉 EXERCISE 6 COMPLETE! 🎉${NC}                     ${GREEN}║${NC}"
echo "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "${BOLD}Outstanding work!${NC} You completed all $TASKS_COMPLETED/$TOTAL_TASKS scenarios."
echo ""
echo "${BOLD}Redirection Operators You Discovered:${NC}"
echo "  ✓ ${BOLD}>${NC}   (Redirect stdout): Overwrites a file with a command's output."
echo "  ✓ ${BOLD}2>${NC}  (Redirect stderr): Captures only error messages."
echo "  ✓ ${BOLD}>>${NC}  (Append stdout): Adds a command's output to the end of a file."
echo "  ✓ ${BOLD}<${NC}   (Redirect stdin): Feeds a file's content into a command as input."
echo ""
echo "${BOLD}Next Exercise:${NC}"
echo "  Exercise 7 will teach you how to chain commands together with pipes and filters."
echo ""
echo "${GREEN}Run:${NC} cd ~/devops-progress/2-linux/exercises && ./ex07-pipes-filters.sh"
echo ""
