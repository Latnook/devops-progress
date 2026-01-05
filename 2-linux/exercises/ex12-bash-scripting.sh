#!/bin/bash

# Interactive Tutorial: Exercise 12 - Bash Scripting
# Learn to write your own simple Bash scripts

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

WORK_DIR="$HOME/linux-exercises/ex12"
# Clean up previous runs
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

TASKS_COMPLETED=0
TOTAL_TASKS=4

clear

echo "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo "${BLUE}║${NC}       ${BOLD}Exercise 12: Bash Scripting - Interactive Tutorial${NC}       ${BLUE}║${NC}"
echo "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "${GREEN}Welcome!${NC} You've learned many commands. Now you'll learn to combine them"
echo "into reusable, automated scripts."
echo ""
echo "${BOLD}How this works:${NC}"
echo "  • In each task, you will write a simple script to solve a problem."
echo "  • We will use 'nano' as a simple text editor. Type '${BOLD}Ctrl+X${NC}' to exit."
echo "  • You'll learn about variables, arguments, and loops."
echo "  • Type ${CYAN}'hint'${NC} if you get stuck."
echo ""
echo "Working directory: ${YELLOW}$WORK_DIR${NC}"
echo ""
read -p "Press Enter to begin..."

clear

# ============================================================
# TASK 1: Your First Script with Variables
# ============================================================

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 1/$TOTAL_TASKS: Writing Your First Script${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  You need to create a script named 'welcome.sh' that greets a specific user."
echo "  The script should use a variable to hold the user's name."
echo ""
echo "${BOLD}YOUR GOAL:${NC}"
echo "  1. Create a script named 'welcome.sh'."
echo "  2. The script must start with the 'shebang': ${CYAN}#!/bin/bash${NC}"
echo "  3. Inside, create a variable: ${CYAN}USER_NAME=\"Alice\"${NC}"
echo "  4. It should then print the message: 'Hello, Alice'"
echo "  5. Make the script executable and run it."
echo ""
echo "First, run the command to edit the file. We'll check its contents after you exit."
echo "Type ${CYAN}'hint'${NC} for help, or type the command to start editing."
echo ""

hint_count=0
while true; do
    read -p "edit> " user_cmd

    if [[ "$user_cmd" == "hint" ]]; then
        hint_count=$((hint_count + 1))
        case $hint_count in
            1)
                echo "${CYAN}HINT 1:${NC} Use a text editor like 'nano' to create the file: nano welcome.sh"
                ;;
            2)
                echo "${CYAN}HINT 2:${NC} Inside nano, type the shebang, the variable, and the 'echo' command. Use \$VAR_NAME to access a variable's value."
                ;;
            3)
                echo "${CYAN}HINT 3:${NC} The script should look like this:"
                echo "#!/bin/bash"
                echo "USER_NAME=\"Alice\""
                echo "echo \"Hello, \$USER_NAME\""
                ;;
        esac
    elif [[ "$user_cmd" == "nano welcome.sh" ]]; then
        # Create a dummy script for them to edit
        echo "#!/bin/bash" > welcome.sh
        echo "" >> welcome.sh
        echo "# Enter your script content here" >> welcome.sh
        
        eval "$user_cmd"
        
        # Check the script's content
        if grep -q "USER_NAME=\"Alice\"" welcome.sh && grep -q "echo.*Hello.*\$USER_NAME" welcome.sh; then
            echo ""
            echo "${GREEN}✓ Script created successfully!${NC}"
            echo ""
            break
        else
            echo "${RED}The script content isn't quite right. It needs a variable and an echo command. Try editing it again.${NC}"
            rm welcome.sh
        fi
    else
        echo "${YELLOW}Use 'nano welcome.sh' to start editing the script.${NC}"
    fi
done

