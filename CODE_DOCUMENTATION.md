# Code Documentation: PingWatch

This document describes the technical implementation details for the PingWatch scripts.

## The Logging Engine

### Windows (`.bat`)
- **Path Resolution**: `set "LOG=%~dp0PingWatch.log"` uses `%~dp0` to ensure the log is always created in the script's own folder, even if run from a different directory.
- **Colored Output**: Uses lightweight `powershell -Command "Write-Host ..."` calls to provide a colorful UI in the standard CMD window without any third-party executables.
- **Time Formatting**: `for /f "tokens=..." %%a in ("%TIME%")` parses the system time into tokens to force a leading `0` for hours before 10 AM, ensuring fixed-width, neatly-aligned log entries.

### Linux/macOS (`.sh`)
- **OS Detection**: `if [[ "$OSTYPE" == "msys" ... ]]` detects if the script is running in Git Bash on Windows to appropriately use `ping.exe` flags (`-n`, `-w`) instead of Linux flags (`-c`, `-W`).
- **Colored Output**: Uses standard ANSI escape codes (`\033[...m`) for high-performance, native colored output.
- **Path Resolution**: `SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"` provides sophisticated path discovery to robustly locate the log file safely.
- **Time Formatting**: `date "+%d/%m/%Y %H:%M:%S"` leverages native high-precision string formatting.

## The Network Check

- **Minimal Packets**: `ping -n %PACKETS%` (Win) / `ping -c $PACKETS` (Unix) conditionally sends only the configured packet(s) needed.
- **Strict Timeouts**: `-w 2000` (Win) / `-W 2` (Unix) waits exactly 2 seconds before giving up. This prevents the script from hanging indefinitely on a dead connection or dropped packet.
- **Suppressed Output**: `>nul 2>&1` (Win) / `> /dev/null 2>&1` (Unix) silences the native raw ping output. The scripts parse the exit codes and manually format their own display for a cleaner UI.
- **Exit Code Verification**: `if %ERRORLEVEL%==0` (Win) / `if [ $? -eq 0 ]` (Unix) checks the ping command's exit code directly. Success = 0. This boolean check is the fastest and most reliable way to verify reachability natively.

## The Scheduler and Interactive Hotkeys

Recent optimizations have transformed the idle state from a dumb sleep into an interactive, event-driven loop.

### Windows
- **PowerShell Key Listener**: Rather than `timeout /t`, Windows uses a compact embedded PowerShell script during the interval loop.
- **Interrupt Handling**: The listener actively monitors `[System.Console]::KeyAvailable` checking for pressed keys and intercepts `Ctrl+C` inputs securely.
- **Hotkeys**: If a key is pressed, it is returned to the batch context. The script parses the key to switch targets (`1`-`5`), modify intervals (`F`, `M`, `N`), or execute an on-demand ping (any other key).

### Linux/macOS
- **Non-Blocking Read**: Uses `read -t "$INTERVAL" -n 1 -s`. This functionally tells Bash to wait for `$INTERVAL` seconds **OR** for a single keystroke, whichever comes first.
- **Secure Input**: The `-s` silent flag ensures pressed characters don't clutter the console.
- **Hotkeys**: Standard bash `if/then` evaluates the `$KEY` string directly to dynamically change `$TARGET` or `$INTERVAL` for the next loop execution.
