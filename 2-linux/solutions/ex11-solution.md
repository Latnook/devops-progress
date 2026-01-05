# Exercise 11 Solution: Services & Processes

## Objective
Manage systemd services and control processes with priority.

---

## Systemctl Commands

### Basic Service Management
```bash
systemctl status service      # Check status
systemctl start service       # Start
systemctl stop service        # Stop
systemctl restart service     # Restart
systemctl enable service      # Enable at boot
systemctl disable service     # Disable at boot
systemctl is-active service   # Check if running
```

### Switch Targets
```bash
systemctl isolate multi-user.target
systemctl isolate graphical.target
```

---

## Process Management

### List Processes
```bash
ps -e           # All processes
ps -l           # With priority info
ps aux          # Detailed format
```

### Kill Processes
```bash
kill <pid>              # Terminate by PID
kill -9 <pid>           # Force kill
killall <name>          # Kill by name
pkill <pattern>         # Kill by pattern
pkill sleep             # Kill all sleep processes
```

---

## Process Control

### Background and Foreground
```bash
sleep 1000 &            # Start in background
CTRL+Z                  # Suspend foreground process
bg                      # Resume in background
fg                      # Bring to foreground
jobs                    # List background jobs
```

### Priority Management
```bash
# Start with priority
nice -n 3 sleep 1003 &

# Change priority of running process (requires root)
sudo renice -n 1 <pid>
sudo renice -n 2 <pid>

# View priority
ps -l
```

**Priority Levels:**
- **-20 to -1**: Higher priority (requires root)
- **0**: Default priority
- **1 to 19**: Lower priority

---

## Example: Service Configuration

### Modify Service Target
```bash
# View current configuration
cat /usr/lib/systemd/system/crond.service | grep -iA1 install

# Modify (example - don't do this in production)
sudo sed -i s/multi-user/graphical/ /usr/lib/systemd/system/crond.service

# Verify
ls -l /etc/systemd/system/graphical.target.wants/*crond*
```

---

## Key Learning Points

1. **systemctl**: Main tool for service management
2. **Targets**: Like runlevels (multi-user, graphical)
3. **nice**: Set priority when starting
4. **renice**: Change priority of running process
5. **Background jobs**: Use &, bg, fg, jobs

---
