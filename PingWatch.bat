@echo off
:: ============================================================
:: PingWatch.bat - Lightweight Network Monitor
:: Pings a host every 10 minutes and logs results to a .log file
:: ============================================================
:: Settings
:: ============================================================
set "TARGET=google.com"
set "PACKETS=1"
set "INTERVAL=600"
set "LOG=%~dp0PingWatch.log"
:: ============================================================

echo.
echo Monitoring: %TARGET% site
echo Packets:    %PACKETS% ping(s)
echo Interval:   %INTERVAL% second(s)
echo Logging to: %LOG%
echo.
echo Press any key to ping ON-DEMAND.
echo Press Ctrl+C to stop this process and close.
echo.

:LOOP
    :: Get current date and time (Robust parsing for DD-MM-YYYY)
    for /f "tokens=1-3 delims=-/ " %%a in ("%DATE%") do set "D=%%a/%%b/%%c"
    for /f "tokens=1-3 delims=:." %%a in ("%TIME%") do (
        set "HH=%%a"
        set "MM=%%b"
        set "SS=%%c"
    )
    :: Handle leading space in hour (for times before 10 AM)
    set "HH=%HH: =0%"
    set "T=%HH%:%MM%:%SS%"

    :: Ping using configured packet count, suppress output, check result
    ping -n %PACKETS% -w 2000 %TARGET% >nul 2>&1

    if %ERRORLEVEL%==0 (
        echo [%D% %T%] SUCCESS - %TARGET% is reachable >> "%LOG%"
        echo [%D% %T%] SUCCESS - %TARGET% is reachable
    ) else (
        echo [%D% %T%] FAILURE - %TARGET% is NOT reachable >> "%LOG%"
        echo [%D% %T%] FAILURE - %TARGET% is NOT reachable
    )

    :: Wait for interval or ANY KEY to ping on-demand
    timeout /t %INTERVAL% >nul

goto LOOP
