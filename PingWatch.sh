#!/bin/bash
# ============================================================
# PingWatch.sh - Lightweight Network Monitor
# Pings a host every 10 minutes and logs results to a .log file
# ============================================================
# Settings
# ============================================================
# Auto-detect IP Protocol Capability
HAS_IPV4=0
HAS_IPV6=0

if [[ "$OS" == "Windows_NT" ]]; then
    HAS_IPV4=$(powershell.exe -NoProfile -Command "if (Get-NetRoute -DestinationPrefix '0.0.0.0/0' -ErrorAction SilentlyContinue) { Write-Output 1 } else { Write-Output 0 }" | tr -d '\r')
    HAS_IPV6=$(powershell.exe -NoProfile -Command "if (Get-NetRoute -DestinationPrefix '::/0' -ErrorAction SilentlyContinue) { Write-Output 1 } else { Write-Output 0 }" | tr -d '\r')
else
    ip route show default 2>/dev/null | grep -q "^default" && HAS_IPV4=1
    ip -6 route show default 2>/dev/null | grep -q "^default" && HAS_IPV6=1
fi

# Define Targets dynamically
T1="8.8.8.8"
T2="1.1.1.1"
T3="9.9.9.9"
T4="208.67.222.222"
T5="google.com"

if [[ "$HAS_IPV4" == "0" && "$HAS_IPV6" == "1" ]]; then
    T1="2001:4860:4860::8888"
    T2="2606:4700:4700::1111"
    T3="2620:fe::fe"
    T4="2620:0:ccc::2"
fi

TARGET="$T1"
if [[ "$HAS_IPV4" == "0" && "$HAS_IPV6" == "1" ]]; then TARGET="$T5"; fi

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

# Hide the literal ^C character from terminal output
stty -echoctl

# Trap Ctrl+C (SIGINT) and EXIT to clean up terminal and exit cleanly
cleanup_and_exit() {
    echo ""
    echo -e "${YELLOW}Exiting PingWatch...${RESET}"
    stty echoctl
    trap - SIGINT EXIT
    exit 0
}
trap cleanup_and_exit SIGINT EXIT

if [[ "$HAS_IPV4" == "0" && "$HAS_IPV6" == "1" ]]; then
    echo -e "${YELLOW}Network: IPv6-Only detected. Using IPv6 Targets.${RESET}"
elif [[ "$HAS_IPV6" == "0" && "$HAS_IPV4" == "1" ]]; then
    echo -e "${YELLOW}Network: IPv4-Only detected.${RESET}"
elif [[ "$HAS_IPV4" == "1" && "$HAS_IPV6" == "1" ]]; then
    echo -e "${YELLOW}Network: Dual-Stack (IPv4 + IPv6) detected.${RESET}"
else
    echo -e "${YELLOW}Network: No active internet gateway detected.${RESET}"
fi

echo -e "${YELLOW}Monitoring: $TARGET site${RESET}"
echo -e "${YELLOW}Packets:    $PACKETS ping(s)${RESET}"
echo -e "${YELLOW}Interval:   $INTERVAL second(s)${RESET}"
echo -e "${YELLOW}Logging to: $LOG${RESET}"
echo ""
echo -e "${YELLOW}Targets: (1) $T1 (2) $T2 (3) $T3 (4) $T4 (5) $T5${RESET}"
echo -e "${YELLOW}Intervals: (F)ast 10s | (M)edium 60s | (N)ormal 600s${RESET}"
echo -e "${YELLOW}Press any other key to ping ON-DEMAND.${RESET}"
echo -e "${YELLOW}Press Ctrl+C to stop this process and close.${RESET}"
echo ""

while true; do
    # Get current date and time
    TS=$(date "+%d/%m/%Y %H:%M:%S")

    # Determine which target to ping based on keypress
    CURRENT_TARGET="$TARGET"
    if [[ "$KEY" == "1" ]]; then CURRENT_TARGET="$T1"; fi
    if [[ "$KEY" == "2" ]]; then CURRENT_TARGET="$T2"; fi
    if [[ "$KEY" == "3" ]]; then CURRENT_TARGET="$T3"; fi
    if [[ "$KEY" == "4" ]]; then CURRENT_TARGET="$T4"; fi
    if [[ "$KEY" == "5" ]]; then CURRENT_TARGET="$T5"; fi
    if [[ "$KEY" == "f" || "$KEY" == "F" ]]; then INTERVAL=10; fi
    if [[ "$KEY" == "m" || "$KEY" == "M" ]]; then INTERVAL=60; fi
    if [[ "$KEY" == "n" || "$KEY" == "N" ]]; then INTERVAL=600; fi

    # Ping using configured packet count, capture output
    # Auto-detect OS: Git Bash on Windows uses ping.exe (different flags)
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OS" == "Windows_NT" ]]; then
        # Windows ping.exe: -n for count, -w for timeout (milliseconds)
        PING_OUT=$(ping -n "$PACKETS" -w 2000 "$CURRENT_TARGET")
        RET=$?
        # Extract Average from summary if it exists (for multiple packets)
        # -n + /p: only print when pattern matches (no whole-line fallback)
        # Capture group allows digits, dot, and '<' to handle "<1ms" or decimal forms
        LATENCY=$(echo "$PING_OUT" | grep -i "Average =" | sed -n 's/.*Average = \([0-9.<][0-9.<]*\)ms.*/\1/p')
        if [[ -z "$LATENCY" ]]; then
             LATENCY=$(echo "$PING_OUT" | grep -i "time=" | head -n 1 | sed -n 's/.*time=\([0-9.<][0-9.<]*\)ms.*/\1/p')
        fi
    else
        # Linux/macOS ping: -c for count, -W for timeout (seconds)
        PING_OUT=$(ping -c "$PACKETS" -W 2 "$CURRENT_TARGET")
        RET=$?
        # Extract avg from summary (e.g., .../22.154/...) or first time=
        LATENCY=$(echo "$PING_OUT" | grep "avg/" | awk -F'/' '{print $5}')
        if [[ -z "$LATENCY" ]]; then
             LATENCY=$(echo "$PING_OUT" | grep "time=" | head -n 1 | sed -n 's/.*time=\([0-9.<][0-9.<]*\).*/\1/p')
        fi
    fi

    if [ "$RET" -eq 0 ]; then
        # Append "ms" if we got a value
        [[ -n "$LATENCY" ]] && LATENCY_STR=" (Latency: ${LATENCY}ms)" || LATENCY_STR=""
        echo "[$TS] SUCCESS - $CURRENT_TARGET is reachable$LATENCY_STR" >> "$LOG"
        echo -e "${GREEN}[$TS] SUCCESS - $CURRENT_TARGET is reachable$LATENCY_STR${RESET}"
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
