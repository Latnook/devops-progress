# Linux Exercises - Implementation Status

## Overview

This document tracks the implementation of 13 interactive Linux tutorial exercises following the pattern established in ex01-command-structure.sh.

## Completed Exercises (2/13)

### ✓ ex01-command-structure.sh
- **Status**: Complete (Original gold standard)
- **Lines**: 502
- **Tasks**: 6 interactive tasks
- **Topics**: Command syntax, options, arguments, help, date formatting
- **Pattern**: Full interactive with tput colors, progressive hints, result validation

### ✓ ex02-filesystem-commands.sh
- **Status**: Complete (Newly created)
- **Lines**: 610
- **Tasks**: 7 interactive tasks
- **Topics**: mkdir, touch, cp, mv, rm, head, wildcards
- **Features**:
  - Interactive command validation
  - Progressive 3-level hints
  - Result-based checking (not command syntax)
  - Clear task format: CONCEPT → SCENARIO → YOUR GOAL → What you know
  - Progress tracking (Task X/Y)
  - Completion summary with skills mastered

### ✓ ex03-wildcards.sh
- **Status**: Complete (Newly created)
- **Lines**: 553
- **Tasks**: 6 interactive tasks
- **Topics**: *, ?, [abc], [a-z], [0-9], case-insensitive matching
- **Features**: Same pattern as ex01 and ex02

## Remaining Exercises (10/13)

### ex04-permissions.sh
**Target Topics**: chmod, umask, SUID, SGID, sticky bit
**Suggested Tasks**:
1. Basic chmod with numbers (chmod 755)
2. chmod with symbols (u+x, go-w)
3. Understanding umask
4. Setting SUID bit (chmod 4755)
5. Setting SGID bit (chmod 2755)
6. Setting sticky bit on directory (chmod 1755)
7. CHALLENGE: Complex permission scenario

### ex05-links.sh
**Target Topics**: Hard links, symbolic links
**Suggested Tasks**:
1. Create hard link (ln original hard-link)
2. Create symbolic link (ln -s original sym-link)
3. Compare inode numbers (ls -li)
4. Test hard link when original deleted
5. Test symbolic link when original deleted
6. CHALLENGE: Link behavior with permissions

### ex06-io-redirection.sh
**Target Topics**: >, >>, 2>, &>, <, noclobber
**Suggested Tasks**:
1. Redirect stdout (command > file)
2. Append output (command >> file)
3. Redirect stderr (command 2> file)
4. Redirect both (command &> file)
5. Input redirection (command < file)
6. noclobber protection (set -o noclobber)
7. CHALLENGE: Complex redirection pipeline

### ex07-pipes-filters.sh
**Target Topics**: grep, awk, cut, sort, tr, wc, pipes
**Suggested Tasks**:
1. Basic pipe (ls | grep pattern)
2. awk field extraction (awk '{print $1}')
3. cut columns (cut -c1-5)
4. sort output (sort -n)
5. Character translation (tr 'a-z' 'A-Z')
6. Count with wc (wc -l)
7. CHALLENGE: Multi-stage pipeline

### ex08-regex.sh
**Target Topics**: Regular expressions with grep
**Suggested Tasks**:
1. Anchors (^ and $)
2. Character classes ([0-9])
3. Dot wildcard (.)
4. Star quantifier (*)
5. egrep alternation (pattern1|pattern2)
6. CHALLENGE: Complex regex pattern

### ex09-find.sh
**Target Topics**: find command with predicates and -exec
**Suggested Tasks**:
1. Find by type (find -type f)
2. Find by name (find -name "*.txt")
3. Find by size (find -size +1M)
4. Find by time (find -mmin -60)
5. Find with -exec (find -exec command {} \;)
6. CHALLENGE: Complex find with multiple predicates

### ex10-advanced-bash.sh
**Target Topics**: alias, PS1, environment variables, history
**Suggested Tasks**:
1. Create alias (alias ll='ls -la')
2. Save alias to .bashrc
3. Customize PS1 prompt
4. Set environment variable (export VAR=value)
5. Manage HISTSIZE
6. CHALLENGE: Complete bash customization

### ex11-services-processes.sh
**Target Topics**: systemctl, ps, kill, nice, renice
**Suggested Tasks**:
1. Check service status (systemctl status)
2. Start/stop service (systemctl start/stop)
3. List processes (ps aux)
4. Kill process (kill PID)
5. Start with priority (nice -n 5 command)
6. Change priority (renice -n 10 PID)
7. CHALLENGE: Process management scenario

### ex12-bash-scripting.sh
**Target Topics**: Variables, conditionals, loops, parameters
**Suggested Tasks**:
1. Variables and $1, $2 parameters
2. Command substitution $(command)
3. if/elif/else statements
4. String comparisons (=, !=)
5. Numeric comparisons (-eq, -lt, -gt)
6. for loop
7. CHALLENGE: Complete script with all features

### ex13-sed-awk.sh
**Target Topics**: sed stream editing, awk text processing
**Suggested Tasks**:
1. sed substitution (sed 's/old/new/')
2. sed deletion (sed '/pattern/d')
3. awk field printing (awk '{print $1, $3}')
4. awk with BEGIN/END blocks
5. awk with field separator (-F:)
6. awk calculations (sum, average)
7. CHALLENGE: Complex text processing

## Implementation Pattern Template

Each exercise must follow this exact structure:

