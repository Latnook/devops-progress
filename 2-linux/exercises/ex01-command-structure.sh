#!/bin/bash

# Interactive Tutorial: Exercise 1 - Command Structure
# Learn Linux command syntax by solving real challenges

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

WORK_DIR="$HOME/linux-exercises/ex01"
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


clear

echo "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo "${BLUE}║${NC}   ${BOLD}Exercise 1: Command Structure - Interactive Tutorial${NC}        ${BLUE}║${NC}"
echo "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "${GREEN}Welcome!${NC} You'll learn Linux command structure by solving real challenges."
echo ""
echo "${BOLD}How this works:${NC}"
echo "  • Each task presents a real scenario"
echo "  • Figure out the command to solve it (use '--help' and 'man'!)"
echo "  • Type ${CYAN}'hint'${NC} if you need help"
echo "  • We check if you achieved the goal (multiple solutions accepted!)"
echo ""
echo "Working directory: ${YELLOW}$WORK_DIR${NC}"
echo ""
read -p "Press Enter to begin..."

clear

# ============================================================
# TASK 1: Basic Command
# ============================================================

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 1/$TOTAL_TASKS: Viewing Directory Contents${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}CONCEPT:${NC} Linux commands have this structure:"
echo "    ${CYAN}command [options] [arguments]${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  You need to see what files are in the /boot directory."
echo ""
echo "${BOLD}YOUR GOAL:${NC} List the contents of /boot"
echo ""
echo "Type ${CYAN}'hint'${NC} for help, or try a command:"
echo ""

hint_count=0
while true; do
    read -p "> " user_cmd

    if [[ "$user_cmd" == "hint" ]]; then
        hint_count=$((hint_count + 1))
        case $hint_count in
            1) echo "${CYAN}HINT 1:${NC} There is a command to 'list' files.";;
            2) echo "${CYAN}HINT 2:${NC} The command is two letters long.";;
            3) echo "${CYAN}HINT 3:${NC} Try: ls /boot";;
        esac
    elif handle_help "$user_cmd" "ls"; then
        continue
    elif [[ "$user_cmd" =~ ^ls.*boot ]]; then
        # Run their command and check if it succeeded
        if eval "$user_cmd" &>/dev/null; then
            echo ""
            eval "$user_cmd"
            echo ""
            echo "${GREEN}✓ Success!${NC} You listed the /boot directory contents."
            echo ""
            echo "${BOLD}What happened:${NC}"
            echo "  • ${CYAN}ls${NC} = the command (list)"
            echo "  • ${CYAN}/boot${NC} = the argument (what to list)"
            TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
            echo ""
            read -p "Press Enter to continue..."
            break
        else
            echo "${RED}That command had an error. Try again!${NC}"
        fi
    elif [[ "$user_cmd" =~ ^ls ]]; then
        echo "${YELLOW}You're using the right command, but you need to specify the /boot directory${NC}"
    else
        echo "${YELLOW}Not quite. Remember, you're trying to list files. Type 'hint' if you need help.${NC}"
    fi
done

clear

# ============================================================
# TASK 2: Using Options
# ============================================================

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 2/$TOTAL_TASKS: Getting Detailed Information${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}CONCEPT:${NC} Options modify how commands work"
echo "  • Short form: ${CYAN}-l${NC} (single dash)"
echo "  • Long form: ${CYAN}--help${NC} (double dash)"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  The default file listing is not very informative. You need to"
echo "  see file sizes, permissions, and modification dates for files in /boot."
echo ""
echo "${BOLD}YOUR GOAL:${NC} Display a 'long listing' of all files in /boot."
echo "  (Hint: How do you get help for a command?)"
echo ""
echo "Type ${CYAN}'hint'${NC} for help, or try a command:"
echo ""

hint_count=0
while true; do
    read -p "> " user_cmd

    if [[ "$user_cmd" == "hint" ]]; then
        hint_count=$((hint_count + 1))
        case $hint_count in
            1) echo "${CYAN}HINT 1:${NC} Use the command's built-in help to find the right option. Try 'ls --help'.";;
            2) echo "${CYAN}HINT 2:${NC} Look for an option related to 'long' or 'detailed' format.";;
            3) echo "${CYAN}HINT 3:${NC} The option is '-l'.";;
        esac
    elif handle_help "$user_cmd" "ls"; then
        continue
    elif [[ "$user_cmd" =~ ^ls.*-.*l.*boot ]]; then
        output=$(eval "$user_cmd" 2>&1)
        if echo "$output" | grep -q "^[-d]"; then
            echo ""
            eval "$user_cmd"
            echo ""
            echo "${GREEN}✓ Excellent!${NC} You used the long format option."
            TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
            echo ""
            read -p "Press Enter to continue..."
            break
        else
            echo "${YELLOW}The command ran but didn't show the long format. Make sure you're using the correct option.${NC}"
        fi
    elif [[ "$user_cmd" =~ ^ls.*boot ]]; then
        echo "${YELLOW}Good! Now you need to add an option to change the output format.${NC}"
    else
        echo "${YELLOW}Use the 'ls' command. You'll need to find the right option. Type 'hint' if stuck.${NC}"
    fi
