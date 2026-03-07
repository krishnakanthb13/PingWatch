# PingWatch - Lightweight Network Monitor

A minimal Windows batch script that pings a target host every 10 minutes
and logs success or failure to a plain text file in the same directory.

Designed for low-resource environments (e.g. mobile hotspot / USB tethering).

---

## Files

| File               | Purpose                                      |
|--------------------|----------------------------------------------|
| PingWatch.bat      | Main script - run this                       |
| PingWatch_log.txt  | Auto-created log file (same folder as .bat)  |

---

## How to Use

1. Place `PingWatch.bat` in any folder you like.
2. Double-click it (or right-click → Run as Administrator if needed).
3. When prompted, type a website or IP address, e.g.:
       google.com
       8.8.8.8
       192.168.1.1
4. Press Enter. The script starts monitoring immediately.
5. Results print on screen AND are saved to `PingWatch_log.txt`.
6. To stop: press **Ctrl+C** in the window, then close it.

---

## Log File Format

Each line in `PingWatch_log.txt` looks like:

    [DD/MM/YYYY HH:MM] SUCCESS - google.com is reachable
    [DD/MM/YYYY HH:MM] FAILURE - google.com is NOT reachable

The log file grows over time. You can open it any time in Notepad.
To clear it, simply delete the file — it will be recreated on the next run.

---

## Code Documentation

### `setlocal`
Keeps all variables scoped to this script only.
Prevents pollution of the system environment. Clean and safe.

### `set "LOG=%~dp0PingWatch_log.txt"`
`%~dp0` = the folder where the .bat file lives (drive + path).
This means the log always saves next to the script, regardless of where
you place it. No hardcoded paths needed.

### `set /p TARGET=...`
Prompts the user to type the address interactively.
No GUI needed — keeps the script lean.

### `ping -n 1 -w 2000 %TARGET% >nul 2>&1`
- `-n 1`     → Send only 1 ping packet (minimum needed to test connectivity)
- `-w 2000`  → Wait up to 2 seconds for a reply (2000ms timeout)
- `>nul`     → Suppress standard output (we only care about exit code)
- `2>&1`     → Also suppress error output
Why: 1 packet is enough to confirm reachability. Less traffic = better
for metered/mobile connections. Suppressing output saves CPU cycles
from rendering text we don't need.

### `if %ERRORLEVEL%==0`
ping.exe returns exit code 0 on success, non-zero on failure.
This is the most reliable and CPU-cheap way to check the result —
no string parsing, no extra tools.

### `>> "%LOG%"`
Double `>>` appends to the file instead of overwriting it.
Quotes around the path handle spaces in folder names safely.

### `timeout /t 600 /nobreak >nul`
- `timeout`    → Built-in Windows command, no extra processes spawned
- `/t 600`     → Wait 600 seconds (10 minutes)
- `/nobreak`   → Prevents accidental skipping by pressing a key
- `>nul`       → Suppresses the countdown display (saves tiny CPU cycles)
Why timeout over ping sleep or ping -n X: `timeout` is a native,
single-purpose idle command. It sleeps the process entirely —
virtually zero CPU and RAM use during the wait period.

### `goto LOOP`
Simple infinite loop back to the top. No scheduled tasks, no services,
no background agents. The script itself IS the scheduler. This keeps
it self-contained and easy to kill.

---

## Resource Usage

| Resource | Usage                              |
|----------|------------------------------------|
| CPU      | Near-zero (idle 99.8% of the time) |
| RAM      | ~1-3 MB (cmd.exe overhead only)    |
| Network  | 1 ICMP packet per 10 minutes       |
| Disk     | Appends ~50 bytes per entry        |

This script is intentionally minimal. It does one thing, does it well,
and gets out of the way.

---

## Tips

- Run it in the background by minimising the window — it won't slow
  your PC down.
- To change the interval, edit the `timeout /t 600` line.
  Example: `/t 300` = every 5 minutes, `/t 1800` = every 30 minutes.
- You can run multiple instances simultaneously for different targets —
  each will create its own log if placed in different folders.
- On Windows 11, if Defender flags it, right-click → Properties →
  Unblock, then run again.

---

## Requirements

- Windows 7 / 8 / 10 / 11 (any edition)
- No admin rights required in most cases
- No installs, no dependencies
