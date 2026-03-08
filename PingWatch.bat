@echo off
:: ============================================================
:: PingWatch.bat - Lightweight Network Monitor
:: Pings a host every 10 minutes and logs results to a .log file
:: ============================================================
:: Settings
:: ============================================================
setlocal EnableDelayedExpansion
set "TARGET=8.8.8.8"           :: Google Public DNS (Google.com)
set "PACKETS=1"                :: Number of pings to send per check
set "INTERVAL=600"             :: Ping interval in seconds
set "LOG=%~dp0PingWatch.log"   :: Output log filename
:: ============================================================

:: Color codes via PowerShell helper
:: We use PowerShell Write-Host for colored output in CMD

echo.
call :print_yellow "Monitoring: %TARGET% site"
call :print_yellow "Packets:    %PACKETS% ping(s)"
call :print_yellow "Interval:   %INTERVAL% second(s)"
call :print_yellow "Logging to: %LOG%"
echo.
call :print_yellow "Press any key to ping ON-DEMAND."
call :print_yellow "Press Ctrl+C to stop this process and close."
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
        call :print_green "[%D% %T%] SUCCESS - %TARGET% is reachable"
    ) else (
        echo [%D% %T%] FAILURE - %TARGET% is NOT reachable >> "%LOG%"
        call :print_red "[%D% %T%] FAILURE - %TARGET% is NOT reachable"
    )

    :: Wait for interval or ANY KEY to ping on-demand
    timeout /t %INTERVAL% >nul

goto LOOP

:: ============================================================
:: Color helper functions using PowerShell
:: ============================================================
:print_yellow
powershell -NoProfile -Command "Write-Host '%~1' -ForegroundColor Yellow"
goto :eof

:print_green
powershell -NoProfile -Command "Write-Host '%~1' -ForegroundColor Green"
goto :eof

:print_red
powershell -NoProfile -Command "Write-Host '%~1' -ForegroundColor Red"
goto :eof