echo "Now, make the script executable and run it."
hint_count=0
while true; do
    read -p "run> " user_cmd
     if [[ "$user_cmd" == "hint" ]]; then
        hint_count=$((hint_count + 1))
        case $hint_count in
            1)
                echo "${CYAN}HINT 1:${NC} You need to use 'chmod' to make it executable first."
                ;;
            2)
                echo "${CYAN}HINT 2:${NC} After 'chmod +x welcome.sh', you can run it with './welcome.sh'"
                ;;
        esac
    elif [[ "$user_cmd" == *"./welcome.sh"* ]]; then
        # They might try to run it without making it executable
        if [ ! -x "welcome.sh" ]; then
            echo "${RED}Permission denied! You must make the script executable first with 'chmod'.${NC}"
            continue
        fi
        output=$(eval "$user_cmd" 2>/dev/null)
        if [[ "$output" == "Hello, Alice" ]]; then
            echo ""
            echo "${GREEN}✓ Success!${NC} You wrote and executed your first script."
            echo ""
            echo "${BOLD}Discovery:${NC}"
            echo "  - Scripts start with a shebang (${CYAN}#!/bin/bash${NC}) to specify the interpreter."
            echo "  - Variables are assigned with ${CYAN}NAME=\"Value\"${NC} (no spaces)."
            echo "  - Variables are accessed with a dollar sign (${CYAN}\$NAME${NC})."
            echo "  - Scripts must be made executable (${CYAN}chmod +x${NC}) before they can be run."
            TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
            echo ""
            read -p "Press Enter to continue..."
            break
        else
            echo "${RED}The script ran, but the output was not 'Hello, Alice'. Check the script's content.${NC}"
        fi
    elif [[ "$user_cmd" == *"chmod"* ]]; then
        eval "$user_cmd"
        if [ -x "welcome.sh" ]; then
            echo "${GREEN}✓ Script is now executable. Now run it!${NC}"
        else
            echo "${RED}That didn't make the script executable. Try 'chmod +x welcome.sh'${NC}"
        fi
    else
        echo "${YELLOW}You need to make the script executable and then run it. Use 'chmod' and then './welcome.sh'.${NC}"
    fi
done

clear

# ============================================================
# TASK 2: Using Arguments
# ============================================================

cat > "greeter.sh" << EOF
#!/bin/bash
# A simple greeter script
echo "Hello, \$1"
EOF
chmod +x greeter.sh

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 2/$TOTAL_TASKS: Using Script Arguments${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  Your previous script was not very flexible because the name was hard-coded."
echo "  A better script would accept the name as an 'argument' from the command line."
echo "  We've created a script 'greeter.sh' for you that does this."
echo ""
echo "Content of 'greeter.sh':"
cat greeter.sh
echo ""
echo "${BOLD}YOUR GOAL:${NC} Run the 'greeter.sh' script, passing the name 'Bob' as the first argument, to produce the output 'Hello, Bob'."
echo ""
echo "Type ${CYAN}'hint'${NC} for help, or try a command:"
echo ""

hint_count=0
while true; do
    read -p "> " user_cmd

    if [[ "$user_cmd" == "hint" ]]; then
        hint_count=$((hint_count + 1))
        case $hint_count in
            1)
                echo "${CYAN}HINT 1:${NC} You can pass arguments to a script by putting them after the script's name, separated by spaces."
                ;;
            2)
                echo "${CYAN}HINT 2:${NC} Try: ./greeter.sh Bob"
                ;;
        esac
    elif [[ "$user_cmd" == *"./greeter.sh"* ]]; then
        output=$(eval "$user_cmd" 2>/dev/null)
        if [[ "$output" == "Hello, Bob" ]]; then
            echo ""
            echo "${GREEN}✓ Perfect!${NC} You've passed an argument to the script."
            echo ""
            echo "${BOLD}Discovery:${NC}"
            echo "  Inside a script, special variables hold the arguments passed to it:"
            echo "  - ${CYAN}\$1${NC} holds the first argument."
            echo "  - ${CYAN}\$2${NC} holds the second, and so on."
            echo "  - ${CYAN}\$@${NC} holds all arguments."
            echo "  - ${CYAN}\$#${NC} holds the count of arguments."
            TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
            echo ""
            read -p "Press Enter to continue..."
            break
        elif [[ "$output" == "Hello, " ]]; then
            echo "${RED}You ran the script, but didn't pass an argument, so \$1 was empty.${NC}"
        else
            echo "${RED}The output was not 'Hello, Bob'. Did you pass the correct name?${NC}"
        fi
    else
        echo "${YELLOW}You need to run './greeter.sh' and provide 'Bob' as an argument. Type 'hint' if you are stuck.${NC}"
    fi
done

clear