```bash
#!/bin/bash

# Interactive Tutorial: Exercise N - Topic Name
# Brief description

set -e

# Colors using tput (EXACT same code as ex01)
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

WORK_DIR="$HOME/linux-exercises/exNN"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

TASKS_COMPLETED=0
TOTAL_TASKS=N

clear

# Welcome screen (EXACT format as ex01)
echo "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo "${BLUE}║${NC}   ${BOLD}Exercise N: Topic - Interactive Tutorial${NC}               ${BLUE}║${NC}"
echo "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "${GREEN}Welcome!${NC} Description..."
echo ""
echo "${BOLD}How this works:${NC}"
echo "  • Each task presents a real scenario"
echo "  • Figure out the command to solve it"
echo "  • Type ${CYAN}'hint'${NC} if you need help"
echo "  • We check if you achieved the goal (multiple solutions accepted!)"
echo ""
echo "Working directory: ${YELLOW}$WORK_DIR${NC}"
echo ""
read -p "Press Enter to begin..."

clear

# ============================================================
# TASK 1: Task Name
# ============================================================

echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo "${BOLD}Task 1/$TOTAL_TASKS: Task Description${NC}"
echo "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}CONCEPT:${NC} Explanation of the concept"
echo ""
echo "${BOLD}SCENARIO:${NC}"
echo "  Real-world scenario description"
echo ""
echo "${BOLD}YOUR GOAL:${NC} Specific, measurable goal"
echo ""
echo "${YELLOW}What you know:${NC}"
echo "  • Hint about tools available"
echo "  • Syntax guidance"
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
                echo "${CYAN}HINT 1:${NC} General guidance"
                ;;
            2)
                echo "${CYAN}HINT 2:${NC} More specific hint"
                ;;
            3)
                echo "${CYAN}HINT 3:${NC} Near-complete solution"
                ;;
        esac
    elif [[ "$user_cmd" =~ pattern_to_match ]]; then
        # Validate RESULT, not exact command
        if [desired_result_achieved]; then
            echo ""
            eval "$user_cmd"
            echo ""
            echo "${GREEN}✓ Success!${NC} Explanation"
            echo ""
            echo "${BOLD}What happened:${NC}"
            echo "  • Breakdown of what command did"
            TASKS_COMPLETED=$((TASKS_COMPLETED + 1))
            echo ""
            read -p "Press Enter to continue..."
            break
        else
            echo "${YELLOW}Feedback on why it didn't work${NC}"
        fi
    else
        echo "${YELLOW}General guidance${NC}"
    fi
done

clear

# [Repeat for each task]

# ============================================================
# COMPLETION
# ============================================================

echo "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo "${GREEN}║${NC}                ${BOLD}🎉 EXERCISE N COMPLETE! 🎉${NC}                     ${GREEN}║${NC}"
echo "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "${BOLD}Outstanding work!${NC} You completed all $TASKS_COMPLETED/$TOTAL_TASKS tasks."
echo ""
echo "${BOLD}Skills Mastered:${NC}"
echo "  ✓ Skill 1"
echo "  ✓ Skill 2"
echo ""
echo "${BOLD}Commands You Used:${NC}"
echo "  • command1 - Description"
echo ""
echo "${BOLD}Practice More:${NC}"
echo "  • Suggestion 1"
echo ""
echo "${BOLD}Next Exercise:${NC}"
echo "  Exercise N+1: Topic"
echo "  Description"
echo ""
echo "${GREEN}Run:${NC} ./exNN-topic.sh"
echo ""
```

## Key Requirements

1. **tput colors** with fallback
2. **Clear task format**: CONCEPT → SCENARIO → YOUR GOAL → What you know
3. **Progressive hints** (3 levels)
4. **Result validation** (not command matching)
5. **Progress tracking** (Task X/Y)
6. **Completion summary** at end
7. **Working directory**: ~/linux-exercises/exNN/
8. **set -e** for error handling
9. **Interactive input**: read -p "> " user_cmd
10. **Flexible command matching**: Accept multiple valid solutions

## Next Steps

To complete the remaining 10 exercises:

1. Use ex01, ex02, ex03 as templates
2. Extract concepts from `/home/latnook/devops-progress/2-linux/docs/fundamentals.md`
3. Follow the EXACT pattern (do not deviate)
4. Each exercise should be 500-700 lines
5. Test interactively to ensure validation works
6. Make executable: `chmod +x ex*.sh`

## Estimated Effort

- **Per exercise**: ~2 hours (planning + coding + testing)
- **Total remaining**: ~20 hours
- **Lines of code**: ~6,000 lines remaining

## Usage

Once all exercises are complete, users can run:

```bash
cd ~/devops-progress/2-linux/exercises
./ex01-command-structure.sh      # Command basics
./ex02-filesystem-commands.sh    # File operations
./ex03-wildcards.sh              # Pattern matching
./ex04-permissions.sh            # Permissions and special bits
./ex05-links.sh                  # Hard and symbolic links
./ex06-io-redirection.sh         # I/O redirection
./ex07-pipes-filters.sh          # Pipes and text filters
./ex08-regex.sh                  # Regular expressions
./ex09-find.sh                   # Finding files
./ex10-advanced-bash.sh          # Bash customization
./ex11-services-processes.sh     # System management
./ex12-bash-scripting.sh         # Shell scripting
./ex13-sed-awk.sh               # Advanced text processing
```

## Quality Standards

Each exercise must:
- ✓ Be fully interactive (no passive reading)
- ✓ Validate results, not command syntax
- ✓ Provide educational feedback
- ✓ Have 5-8 tasks including a CHALLENGE
- ✓ Create files in ~/linux-exercises/exNN/
- ✓ Be self-contained (setup test environment)
- ✓ Match ex01's professional polish

---

**Status**: 3/13 exercises complete (23%)
**Created**: 2026-01-05
**Last Updated**: 2026-01-05
