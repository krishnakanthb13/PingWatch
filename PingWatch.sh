#!/bin/bash
# ============================================================
# PingWatch.sh - Lightweight Network Monitor
# Pings a host every 10 minutes and logs results to a .log file
# ============================================================
# Settings
# ============================================================
TARGET="8.8.8.8"               # Google Public DNS (Google.com)
PACKETS=1                      # Number of pings to send per check
INTERVAL=600                   # Ping interval in seconds
# Get current directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG="$SCRIPT_DIR/PingWatch.log"
# ============================================================

# ANSI color codes
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
RED='\033[1;31m'
RESET='\033[0m'

echo ""
echo -e "${YELLOW}Monitoring: $TARGET site${RESET}"
echo -e "${YELLOW}Packets:    $PACKETS ping(s)${RESET}"
echo -e "${YELLOW}Interval:   $INTERVAL second(s)${RESET}"
echo -e "${YELLOW}Logging to: $LOG${RESET}"
echo ""
echo -e "${YELLOW}Hotkeys: (1) 8.8.8.8 (2) 1.1.1.1 (3) 9.9.9.9 (4) 208.67.222.222 (5) google.com${RESET}"
echo -e "${YELLOW}Press any key to ping ON-DEMAND.${RESET}"
echo -e "${YELLOW}Press Ctrl+C to stop this process and close.${RESET}"
echo ""

while true; do
    # Get current date and time
    TS=$(date "+%d/%m/%Y %H:%M:%S")

    # Determine which target to ping based on keypress
    CURRENT_TARGET="$TARGET"
    if [[ "$KEY" == "1" ]]; then CURRENT_TARGET="8.8.8.8"; fi
    if [[ "$KEY" == "2" ]]; then CURRENT_TARGET="1.1.1.1"; fi
    if [[ "$KEY" == "3" ]]; then CURRENT_TARGET="9.9.9.9"; fi
    if [[ "$KEY" == "4" ]]; then CURRENT_TARGET="208.67.222.222"; fi
    if [[ "$KEY" == "5" ]]; then CURRENT_TARGET="google.com"; fi

    # Ping using configured packet count, suppress output
    # Auto-detect OS: Git Bash on Windows uses ping.exe (different flags)
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OS" == "Windows_NT" ]]; then
        # Windows ping.exe: -n for count, -w for timeout (milliseconds)
        ping -n "$PACKETS" -w 2000 "$CURRENT_TARGET" > /dev/null 2>&1
    else
        # Linux/macOS ping: -c for count, -W for timeout (seconds)
        ping -c "$PACKETS" -W 2 "$CURRENT_TARGET" > /dev/null 2>&1
    fi
    if [ $? -eq 0 ]; then
        echo "[$TS] SUCCESS - $CURRENT_TARGET is reachable" >> "$LOG"
        echo -e "${GREEN}[$TS] SUCCESS - $CURRENT_TARGET is reachable${RESET}"
    else
        echo "[$TS] FAILURE - $CURRENT_TARGET is NOT reachable" >> "$LOG"
        echo -e "${RED}[$TS] FAILURE - $CURRENT_TARGET is NOT reachable${RESET}"
    fi

    # Reset KEY to prevent an infinite loop of hotkey pings
    KEY=""

    # Wait for interval or ANY KEY to ping on-demand
    # read -t for timeout, -n 1 for single char, -s for silent
    read -t "$INTERVAL" -n 1 -s KEY
done
