# Linux Fundamentals - Hands-On Learning Module

A comprehensive, practical Linux learning module with 13 hands-on exercises covering essential Linux system administration skills for DevOps engineers.

## Overview

This module provides structured learning for Linux fundamentals through:
- **Theoretical concepts** with clear explanations
- **Hands-on exercises** with automated setup scripts
- **Complete solutions** with detailed command explanations
- **Verification tools** to check your work
- **Command reference** for quick lookup

## What You'll Learn

### Core Skills (13 Exercises)

| # | Topic | Key Skills |
|---|-------|-----------|
| 1 | Command Structure | Command syntax, options, arguments, help mechanisms |
| 2 | Filesystem Commands | Navigation, file/directory manipulation, copying, moving |
| 3 | Wildcards | Pattern matching, filename generation (FNG) |
| 4 | Permissions | chmod, umask, file permissions, special bits |
| 5 | Links | Hard links vs symbolic links, link management |
| 6 | I/O Redirection | Standard streams, redirection operators, noclobber |
| 7 | Pipes & Filters | grep, awk, cut, sort, tr, wc, piping commands |
| 8 | Regular Expressions | Pattern matching with grep/egrep, regex syntax |
| 9 | Find Command | Advanced file searching, -exec, predicates |
| 10 | Advanced Bash | Aliases, environment variables, shell customization |
| 11 | Services & Processes | systemctl, process management, nice/renice |
| 12 | Bash Scripting | Variables, conditionals, loops, functions |
| 13 | Sed & Awk | Stream editing, text processing, field manipulation |

### Theoretical Foundation (18 Topics)

- Linux history and distributions
- Filesystem hierarchy and structure
- Permission model and security
- Process and service management
- Text processing and automation
- Bash scripting fundamentals
- System administration essentials

## Getting Started

### Prerequisites

- Linux system (Fedora, CentOS, RHEL, Debian, Ubuntu, or similar)
- Bash shell
- Basic terminal access
- Standard Linux utilities (installed by default on most distributions)

### Quick Start

```bash
# Navigate to the Linux module
cd 2-linux

# Read the fundamentals guide
less docs/fundamentals.md

# Start with Exercise 1
./exercises/ex01-command-structure.sh

# Follow the instructions and complete the exercise
# Check your work (when available)
./scripts/verify.sh 1

# View the solution if needed
less solutions/ex01-solution.md
```

## Project Structure

```
2-linux/
├── README.md                      # This file - overview and quick start
├── docs/                          # Comprehensive documentation
│   ├── fundamentals.md           # Complete theory guide (18 topics)
│   ├── commands-reference.md     # Quick command lookup (100+ commands)
│   └── learning-path.md          # Recommended learning sequence
├── exercises/                     # Interactive exercise scripts
│   ├── ex01-command-structure.sh
│   ├── ex02-filesystem-commands.sh
│   ├── ex03-wildcards.sh
│   ├── ex04-permissions.sh
│   ├── ex05-links.sh
│   ├── ex06-io-redirection.sh
│   ├── ex07-pipes-filters.sh
│   ├── ex08-regex.sh
│   ├── ex09-find.sh
│   ├── ex10-advanced-bash.sh
│   ├── ex11-services-processes.sh
│   ├── ex12-bash-scripting.sh
│   └── ex13-sed-awk.sh
├── solutions/                     # Detailed solutions for each exercise
│   ├── ex01-solution.md
│   ├── ex02-solution.md
│   ├── ... (solutions for all 13 exercises)
│   └── ex13-solution.md
└── scripts/                       # Utility scripts
    ├── verify.sh                 # Verify exercise completion
    ├── reset.sh                  # Reset exercise environment
    └── cleanup.sh                # Clean up all exercise files

# Generated files during exercises (in your home directory)
~/linux-exercises/
├── ex01/
├── ex02/
└── ... (exercise working directories)
```

## How to Use This Module

### Recommended Learning Path

1. **Start with Theory** - Read `docs/fundamentals.md` for the topic you're about to practice
2. **Run the Exercise Setup** - Execute the exercise script to set up the environment
3. **Complete the Tasks** - Follow the instructions provided by the exercise
4. **Verify Your Work** - Use the verification script to check correctness
5. **Review Solutions** - Compare your approach with provided solutions
6. **Practice More** - Repeat exercises until commands become second nature

### Exercise Workflow Example

```bash
# Step 1: Read the relevant documentation
less docs/fundamentals.md  # Section on File Permissions

# Step 2: Run exercise setup
./exercises/ex04-permissions.sh
# This creates ~/linux-exercises/ex04/ and provides instructions

# Step 3: Complete the exercise tasks
cd ~/linux-exercises/ex04
# Follow the instructions in the exercise prompt

# Step 4: Verify your work
cd ~/devops-progress/2-linux
./scripts/verify.sh 4

# Step 5: Review the solution
less solutions/ex04-solution.md
```

### Working Directory

All exercises create their working directories in `~/linux-exercises/` to keep your learning environment organized and separate from this repository. This allows you to:
- Experiment freely without affecting the course materials
- Reset exercises easily without losing progress on others
- Keep a clean separation between theory and practice

## Exercise Descriptions

### Exercise 1: Command Structure
Learn the fundamental syntax of Linux commands, how to use options and arguments, and where to find help.

**Skills:** Command syntax, --help, man pages, apropos, option formats

### Exercise 2: Filesystem Commands
Master navigation and file manipulation - the foundation of working with Linux.

**Skills:** pwd, cd, ls, mkdir, rmdir, cp, mv, rm, touch, cat, less, head, tail

### Exercise 3: Wildcards
Become efficient with pattern matching and filename generation for batch operations.

**Skills:** *, ?, [abc], [a-z], [0-9], [!abc], brace expansion

