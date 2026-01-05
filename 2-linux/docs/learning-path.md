# Linux Fundamentals - Recommended Learning Path

A structured, progressive learning path through the Linux fundamentals module, designed to build skills systematically from basic to advanced concepts.

## Learning Philosophy

This module follows a **hands-on, practice-first** approach:

1. **Read** the concept in the fundamentals guide
2. **Practice** with the interactive exercise
3. **Verify** your work with the verification script
4. **Review** the solution to understand best practices
5. **Repeat** until the commands become second nature

## Prerequisites

- Access to a Linux system (Fedora, CentOS, RHEL, Debian, Ubuntu, etc.)
- Basic familiarity with opening a terminal
- Willingness to experiment and make mistakes
- Time to practice (recommended: 1-2 hours per exercise)

## Learning Paths

### Path 1: Complete Beginner (Recommended)

**Duration**: 2-3 weeks with daily practice

#### Week 1: Foundation Skills
**Day 1-2: Exercise 1 - Command Structure**
- **Goal**: Understand how Linux commands work
- **Time**: 1-2 hours
- **Key Concepts**: Command syntax, options, arguments, help systems
- **Prerequisites**: None
- **Practice**: Run commands, experiment with options, read man pages

**Day 3-4: Exercise 2 - Filesystem Commands**
- **Goal**: Navigate and manipulate the filesystem
- **Time**: 2-3 hours
- **Key Concepts**: pwd, cd, ls, mkdir, cp, mv, rm, touch
- **Prerequisites**: Exercise 1
- **Practice**: Create directories, move files, organize your workspace

**Day 5-6: Exercise 3 - Wildcards**
- **Goal**: Work with multiple files efficiently
- **Time**: 1-2 hours
- **Key Concepts**: *, ?, [abc], brace expansion, pattern matching
- **Prerequisites**: Exercises 1-2
- **Practice**: Use wildcards to select groups of files

**Day 7: Review & Practice**
- Repeat Exercises 1-3
- Create your own practice scenarios
- Ensure comfort with basic navigation

#### Week 2: Intermediate Skills
**Day 8-9: Exercise 4 - Permissions**
- **Goal**: Master Linux security model
- **Time**: 2-3 hours
- **Key Concepts**: chmod, umask, SUID, SGID, sticky bit
- **Prerequisites**: Exercises 1-3
- **Practice**: Set permissions, understand security implications

**Day 10: Exercise 5 - Links**
- **Goal**: Understand hard and symbolic links
- **Time**: 1-2 hours
- **Key Concepts**: ln, ln -s, inodes, link behavior
- **Prerequisites**: Exercises 1-4
- **Practice**: Create links, observe their behavior

**Day 11-12: Exercise 6 - I/O Redirection**
- **Goal**: Control input and output streams
- **Time**: 2 hours
- **Key Concepts**: >, >>, 2>, &>, <, noclobber
- **Prerequisites**: Exercises 1-5
- **Practice**: Redirect output, combine streams

**Day 13-14: Exercise 7 - Pipes & Filters**
- **Goal**: Build powerful command pipelines
- **Time**: 2-3 hours
- **Key Concepts**: |, grep, awk, cut, sort, tr, wc
- **Prerequisites**: Exercises 1-6
- **Practice**: Chain commands, process text

#### Week 3: Advanced Skills
**Day 15-16: Exercise 8 - Regular Expressions**
- **Goal**: Master pattern matching
- **Time**: 2-3 hours
- **Key Concepts**: grep, egrep, regex metacharacters
- **Prerequisites**: Exercises 1-7
- **Practice**: Search with complex patterns

**Day 17-18: Exercise 9 - Find Command**
- **Goal**: Perform sophisticated file searches
- **Time**: 2 hours
- **Key Concepts**: find with various predicates, -exec
- **Prerequisites**: Exercises 1-8
- **Practice**: Search by size, time, permissions

**Day 19-20: Exercise 10 - Advanced Bash**
- **Goal**: Customize your shell environment
- **Time**: 1-2 hours
- **Key Concepts**: alias, PS1, HISTSIZE, environment variables
- **Prerequisites**: All previous exercises
- **Practice**: Personalize your shell

**Day 21: Exercise 11 - Services & Processes**
- **Goal**: Manage system services and processes
- **Time**: 2-3 hours
- **Key Concepts**: systemctl, ps, kill, nice, renice
- **Prerequisites**: All previous exercises
- **Practice**: Start/stop services, manage processes

