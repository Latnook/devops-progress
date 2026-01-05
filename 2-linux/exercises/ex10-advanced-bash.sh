#!/bin/bash

# Interactive Tutorial: Exercise 10 - Advanced Bash
# Master aliases, environment variables, and shell customization

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

WORK_DIR="$HOME/linux-exercises/ex10"
# Clean up previous runs
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

TASKS_COMPLETED=0
TOTAL_TASKS=3

# Function to handle help commands
handle_help() {
    local cmd="$1"
    # Allow help for any of the commands used in this exercise
    for main_cmd in alias export; do
        # Bash builtins don't have man pages or --help in the same way
        if [[ "$cmd" == "help $main_cmd" ]]; then
            echo ""
            help $main_cmd
            echo "${CYAN}Help page displayed. Now try to construct the command.${NC}"
            return 0
        fi
    done
    # For PS1, which is a variable
    if [[ "$cmd" == "man bash" ]]; then
        man bash
        echo "${CYAN}Man page closed. Now try to construct the command.${NC}"
        return 0
    fi

    return 1
}

clear

echo "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo "${BLUE}║${NC}   ${BOLD}Exercise 10: Advanced Bash Features - Interactive Tutorial${NC}   ${BLUE}║${NC}"
echo "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "${GREEN}Welcome!${NC} You'll now learn to customize your shell to make it more powerful and efficient."
echo ""
echo "${BOLD}How this works:${NC}"
echo "  • Each task gives you a problem that can be solved with a Bash feature."
echo "  • You'll discover aliases, environment variables, and more."
echo "  • Type ${CYAN}'hint'${NC} if you get stuck."
echo ""
echo "Working directory: ${YELLOW}$WORK_DIR${NC}"
echo ""
read -p "Press Enter to begin..."

clear

# ============================================================
# TASK 1: Creating a Shortcut with 'alias'
# ============================================================

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 1/$TOTAL_TASKS: Creating Command Aliases${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  You frequently type 'ls -l -h --color=auto' to get a detailed, human-readable"
echo "  directory listing. This is long and tedious to type every time. You want to"
echo "  create a shortcut command, 'll', that does the exact same thing."
echo ""
echo "${BOLD}YOUR GOAL:${NC} Create a shell alias named 'll' that executes 'ls -l -h --color=auto'."
echo ""
echo "Type ${CYAN}'hint'${NC} for help, or try a command:"
echo ""

hint_count=0
while true; do
    read -p "> " user_cmd

    if [[ "$user_cmd" == "hint" ]]; then
        hint_count=$((hint_count + 1))
        case $hint_count in
            1) echo "${CYAN}HINT 1:${NC} The command to create an alias is 'alias'. Since it's a shell builtin, use 'help alias' to learn more.";;
            2) echo "${CYAN}HINT 2:${NC} The syntax is: alias name='command_to_run'";;
            3) echo "${CYAN}HINT 3:${NC} Try: alias ll='ls -l -h --color=auto'";;
        esac
    elif handle_help "$user_cmd" "alias"; then
        continue
    elif [[ "$user_cmd" == "alias ll"* && "$user_cmd" == *"ls -l -h"* ]]; then
        eval "$user_cmd"
        alias_def=$(alias ll 2>/dev/null)
        if [[ -n "$alias_def" ]]; then
            echo ""
            echo "${GREEN}✓ Success!${NC} You've created the 'll' alias."
            echo "Now, test your new alias by simply typing 'll':"
            ll
            TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
            unalias ll
            echo ""
            read -p "Press Enter to continue..."
            break
        else
            echo "${RED}That didn't seem to set the alias correctly. Check your syntax.${NC}"
        fi
    else
        echo "${YELLOW}Use the 'alias' command to create a shortcut named 'll'. Type 'hint' if you need help.${NC}"
    fi
done

clear

# ============================================================
# TASK 2: Using Environment Variables
# ============================================================

