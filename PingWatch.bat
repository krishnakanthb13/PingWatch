@echo off
:: ============================================================
:: PingWatch.bat - Lightweight Network Monitor
:: Pings a host every 10 minutes and logs results to a .txt file
:: ============================================================
:: Settings
:: ============================================================
set "TARGET=google.com"
set "PACKETS=1"
set "INTERVAL=600"
set "LOG=%~dp0PingWatch_log.txt"
:: ============================================================

echo.
echo Monitoring: %TARGET% site
echo Packets:    %PACKETS% pings
echo Interval:   %INTERVAL% seconds
echo Logging to: %LOG%
echo.
echo Press Ctrl+C to stop this process and close.
echo.

:LOOP
    :: Get current date and time
    for /f "tokens=1-4 delims=/ " %%a in ("%DATE%") do set "D=%%a/%%b/%%c"
    for /f "tokens=1-2 delims=:." %%a in ("%TIME%") do set "T=%%a:%%b"

    :: Ping using configured packet count, suppress output, check result
    ping -n %PACKETS% -w 2000 %TARGET% >nul 2>&1

    if %ERRORLEVEL%==0 (
        echo [%D% %T%] SUCCESS - %TARGET% is reachable >> "%LOG%"
        echo [%D% %T%] SUCCESS - %TARGET% is reachable
    ) else (
        echo [%D% %T%] FAILURE - %TARGET% is NOT reachable >> "%LOG%"
        echo [%D% %T%] FAILURE - %TARGET% is NOT reachable
    )

    :: Wait using configured interval, silent mode
    timeout /t %INTERVAL% /nobreak >nul

goto LOOP