done

clear

# ============================================================
# TASK 3: Finding Hidden Files
# ============================================================

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 3/$TOTAL_TASKS: Discovering Hidden Files${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  You ran 'ls ~' and it showed 10 files. But your colleague insists"
echo "  there are actually 47 files in your home directory (~)."
echo "  This implies some files are hidden."
echo ""
echo "${BOLD}YOUR GOAL:${NC} Find and list ALL the files that actually exist in your home directory."
echo ""
echo "Type ${CYAN}'hint'${NC} for help, or try a command:"
echo ""

touch ~/.test_hidden_ex01

hint_count=0
while true; do
    read -p "> " user_cmd

    if [[ "$user_cmd" == "hint" ]]; then
        hint_count=$((hint_count + 1))
        case $hint_count in
            1) echo "${CYAN}HINT 1:${NC} Check the help for 'ls' again. Is there an option to show 'all' files?";;
            2) echo "${CYAN}HINT 2:${NC} The option you are looking for is '-a'.";;
            3) echo "${CYAN}HINT 3:${NC} Try: ls -a ~";;
        esac
    elif handle_help "$user_cmd" "ls"; then
        continue
    elif [[ "$user_cmd" =~ ^ls.*-.*a ]]; then
        output=$(eval "$user_cmd" 2>&1)
        if echo "$output" | grep -q ".test_hidden_ex01"; then
            echo ""
            eval "$user_cmd" | head -20
            echo "... (showing first 20 files) ..."
            echo ""
            echo "${GREEN}✓ Perfect!${NC} You found the hidden files."
            TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
            rm -f ~/.test_hidden_ex01
            echo ""
            read -p "Press Enter to continue..."
            break
        else
            echo "${YELLOW}That command ran but didn't show the hidden files. You need to use the right option and specify your home directory (~).${NC}"
        fi
    else
        echo "${YELLOW}Use 'ls' to list files. You need to find the option that reveals hidden files. Type 'hint' if you need help.${NC}"
    fi
done

clear

# ============================================================
# TASK 4: Getting Help
# ============================================================

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 4/$TOTAL_TASKS: Finding Help When Stuck${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  You need to know what the 'date' command does and what its capabilities are."
echo ""
echo "${BOLD}YOUR GOAL:${NC} Use one of the built-in help commands to view the documentation for the 'date' command."
echo ""
echo "Type ${CYAN}'hint'${NC} for help, or try a command:"
echo ""

hint_count=0
while true; do
    read -p "> " user_cmd

    if [[ "$user_cmd" == "hint" ]]; then
        hint_count=$((hint_count + 1))
        case $hint_count in
            1) echo "${CYAN}HINT 1:${NC} You can get a quick summary with 'command --help'.";;
            2) echo "${CYAN}HINT 2:${NC} For a detailed manual, use 'man command'.";;
            3) echo "${CYAN}HINT 3:${NC} Try 'date --help' or 'man date'.";;
        esac
    # This is the task, so we handle it as the success case
    elif [[ "$user_cmd" == "date --help" ]] || [[ "$user_cmd" == "man date" ]]; then
        if [[ "$user_cmd" == "date --help" ]]; then
            date --help | head -30
            echo "... (help continues) ..."
        else
            man date
        fi
        echo ""
        echo "${GREEN}✓ Great!${NC} You accessed the help documentation."
        echo ""
        echo "${BOLD}Remember:${NC} This should be your first step whenever you're unsure!"
        TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
        echo ""
        read -p "Press Enter to continue..."
        break
    elif [[ "$user_cmd" =~ help ]]; then
        echo "${YELLOW}Close! You need to specify *which* command you want help with.${NC}"
    else
        echo "${YELLOW}You need to view the help for the 'date' command. Type 'hint' if stuck.${NC}"
    fi
done

clear

