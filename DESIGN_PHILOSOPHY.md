# Design Philosophy: PingWatch

## The Core Ideology

PingWatch was conceived out of a fundamental need for reliability in constrained environments. When monitoring a flaky network, the monitoring tool itself must never be the point of failure.

Our design philosophy is anchored in three primary tenets:

1. **Absolute Minimalism**: Features should only be added if they require zero external dependencies. If a feature requires Python, Node.js, or compiled binaries, it does not belong in PingWatch.
2. **Native Resilience**: By leveraging native OS features (Batch on Windows, Bash on Unix), PingWatch guarantees cross-compatibility out-of-the-box on almost any system manufactured in the last two decades.
3. **Set, Forget, or Intervene**: The tool must be invisible when you don't need it (idling at effectively 0% CPU), but instantly responsive when you do (interactive hotkeys for on-demand diagnostics).

## Key Architectural Decisions

### Why Not Python/Go/Rust?
While modern languages offer superior text-parsing and asynchronous features, they require the host system to have the runtime installed (Python/Node) or force the distribution of heavy standalone binaries (Go/Rust). PingWatch is designed to be copy-pasted in an email or downloaded over a dying 2G connection. At ~4KB, the script is universally portable.

### The Interactive Scheduler Swap
Originally, PingWatch used static `timeout` / `sleep` commands. While efficient, this forced users to wait up to 10 minutes (the default interval) or restart the script just to run a manual check. 
The transition to a hybrid PowerShell key-listener (Windows) and a timeout-based `read` (Linux) enables a responsive, interactive CLI without compromising the native requirement.

### Log Grep-ability
Logs are strictly formatted as `[DD/MM/YYYY HH:MM:SS] STATUS - Target`. This uniform, fixed-width prefix ensures that standard text tools (like `grep`, `awk`, or Excel CSV importing) can perfectly parse thousands of lines of logs without regex gymnastics.
