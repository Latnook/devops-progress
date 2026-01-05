#!/bin/bash

# Interactive Tutorial: Exercise 13 - Sed and Awk
# Master advanced text processing with stream editing and pattern scanning

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

WORK_DIR="$HOME/linux-exercises/ex13"
# Clean up previous runs
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

TASKS_COMPLETED=0
TOTAL_TASKS=4

# Function to handle help commands
handle_help() {
    local cmd="$1"
    for main_cmd in sed awk; do
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

# Setup test file
cat > "data.csv" << EOF
product_id,product_name,category,price,in_stock
101,Laptop,Electronics,1200,yes
102,Mouse,Electronics,25,yes
103,T-Shirt,Apparel,20,no
104,Keyboard,Electronics,75,yes
105,Jeans,Apparel,60,yes
EOF

clear

echo "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo "${BLUE}║${NC}        ${BOLD}Exercise 13: Sed and Awk - Interactive Tutorial${NC}       ${BLUE}║${NC}"
echo "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "${GREEN}Welcome!${NC} You will now learn two of the most powerful text-processing tools:"
echo "'sed' (the Stream Editor) and 'awk' (a pattern-scanning language)."

echo ""
echo "${BOLD}How this works:${NC}"

echo "  • Each task requires you to manipulate or extract data from a sample file."
echo "  • You'll discover how 'sed' and 'awk' work through problem-solving."
echo "  • Type ${CYAN}'hint'${NC} if you get stuck."

echo ""
echo "We'll be working with this 'data.csv' file:"
cat data.csv
echo ""
read -p "Press Enter to begin..."

clear

# ============================================================ 
# TASK 1: Substituting Text with 'sed'
# ============================================================ 

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 1/$TOTAL_TASKS: Find and Replace with 'sed'${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  The 'data.csv' file uses 'yes' and 'no' to indicate stock status."
echo "  This is not very clear. You need to replace every instance of 'yes' with"
echo "  'AVAILABLE' to make the output more readable."

echo ""
echo "${BOLD}YOUR GOAL:${NC} Use 'sed' to substitute all occurrences of 'yes' with 'AVAILABLE' in the 'data.csv' file."

echo ""
echo "Type ${CYAN}'hint'${NC} for help, or try a command:"


hint_count=0
while true; do
    read -p "> " user_cmd

    if [[ "$user_cmd" == "hint" ]]; then
        hint_count=$((hint_count + 1))
        case $hint_count in
            1) echo "${CYAN}HINT 1:${NC} 'sed' is the 'stream editor'. Its most common use is for substitution.";;
            2) echo "${CYAN}HINT 2:${NC} The basic syntax is: sed 's/old_text/new_text/g' filename";;
            3) echo "${CYAN}HINT 3:${NC} 's' stands for substitute, and 'g' stands for global (replace all on a line, not just the first).";;
            4) echo "${CYAN}HINT 4:${NC} Try: sed 's/yes/AVAILABLE/g' data.csv";;
        esac
    elif handle_help "$user_cmd" "sed"; then
        continue
    elif [[ "$user_cmd" == *"sed"* && "$user_cmd" == *"s/yes/AVAILABLE/g"* && "$user_cmd" == *"data.csv"* ]]; then
        output=$(eval "$user_cmd" 2>/dev/null)
        if echo "$output" | grep -q "AVAILABLE" && ! echo "$output" | grep -q ",yes"; then
            echo ""
            echo "${GREEN}✓ Success!${NC} You've substituted the text."
            echo "Your transformed output:"
            echo "${CYAN}$output${NC}"
            TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
            echo ""
            read -p "Press Enter to continue..."
            break
        else
            echo "${RED}That didn't produce the correct output. Make sure you are replacing 'yes' with 'AVAILABLE'.${NC}"
        fi
    else
        echo "${YELLOW}Use the 'sed' command. You need to use its substitute 's' command. Type 'hint' if you need help.${NC}"
    fi
done

clear

