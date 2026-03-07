@echo off
:: ============================================================
:: PingWatch.bat - Lightweight Network Monitor
:: Pings a host every 10 minutes and logs results to a .txt file
:: ============================================================

setlocal

set "LOG=%~dp0PingWatch_log.txt"
set /p TARGET="Enter website or IP to ping: "

if "%TARGET%"=="" (
    echo No address entered. Exiting.
    pause
    exit /b
)

echo.
echo Monitoring: %TARGET%
echo Logging to: %LOG%
echo Press Ctrl+C to stop.
echo.

:LOOP
    :: Get current date and time
    for /f "tokens=1-4 delims=/ " %%a in ("%DATE%") do set "D=%%a/%%b/%%c"
    for /f "tokens=1-2 delims=:." %%a in ("%TIME%") do set "T=%%a:%%b"

    :: Ping once, suppress output, check result
    ping -n 1 -w 2000 %TARGET% >nul 2>&1

    if %ERRORLEVEL%==0 (
        echo [%D% %T%] SUCCESS - %TARGET% is reachable >> "%LOG%"
        echo [%D% %T%] SUCCESS - %TARGET% is reachable
    ) else (
        echo [%D% %T%] FAILURE - %TARGET% is NOT reachable >> "%LOG%"
        echo [%D% %T%] FAILURE - %TARGET% is NOT reachable
    )

    :: Wait 10 minutes (600 seconds) using timeout, silent mode
    timeout /t 600 /nobreak >nul

goto LOOP