# ============================================================
# TASK 3: Using a For Loop
# ============================================================

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 3/$TOTAL_TASKS: Looping with a 'for' loop${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  You need a script that processes a list of files. A 'for' loop is the perfect tool for this."
echo ""
echo "${BOLD}YOUR GOAL:${NC} Write a script named 'backup.sh' that:"
echo "  1. Starts with the shebang."
echo "  2. Loops through three filenames: 'file1.txt', 'file2.txt', 'file3.log'."
echo "  3. Inside the loop, it should print a message like 'Backing up file...'"
echo "  4. Make it executable and run it."
echo ""
echo "Start by using 'nano backup.sh' to create the script."
echo ""

hint_count=0
while true; do
    read -p "edit> " user_cmd

    if [[ "$user_cmd" == "hint" ]]; then
        hint_count=$((hint_count + 1))
        case $hint_count in
            1)
                echo "${CYAN}HINT 1:${NC} The for loop syntax is: for VAR_NAME in item1 item2 item3; do ... done"
                ;;
            2)
                echo "${CYAN}HINT 2:${NC} Inside the loop, you can access the current item with \$VAR_NAME."
                ;;
            3)
                echo "${CYAN}HINT 3:${NC} Try this script content:"
                echo "#!/bin/bash"
                echo "for FILENAME in file1.txt file2.txt file3.log; do"
                echo "  echo \"Backing up \$FILENAME\""
                echo "done"
                ;;
        esac
    elif [[ "$user_cmd" == "nano backup.sh" ]]; then
        eval "$user_cmd"
        # Check the script's content
        if grep -q "for" backup.sh && grep -q "in" backup.sh && grep -q "do" backup.sh && grep -q "done" backup.sh && grep -q "echo.*Backing up" backup.sh; then
            echo ""
            echo "${GREEN}✓ Script created successfully!${NC}"
            echo ""
            break
        else
            echo "${RED}The script doesn't seem to contain a valid 'for' loop. Try editing it again.${NC}"
            rm -f backup.sh
        fi
    else
        echo "${YELLOW}Use 'nano backup.sh' to start editing the script.${NC}"
    fi
done

echo "Now, make the script executable and run it."
hint_count=0
while true; do
    read -p "run> " user_cmd
     if [[ "$user_cmd" == "hint" ]]; then
        echo "${CYAN}HINT:${NC} Use 'chmod +x backup.sh' then './backup.sh'."
     elif [[ "$user_cmd" == *"./backup.sh"* ]]; then
        if [ ! -x "backup.sh" ]; then
            echo "${RED}Permission denied! You must make the script executable first.${NC}"
            continue
        fi
        output=$(eval "$user_cmd" 2>/dev/null)
        line_count=$(echo "$output" | wc -l)
        if [ "$line_count" -eq 3 ] && echo "$output" | grep -q "file1.txt" && echo "$output" | grep -q "file3.log"; then
            echo ""
            echo "${GREEN}✓ Excellent!${NC} The script looped through all the files."
            echo ""
            echo "Your script's output:"
            echo "${CYAN}$output${NC}"
            echo ""
            TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
            echo ""
            read -p "Press Enter to continue..."
            break
        else
            echo "${RED}The script output was incorrect. It should have printed three 'Backing up...' lines.${NC}"
        fi
    elif [[ "$user_cmd" == *"chmod"* ]]; then
        eval "$user_cmd"
        if [ -x "backup.sh" ]; then
            echo "${GREEN}✓ Script is now executable. Now run it!${NC}"
        fi
    else
        echo "${YELLOW}Make the script executable, then run it.${NC}"
    fi
done


clear