# ============================================================ 
# TASK 2: Printing Specific Columns with 'awk'
# ============================================================ 

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 2/$TOTAL_TASKS: Extracting Columns with 'awk'${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  You don't need all the data from 'data.csv'. You have been asked for a"
echo "  simple list containing just the product name and its price."
echo "  'awk' is the perfect tool for this, as it is designed to process columnar data."

echo ""
echo "${BOLD}YOUR GOAL:${NC} Use 'awk' to print only the product name (column 2) and the price (column 4) from 'data.csv'."

echo ""
echo "Type ${CYAN}'hint'${NC} for help, or try a command:"


hint_count=0
while true; do
    read -p "> " user_cmd

    if [[ "$user_cmd" == "hint" ]]; then
        hint_count=$((hint_count + 1))
        case $hint_count in
            1) echo "${CYAN}HINT 1:${NC} 'awk' processes text line by line and splits each line into fields.";;
            2) echo "${CYAN}HINT 2:${NC} You need to tell 'awk' that the fields are separated by a comma. Use the '-F' option: awk -F',' '{...}'";;
            3) echo "${CYAN}HINT 3:${NC} Inside the curly braces, you can access columns with \$1, \$2, etc. You want to print column 2 and column 4.";;
            4) echo "${CYAN}HINT 4:${NC} Try: awk -F',' '{print \$2, \$4}' data.csv";;
        esac
    elif handle_help "$user_cmd" "awk"; then
        continue
    elif [[ "$user_cmd" == *"awk"* && "$user_cmd" == *"-F,"* && "$user_cmd" == *"print"* && "$user_cmd" == *"\$2"* && "$user_cmd" == *"\$4"* && "$user_cmd" == *"data.csv"* ]]; then
        output=$(eval "$user_cmd" 2>/dev/null)
        if echo "$output" | grep -q "Laptop 1200" && echo "$output" | grep -q "Jeans 60"; then
            echo ""
            echo "${GREEN}✓ Perfect!${NC} You've extracted the specific columns."
            echo "Your output:"
            echo "${CYAN}$output${NC}"
            TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
            echo ""
            read -p "Press Enter to continue..."
            break
        else
            echo "${RED}The output isn't quite right. It should contain only the product names and prices.${NC}"
        fi
    else
        echo "${YELLOW}Use 'awk'. You need to set the Field separator (-F) and then 'print' the desired columns. Type 'hint' if stuck.${NC}"
    fi
done

clear

# ============================================================ 
# TASK 3: Filtering Rows and Columns with 'awk'
# ============================================================ 

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 3/$TOTAL_TASKS: Filtering and Extracting with 'awk'${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  Now for a more complex query. You need a list of product names and prices,"
echo "  but ONLY for products in the 'Electronics' category."

echo ""
echo "${BOLD}YOUR GOAL:${NC} Use a single 'awk' command to print the product name and price for lines where the category (column 3) is 'Electronics'."

echo ""
echo "Type ${CYAN}'hint'${NC} for help, or try a command:"


hint_count=0
while true; do
    read -p "> " user_cmd

    if [[ "$user_cmd" == "hint" ]]; then
        hint_count=$((hint_count + 1))
        case $hint_count in
            1) echo "${CYAN}HINT 1:${NC} 'awk' can take a pattern before its action block: awk -F',' '/pattern/ {action}'";;
            2) echo "${CYAN}HINT 2:${NC} You can also use an if statement inside the action block: '{ if (\$3 == \"Electronics\" ) print \$2, \$4 }'";;
            3) echo "${CYAN}HINT 3:${NC} Try: awk -F',' '\\$3 == \"Electronics\" {print \$2, \$4}' data.csv";;
        esac
    elif handle_help "$user_cmd" "awk"; then
        continue
    elif [[ "$user_cmd" == *"awk"* && "$user_cmd" == *"-F,"* && "$user_cmd" == *"Electronics"* && "$user_cmd" == *"print"* && "$user_cmd" == *"\$2"* && "$user_cmd" == *"\$4"* ]]; then
        output=$(eval "$user_cmd" 2>/dev/null)
        line_count=$(echo "$output" | wc -l)
        if [ "$line_count" -eq 3 ] && echo "$output" | grep -q "Laptop" && echo "$output" | grep -q "Mouse" && echo "$output" | grep -q "Keyboard"; then
            echo ""
            echo "${GREEN}✓ Excellent!${NC} You filtered rows and extracted columns in one command."
            echo "Your output:"
            echo "${CYAN}$output${NC}"
            TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
            echo ""
            read -p "Press Enter to continue..."
            break
        else
            echo "${RED}That's not the right output. It should only contain the three products from the 'Electronics' category.${NC}"
        fi
    else
        echo "${YELLOW}Use 'awk'. You need to add a condition to check the third column before you print. Type 'hint' if you're stuck.${NC}"
    fi
