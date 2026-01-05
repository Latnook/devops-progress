#!/bin/bash

# Interactive Tutorial: Exercise 5 - Hard and Symbolic Links
# Discover the difference between hard and soft links by solving problems

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

WORK_DIR="$HOME/linux-exercises/ex05"
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

# Setup
echo "Original file content." > original_file.txt

clear

echo "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo "${BLUE}║${NC}        ${BOLD}Exercise 5: Hard vs. Symbolic Links${NC}                 ${BLUE}║${NC}"
echo "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "${GREEN}Welcome!${NC} You'll discover the two types of links in Linux and their differences."
echo "Links are pointers to other files or directories."
echo ""
echo "${BOLD}How this works:${NC}"
echo "  • Each task presents a scenario where you need to create a specific type of link."
echo "  • Use '${BOLD}ls -li${NC}' to see file inodes (a unique file identifier)."
echo "  • Use '${BOLD}ln${NC}' to create links. Check its 'man' page to learn how."
echo "  • Type ${CYAN}'hint'${NC} if you get stuck."
echo ""
echo "Working directory: ${YELLOW}$WORK_DIR${NC}"
echo ""
read -p "Press Enter to begin..."

clear

# ============================================================
# TASK 1: Creating a Hard Link
# ============================================================

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 1/$TOTAL_TASKS: Creating a Hard Link${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  You have a critical file, 'original_file.txt'. You want to create a"
echo "  backup copy named 'hard_link_backup.txt' that is indestructible."
echo "  Even if the original file is deleted, the backup must still contain the data."
echo "  This requires creating a 'hard link'."
echo ""
echo "Current file:"
ls -li original_file.txt
echo ""
echo "${BOLD}YOUR GOAL:${NC} Create a hard link named 'hard_link_backup.txt' that points to 'original_file.txt'."
echo ""
echo "Type ${CYAN}'hint'${NC} for help, or try a command:"
echo ""

hint_count=0
while true; do
    read -p "> " user_cmd

    if [[ "$user_cmd" == "hint" ]]; then
        hint_count=$((hint_count + 1))
        case $hint_count in
            1) echo "${CYAN}HINT 1:${NC} The command to create links is 'ln'.";;
            2) echo "${CYAN}HINT 2:${NC} By default, 'ln' creates hard links. The syntax is 'ln <target> <link_name>'.";;
            3) echo "${CYAN}HINT 3:${NC} Try: ln original_file.txt hard_link_backup.txt";;
        esac
    elif handle_help "$user_cmd" "ln"; then
        continue
    elif [[ "$user_cmd" =~ ^ln.*original_file.txt.*hard_link_backup.txt ]]; then
        eval "$user_cmd"
        if [ -f "hard_link_backup.txt" ]; then
            original_inode=$(stat -c "%i" original_file.txt)
            hard_link_inode=$(stat -c "%i" hard_link_backup.txt)

            if [[ "$original_inode" == "$hard_link_inode" ]]; then
                echo ""
                echo "${GREEN}✓ Success!${NC} You've created a hard link."
                ls -li original_file.txt hard_link_backup.txt
                TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
                echo ""
                read -p "Press Enter to continue..."
                break
            else
                 echo "${RED}You created a file, but it's not a hard link. It should have the same inode number as the original.${NC}"
            fi
        else
            echo "${RED}The command didn't create the file. Check your syntax.${NC}"
        fi
    else
        echo "${YELLOW}Use the 'ln' command to create a link from the original file to the new backup name. Type 'hint' if you need help.${NC}"
    fi
done

clear

