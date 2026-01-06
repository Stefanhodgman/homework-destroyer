@echo off
echo ============================================
echo   FIX ROJO PLUGIN - Downgrade to Match Server
echo ============================================
echo.
echo Your server is version 7.6.1 (protocol 4)
echo Your plugin is 7.6.0-Boatly (protocol 5) - TOO NEW!
echo.
echo We need to install the matching plugin version.
echo.
echo STEP 1: Download Matching Plugin
echo ================================
echo.

cd /d "%~dp0"

echo Downloading Rojo 7.6.1 plugin...
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://github.com/rojo-rbx/rojo/releases/download/v7.6.1/Rojo.rbxm' -OutFile 'Rojo-7.6.1.rbxm'}"

if exist "Rojo-7.6.1.rbxm" (
    echo.
    echo SUCCESS! Plugin downloaded to: Rojo-7.6.1.rbxm
    echo.
    echo ============================================
    echo   STEP 2: Install Plugin in Roblox Studio
    echo ============================================
    echo.
    echo 1. Open Roblox Studio
    echo 2. Go to: PLUGINS tab -^> Manage Plugins
    echo 3. Find "Rojo" in the list
    echo 4. Click UNINSTALL on the current version
    echo 5. Close Manage Plugins window
    echo 6. Go to: PLUGINS -^> Plugins Folder
    echo 7. Copy Rojo-7.6.1.rbxm into that folder
    echo 8. Restart Roblox Studio
    echo 9. Run START_GAME.bat again
    echo.
    echo The plugin file is ready in this folder: Rojo-7.6.1.rbxm
    echo.
) else (
    echo.
    echo Download failed!
    echo.
    echo MANUAL STEPS:
    echo 1. Go to: https://github.com/rojo-rbx/rojo/releases/tag/v7.6.1
    echo 2. Download: Rojo.rbxm
    echo 3. In Studio: PLUGINS -^> Manage Plugins -^> Uninstall old Rojo
    echo 4. In Studio: PLUGINS -^> Plugins Folder
    echo 5. Copy Rojo.rbxm into that folder
    echo 6. Restart Studio
    echo.
)

pause
