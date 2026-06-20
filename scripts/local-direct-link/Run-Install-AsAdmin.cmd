@echo off
setlocal
set SCRIPT_DIR=%~dp0
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%Install-DirectLinuxLink.ps1"
echo.
echo Installer finished. Press any key to close this window.
pause >nul
