# Code Documentation: PingWatch

This document describes the technical implementation details for the PingWatch scripts.

## The Logging Engine

### Windows (`.bat`)
- **Path Resolution**: `set "LOG=%~dp0PingWatch.log"` ensures the log is in the script's folder.
- **Unique Temp Files**: `%TEMP%\ping_watch_%RANDOM%_%RANDOM%.txt` guarantees that concurrent instances (or multiple Targets) don't overwrite each other's temporary diagnostic data, even in read-only script directories.
- **Locale-Agnostic Latency Parsing**: Instead of searching for "Average", a robust `for`-loop nested inside another `for`-loop scans for numeric tokens associated with the standard `ms` suffix. This "token-proximity" logic works regardless of the system language (English, French, German, etc.) or ping output format (`19ms` vs `19 ms`).
- **Variable Isolation**: Loop-assigned tokens use a dedicated `TOK` variable. This prevents clobbering the global `T` variable (used for the timestamp), ensuring that high-frequency logs never show corrupted time values.
- **Colored Output**: Uses lightweight `powershell -Command "Write-Host ..."` calls for a colorful UI in CMD.
- **Time Formatting**: Parses `%TIME%` to force fixed-width, neatly-aligned entries.

### Linux/macOS (`.sh`)
- **OS Detection**: Detects Git Bash (`msys`/`cygwin`) vs. Linux/macOS to toggle `ping.exe` vs native `ping` flags.
- **Latency Extraction**: Uses `sed -n 's/.../p'` with decimal support (`[0-9.<]`) to capture response times like `0.4ms` or `<1ms` without falling back to whole-line summaries if a match fails.
- **POSIX Safety**: Conditionals like `[ "$RET" -eq 0 ]` use explicit double-quotes to ensure the shell receives a single token, preventing syntax crashes if a command exit code is unexpectedly empty or contains spaces.
- **Colored Output**: High-performance ANSI escape codes (`\033[...]m`).
- **Path Resolution**: Sophisticated path discovery via `dirname` and `pwd`.
- **Time Formatting**: Native high-precision formatting via `date`.

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
