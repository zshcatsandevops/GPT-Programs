
Optimize Windows update batch script
Oct 24
·
catsanzsh/-catbackups
·
main
·
+196
-0

Archive

Share

Create PR


@echo off
title SAMSOFT AUTO-UPDATER 11 — November 2025 Edition (Fixed)
color 0A
cls

echo ===============================================================
echo        SAMSOFT AUTO WINDOWS 11 UPDATER — NOVEMBER 2025
echo ===============================================================
echo   • Installs latest cumulative update (official Microsoft source)
echo   • Works offline (from .MSU) or online (via PowerShell)
echo ===============================================================
echo.

:: Step 1: Detect Windows build
for /f "tokens=2 delims=:" %%a in ('systeminfo ^| findstr /b /c:"OS Version"') do set "build=%%a"
echo Detected Build:%build%
set WORKDIR=%SystemRoot%\Temp\SamsoftUpdater
if not exist "%WORKDIR%" mkdir "%WORKDIR%"
cd /d "%WORKDIR%"
echo Working folder: %WORKDIR%
echo.

:: Step 2: If offline .msu exists, install it
if exist "%WORKDIR%\*.msu" (
    echo Found local update packages...
    for %%F in ("%WORKDIR%\*.msu") do (
        echo Installing %%~nxF ...
        wusa "%%F" /quiet /norestart
    )
    goto :end
)

:: Step 3: Attempt online update using PowerShell
echo Attempting to fetch & install updates via PowerShell...
powershell -NoProfile -ExecutionPolicy Bypass ^
  "Install-Module -Name PSWindowsUpdate -Force -ErrorAction SilentlyContinue;" ^
  "Import-Module PSWindowsUpdate;" ^
  "Write-Host 'Checking for updates...';" ^
  "Get-WindowsUpdate -AcceptAll -Install -IgnoreReboot | Out-File 'C:\\Windows\\Temp\\SamsoftUpdater\\update_log.txt'"

if %errorlevel% neq 0 (
    echo [ERROR] Online update failed or module not available.
    echo Try placing .MSU update files in %WORKDIR% for offline install.
    pause
    exit /b
)

:end
echo.
echo ===============================================================
echo   Update complete! Check Windows Update History for details.
echo   You may need to restart your PC.
echo ===============================================================
choice /m "Restart now?"
if errorlevel 1 shutdown /r /t 10
exit  make this batch scirpt pure and optimized with joy :D have it have everything windows update and prompts like Microsoft Toolkit in batch 3 2 1 go  ! > Program.bat
Copy
Summary

Added Program.bat, a refreshed SAMSOFT auto-updater with an interactive menu that supports offline MSU installation, online PSWindowsUpdate execution, log viewing, and workspace access for Windows 11 maintenance.

Implemented administrative privilege checks, workspace preparation, detailed logging, and reboot guidance to streamline update workflows and keep users informed throughout the process.

Testing

⚠️ No automated tests were run (Windows batch script).


File (1)

Program.bat
New



Diff
Logs

Program.bat
New
+196
-0

@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

set "SCRIPT_NAME=SAMSOFT Auto-Updater"
set "SCRIPT_VERSION=11.0.0 — November 2025 Edition"
set "WORKDIR=%SystemRoot%\Temp\SamsoftUpdater"
set "LOGFILE=%WORKDIR%\update_log.txt"
set "PS_SCRIPT=%WORKDIR%\Invoke-Update.ps1"

call :SetStyle
cls
call :Banner "Boot"

call :EnsureAdmin || goto :Eof
call :PrepareWorkspace || goto :Eof
call :DetectBuild

:MainMenu
cls
call :Banner "Dashboard"
echo  [1] Offline install (from existing .MSU files)
echo  [2] Online install (Windows Update via PowerShell)
echo  [3] View update log
echo  [4] Open work folder
echo  [5] Exit
choice /c 12345 /n /m "Select an option: "
set "selection=%errorlevel%"
cls
if "%selection%"=="1" call :OfflineInstall & goto :PostAction
if "%selection%"=="2" call :OnlineInstall & goto :PostAction
if "%selection%"=="3" call :ShowLog & goto :WaitKey
if "%selection%"=="4" call :OpenWorkdir & goto :WaitKey
if "%selection%"=="5" goto :Goodbye
goto :MainMenu

:PostAction
call :DetectPendingReboot
:WaitKey
echo.
choice /n /m "Return to main menu?" >nul
if errorlevel 2 goto :Goodbye
goto :MainMenu

:Goodbye
cls
call :Banner "Complete"
echo  Update assistant finished. Review Windows Update history for details.
echo  Thank you for using SAMSOFT with joy! ^>^/
echo.
choice /m "Restart now?"
if errorlevel 1 shutdown /r /t 10
exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Helper Routines
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:SetStyle
set "PrimaryColor=0A"
color %PrimaryColor%
title %SCRIPT_NAME% — %SCRIPT_VERSION%
exit /b