cat > "my_script.sh" << 'EOF'
#!/bin/bash
echo "This script is running in mode: $SCRIPT_MODE"
EOF
chmod +x my_script.sh

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 2/$TOTAL_TASKS: Environment Variables${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  You have a script, 'my_script.sh', that behaves differently based on an"
echo "  'environment variable' named 'SCRIPT_MODE'. You need to run this script"
echo "  in 'production' mode without modifying the script itself."
echo ""
echo "Content of 'my_script.sh':"
cat my_script.sh
echo ""
echo "${BOLD}YOUR GOAL:${NC} Set an environment variable 'SCRIPT_MODE' to the value 'production', then run './my_script.sh'."
echo "  You can do this temporarily for a single command."
echo ""
echo "Type ${CYAN}'hint'${NC} for help, or try a command:"
echo ""

hint_count=0
while true; do
    read -p "> " user_cmd

    if [[ "$user_cmd" == "hint" ]]; then
        hint_count=$((hint_count + 1))
        case $hint_count in
            1) echo "${CYAN}HINT 1:${NC} You can temporarily set a variable for a single command by defining it just before the command.";;
            2) echo "${CYAN}HINT 2:${NC} The syntax is: VARIABLE_NAME=value command_to_run";;
            3) echo "${CYAN}HINT 3:${NC} Try: SCRIPT_MODE=production ./my_script.sh";;
        esac
    elif handle_help "$user_cmd" "export"; then # `export` is a related command
        continue
    elif [[ "$user_cmd" == "SCRIPT_MODE=production"* && "$user_cmd" == *"./my_script.sh"* ]]; then
        output=$(eval "$user_cmd" 2>/dev/null)
        if [[ "$output" == "This script is running in mode: production" ]]; then
            echo ""
            echo "${GREEN}✓ Perfect!${NC} You've controlled the script with an environment variable."
            echo "Your script's output:"
            echo "${CYAN}$output${NC}"
            TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
            echo ""
            read -p "Press Enter to continue..."
            break
        else
            echo "${RED}The script didn't run in production mode. Check the variable name and value.${NC}"
        fi
    else
        echo "${YELLOW}You need to set the SCRIPT_MODE variable and then run the script. Type 'hint' if stuck.${NC}"
    fi
done

clear

# ============================================================
# TASK 3: Challenge - Customizing the Prompt
# ============================================================

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 3/$TOTAL_TASKS: CHALLENGE - Customizing Your Prompt${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  Your default command prompt is boring. You want to change it to show your"
echo "  username and the current time, like this: '[my_user|HH:MM:SS]$ '."
echo "  The prompt is controlled by a special environment variable."
echo ""
echo "${BOLD}YOUR GOAL:${NC} Change your shell prompt by setting the correct environment variable."
echo ""
echo "Type ${CYAN}'hint'${NC} for help, or try a command:"
echo ""

hint_count=0
while true; do
    (
        PS1="$ "
        read -p "> " user_cmd

        if [[ "$user_cmd" == "hint" ]]; then
            hint_count=$((hint_count + 1))
            case $hint_count in
                1) echo "${CYAN}HINT 1:${NC} The primary prompt is controlled by the environment variable 'PS1'.";;
                2) echo "${CYAN}HINT 2:${NC} You can run commands inside the prompt string with '\$(command)'.";;
                3) echo "${CYAN}HINT 3:${NC} Special sequences like '\u' (username) and '\T' (time) can also be used. Check 'man bash' under the 'PROMPTING' section!";;
                4) echo "${CYAN}HINT 4:${NC} Try: export PS1='[\u|\T]\$ '";;
            esac
            exit 1
        elif handle_help "$user_cmd" "bash"; then
             exit 1
        elif [[ "$user_cmd" =~ ^(export)?\s*PS1=.*([\$]\(whoami\)|\\u).*([\$]\(date.*%T\)|\\T) ]]; then
            echo ""
            echo "${GREEN}✓ OUTSTANDING!${NC} You've customized your shell prompt."
            new_prompt="[$(whoami)|$(date +%T)]\$ "
            echo "If this were your real shell, your prompt would now look something like this:"
            echo "${BOLD}${CYAN}$new_prompt${NC}"
            exit 0
        else
            echo "${YELLOW}Not quite. You need to set the 'PS1' variable to a string containing your username and the time. Type 'hint' if stuck.${NC}"
            exit 1
        fi
    )
    if [ $? -eq 0 ]; then
        TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
        read -p "Press Enter to continue..."
        break
    fi
done

clear

# ============================================================
# COMPLETION
# ============================================================

cd ..
rm -rf "$WORK_DIR"

echo "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo "${GREEN}║${NC}               ${BOLD}🎉 EXERCISE 10 COMPLETE! 🎉${NC}                    ${GREEN}║${NC}"
echo "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "${BOLD}Excellent work!${NC} You've learned some of the most common ways to customize your shell."
echo ""
echo "${BOLD}Advanced Bash Features You Discovered:${NC}"
echo "  ✓ ${BOLD}alias${NC}: Create shortcuts for long or frequently used commands."
echo "  ✓ ${BOLD}Environment Variables${NC}: Pass configuration to programs without changing them."
echo "  ✓ ${BOLD}PS1${NC}: A special variable to completely customize your command prompt."
echo ""
echo "${BOLD}Next Exercise:${NC}"
echo "  Exercise 11 will cover how to manage services and processes."
echo ""
echo "${GREEN}Run:${NC} cd ~/devops-progress/2-linux/exercises && ./ex11-services-processes.sh"
echo ""