### Exercise 4: Permissions
Understand and control Linux file permissions and security.

**Skills:** chmod, chown, chgrp, umask, SUID, SGID, sticky bit

### Exercise 5: Links
Learn the difference between hard and symbolic links and when to use each.

**Skills:** ln, ln -s, inode concepts, link management

### Exercise 6: I/O Redirection
Master input/output control to create powerful command pipelines.

**Skills:** >, >>, 2>, &>, <, noclobber, file descriptors

### Exercise 7: Pipes & Filters
Combine commands to create sophisticated text processing pipelines.

**Skills:** |, grep, awk, cut, sort, uniq, tr, wc, tee

### Exercise 8: Regular Expressions
Unlock powerful pattern matching for searching and filtering.

**Skills:** grep, egrep, regex patterns, character classes, quantifiers

### Exercise 9: Find Command
Perform advanced file searches with complex criteria and actions.

**Skills:** find, -name, -type, -size, -mtime, -exec, -user, -perm

### Exercise 10: Advanced Bash
Customize your shell environment and improve productivity.

**Skills:** alias, PS1, HISTSIZE, HISTFILE, environment variables, .bashrc

### Exercise 11: Services & Processes
Manage system services and processes like a system administrator.

**Skills:** systemctl, ps, kill, killall, nice, renice, bg, fg, jobs

### Exercise 12: Bash Scripting
Write automation scripts to perform complex tasks.

**Skills:** Variables, conditionals (if/then/else), loops (for/while), read, functions

### Exercise 13: Sed & Awk
Master text stream editing and field processing.

**Skills:** sed (substitute, delete, insert), awk (field processing, patterns)

## Tips for Success

### Best Practices

1. **Don't just copy-paste** - Type each command to build muscle memory
2. **Experiment** - Try variations of commands to understand their behavior
3. **Read man pages** - Use `man <command>` to understand all options
4. **Use tab completion** - Press Tab to autocomplete commands and paths
5. **Practice regularly** - Consistency is key to mastering Linux
6. **Make mistakes** - Learn by breaking things in the exercise environment
7. **Take notes** - Document commands and patterns you find useful

### Common Pitfalls

- Forgetting to use `sudo` when required
- Not reading error messages carefully
- Skipping the theory before practicing
- Not verifying permissions before operations
- Forgetting to escape special characters
- Not understanding the difference between absolute and relative paths

### Getting Help

1. **Command help**: `command --help` or `man command`
2. **Search commands**: `apropos keyword`
3. **Solutions directory**: Complete solutions for all exercises
4. **Command reference**: `docs/commands-reference.md`
5. **Fundamentals guide**: `docs/fundamentals.md`

## Cleaning Up

### Reset a Single Exercise

```bash
./scripts/reset.sh 4  # Reset exercise 4
```

### Clean Up All Exercises

```bash
./scripts/cleanup.sh  # Remove all exercise directories
```

### Remove All Generated Files

```bash
rm -rf ~/linux-exercises  # Complete cleanup (use with caution!)
```

## Integration with DevOps Learning Path

This Linux fundamentals module is part of a comprehensive DevOps learning journey:

- **Previous Module**: [1-microservices_test](../1-microservices_test/README.md) - Polyglot microservices with monitoring
- **Current Module**: **2-linux** - Linux fundamentals and system administration
- **Next Topics**:
  - Service discovery (Consul, Eureka)
  - API gateways (Kong, Nginx)
  - Kubernetes deployment
  - Logging aggregation (ELK, Loki)
  - CI/CD pipelines

### Why Linux Fundamentals Matter for DevOps

- **Infrastructure as Code**: Understanding filesystem and permissions
- **Automation**: Writing scripts to automate repetitive tasks
- **Troubleshooting**: Using logs, processes, and system tools
- **Security**: Managing permissions, users, and system access
- **Container Knowledge**: Linux fundamentals underpin Docker/Kubernetes
- **System Administration**: Managing services, processes, and resources

## Command Reference Quick Links

### Most Used Commands by Category

```bash
# Navigation
pwd, cd, ls

# File Operations
cp, mv, rm, mkdir, rmdir, touch

# Viewing Files
cat, less, more, head, tail

# Permissions
chmod, chown, chgrp, umask

# Searching
find, grep, locate

# Text Processing
sed, awk, cut, sort, uniq, tr, wc

# Process Management
ps, kill, nice, systemctl

# System Info
df, du, free, uname, hostname

# Networking
ping, curl, wget, ssh, scp
```

See `docs/commands-reference.md` for complete details on 100+ commands.

## Learning Outcomes

After completing this module, you will be able to:

✅ Navigate the Linux filesystem efficiently
✅ Manage files and directories with confidence
✅ Understand and control file permissions and security
✅ Use wildcards and regex for powerful pattern matching
✅ Build command pipelines with pipes and redirection
✅ Search and filter data with grep, find, and awk
✅ Manage processes and system services
✅ Write Bash scripts to automate tasks
✅ Customize your shell environment
✅ Troubleshoot common Linux issues
✅ Apply text processing with sed and awk
✅ Use Linux efficiently for DevOps workflows

## Next Steps

1. Complete all 13 exercises in order
2. Review the command reference regularly
3. Practice writing your own scripts
4. Move on to the next DevOps topic
5. Apply Linux skills in real-world projects

## Resources

- **Fundamentals Guide**: `docs/fundamentals.md` - Complete theory
- **Command Reference**: `docs/commands-reference.md` - Quick lookup
- **Learning Path**: `docs/learning-path.md` - Study recommendations
- **Original Materials**: Based on comprehensive Linux fundamentals course

---

**Ready to start?** Run your first exercise:

```bash
./exercises/ex01-command-structure.sh
```

Happy Learning! 🐧
