#!/bin/bash

# Interactive Tutorial: Exercise 4 - File Permissions
# Master file permissions by solving real-world security scenarios

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

WORK_DIR="$HOME/linux-exercises/ex04"
# Clean up previous runs
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

TASKS_COMPLETED=0
TOTAL_TASKS=5

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
touch "report.txt"
touch "run_me.sh"
mkdir "private_docs"
touch "private_docs/secret.txt"
mkdir "shared_folder"
touch "shared_folder/project_plan.txt"

clear

echo "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo "${BLUE}║${NC}      ${BOLD}Exercise 4: File Permissions - Interactive Tutorial${NC}     ${BLUE}║${NC}"
echo "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "${GREEN}Welcome!${NC} You'll learn to control access to files and directories."
echo "Permissions are a critical security concept in Linux."
echo ""
echo "${BOLD}How this works:${NC}"
echo "  • Each task is a security scenario. Your goal is to set the correct permissions."
echo "  • Use '${BOLD}ls -l${NC}' to view permissions."
echo "  • Use '${BOLD}chmod${NC}' to change them. Discover its options with '--help' or 'man'."
echo "  • Type ${CYAN}'hint'${NC} if you get stuck."
echo ""
echo "Working directory: ${YELLOW}$WORK_DIR${NC}"
echo ""
read -p "Press Enter to begin..."

clear

# ============================================================
# TASK 1: Making a File Executable
# ============================================================

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 1/$TOTAL_TASKS: Making a Script Executable${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  You've written a shell script named 'run_me.sh', but when you try to run it"
echo "  (./run_me.sh), you get a 'Permission denied' error. You need to make it"
echo "  executable for yourself, but keep it read-only for everyone else."
echo ""
echo "Current permissions for 'run_me.sh':"
ls -l run_me.sh
echo ""
echo "${BOLD}YOUR GOAL:${NC} Add the 'execute' permission for ONLY the file's owner (user)."
echo ""
echo "Type ${CYAN}'hint'${NC} for help, or try a command:"
echo ""

hint_count=0
while true; do
    read -p "> " user_cmd

    if [[ "$user_cmd" == "hint" ]]; then
        hint_count=$((hint_count + 1))
        case $hint_count in
            1) echo "${CYAN}HINT 1:${NC} The command to change file modes (permissions) is 'chmod'.";;
            2) echo "${CYAN}HINT 2:${NC} You can add a permission for the 'user' (owner) with 'u+'. The symbol for execute is 'x'.";;
            3) echo "${CYAN}HINT 3:${NC} Try: chmod u+x run_me.sh";;
        esac
    elif handle_help "$user_cmd" "chmod"; then
        continue
    elif [[ "$user_cmd" =~ ^chmod.*u+x.*run_me.sh ]]; then
        eval "$user_cmd"
        perms=$(stat -c "%A" run_me.sh)
        if [[ "${perms:1:3}" == *"x"* ]]; then
            echo ""
            echo "${GREEN}✓ Success!${NC} The script is now executable by you."
            ls -l run_me.sh
            TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
            echo ""
            read -p "Press Enter to continue..."
            break
        else
            echo "${RED}That didn't seem to work. Make sure you are adding the execute permission for the user.${NC}"
        fi
    elif [[ "$user_cmd" =~ ^chmod ]]; then
        echo "${YELLOW}You're using the right command. Now, how do you specify adding execute permission for the user?${NC}"
    else
        echo "${YELLOW}Not quite. What command changes file permissions? Type 'hint' if you need help.${NC}"
    fi
done

clear

# ============================================================
# TASK 2: Using Numeric Modes
# ============================================================

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 2/$TOTAL_TASKS: Setting Exact Permissions with Numbers${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  'report.txt' needs standard file permissions. It should be writable by you"
echo "  (the owner), but only readable by your group and everyone else."
echo "  This is a very common requirement for general files."
echo ""
echo "Current permissions for 'report.txt':"
ls -l report.txt
echo ""
echo "${BOLD}YOUR GOAL:${NC} Set the permissions for 'report.txt' to be 'rw-r--r--'."
echo "  (Hint: You can do this with numbers instead of symbols like 'u+x')."
echo ""
echo "Type ${CYAN}'hint'${NC} for help, or try a command:"
echo ""

hint_count=0
while true; do
    read -p "> " user_cmd

    if [[ "$user_cmd" == "hint" ]]; then
        hint_count=$((hint_count + 1))
        case $hint_count in
            1) echo "${CYAN}HINT 1:${NC} Permissions can be represented by numbers: Read (4), Write (2), Execute (1). Add them up for each category (user, group, other).";;
            2) echo "${CYAN}HINT 2:${NC} You want: User=rw-(4+2=6), Group=r--(4), Other=r--(4). The numeric code is 644.";;
            3) echo "${CYAN}HINT 3:${NC} Try: chmod 644 report.txt";;
        esac
    elif handle_help "$user_cmd" "chmod"; then
        continue
    elif [[ "$user_cmd" =~ ^chmod.*644.*report.txt ]]; then
        eval "$user_cmd"
        perms=$(stat -c "%a" report.txt)
        if [[ "$perms" == "644" ]]; then
            echo ""
            echo "${GREEN}✓ Excellent!${NC} You've set the standard file permissions."
            ls -l report.txt
            TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
            echo ""
            read -p "Press Enter to continue..."
            break
        else
            echo "${RED}That command ran, but the permissions aren't '644'. Check your command.${NC}"
        fi
    elif [[ "$user_cmd" =~ ^chmod ]]; then
        echo "${YELLOW}You're using chmod. Now try using the 3-digit numeric code to set the permissions.${NC}"
    else
        echo "${YELLOW}Use the 'chmod' command. This time, try using numbers. Type 'hint' if stuck.${NC}"
    fi