done

clear

# ============================================================ 
# TASK 4: Challenge - Calculation with 'awk'
# ============================================================ 

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 4/$TOTAL_TASKS: CHALLENGE - Calculating a Total with 'awk'${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  You've been asked to find the total value of all 'Electronics' currently in stock."

echo ""
echo "${BOLD}YOUR GOAL:${NC} Use a single 'awk' command to calculate the sum of the prices (column 4) for all products in the 'Electronics' category (column 3) that are in stock (column 5 is 'yes')."
echo "  The final output should be just the total number."

echo ""
echo "Type ${CYAN}'hint'${NC} for help, or try a command:"


hint_count=0
while true; do
    read -p "> " user_cmd

    if [[ "$user_cmd" == "hint" ]]; then
        hint_count=$((hint_count + 1))
        case $hint_count in
            1) echo "${CYAN}HINT 1:${NC} 'awk' can have variables. You can create a condition to check both columns: \$3 == \"Electronics\" && \$5 == \"yes\"";;
            2) echo "${CYAN}HINT 2:${NC} Inside the action block for that condition, you can add the price to a running total: 'total += \$4'.";;
            3) echo "${CYAN}HINT 3:${NC} 'awk' has a special block, 'END', that runs after all lines are processed. You can print the total there: 'END {print total}'";;
            4) echo "${CYAN}HINT 4:${NC} Try: awk -F',' '\\$3 == \"Electronics\" && \\$5 == \"yes\" {total += \$4} END {print total}' data.csv";;
        esac
    elif handle_help "$user_cmd" "awk"; then
        continue
    elif [[ "$user_cmd" == *"awk"* && "$user_cmd" == *"-F,"* && "$user_cmd" == *"total"* && "$user_cmd" == *"END"* ]]; then
        output=$(eval "$user_cmd" 2>/dev/null | tr -d '[:space:]')
        if [[ "$output" == "1300" ]]; then
            echo ""
            echo "${GREEN}✓ OUTSTANDING!${NC} You've performed a calculation with awk."
            echo "Your final calculated total: ${CYAN}$output${NC}"
            TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
            echo ""
            read -p "Press Enter to continue..."
            break
        else
            echo "${RED}That's not the correct total. The total value of in-stock electronics should be 1300.${NC}"
        fi
    else
        echo "${YELLOW}This is a complex 'awk' command. You'll need a condition, a running total, and an END block. Type 'hint' if you're stuck.${NC}"
    fi
done

clear

# ============================================================ 
# COMPLETION
# ============================================================ 

cd ..
rm -rf "$WORK_DIR"

echo "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo "${GREEN}║${NC}               ${BOLD}🎉 EXERCISE 13 COMPLETE! 🎉${NC}                    ${GREEN}║${NC}"
echo "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "${BOLD}Incredible work!${NC} You've mastered the basics of 'sed' and 'awk'."

echo ""
echo "${BOLD}Commands and Concepts You Mastered:${NC}"
echo "  ✓ ${BOLD}sed${NC}: The Stream Editor, perfect for find-and-replace operations ('s/old/new/g')."
echo "  ✓ ${BOLD}awk${NC}: A powerful, column-aware text processing language."
echo "    - Setting delimiters with ${BOLD}-F${NC}. "
echo "    - Accessing columns with ${BOLD}\$1, \$2, ...${NC}"
echo "    - Filtering rows with conditions."
echo "    - Performing calculations and using blocks like ${BOLD}END${NC}. "

echo ""
echo "${YELLOW}You have completed all the Linux exercises! Feel free to go back and practice them again.${NC}"
echo ""