# ============================================================
# TASK 2: Testing Hard Link Resilience
# ============================================================

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 2/$TOTAL_TASKS: Testing Hard Link Resilience${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  Now, let's test the 'indestructible' nature of the hard link."
echo ""
echo "${BOLD}YOUR GOAL:${NC} First, delete the 'original_file.txt'. Then, prove the data still exists by displaying the contents of 'hard_link_backup.txt'."
echo ""
echo "Type ${CYAN}'hint'${NC} for help, or try a command to remove the original file:"
echo ""

hint_count=0
while true; do
    read -p "> " user_cmd
    if [[ "$user_cmd" == "hint" ]]; then
         echo "${CYAN}HINT:${NC} The command to remove a file is 'rm'."
    elif handle_help "$user_cmd" "rm"; then
        continue
    elif [[ "$user_cmd" =~ ^rm.*original_file.txt ]]; then
        eval "$user_cmd"
        if [ ! -f "original_file.txt" ]; then
            echo ""
            echo "${GREEN}✓ Original file removed.${NC}"
            echo ""
            break
        else
            echo "${RED}The original file still exists. Try 'rm original_file.txt'.${NC}"
        fi
    else
        echo "${YELLOW}First, you need to remove the original file.${NC}"
    fi
done

echo "Now, display the contents of the backup file to prove the data is safe."
echo ""
while true; do
    read -p "> " user_cmd
    if [[ "$user_cmd" == "hint" ]]; then
         echo "${CYAN}HINT:${NC} The command to display file content is 'cat'."
    elif handle_help "$user_cmd" "cat"; then
        continue
    elif [[ "$user_cmd" =~ ^cat.*hard_link_backup.txt ]]; then
        output=$(eval "$user_cmd" 2>&1)
        if [[ "$output" == *"Original file content."* ]]; then
            echo ""
            echo "Output of your command:"
            echo "${CYAN}$output${NC}"
            echo ""
            echo "${GREEN}✓ Perfect!${NC} The data is still there!"
            ls -li hard_link_backup.txt
            TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
            ln hard_link_backup.txt original_file.txt
            echo ""
            read -p "Press Enter to continue..."
            break
        else
            echo "${RED}That didn't display the correct content. Try using 'cat'.${NC}"
        fi
    else
        echo "${YELLOW}Now you need to display the content of 'hard_link_backup.txt'.${NC}"
    fi
done

clear

# ============================================================
# TASK 3: Creating a Symbolic Link
# ============================================================

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 3/$TOTAL_TASKS: Creating a Symbolic (Soft) Link${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  This time, you just want a convenient shortcut to 'original_file.txt'."
echo "  The shortcut should be named 'symbolic_link_shortcut.txt'. If the original"
echo "  is deleted, it's okay for this shortcut to break. This is a 'symbolic link'."
echo ""
echo "Current file:"
ls -li original_file.txt
echo ""
echo "${BOLD}YOUR GOAL:${NC} Create a symbolic link named 'symbolic_link_shortcut.txt' that points to 'original_file.txt'."
echo ""
echo "Type ${CYAN}'hint'${NC} for help, or try a command:"
echo ""

hint_count=0
while true; do
    read -p "> " user_cmd

    if [[ "$user_cmd" == "hint" ]]; then
        hint_count=$((hint_count + 1))
        case $hint_count in
            1) echo "${CYAN}HINT 1:${NC} Use the 'ln' command, but check the 'man' page for an option to create a 'symbolic' link.";;
            2) echo "${CYAN}HINT 2:${NC} The option is '-s'.";;
            3) echo "${CYAN}HINT 3:${NC} Try: ln -s original_file.txt symbolic_link_shortcut.txt";;
        esac
    elif handle_help "$user_cmd" "ln"; then
        continue
    elif [[ "$user_cmd" =~ ^ln.*-s.*original_file.txt.*symbolic_link_shortcut.txt ]]; then
        eval "$user_cmd"
        if [ -L "symbolic_link_shortcut.txt" ]; then
            original_inode=$(stat -c "%i" original_file.txt)
            symlink_inode=$(stat -c "%i" symbolic_link_shortcut.txt)

            if [[ "$original_inode" != "$symlink_inode" ]]; then
                echo ""
                echo "${GREEN}✓ Success!${NC} You've created a symbolic link."
                ls -li original_file.txt symbolic_link_shortcut.txt
                TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
                echo ""
                read -p "Press Enter to continue..."
                break
            else
                 echo "${RED}You created a link, but it's not a symbolic one. It should have a different inode number.${NC}"
            fi
        else
            echo "${RED}The command didn't create a symbolic link. Did you use the '-s' option?${NC}"
        fi
    else
        echo "${YELLOW}Use the 'ln' command. You'll need an option to make the link symbolic. Type 'hint' if stuck.${NC}"
    fi