done

clear

# ============================================================
# TASK 3: Protecting a Directory
# ============================================================

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 3/$TOTAL_TASKS: Securing a Private Directory${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  The 'private_docs' directory and its contents are for your eyes only."
echo "  No one else on the system—not your group, not others—should be able"
echo "  to read, write, or even list the contents of this directory."
echo ""
echo "Current permissions:"
ls -ld private_docs
ls -l private_docs
echo ""
echo "${BOLD}YOUR GOAL:${NC} Remove ALL permissions for the 'group' and 'others' from the 'private_docs' directory itself."
echo ""
echo "Type ${CYAN}'hint'${NC} for help, or try a command:"
echo ""

hint_count=0
while true; do
    read -p "> " user_cmd

    if [[ "$user_cmd" == "hint" ]]; then
        hint_count=$((hint_count + 1))
        case $hint_count in
            1) echo "${CYAN}HINT 1:${NC} You can set permissions for group and other at the same time with 'go'.";;
            2) echo "${CYAN}HINT 2:${NC} The '=' operator sets exact permissions. What would you set group and other to for no permissions?";;
            3) echo "${CYAN}HINT 3:${NC} Try: chmod go= private_docs  (The equals sign with nothing after it removes all permissions).";;
            4) echo "${CYAN}HINT 4:${NC} Or, with numbers: chmod 700 private_docs";;
        esac
    elif handle_help "$user_cmd" "chmod"; then
        continue
    elif [[ "$user_cmd" =~ ^chmod.*private_docs ]]; then
        eval "$user_cmd"
        perms=$(stat -c "%A" private_docs)
        if [[ "${perms:4:6}" == "------" ]]; then
            echo ""
            echo "${GREEN}✓ Perfect!${NC} The directory is now completely private."
            ls -ld private_docs
            TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
            echo ""
            read -p "Press Enter to continue..."
            break
        else
            echo "${YELLOW}Not quite. The permissions for group and other should be '------'.${NC}"
        fi
    else
        echo "${YELLOW}Use 'chmod'. You need to remove permissions from group and other for 'private_docs'. Type 'hint' if stuck.${NC}"
    fi
done

clear

# ============================================================
# TASK 4: The Sticky Bit
# ============================================================

chmod 777 shared_folder

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 4/$TOTAL_TASKS: The 'Sticky Bit' for Shared Directories${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  The 'shared_folder' is a collaborative space like '/tmp'. Everyone needs to"
echo "  be able to create files in it. However, a major security flaw exists:"
echo "  any user can delete any other user's files. This is dangerous."
echo ""
echo "Current permissions on 'shared_folder':"
ls -ld shared_folder
echo ""
echo "${BOLD}YOUR GOAL:${NC} Set the special permission on 'shared_folder' that allows users to delete ONLY their own files, even if the directory is world-writable."
echo ""
echo "Type ${CYAN}'hint'${NC} for help, or try a command:"
echo ""

hint_count=0
while true; do
    read -p "> " user_cmd

    if [[ "$user_cmd" == "hint" ]]; then
        hint_count=$((hint_count + 1))
        case $hint_count in
            1) echo "${CYAN}HINT 1:${NC} This requires a 'special permission'. The one you're looking for is called the 'sticky bit'.";;
            2) echo "${CYAN}HINT 2:${NC} You can add it with symbolic mode '+t'.";;
            3) echo "${CYAN}HINT 3:${NC} Try: chmod +t shared_folder";;
            4) echo "${CYAN}HINT 4:${NC} With numeric mode, it's the first digit: 1. So you'd use 'chmod 1777 shared_folder'.";;
        esac
    elif handle_help "$user_cmd" "chmod"; then
        continue
    elif [[ "$user_cmd" =~ ^chmod.*shared_folder ]]; then
        eval "$user_cmd"
        perms=$(stat -c "%A" shared_folder)
        if [[ "${perms:9:1}" == "t" ]] || [[ "${perms:9:1}" == "T" ]]; then
            echo ""
            echo "${GREEN}✓ Success!${NC} The shared directory is now secure."
            ls -ld shared_folder
            TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
            echo ""
            read -p "Press Enter to continue..."
            break
        else
            echo "${YELLOW}The permissions are not quite right. You need to add the sticky bit. Look for a 't' in the permissions.${NC}"
        fi
    else
        echo "${YELLOW}Use 'chmod'. You need to add a special permission to 'shared_folder'. Type 'hint' if you're stuck.${NC}"
    fi
