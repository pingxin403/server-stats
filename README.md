# 🖥️ Server Stats Analyzer

A lightweight, dependency-free Bash script to analyze real-time Linux server performance metrics.

## 📊 Features
- ✅ Total CPU Usage (Instant snapshot)
- ✅ Memory Usage (Total, Used, Free + Percentages)
- ✅ Disk Usage (Root filesystem breakdown)
- ✅ Top 5 Processes by CPU & Memory
- 🌟 **Stretch Goals**: OS Version, Kernel, Uptime, Load Average, Active Users, Failed Login Attempts

## 🚀 Quick Start
```bash
# 1. Clone or download the script
git clone https://github.com/pingxin403/server-stats.git
cd server-stats

# 2. Make it executable
chmod +x server-stats.sh

# 3. Run it
./server-stats.sh
```

## 📝 Output Example
```text
==========================================
       Server Performance Statistics      
==========================================
Date: 2026-04-30 10:15:00
Hostname: web-server-01
==========================================

📊 SYSTEM INFO
OS Version   : Ubuntu 24.04.1 LTS
Kernel       : 6.8.0-xx-generic
Uptime       : up 14 days, 3 hours, 22 minutes
Load Average : 0.45, 0.38, 0.31
Logged In    : 2 user(s)
Failed Logins: 12 (since last log rotation)

🔥 CPU USAGE
Total CPU Usage: 24.5%

💾 MEMORY USAGE
Total: 8192MB | Used: 3456MB (42.2%) | Free: 4736MB (57.8%)

💽 DISK USAGE (Root Filesystem)
Total: 50G | Used: 18G (36%) | Free: 30G (64%)

🚀 TOP 5 PROCESSES BY CPU
USER       PID      %CPU   %MEM   RSS(MB)    COMMAND
root       1024     12.4   1.2    156        /usr/bin/node
...

🧠 TOP 5 PROCESSES BY MEMORY
...
==========================================
✅ Analysis complete.
==========================================
```

## ⚠️ Notes
- **Failed Logins**: Requires read access to `/var/log/auth.log` or `/var/log/secure`. Run with `sudo` if count returns `0`.
- **CPU Calculation**: Uses a 1-second snapshot from `top`. Falls back to `ps` sum if `top` output format differs.
- **Cross-Distro**: Tested on Debian/Ubuntu, RHEL/CentOS, and Alpine Linux.

## 🤝 Contributing
Pull requests are welcome! Feel free to add more metrics or improve formatting.

----

https://roadmap.sh/projects/server-stats
