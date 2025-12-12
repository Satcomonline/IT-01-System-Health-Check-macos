#!/bin/zsh
# IT-01 System Health Check - macOS
# Author: Daniel Martinez
# Description: Collects system info, resource usage, and network diagnostics
#              and saves a report to ~/Desktop/system_reports/

# ===== CONFIG =====
REPORT_DIR="$HOME/Desktop/system_reports"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
REPORT_FILE="$REPORT_DIR/system-report-$TIMESTAMP.txt"

# Create report directory if it doesn't exist
mkdir -p "$REPORT_DIR"

# Helper function to write section headers
section() {
  echo "" >> "$REPORT_FILE"
  echo "==================== $1 ====================" >> "$REPORT_FILE"
}

echo "Generating system health report..."
echo "Output file: $REPORT_FILE"
echo "System Health Report - macOS" > "$REPORT_FILE"
echo "Generated at: $(date)" >> "$REPORT_FILE"
echo "---------------------------------------------" >> "$REPORT_FILE"

# ===== BASIC SYSTEM INFO =====
section "Basic System Info"
echo "Hostname: $(hostname)" >> "$REPORT_FILE"
echo "User: $(whoami)" >> "$REPORT_FILE"
echo "OS Version:" >> "$REPORT_FILE"
sw_vers >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "Uptime: $(uptime)" >> "$REPORT_FILE"

# ===== CPU USAGE =====
section "CPU Usage (snapshot)"
# macOS 'top' behaves differently from Linux; this gets 1 sample (-l 1)
top -l 1 -n 0 | head -n 10 >> "$REPORT_FILE"

# ===== MEMORY USAGE =====
section "Memory Usage"
# vm_stat gives page statistics; we include raw data and a simple note
vm_stat >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "Note: vm_stat shows memory in pages. Page size is typically 4096 bytes." >> "$REPORT_FILE"

# ===== DISK USAGE =====
section "Disk Usage (Human-Readable)"
df -h >> "$REPORT_FILE"

# ===== NETWORK INFORMATION =====
section "Network Configuration"
echo "IP Configuration:" >> "$REPORT_FILE"
ipconfig getifaddr en0 2>/dev/null && echo "Primary interface: en0" >> "$REPORT_FILE" || echo "en0 not active" >> "$REPORT_FILE"
ipconfig getifaddr en1 2>/dev/null && echo "Secondary interface: en1" >> "$REPORT_FILE" || echo "en1 not active" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
ifconfig >> "$REPORT_FILE"

section "Network Connectivity Tests"
echo "Ping test to 8.8.8.8 (Google DNS):" >> "$REPORT_FILE"
ping -c 4 8.8.8.8 >> "$REPORT_FILE" 2>&1

echo "" >> "$REPORT_FILE"
echo "Ping test to google.com:" >> "$REPORT_FILE"
ping -c 4 google.com >> "$REPORT_FILE" 2>&1

# ===== RECENT SYSTEM LOGS (HIGH-LEVEL) =====
section "Recent System Log Messages (last 5 minutes)"
# Modern macOS uses unified logging; this may require sudo for deeper logs
log show --style syslog --last 5m 2>/dev/null | head -n 100 >> "$REPORT_FILE" || echo "Unified logs not available without sudo or on this OS version." >> "$REPORT_FILE"

# ===== TOP PROCESSES =====
section "Top CPU-consuming Processes"
ps aux | sort -nrk 3 | head -n 10 >> "$REPORT_FILE"

section "Top Memory-consuming Processes"
ps aux | sort -nrk 4 | head -n 10 >> "$REPORT_FILE"

# ===== LAST REBOOT & SHUTDOWN =====
section "Last Reboot and Logins"
who -b >> "$REPORT_FILE" 2>/dev/null || echo "who -b not supported on this macOS version." >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
last | head -n 10 >> "$REPORT_FILE"

# ===== SUMMARY =====
section "Summary"
echo "This report provides a snapshot of system health for troubleshooting performance, network, and stability issues." >> "$REPORT_FILE"
echo "Reviewed sections:" >> "$REPORT_FILE"
echo "- Basic system info and OS version" >> "$REPORT_FILE"
echo "- CPU and memory usage snapshot" >> "$REPORT_FILE"
echo "- Disk usage and available space" >> "$REPORT_FILE"
echo "- Network configuration and connectivity" >> "$REPORT_FILE"
echo "- Recent system logs (last 5 minutes)" >> "$REPORT_FILE"
echo "- Top resource-consuming processes" >> "$REPORT_FILE"
echo "- Last reboot/logins" >> "$REPORT_FILE"

echo ""
echo "Done. Report saved to: $REPORT_FILE"
echo "Open the file to review system health details."