done

clear

# ============================================================
# TASK 5: Challenge - SUID
# ============================================================

echo '#!/bin/bash' > view_log.sh
echo 'echo "Viewing secret logs..."' >> view_log.sh
chmod 755 view_log.sh


echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 5/$TOTAL_TASKS: CHALLENGE - The SUID Bit${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  The script 'view_log.sh' needs to be run by regular users, but it must"
echo "  execute with the permissions of its owner (let's imagine its owner is 'root')."
echo "  This is a powerful and potentially dangerous permission, used by commands"
echo "  like 'passwd' to modify files regular users can't normally touch."
echo ""
echo "Current permissions:"
ls -l view_log.sh
echo ""
echo "${BOLD}YOUR GOAL:${NC} Set the special 'Set User ID' (SUID) permission on 'view_log.sh'."
echo ""
echo "${CYAN}Try to figure this out without hints. Check the 'man chmod' page for 'SUID'.${NC}"
echo ""

hint_count=0
while true; do
    read -p "> " user_cmd

    if [[ "$user_cmd" == "hint" ]]; then
        hint_count=$((hint_count + 1))
        case $hint_count in
            1) echo "${CYAN}HINT 1:${NC} In symbolic mode, the SUID bit is represented by 's' and applies to the user.";;
            2) echo "${CYAN}HINT 2:${NC} Try: chmod u+s view_log.sh";;
            3) echo "${CYAN}HINT 3:${NC} In numeric mode, the SUID bit is the first of four digits: 4. Example: chmod 4755 script.sh";;
        esac
    elif handle_help "$user_cmd" "chmod"; then
        continue
    elif [[ "$user_cmd" =~ ^chmod.*view_log.sh ]]; then
        eval "$user_cmd"
        perms=$(stat -c "%A" view_log.sh)
        if [[ "${perms:3:1}" == "s" ]] || [[ "${perms:3:1}" == "S" ]]; then
            echo ""
            echo "${GREEN}✓ EXCELLENT!${NC} You've set the SUID bit."
            ls -l view_log.sh
            TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
            echo ""
            read -p "Press Enter to continue..."
            break
        else
             echo "${YELLOW}The SUID bit doesn't seem to be set. Look for an 's' in the user permission block.${NC}"
        fi
    else
        echo "${YELLOW}Use 'chmod'. You are looking for a special permission related to 'Set User ID'. Type 'hint' if stuck.${NC}"
    fi
done


clear

# ============================================================
# COMPLETION
# ============================================================

cd ..
rm -rf "$WORK_DIR"

echo "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo "${GREEN}║${NC}                ${BOLD}🎉 EXERCISE 4 COMPLETE! 🎉${NC}                     ${GREEN}║${NC}"
echo "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "${BOLD}Outstanding work!${NC} You completed all $TASKS_COMPLETED/$TOTAL_TASKS scenarios."
echo ""
echo "${BOLD}Permissions You Discovered & Mastered:${NC}"
echo "  ✓ Changing permissions with ${BOLD}chmod${NC}."
echo "  ✓ ${BOLD}Symbolic Mode${NC}: 'u+x' (user add execute), 'go=' (group/other set to nothing)."
echo "  ✓ ${BOLD}Numeric Mode${NC}: '644' (rw-r--r--), '700' (rwx------)."
echo "  ✓ The ${BOLD}SUID bit${NC} ('u+s' or '4755'): Run a file as its owner."
echo "  ✓ The ${BOLD}Sticky Bit${NC} ('+t' or '1777'): Protect files in a shared directory."
echo ""
echo "${BOLD}Next Exercise:${NC}"
echo "  Exercise 5 will cover the difference between hard and symbolic links."
echo ""
echo "${GREEN}Run:${NC} cd ~/devops-progress/2-linux/exercises && ./ex05-links.sh"
echo ""
