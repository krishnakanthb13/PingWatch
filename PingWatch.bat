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

call :print_yellow "Monitoring: %TARGET% site"
call :print_yellow "Packets:    %PACKETS% ping(s)"
call :print_yellow "Interval:   %INTERVAL% second(s)"
call :print_yellow "Logging to: %LOG%"
echo.
call :print_yellow "Targets: (1) 8.8.8.8 (2) 1.1.1.1 (3) 9.9.9.9 (4) 208.67.222.222 (5) google.com"
call :print_yellow "Intervals: (F)ast 10s | (M)edium 60s | (N)ormal 600s"
call :print_yellow "Press any other key to ping ON-DEMAND."
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

    :: Reset KEY and determine which target to ping
    set "CURRENT_TARGET=%TARGET%"
    if "%KEY%"=="1" set "CURRENT_TARGET=8.8.8.8"
    if "%KEY%"=="2" set "CURRENT_TARGET=1.1.1.1"
    if "%KEY%"=="3" set "CURRENT_TARGET=9.9.9.9"
    if "%KEY%"=="4" set "CURRENT_TARGET=208.67.222.222"
    if "%KEY%"=="5" set "CURRENT_TARGET=google.com"
    if /I "%KEY%"=="F" set "INTERVAL=10"
    if /I "%KEY%"=="M" set "INTERVAL=60"
    if /I "%KEY%"=="N" set "INTERVAL=600"

    :: Capture ping output to a unique temporary file to avoid concurrency and CWD issues
    set "TEMP_OUT=%TEMP%\ping_watch_%RANDOM%_%RANDOM%.txt"
    set "LATENCY=N/A"
    set "STATUS=FAILURE"
    
    ping -n %PACKETS% -w 2000 %CURRENT_TARGET% > "%TEMP_OUT%" 2>&1
    if %ERRORLEVEL%==0 (
        set "STATUS=SUCCESS"
        set "LAST_NUM="
        :: Extract numeric latency values in a locale-agnostic way (handles "time=", "temps=", "Zeit=", etc.)
        for /f "tokens=*" %%L in ('findstr /R "[0-9][0-9]*ms" "%TEMP_OUT%"') do (
            for /f "tokens=1-15 delims==, " %%a in ("%%L") do (
                for %%v in (%%a %%b %%c %%d %%e %%f %%g %%h %%i %%j %%k %%l %%m %%n %%o) do (
                    set "TOK=%%v"
                    set "CLEAN=!TOK:ms=!"
                    if "!CLEAN!" neq "!TOK!" (
                        :: We hit 'ms'. If 'CLEAN' is empty, the number was a separate token (e.g. "19 ms")
                        if "!CLEAN!"=="" (
                            if defined LAST_NUM set "LATENCY=!LAST_NUM!"
                        ) else (
                            set "LATENCY=!CLEAN!"
                        )
                    ) else (
                        :: Store potential numeric strings to associate with 'ms' if it follows as a separate token
                        set "W=!TOK!"
                        for /f "delims=0123456789" %%x in ("!TOK!") do set "W=NO"
                        if "!W!" neq "NO" if not "!TOK!"=="" set "LAST_NUM=!TOK!"
                    )
                )
            )
        )
        :: Cleanup and format the final result
        if "!LATENCY!"=="N/A" ( set "STATUS=FAILURE" ) else ( set "LATENCY=!LATENCY!ms" )
    )
    if exist "%TEMP_OUT%" del "%TEMP_OUT%"

    if "%STATUS%"=="SUCCESS" (
        set "PMSG=[%D% %T%] SUCCESS - %CURRENT_TARGET% is reachable (Latency: %LATENCY%)"
        echo !PMSG! >> "%LOG%"
        call :print_green "!PMSG!"
    ) else (
        echo [%D% %T%] FAILURE - %CURRENT_TARGET% is NOT reachable >> "%LOG%"
        call :print_red "[%D% %T%] FAILURE - %CURRENT_TARGET% is NOT reachable"
    )

    :: Wait for interval or ANY KEY to ping on-demand
    :: We use a PowerShell one-liner to capture the pressed key and timeout
    set "KEY="
    for /f "delims=" %%A in ('powershell -NoProfile -Command "if ([System.Console]::IsInputRedirected) { Start-Sleep -Seconds %INTERVAL% } else { [Console]::TreatControlCAsInput = $true; $d = (Get-Date).AddSeconds(%INTERVAL%); while ((Get-Date) -lt $d) { if ([System.Console]::KeyAvailable) { $k = [System.Console]::ReadKey($true); if ($k.Modifiers -band [ConsoleModifiers]::Control -and $k.Key -eq [ConsoleKey]::C) { Write-Output 'CTRL_C'; break } else { Write-Output $k.KeyChar; break } }; Start-Sleep -Milliseconds 50 } }"') do set "KEY=%%A"

    if "!KEY!"=="CTRL_C" (
        echo.
        call :print_yellow "Exiting PingWatch..."
        goto :eof
    )

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