done

clear

# ============================================================
# TASK 4: Challenge - Breaking a Symbolic Link
# ============================================================

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 4/$TOTAL_TASKS: CHALLENGE - Breaking a Symbolic Link${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  Let's see what happens to a symbolic link when its target disappears."
echo ""
echo "${BOLD}YOUR GOAL:${NC} Delete 'original_file.txt' again. Then, use 'ls -l' to observe the state of the 'symbolic_link_shortcut.txt'."
echo ""
echo "${CYAN}This is a two-step challenge. First delete, then list.${NC}"
echo ""

while true; do
    read -p "First, delete the original file > " user_cmd
    if [[ "$user_cmd" == "hint" ]]; then
         echo "${CYAN}HINT:${NC} Use 'rm original_file.txt'"
    elif handle_help "$user_cmd" "rm"; then
        continue
    elif [[ "$user_cmd" =~ ^rm.*original_file.txt ]]; then
        eval "$user_cmd"
        if [ ! -f "original_file.txt" ]; then
            echo "${GREEN}✓ Original file deleted.${NC}"
            break
        fi
    else
        echo "${YELLOW}Use 'rm' to delete 'original_file.txt'.${NC}"
    fi
done

echo ""
echo "Now, examine the symbolic link with 'ls -l'."
echo ""

while true; do
    read -p "Now, examine the link > " user_cmd
     if [[ "$user_cmd" == "hint" ]]; then
         echo "${CYAN}HINT:${NC} Use 'ls -l symbolic_link_shortcut.txt'"
     elif handle_help "$user_cmd" "ls"; then
        continue
     elif [[ "$user_cmd" =~ ^ls.*-l.*symbolic_link_shortcut.txt ]]; then
        output=$(eval "$user_cmd" 2>&1)
        if echo "$output" | grep -q "symbolic_link_shortcut.txt -> original_file.txt"; then
             echo ""
            eval "$user_cmd"
            echo ""
            echo "${GREEN}✓ Exactly!${NC} You've created a broken link."
            TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
            echo ""
            read -p "Press Enter to continue..."
            break
        else
            echo "${YELLOW}Something's not right. Use 'ls -l' to see the link's status.${NC}"
        fi
    else
        echo "${YELLOW}Use 'ls -l' to examine the link.${NC}"
    fi
done

clear

# ============================================================
# COMPLETION
# ============================================================

cd ..
rm -rf "$WORK_DIR"

echo "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo "${GREEN}║${NC}                ${BOLD}🎉 EXERCISE 5 COMPLETE! 🎉${NC}                     ${GREEN}║${NC}"
echo "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "${BOLD}Outstanding work!${NC} You completed all $TASKS_COMPLETED/$TOTAL_TASKS scenarios."
echo ""
echo "${BOLD}Links You Discovered & Mastered:${NC}"
echo "  ✓ ${BOLD}Hard Links${NC} ('ln target link'):"
echo "    - An identical 'mirror' of a file."
echo "    - Shares the same inode (data)."
echo "    - Deleting the original does NOT delete the data."
echo "    - Cannot link to a directory."
echo "    - Cannot cross filesystems."
echo "  ✓ ${BOLD}Symbolic Links${NC} ('ln -s target link'):"
echo "    - A 'shortcut' or 'pointer' to a file path."
echo "    - Has its own, different inode."
echo "    - Is 'broken' if the original is deleted or moved."
echo "    - CAN link to a directory."
echo "    - CAN cross filesystems."
echo ""
echo "${BOLD}Next Exercise:${NC}"
echo "  Exercise 6 will introduce you to the powerful world of I/O redirection."
echo ""
echo "${GREEN}Run:${NC} cd ~/devops-progress/2-linux/exercises && ./ex06-io-redirection.sh"
echo ""
