# Exercise 10 Solution: Advanced Bash

## Objective
Use aliases, history, environment variables, and customize prompts.

---

## Aliases

### Create Aliases
```bash
alias run='chmod a+x'
alias links='ls -lR | grep ^l'
alias large='find -size +2M -exec du -h {} \;'
alias del='mv -t ~/.recycle'
alias disk='df | grep /$ | awk "{print \$(NF-1)}" | tr -d %'
```

### Save Permanently
```bash
alias >> ~/.bashrc
source ~/.bashrc  # Reload
```

---

## History Management

### View and Configure
```bash
echo $HISTFILE              # Show history file location
tail $HISTFILE              # View recent commands
HISTSIZE=2000               # Set for current session
echo "export HISTSIZE=2000" >> ~/.bash_profile  # Make permanent
```

### Use History
```bash
!$      # Last argument of previous command
!!      # Repeat last command
!123    # Run command 123 from history
```

---

## Prompt Customization

### Custom PS1
```bash
PS1='[\$(whoami)@\$(pwd)]\$ '
```

### Common Variables
- `\u` - Username
- `\h` - Hostname
- `\w` - Working directory
- `\$` - $ for user, # for root

---

## Environment Variables

### View and Set
```bash
echo $PATH
echo $HOME
echo $SHELL
export MY_VAR=value
```

### Make Permanent
```bash
echo "export MY_VAR=value" >> ~/.bash_profile
```

---

## Key Learning Points

1. **Aliases**: Shortcuts for complex commands
2. **~/.bashrc**: Loaded for interactive shells
3. **~/.bash_profile**: Loaded for login shells
4. **$HISTFILE**: Command history location
5. **PS1**: Primary prompt string

---
