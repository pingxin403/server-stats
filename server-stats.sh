#!/usr/bin/env bash
# server-stats.sh - Linux Server Performance Statistics Analyzer
# 兼容主流 Linux 发行版，无需额外依赖（仅使用系统自带工具）

# 终端颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=========================================="
echo -e "       Server Performance Statistics      "
echo -e "==========================================${NC}"
echo -e "Date: $(date '+%Y-%m-%d %H:%M:%S')"
echo -e "Hostname: $(hostname)"
echo -e "${BLUE}==========================================${NC}"

# 📊 基础系统信息 (Stretch Goals)
echo -e "\n${GREEN}📊 SYSTEM INFO${NC}"
OS_NAME="Unknown"
if command -v lsb_release &>/dev/null; then
    OS_NAME=$(lsb_release -d | cut -f2)
elif [ -f /etc/os-release ]; then
    OS_NAME=$(. /etc/os-release && echo "$PRETTY_NAME")
fi
echo -e "OS Version   : $OS_NAME"
echo -e "Kernel       : $(uname -r)"
echo -e "Uptime       : $(uptime -p)"
LOAD=$(uptime | awk -F'load average:' '{print $2}' | xargs)
echo -e "Load Average : $LOAD"
echo -e "Logged In    : $(who | wc -l) user(s)"

# 统计失败登录尝试 (需日志读取权限，非 root 可能返回 0)
FAILED_LOGINS=0
if [ -f /var/log/auth.log ]; then
    FAILED_LOGINS=$(grep -c "Failed password" /var/log/auth.log 2>/dev/null || true)
elif [ -f /var/log/secure ]; then
    FAILED_LOGINS=$(grep -c "Failed password" /var/log/secure 2>/dev/null || true)
fi
echo -e "Failed Logins: ${YELLOW}$FAILED_LOGINS${NC} (since last log rotation)"

# 🔥 CPU 使用率
echo -e "\n${GREEN}🔥 CPU USAGE${NC}"
# 兼容新旧版 top 输出格式提取 idle 值
CPU_IDLE=$(top -bn1 2>/dev/null | grep -iE "cpu" | awk '{for(i=1;i<=NF;i++) if($i ~ /id/) print $(i-1)}' | tail -1 | sed 's/%//g')
if [[ "$CPU_IDLE" =~ ^[0-9.]+$ ]]; then
    CPU_USAGE=$(awk "BEGIN {printf \"%.1f\", 100 - $CPU_IDLE}")
else
    # 降级方案：累加所有进程的 CPU%
    CPU_USAGE=$(ps aux | awk '{sum+=$3} END {printf "%.1f", sum}')
fi
echo -e "Total CPU Usage: ${YELLOW}${CPU_USAGE}%${NC}"

# 💾 内存使用率
echo -e "\n${GREEN}💾 MEMORY USAGE${NC}"
free -m | awk '/^Mem:/ {
    total=$2; used=$3; free=$4;
    printf "Total: %dMB | Used: %dMB (%.1f%%) | Free: %dMB (%.1f%%)\n", total, used, used/total*100, free, free/total*100
}'

# 💽 磁盘使用率 (根目录)
echo -e "\n${GREEN}💽 DISK USAGE (Root Filesystem)${NC}"
df -h / | awk 'NR==2 {
    used_pct=$5; gsub(/%/,"",used_pct);
    free_pct=100-used_pct;
    printf "Total: %s | Used: %s (%s) | Free: %s (%d%%)\n", $2, $3, $5, $4, free_pct
}'

# 🚀 Top 5 进程 (CPU)
echo -e "\n${GREEN}🚀 TOP 5 PROCESSES BY CPU${NC}"
ps aux --sort=-%cpu | head -6 | awk 'NR==1 {
    printf "%-10s %-8s %-6s %-6s %-10s %s\n", "USER", "PID", "%CPU", "%MEM", "RSS(MB)", "COMMAND"
} NR>1 {
    rss_mb=int($6/1024);
    printf "%-10s %-8s %-6s %-6s %-10s %s\n", $1, $2, $3, $4, rss_mb, $11
}'

# 🧠 Top 5 进程 (Memory)
echo -e "\n${GREEN}🧠 TOP 5 PROCESSES BY MEMORY${NC}"
ps aux --sort=-%mem | head -6 | awk 'NR==1 {
    printf "%-10s %-8s %-6s %-6s %-10s %s\n", "USER", "PID", "%CPU", "%MEM", "RSS(MB)", "COMMAND"
} NR>1 {
    rss_mb=int($6/1024);
    printf "%-10s %-8s %-6s %-6s %-10s %s\n", $1, $2, $3, $4, rss_mb, $11
}'

echo -e "\n${BLUE}=========================================="
echo -e "✅ Analysis complete."
echo -e "==========================================${NC}"