**Day 22: Exercise 12 - Bash Scripting**
- **Goal**: Write automation scripts
- **Time**: 3-4 hours
- **Key Concepts**: Variables, conditionals, loops, functions
- **Prerequisites**: All previous exercises
- **Practice**: Automate repetitive tasks

**Day 23: Exercise 13 - Sed & Awk**
- **Goal**: Master text stream editing
- **Time**: 2-3 hours
- **Key Concepts**: sed substitution, awk field processing
- **Prerequisites**: All previous exercises
- **Practice**: Transform text files

**Day 24-25: Final Review & Integration**
- Combine skills from all exercises
- Create real-world automation scripts
- Review weak areas

---

### Path 2: Experienced with Other OSes

**Duration**: 1-2 weeks with focused practice

If you're familiar with Windows PowerShell, macOS Terminal, or other command-line environments:

#### Days 1-3: Core Differences
- Exercise 1: Command Structure (review quickly)
- Exercise 2: Filesystem Commands (focus on Linux-specific paths like /etc, /var)
- Exercise 4: Permissions (very different from Windows!)
- Exercise 5: Links (understand hard vs soft links)

#### Days 4-6: Text Processing Power
- Exercise 6: I/O Redirection
- Exercise 7: Pipes & Filters (Linux's strength!)
- Exercise 8: Regular Expressions
- Exercise 9: Find Command

#### Days 7-10: System Administration
- Exercise 10: Advanced Bash
- Exercise 11: Services & Processes (systemd vs systemctl)
- Exercise 12: Bash Scripting
- Exercise 13: Sed & Awk

---

### Path 3: Quick DevOps Essentials

**Duration**: 3-5 days intensive

For those needing Linux skills quickly for DevOps work:

#### Day 1: Essential Navigation & Files
- Exercise 1: Command Structure (30 min)
- Exercise 2: Filesystem Commands (1 hour)
- Exercise 3: Wildcards (30 min)
- Exercise 4: Permissions (1 hour - critical for containers!)

#### Day 2: Text Processing & Automation
- Exercise 6: I/O Redirection (1 hour)
- Exercise 7: Pipes & Filters (2 hours - essential skill!)
- Exercise 12: Bash Scripting (2 hours)

#### Day 3: System Management
- Exercise 11: Services & Processes (2 hours)
- Exercise 9: Find Command (1 hour)
- Exercise 10: Advanced Bash (1 hour)

#### Day 4-5: Advanced & Practice
- Exercise 8: Regular Expressions (1 hour)
- Exercise 13: Sed & Awk (1 hour)
- Practice: Write deployment scripts
- Practice: Analyze log files

---

## Skill Dependencies

```
Exercise 1: Command Structure
    ↓
Exercise 2: Filesystem Commands
    ↓
Exercise 3: Wildcards
    ↓
Exercise 4: Permissions ← Important for containers/security
    ↓
Exercise 5: Links ← Understanding file system
    ↓
Exercise 6: I/O Redirection ← Foundation for automation
    ↓
Exercise 7: Pipes & Filters ← Critical for log analysis
    ↓
Exercise 8: Regular Expressions ← Advanced text searching
    ↓
Exercise 9: Find Command ← File system mastery
    ↓
Exercise 10: Advanced Bash ← Environment customization
    ↓
Exercise 11: Services & Processes ← System administration
    ↓
Exercise 12: Bash Scripting ← Automation
    ↓
Exercise 13: Sed & Awk ← Advanced text processing
```

---

## Skills by DevOps Use Case

### Container/Docker Work
**Priority Exercises**: 1, 2, 4, 6, 7, 11, 12
- Permissions are critical in containers
- I/O redirection for container logs
- Pipes for analyzing Docker output
- Scripting for container automation

### CI/CD Pipelines
**Priority Exercises**: 1, 2, 6, 7, 12, 13
- Scripting for build automation
- Text processing for build logs
- I/O redirection for pipeline stages

### Infrastructure as Code
**Priority Exercises**: 1, 2, 3, 4, 9, 12
- File manipulation for config management
- Find for locating configuration files
- Scripting for infrastructure automation

### Monitoring & Logging
**Priority Exercises**: 7, 8, 9, 13
- Pipes & filters for log analysis
- Regular expressions for pattern matching
- Find for locating log files
- Sed & Awk for log processing

### Server Administration
**Priority Exercises**: 1-13 (all)
- Complete understanding needed
- Focus on exercises 4, 10, 11

---

## Practice Recommendations

### Daily Practice (20-30 minutes)
1. Review one command from the reference guide
2. Practice the command with different options
3. Combine it with previously learned commands
4. Create a personal cheat sheet

### Weekly Goals
- Complete 2-3 exercises
- Write 1 useful script
- Solve 1 real-world problem using Linux commands

### Monthly Milestones
- **Month 1**: Complete all 13 exercises
- **Month 2**: Apply skills to real projects
- **Month 3**: Create advanced automation scripts

---

## Common Learning Challenges & Solutions

### Challenge 1: "Too many commands to remember"
**Solution**:
- Focus on understanding patterns, not memorizing
- Use man pages and --help frequently
- Create your own cheat sheet of most-used commands
- Practice commands in context, not isolation

### Challenge 2: "Permissions are confusing"
**Solution**:
- Draw out the permission model on paper
- Practice with `ls -l` constantly
- Use a permissions calculator online
- Remember: read(4) + write(2) + execute(1) = 7

### Challenge 3: "Regular expressions are hard"
**Solution**:
- Start with simple patterns
- Use online regex testers
- Practice incrementally (literal → . → * → + → [])
- Test patterns on sample data

### Challenge 4: "I keep breaking things"
**Solution**:
- Use the exercise environment (~/linux-exercises/)
- Always test destructive commands with -i flag first
- Make backups before major changes
- Embrace mistakes as learning opportunities

### Challenge 5: "Bash scripting seems overwhelming"
**Solution**:
- Start with simple one-liners
- Gradually add features
- Copy and modify existing scripts
- Use ShellCheck to validate scripts

---

## Success Metrics

### After Each Exercise
- ✅ Can complete exercise without looking at solution
- ✅ Understand what each command does
- ✅ Can explain command to someone else
- ✅ Can apply command in different context

### After Week 1
- ✅ Navigate filesystem without hesitation
- ✅ Create, move, copy files confidently
- ✅ Use wildcards naturally

### After Week 2
- ✅ Set permissions appropriately
- ✅ Build multi-command pipelines
- ✅ Search and filter text effectively

### After Week 3
- ✅ Write functional bash scripts
- ✅ Manage services and processes
- ✅ Process text with sed/awk

### Module Completion
- ✅ Comfortable working entirely in terminal
- ✅ Can troubleshoot common Linux issues
- ✅ Can automate repetitive tasks
- ✅ Ready for DevOps-specific tools (Docker, Kubernetes, etc.)

---

## Next Steps After This Module

1. **Apply to Real Projects**
   - Use Linux commands in daily work
   - Write scripts for common tasks
   - Automate your workflow

2. **Advanced Linux Topics**
   - System administration (users, groups, security)
   - Networking (iptables, routing, DNS)
   - Performance tuning
   - Kernel concepts

3. **DevOps Tools** (from project roadmap)
   - Docker & Containers
   - Kubernetes
   - CI/CD pipelines
   - Infrastructure as Code (Terraform, Ansible)
   - Logging (ELK stack, Loki)
   - Monitoring (beyond Prometheus/Grafana)

4. **Scripting Languages**
   - Python for system administration
   - Go for DevOps tools
   - YAML for configuration

---

## Study Tips

### Effective Practice
1. **Type, don't copy-paste** - Builds muscle memory
2. **Experiment** - Try variations of commands
3. **Break things** - Learn from errors
4. **Teach others** - Best way to solidify knowledge
5. **Use man pages** - Primary documentation source

### Time Management
- **Short sessions** (30-45 min) are better than marathon sessions
- **Consistent practice** beats occasional cramming
- **Take breaks** - Your brain needs time to process
- **Review regularly** - Revisit previous exercises

### Environment Setup
- Use a dedicated practice environment
- Keep a command history journal
- Save useful scripts in a personal repository
- Create aliases for frequently used commands

---

## Resources Beyond This Module

### Online Tools
- **ExplainShell** (explainshell.com) - Explains command syntax
- **RegexR** (regexr.com) - Regular expression tester
- **ShellCheck** (shellcheck.net) - Bash script validator

### Books
- "The Linux Command Line" by William Shotts
- "Unix and Linux System Administration Handbook"
- "Learning the bash Shell" by Cameron Newham

### Practice Platforms
- OverTheWire Bandit (wargames)
- HackerRank Linux challenges
- LeetCode shell problems

---

## Conclusion

Remember: **Everyone was a beginner once.** The key to mastering Linux is consistent, hands-on practice. Don't rush through exercises - take time to understand concepts deeply.

**Start your journey**: `./exercises/ex01-command-structure.sh`

---

**Last Updated**: 2026-01-05
**Module**: 2-linux - Linux Fundamentals