:Banner
cls
echo ===============================================================
echo       %SCRIPT_NAME% — %SCRIPT_VERSION%
echo ===============================================================
if not "%~1"=="" echo   Mode: %~1
if defined BUILD echo   Detected Build: %BUILD%
if defined CHANNEL echo   Update Channel: %CHANNEL%
echo ===============================================================
echo.
exit /b

:EnsureAdmin
net session >nul 2>&1 && exit /b 0
echo  [!] Administrative privileges are required.
echo      Right-click this script and choose "Run as administrator".
pause
exit /b 1

:PrepareWorkspace
if exist "%WORKDIR%" goto :pw_continue
mkdir "%WORKDIR%" || (
    echo  [!] Unable to create work folder: %WORKDIR%
    pause
    exit /b 1
)
:pw_continue
if exist "%LOGFILE%" del /f /q "%LOGFILE%" >nul 2>&1
for %%# in (Pending.xml) do if exist "%WORKDIR%\%%#" del /f /q "%WORKDIR%\%%#" >nul 2>&1
exit /b 0

:DetectBuild
for /f "tokens=2 delims=:" %%a in ('systeminfo ^| findstr /b /c:"OS Version"') do (
    set "raw=%%a"
)
for /f "tokens=*" %%b in ("!raw!") do set "raw=%%b"
for /f "tokens=2" %%c in ("!raw!") do set "BUILD=%%c"
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ReleaseId >nul 2>&1 && (
    for /f "skip=2 tokens=2,*" %%d in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v DisplayVersion 2^>nul') do set "CHANNEL=%%e"
)
exit /b

:OfflineInstall
call :Banner "Offline"
if not exist "%WORKDIR%\*.msu" (
    echo  No .MSU packages found in:
    echo    %WORKDIR%
    echo.
    echo  Place the desired cumulative update .MSU files here and retry.
    exit /b
)
set "count=0"
for %%F in ("%WORKDIR%\*.msu") do (
    set /a count+=1
    echo  Installing %%~nxF ...
    echo  [%date% %time%] Installing %%~nxF>>"%LOGFILE%"
    wusa "%%~fF" /quiet /norestart
    if errorlevel 1 (
        echo     [!] Installation failed for %%~nxF (see log).
        echo  [%date% %time%] ERROR %%~nxF>>"%LOGFILE%"
    ) else (
        echo     [✓] Success
        echo  [%date% %time%] SUCCESS %%~nxF>>"%LOGFILE%"
    )
)
if "!count!"=="0" echo  No .MSU packages processed.
exit /b

:OnlineInstall
call :Banner "Online"
echo  Preparing PowerShell update routine...
call :WritePowerShellScript || exit /b
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%"
if errorlevel 1 (
    echo.
    echo  [!] Online update failed. Review the log for details.
    exit /b 1
)
echo.
echo  [✓] Online updates finished. A reboot may be required.
exit /b 0

:ShowLog
call :Banner "Log Viewer"
if not exist "%LOGFILE%" (
    echo  No log file found yet. Run an update first.
    exit /b
)
type "%LOGFILE%"
exit /b

:OpenWorkdir
call :Banner "Workspace"
if exist "%WORKDIR%" (
    echo  Opening folder: %WORKDIR%
    start "" explorer "%WORKDIR%"
) else (
    echo  Work folder does not exist.
)
exit /b

:DetectPendingReboot
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" >nul 2>&1 && (
    echo  [!] Windows reports a pending reboot. Please restart soon.
)
exit /b

:WritePowerShellScript
>"%PS_SCRIPT%" ( 
    echo try {
    echo     Import-Module PSWindowsUpdate -ErrorAction SilentlyContinue ^| Out-Null
    echo } catch {
    echo     Install-PackageProvider -Name NuGet -Force -ErrorAction SilentlyContinue ^| Out-Null
    echo     Install-Module -Name PSWindowsUpdate -Force -Confirm:$false -ErrorAction Stop
    echo     Import-Module PSWindowsUpdate -ErrorAction Stop
    echo }
    echo Add-WUServiceManager -MicrosoftUpdate -ErrorAction SilentlyContinue ^| Out-Null
    echo Write-Host "Checking for Windows updates..." -ForegroundColor Cyan
    echo $result = Get-WindowsUpdate -AcceptAll -Install -IgnoreReboot -ErrorAction Stop
    echo $result ^| Tee-Object -FilePath '%LOGFILE%' -Append ^| Out-String ^| Write-Host
    echo Write-Host "Updates processed. Review the log for details." -ForegroundColor Green
    echo exit 0
    echo )
if errorlevel 1 (
    echo  [!] Unable to create PowerShell helper script.
    exit /b 1
)
exit /b 0

:Eof
endlocal
exit /b
