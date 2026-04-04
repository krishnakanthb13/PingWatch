<p align="center">
  <img src="pingwatch_icon.png" width="300" alt="PingWatch Logo">
</p>

---

# PingWatch - Lightweight Network Monitor

A hyper-minimalist network monitor for **Windows (Batch)** and **Linux/macOS (Bash)**. **PingWatch** is optimized for low-resource environments (like mobile hotspots or metered USB tethering), using native system commands to log connectivity without extra dependencies.

---

## 🛠️ Features

- **Latency Tracking**: Automatically captures and logs network response times (ms).
- **Locale-Agnostic**: Smart parsing (Win) works across all system languages (English, French, German, etc.).
- **Cross-Platform**: Full support for Windows (`.bat`) and Unix-like systems (`.sh`).
- **Colorful Interface**: High-visibility terminal output (Yellow for info, Green for success, Red for failure).
- **Smart OS Detection**: Automatically adjusts ping flags for Git Bash (Windows) vs. Linux/macOS environments.
- **Zero Dependencies**: No Python, Node.js, or external tools required—just native shell magic.
- **Set-and-Forget**: Configure your target once and let it run in the background.
- **Resource Efficient**: Consumes ~1.5MB of RAM and effectively 0% CPU while idling.
- **Interactive Hotkeys**: Switch between 5 different targets on-the-fly (`1`-`5`) or toggle ping intervals.
- **On-Demand Checking**: Press any key while focused to trigger a ping immediately.
- **Precision Logging**: Precise timestamps `[DD/MM/YYYY HH:MM:SS]` for every entry.

---

## ⚙️ Configuration

Both scripts contain a `Settings` block at the top. Open `PingWatch.bat` (Windows) or `PingWatch.sh` (Linux/macOS) in any text editor to edit:

### Windows (`.bat` Syntax)
```batch
set "TARGET=8.8.8.8"         :: Google Public DNS (Google.com)
set "PACKETS=1"              :: Number of pings to send per check
set "INTERVAL=600"           :: Time between checks (in seconds)
set "LOG=%~dp0PingWatch.log" :: Output log filename
```

### Linux / macOS (`.sh` Syntax)
```bash
TARGET="8.8.8.8"               # Google Public DNS (Google.com)
PACKETS=1                      # Number of pings to send per check
INTERVAL=600                   # Time between checks (in seconds)
LOG="PingWatch.log"            # Output log filename
```

---

## 🚀 How to Use

### Windows
1. **Launch**: Double-click `PingWatch.bat`.
2. **Monitor**: The console will show status, and a `PingWatch.log` file is updated in the same folder.
3. **Hotkeys**: Press `1`-`5` to change targets, or `F`/`M`/`N` to change the ping interval.
4. **On-Demand**: Press any other key to trigger a ping immediately.
5. **Stop**: Press **Ctrl+C** or close the window.

### Linux / macOS
1. **Permissions**: Make the script executable: `chmod +x PingWatch.sh`
2. **Launch**: Run it from the terminal: `./PingWatch.sh`
3. **Monitor**: Status is printed and appended to `PingWatch.log`.
4. **Hotkeys**: Press `1`-`5` to change targets, or `f`/`m`/`n` to change the ping interval.
5. **On-Demand**: Press any other key to trigger an instant ping.
6. **Stop**: Press **Ctrl+C**.

---

## 🎯 Recommended Targets

If you want the most reliable monitoring without being filtered or blocked for frequent pings, consider using these high-availability public DNS addresses:

| Provider | Hostname / IP | Benefit |
|----------|---------------|---------|
| **Google DNS** | `8.8.8.8` | Highly reliable and virtually never down. |
| **Cloudflare** | `1.1.1.1` | Optimized for speed and handles high ICMP traffic. |
| **Quad9** | `9.9.9.9` | High stability with security focus. |
| **OpenDNS** | `208.67.222.222` | Enterprise-grade availability. |
| **Google Site**| `google.com` | A solid check for actual web accessibility. |

> [!TIP]
> For best results, use IPs like `8.8.8.8` or `1.1.1.1` instead of domain names. This bypasses DNS lookups and ensures you are testing your raw internet connection.

---

## 📚 Project Documentation

For deeper insights into the scripts, please see:
- [CODE_DOCUMENTATION.md](CODE_DOCUMENTATION.md) - Technical details and implementation mechanisms.
- [DESIGN_PHILOSOPHY.md](DESIGN_PHILOSOPHY.md) - Project goals, reasoning, and core ideology.

---

## 📊 Performance & Resource Usage

| Resource | Usage                              | Why? |
|----------|------------------------------------|------|
| **CPU**  | < 0.1%                             | Spends 99.8% of time in an idle sleep state. |
| **RAM**  | ~1.5 MB                            | Overhead of a standard `cmd.exe` or `bash` process. |
| **Network**| ~32 Bytes / Check                 | Minimal ICMP Echo Request packets. |
| **Disk** | ~50 Bytes / Entry                  | Direct, efficient binary-safe appending to `.log`. |

---

## 📋 Log File Format

Entries in `PingWatch.log` are designed to be easily grep-able or imported into Excel:

```text
[07/03/2026 13:45:12] SUCCESS - 8.8.8.8 is reachable (Latency: 28ms)
[07/03/2026 13:55:04] SUCCESS - 8.8.8.8 is reachable (Latency: 31ms)
[07/03/2026 14:05:59] FAILURE - 8.8.8.8 is NOT reachable
```

---

## 💡 Pro Tips

- **Minimize to Tray (Win)**: Run the script and minimize; it continues logging without slowing your PC.
- **Background (Unix)**: Run as a background process with `nohup ./PingWatch.sh &`.
- **Multiple Targets**: Copy the script into different folders. Each instance will manage its own `PingWatch.log`.
- **Auto-Start**: 
  - **Windows**: Place a shortcut to `.bat` in `shell:startup`.
  - **Linux**: Add to your `.bashrc` or `crontab -e @reboot`.
- **Windows Defender**: On Windows 11, if Defender flags the script, right-click → Properties → **Unblock**.

---

## 💻 Requirements

- **Windows**: Windows 7 / 8 / 10 / 11 (Any edition).
- **Unix**: Linux (Any distro), macOS, or WSL.
- **Rights**: Standard user permissions (Administrator/Root NOT required).
- **Disk**: ~500KB for the script; log size depends on duration.
