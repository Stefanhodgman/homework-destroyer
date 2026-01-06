@echo off
echo Stopping Rojo server...
taskkill /FI "WINDOWTITLE eq Rojo Server*" /T /F 2>nul
if %errorlevel% equ 0 (
    echo Rojo server stopped successfully.
) else (
    echo No Rojo server found running.
)
pause
