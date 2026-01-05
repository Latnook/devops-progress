#!/bin/bash

# Interactive Tutorial: Exercise 11 - Services and Process Management
# Master managing system services and controlling running processes

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

WORK_DIR="$HOME/linux-exercises/ex11"
# Clean up previous runs
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"
# For cleanup
pkill -f "sleep 3600" &>/dev/null || true
pkill -f "sleep 120" &>/dev/null || true


TASKS_COMPLETED=0
TOTAL_TASKS=4

# Function to handle help commands
handle_help() {
    local cmd="$1"
    for main_cmd in ps kill pkill jobs systemctl; do
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

clear

echo "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo "${BLUE}║${NC}  ${BOLD}Exercise 11: Services & Process Management - Interactive Tutorial${NC} ${BLUE}║${NC}"
echo "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "${GREEN}Welcome!${NC} You'll learn how to view, manage, and terminate running processes."
echo "This is a core skill for any system administrator."
echo ""
echo "${BOLD}How this works:${NC}"
echo "  • Each task presents a scenario involving processes."
echo "  • You'll discover commands like 'ps', 'kill', and 'systemctl'."
echo "  • Type ${CYAN}'hint'${NC} if you get stuck."
echo ""
echo "Working directory: ${YELLOW}$WORK_DIR${NC}"
echo ""
read -p "Press Enter to begin..."

clear

# ============================================================
# TASK 1: Listing Processes with 'ps'
# ============================================================

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 1/$TOTAL_TASKS: Listing Running Processes${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  You need to see all the processes currently running on the entire system,"
echo "  not just the ones in your current terminal. This gives you a complete"
echo "  overview of what the machine is doing."
echo ""
echo "${BOLD}YOUR GOAL:${NC} Use the 'ps' command with the correct options to display every single process running on the system."
echo ""
echo "Type ${CYAN}'hint'${NC} for help, or try a command:"
echo ""

hint_count=0
while true; do
    read -p "> " user_cmd

    if [[ "$user_cmd" == "hint" ]]; then
        hint_count=$((hint_count + 1))
        case $hint_count in
            1) echo "${CYAN}HINT 1:${NC} The command to see 'process status' is 'ps'. Check its 'man' page for options.";;
            2) echo "${CYAN}HINT 2:${NC} You are looking for options that mean 'every' or 'all' processes. Common options are '-e' (every) and '-f' (full format).";;
            3) echo "${CYAN}HINT 3:${NC} Try: ps -ef";;
        esac
    elif handle_help "$user_cmd" "ps"; then
        continue
    elif [[ "$user_cmd" == "ps -ef" || "$user_cmd" == "ps aux" ]]; then
        output=$(eval "$user_cmd" 2>/dev/null | head -n 20)
        line_count=$(echo "$output" | wc -l)
        if [ "$line_count" -gt 5 ]; then
            echo ""
            echo "${GREEN}✓ Success!${NC} You've listed all system processes."
            echo "Showing the first 20 lines of your output:"
            echo "${CYAN}$output${NC}"
            echo "..."
            TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
            echo ""
            read -p "Press Enter to continue..."
            break
        else
            echo "${RED}That didn't seem to list all processes. The output should be many lines long.${NC}"
        fi
    else
        echo "${YELLOW}Use the 'ps' command. You need to find the options to list all processes system-wide. Type 'hint' if you need help.${NC}"
    fi
done

clear

# ============================================================
# TASK 2: Finding and Killing a Process
# ============================================================

sleep 3600 &
SLEEP_PID=$!

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 2/$TOTAL_TASKS: Finding and Terminating a Process${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  A runaway process, 'sleep 3600', was started in the background. It's consuming"
echo "  resources and needs to be stopped. You must first find its Process ID (PID)"
echo "  and then use that PID to terminate it."
echo ""
echo "${BOLD}YOUR GOAL:${NC} Find the PID of the 'sleep 3600' process and terminate it."
echo "  (Hint: Pipe the output of 'ps' into 'grep' to find the process)."
echo ""
echo "Type ${CYAN}'hint'${NC} for help, or try a command:"
echo ""

hint_count=0
while true; do
    read -p "> " user_cmd

    if [[ "$user_cmd" == "hint" ]]; then
        hint_count=$((hint_count + 1))
        case $hint_count in
            1) echo "${CYAN}HINT 1:${NC} First, find the line with the process: 'ps -ef | grep sleep'.";;
            2) echo "${CYAN}HINT 2:${NC} The second column in the output is the PID. Once you have the PID, use the 'kill <PID>' command.";;
            3) echo "${CYAN}HINT 3:${NC} The PID is $SLEEP_PID. So you would run: kill $SLEEP_PID";;
            4) echo "${CYAN}HINT 4:${NC} You can also do this in one step with 'pkill': pkill -f sleep";;
        esac
    elif handle_help "$user_cmd" "ps" || handle_help "$user_cmd" "kill" || handle_help "$user_cmd" "pkill"; then
        continue
    elif [[ "$user_cmd" == *"kill"* ]]; then
        eval "$user_cmd" 2>/dev/null || true
        if ! ps -p $SLEEP_PID &>/dev/null; then
             echo ""
            echo "${GREEN}✓ Perfect!${NC} The process has been terminated."
            TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
            echo ""
            read -p "Press Enter to continue..."
            break
        else
            echo "${RED}The process is still running. Make sure you used the correct PID with the 'kill' command.${NC}"
        fi
    else
        echo "${YELLOW}This is a two-step task. First, find the PID of the 'sleep' process. Then use the 'kill' command.${NC}"
    fi