# ============================================================
# TASK 5: Custom Formatting
# ============================================================

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 5/$TOTAL_TASKS: Formatting Output${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  You're writing a script that needs to log the current time"
echo "  in a very specific format: HH:MM:SS (e.g., 14:35:22)."
echo "  The default 'date' command output is not suitable."
echo ""
echo "${BOLD}YOUR GOAL:${NC} Use the 'date' command to display ONLY the current time as HH:MM:SS."
echo "  (Hint: check the man page or --help for 'date' to see how to control the format)."
echo ""
echo "Type ${CYAN}'hint'${NC} for help, or try a command:"
echo ""

hint_count=0
while true; do
    read -p "> " user_cmd

    if [[ "$user_cmd" == "hint" ]]; then
        hint_count=$((hint_count + 1))
        case $hint_count in
            1) echo "${CYAN}HINT 1:${NC} The 'date' help says you can provide a FORMAT string starting with a '+'." ;;
            2) echo "${CYAN}HINT 2:${NC} Look for format codes for Hour, Minute, and Second. They are usually '%H', '%M', and '%S'.";;
            3) echo "${CYAN}HINT 3:${NC} Try: date +'%H:%M:%S'";;
        esac
    elif handle_help "$user_cmd" "date"; then
        continue
    elif [[ "$user_cmd" =~ ^date.* ]]; then
        output=$(eval "$user_cmd" 2>&1)
        if echo "$output" | grep -qE "^[0-9]{2}:[0-9]{2}:[0-9]{2}$"; then
            echo ""
            echo "Current time: $(eval "$user_cmd")"
            echo ""
            echo "${GREEN}✓ Perfect!${NC} You discovered how to format the time correctly."
            TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
            echo ""
            read -p "Press Enter to continue..."
            break
        else
            echo "${YELLOW}Not quite. The output format should be exactly HH:MM:SS. You might need to check the help documentation again.${NC}"
        fi
    else
        echo "${YELLOW}Use the 'date' command. You'll need to figure out how to specify a custom output format. Type 'hint' if stuck.${NC}"
    fi
done

clear

# ============================================================
# TASK 6: Challenge
# ============================================================

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 6/$TOTAL_TASKS: CHALLENGE - Find the Newest File${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  An application just updated one of its configuration files in /etc/,"
echo "  but you don't know which one. You need to find the file that was"
echo "  modified most recently."
echo ""
echo "${BOLD}YOUR GOAL:${NC} List all the files in /etc/ in a way that the newest file appears at the top."
echo "  (Hint: You'll need to combine two different options for the 'ls' command.)"
echo ""
echo "${CYAN}Try to figure this out without a hint! Use 'ls --help'.${NC}"
echo ""

hint_count=0
while true; do
    read -p "> " user_cmd

    if [[ "$user_cmd" == "hint" ]]; then
        hint_count=$((hint_count + 1))
        case $hint_count in
            1) echo "${CYAN}HINT 1:${NC} You need to display modification times, and then sort by them. Look for options related to 'long' format and 'time'.";;
            2) echo "${CYAN}HINT 2:${NC} The options are '-l' (long format to show time) and '-t' (sort by time).";;
            3) echo "${CYAN}HINT 3:${NC} Try combining them: ls -lt /etc";;
        esac
    elif handle_help "$user_cmd" "ls"; then
        continue
    elif [[ "$user_cmd" =~ ^ls.*-.*l.*-.*t.*etc ]] || [[ "$user_cmd" =~ ^ls.*-.*t.*-.*l.*etc ]] || [[ "$user_cmd" =~ ^ls.*-[lt]{2,}.*etc ]] || [[ "$user_cmd" =~ ^ls.*-[tl]{2,}.*etc ]]; then
        echo ""
        eval "$user_cmd" | head -15
        echo ""
        echo "... (showing first 15 files) ..."
        echo ""
        echo "${GREEN}✓ EXCELLENT!${NC} You solved the challenge!"
        TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
        echo ""
        read -p "Press Enter to continue..."
        break
    elif [[ "$user_cmd" =~ ^ls.*etc ]]; then
        echo "${YELLOW}You're listing /etc, which is correct. Now you need to add the right options to sort by time.${NC}"
    else
        echo "${YELLOW}Use 'ls' with options. Remember the goal is to sort by time. Type 'hint' if you're stuck.${NC}"
    fi
done

clear

# ============================================================
# COMPLETION
# ============================================================

echo "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo "${GREEN}║${NC}                ${BOLD}🎉 EXERCISE 1 COMPLETE! 🎉${NC}                     ${GREEN}║${NC}"
echo "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "${BOLD}Outstanding work!${NC} You completed all $TASKS_COMPLETED/$TOTAL_TASKS tasks by problem-solving."
echo ""
echo "${BOLD}Skills Mastered:${NC}"
echo "  ✓ Executing commands with arguments."
echo "  ✓ Discovering and using command options to change behavior."
echo "  ✓ Combining multiple options for powerful results."
echo "  ✓ Using '--help' and 'man' to learn independently."
echo "  ✓ Discovering how to format command output."
echo "  ✓ Applying commands to solve real-world problems."
echo ""
echo "${BOLD}Commands You Discovered:${NC}"
echo "  • ls      - List directory contents"
echo "  • date    - Display/format date and time"
echo "  • --help  - Get command help"
echo "  • man     - Read command manual"
echo ""
echo "${BOLD}Next Challenge:${NC}"
echo "  Exercise 2 will test your ability to manage files and directories."
echo "  You'll be creating, renaming, moving, and deleting things - without instructions!"
echo ""
echo "${GREEN}Run:${NC} cd ~/devops-progress/2-linux/exercises && ./ex02-filesystem-commands.sh"
echo ""

# Final cleanup
cd ~
rm -rf "$WORK_DIR"
rm -f ~/.test_hidden_ex01