# ============================================================
# TASK 4: Challenge - Conditionals
# ============================================================

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 4/$TOTAL_TASKS: CHALLENGE - Conditional Logic${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  You need a script that checks if a specific file exists before trying to use it."
echo ""
echo "${BOLD}YOUR GOAL:${NC} Create a script named 'checker.sh' that:"
echo "  1. Accepts a filename as its first argument (\$1)."
echo "  2. Uses an 'if' statement to check if that file exists."
echo "  3. If it exists, it should print 'File found!'."
echo "  4. If it does NOT exist, it should print 'File not found!'."
echo "  5. We will test it with a file that does exist ('real_file.txt') and one that doesn't."
echo ""
touch real_file.txt
echo "Use 'nano checker.sh' to create the script."
echo ""

hint_count=0
while true; do
    read -p "edit> " user_cmd

    if [[ "$user_cmd" == "hint" ]]; then
        hint_count=$((hint_count + 1))
        case $hint_count in
            1)
                echo "${CYAN}HINT 1:${NC} The 'if' statement syntax is: if [ <condition> ]; then ... else ... fi"
                ;;
            2)
                echo "${CYAN}HINT 2:${NC} The condition to check if a file exists is '-f'. So the condition would be '[ -f \"\$1\" ]'."
                ;;
            3)
                echo "${CYAN}HINT 3:${NC} Full script example:"
                echo "#!/bin/bash"
                echo "if [ -f \"\$1\" ]; then"
                echo "  echo \"File found!\""
                echo "else"
                echo "  echo \"File not found!\""
                echo "fi"
                ;;
        esac
    elif [[ "$user_cmd" == "nano checker.sh" ]]; then
        eval "$user_cmd"
        if grep -q "if" checker.sh && grep -q "then" checker.sh && grep -q "else" checker.sh && grep -q "fi" checker.sh && grep -q -- "-f \"\$1\"" checker.sh; then
            echo ""
            echo "${GREEN}✓ Script created successfully!${NC}"
            break
        else
            echo "${RED}The script doesn't seem to have a valid 'if' statement with the '-f' test. Try again.${NC}"
            rm -f checker.sh
        fi
    else
        echo "${YELLOW}Use 'nano checker.sh' to start.${NC}"
    fi
done

echo ""
echo "Now, make the script executable and run it twice:"
echo "1. With 'real_file.txt' as an argument."
echo "2. With 'fake_file.txt' as an argument."
echo ""

chmod +x checker.sh

# Test 1
while true; do
    read -p "run test 1> " user_cmd
     if [[ "$user_cmd" == "hint" ]]; then
        echo "${CYAN}HINT:${NC} Run './checker.sh real_file.txt'"
     elif [[ "$user_cmd" == "./checker.sh real_file.txt" ]]; then
        output=$(eval "$user_cmd")
        if [[ "$output" == "File found!" ]]; then
            echo "${GREEN}✓ Correct! The file was found.${NC}"
            break
        else
            echo "${RED}The output was wrong. It should have found the file.${NC}"
        fi
     else
        echo "${YELLOW}Run the script with 'real_file.txt' as the argument.${NC}"
     fi
done

# Test 2
while true; do
    read -p "run test 2> " user_cmd
     if [[ "$user_cmd" == "hint" ]]; then
        echo "${CYAN}HINT:${NC} Run './checker.sh fake_file.txt'"
     elif [[ "$user_cmd" == "./checker.sh fake_file.txt" ]]; then
        output=$(eval "$user_cmd")
        if [[ "$output" == "File not found!" ]]; then
            echo "${GREEN}✓ Correct! The file was not found.${NC}"
            TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
            read -p "Press Enter to continue..."
            break
        else
            echo "${RED}The output was wrong. It should NOT have found the file.${NC}"
        fi
     else
        echo "${YELLOW}Now run the script with 'fake_file.txt' as the argument.${NC}"
     fi
done


clear

# ============================================================
# COMPLETION
# ============================================================

# Final cleanup
cd ..
rm -rf "$WORK_DIR"

echo "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo "${GREEN}║${NC}               ${BOLD}🎉 EXERCISE 12 COMPLETE! 🎉${NC}                    ${GREEN}║${NC}"
echo "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "${BOLD}Congratulations!${NC} You've learned the basic building blocks of Bash scripting."
echo ""
echo "${BOLD}Scripting Concepts You Mastered:${NC}"
echo "  ✓ The Shebang: ${BOLD}#!/bin/bash${NC}"
echo "  ✓ Variables: ${BOLD}NAME=\"value\"${NC} and accessing with ${BOLD}\$NAME${NC}."
echo "  ✓ Arguments: Reading command-line input with ${BOLD}\$1${NC}, ${BOLD}\$2${NC}, etc."
echo "  ✓ For Loops: Iterating over a list of items."
echo "  ✓ Conditionals: Using ${BOLD}if [ ... ]; then ... fi${NC} to make decisions."
echo "  ✓ File tests: Checking if a file exists with ${BOLD}[ -f ... ]${NC}."
echo ""
echo "${BOLD}Next Exercise:${NC}"
echo "  Exercise 13 will introduce the powerful text-processing utilities 'sed' and 'awk'."
echo ""
echo "${GREEN}Run:${NC} cd ~/devops-progress/2-linux/exercises && ./ex13-sed-awk.sh"
echo ""