done

pkill -f "sleep 3600" &>/dev/null || true
clear

# ============================================================
# TASK 3: Managing Background Jobs
# ============================================================

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 3/$TOTAL_TASKS: Managing Background Jobs${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  You need to start a long-running command, but you don't want it to tie up"
echo "  your terminal. You want to run it in the background."
echo ""
echo "${BOLD}YOUR GOAL:${NC} Start the command 'sleep 120' in the background."
echo ""
echo "Type ${CYAN}'hint'${NC} for help, or try a command:"
echo ""

hint_count=0
while true; do
    read -p "> " user_cmd

    if [[ "$user_cmd" == "hint" ]]; then
        hint_count=$((hint_count + 1))
        case $hint_count in
            1) echo "${CYAN}HINT 1:${NC} A special character at the end of a command tells the shell to run it in the background.";;
            2) echo "${CYAN}HINT 2:${NC} The character is the ampersand, '&'.";;
            3) echo "${CYAN}HINT 3:${NC} Try: sleep 120 &";;
        esac
    elif handle_help "$user_cmd" "jobs"; then
        continue
    elif [[ "$user_cmd" == *"sleep 120"* && "$user_cmd" == *"&"* ]]; then
        eval "$user_cmd" 2>&1
        BG_PID=$(jobs -p)
        if [[ -n "$BG_PID" ]] && ps -p $BG_PID &>/dev/null; then
            echo ""
            echo "${GREEN}✓ Success!${NC} The command is running in the background."
            echo "You can see the job with the 'jobs' command:"
            jobs
            TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
            kill $BG_PID &>/dev/null || true
            echo ""
            read -p "Press Enter to continue..."
            break
        else
            echo "${RED}The command didn't seem to start in the background. Did you add the '&' at the end?${NC}"
        fi
    else
        echo "${YELLOW}You need to run 'sleep 120', but with a special character to send it to the background. Type 'hint' if you need help.${NC}"
    fi
done

pkill -f "sleep 120" &>/dev/null || true
clear

# ============================================================
# TASK 4: Challenge - Checking a System Service
# ============================================================

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 4/$TOTAL_TASKS: CHALLENGE - Checking a System Service${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  You need to verify that the SSH server (sshd) is running on your machine"
echo "  so you can connect to it remotely. Modern Linux systems use a service"
echo "  manager to handle services like this."
echo ""
echo "${BOLD}YOUR GOAL:${NC} Use the main system service manager command to check the 'status' of the 'sshd' service."
echo ""
echo "Type ${CYAN}'hint'${NC} for help, or try a command:"
echo ""

hint_count=0
while true; do
    read -p "> " user_cmd

    if [[ "$user_cmd" == "hint" ]]; then
        hint_count=$((hint_count + 1))
        case $hint_count in
            1) echo "${CYAN}HINT 1:${NC} The modern command for controlling system services is 'systemctl'.";;
            2) echo "${CYAN}HINT 2:${NC} You want to check the 'status' of the 'sshd' service.";;
            3) echo "${CYAN}HINT 3:${NC} Try: systemctl status sshd";;
        esac
    elif handle_help "$user_cmd" "systemctl"; then
        continue
    elif [[ "$user_cmd" == *"systemctl"* && "$user_cmd" == *"status"* && ("$user_cmd" == *"sshd"* || "$user_cmd" == *"ssh"*) ]]; then
        echo ""
        echo "${GREEN}✓ OUTSTANDING!${NC} That's the correct command to check the service."
        echo ""
        echo "If you ran this for real (possibly with 'sudo'), you would see output like this:"
        echo "${CYAN}"
        echo "● ssh.service - OpenBSD Secure Shell server"
        echo "   Loaded: loaded (/usr/lib/systemd/system/ssh.service; enabled; vendor preset: enabled)"
        echo "   Active: active (running) since Fri 2023-03-10 14:52:17 EST; 2 weeks ago"
        echo " Main PID: 1234 (sshd)"
        echo "${NC}"
        TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
        echo ""
        read -p "Press Enter to continue..."
        break
    else
        echo "${YELLOW}You need to use the system service manager command to check the status of 'sshd'. Type 'hint' if you're stuck.${NC}"
    fi
done

clear

# ============================================================
# COMPLETION
# ============================================================

cd ..
rm -rf "$WORK_DIR"

echo "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo "${GREEN}║${NC}               ${BOLD}🎉 EXERCISE 11 COMPLETE! 🎉${NC}                    ${GREEN}║${NC}"
echo "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "${BOLD}Excellent work!${NC} You've learned the fundamentals of process and service management."
echo ""
echo "${BOLD}Process & Service Commands You Discovered:${NC}"
echo "  ✓ ${BOLD}ps -ef${NC}: List all running processes."
echo "  ✓ ${BOLD}grep${NC}: Used as a filter to find a specific process."
echo "  ✓ ${BOLD}kill${NC}: Terminate a process using its PID."
echo "  ✓ ${BOLD}&${NC}: Run a command in the background."
echo "  ✓ ${BOLD}jobs${NC}: View background jobs."
echo "  ✓ ${BOLD}systemctl${NC}: The primary tool for managing system services (daemons)."
echo ""
echo "${BOLD}Next Exercise:${NC}"
echo "  Exercise 12 will test you on writing your own simple Bash scripts."
echo ""
echo "${GREEN}Run:${NC} cd ~/devops-progress/2-linux/exercises && ./ex12-bash-scripting.sh"
echo ""
