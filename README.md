# PingWatch - Lightweight Network Monitor

A hyper-minimalist Windows batch script designed for monitoring network stability. **PingWatch** is optimized for low-resource environments (like mobile hotspots or metered USB tethering), using native Windows commands to log connectivity without the overhead of modern monitoring suites.

---

## 🛠️ Features

- **Zero Dependencies**: No Python, Node.js, or external executables required.
- **Set-and-Forget**: Configure your target host once and let it run in the background.
- **Resource Efficient**: Consumes ~1-3MB of RAM and effectively 0% CPU while idling.
- **Metered Connection Friendly**: Minimizes data usage by sending single ICMP packets at long intervals.
- **Self-Contained**: Automatically creates logic-based logs in its own directory.

---

## ⚙️ Configuration

The script is non-interactive for speed and reliability. To change where it pings or how often, right-click `PingWatch.bat` → **Edit** and modify the `Settings` block at the top:

```batch
:: ============================================================
:: Settings
:: ============================================================
set "TARGET=google.com"    :: The website or IP address to monitor
set "PACKETS=1"           :: Number of pings to send per check
set "INTERVAL=600"         :: Time between checks (in seconds)
:: ============================================================
```

---

## 🚀 How to Use

1. **Setup**: Place `PingWatch.bat` in a folder of your choice.
2. **Configure**: (Optional) Edit the `TARGET` variable in the file if you want to ping something other than Google.
3. **Launch**: Double-click `PingWatch.bat`.
4. **Monitor**: The console will show the status, and a `PingWatch_log.txt` file will be created/updated in the same folder.
5. **Stop**: To stop the process, press **Ctrl+C** in the terminal window and confirm (if prompted), or simply close the window.

---

## 🔍 Technical Deep Dive

### The Loop Logic
The script operates in a continuous cycle:

1. **Timestamping**: Uses native `%DATE%` and `%TIME%` variables, parsed for clean `[DD/MM/YYYY HH:MM]` formatting.
2. **Ping Execution**: 
   - `ping -n %PACKETS%`: Sends exactly the number of packets specified (default 1).
   - `-w 2000`: Waits 2 seconds for a response before timing out.
   - `>nul 2>&1`: Suppresses all command output to keep the console clean and save CPU cycles.
3. **Conditionals**: Checks `%ERRORLEVEL%`. If `0`, the host is reachable; otherwise, a failure is logged.
4. **Appending**: Uses `>>` to append logs. This ensures you never lose history unless you manually delete the log file.
5. **Native Sleep**: Uses the `timeout` command which puts the process into an idle state, requiring nearly zero system interrupts.

---

## 📊 Performance & Resource Usage

| Resource | Usage                              | Why? |
|----------|------------------------------------|------|
| **CPU**  | < 0.1%                             | Spends 99.8% of time in `timeout` (idle state). |
| **RAM**  | ~1.5 MB                            | Only the overhead of a standard `cmd.exe` process. |
| **Network**| ~32 Bytes / 10 Mins               | Standard ICMP Echo Request. |
| **Disk** | ~50 Bytes / Entry                  | Efficient plain-text appending. |

---

## 📋 Log File Format

Entries in `PingWatch_log.txt` are designed to be easily grep-able or imported into Excel:

```text
[07/03/2026 13:45] SUCCESS - google.com is reachable
[07/03/2026 13:55] SUCCESS - google.com is reachable
[07/03/2026 14:05] FAILURE - google.com is NOT reachable
```

---

## 💡 Pro Tips

- **Minimize to Tray**: Run the script and then minimize the window; it will continue logging without cluttering your taskbar.
- **Multiple Targets**: Copy the script to different folders and change the `TARGET` in each one. They will each maintain their own separate log files.
- **Startup**: Create a shortcut to the `.bat` file in your Windows Startup folder (`shell:startup`) to begin monitoring automatically when you log in.

---

## 💻 Requirements

- **OS**: Windows 7 / 8 / 10 / 11.
- **Rights**: Standard user permissions (Administrator not required).
- **Disk**: Minimal space for text logs.
