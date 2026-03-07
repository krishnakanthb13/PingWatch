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

echo ""
echo "Monitoring: $TARGET site"
echo "Packets:    $PACKETS ping(s)"
echo "Interval:   $INTERVAL second(s)"
echo "Logging to: $LOG"
echo ""
echo "Press any key to ping ON-DEMAND."
echo "Press Ctrl+C to stop this process and close."
echo ""

while true; do
    # Get current date and time
    TS=$(date "+%d/%m/%Y %H:%M:%S")

    # Ping using configured packet count, suppress output
    # -c for count, -W for timeout in seconds
    if ping -c "$PACKETS" -W 2 "$TARGET" > /dev/null 2>&1; then
        echo "[$TS] SUCCESS - $TARGET is reachable" >> "$LOG"
        echo "[$TS] SUCCESS - $TARGET is reachable"
    else
        echo "[$TS] FAILURE - $TARGET is NOT reachable" >> "$LOG"
        echo "[$TS] FAILURE - $TARGET is NOT reachable"
    fi

    # Wait for interval or ANY KEY to ping on-demand
    # read -t for timeout, -n 1 for single char, -s for silent
    read -t "$INTERVAL" -n 1 -s
done
