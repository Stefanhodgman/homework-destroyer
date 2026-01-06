@echo off
echo ============================================
echo   FIX ROJO VERSION MISMATCH
echo ============================================
echo.
echo Your Rojo plugin (7.6.0-Boatly) is newer than your server (7.6.1)
echo.
echo OPTION 1: Download Latest Rojo Server (RECOMMENDED)
echo ================================================
echo 1. Go to: https://github.com/rojo-rbx/rojo/releases/latest
echo 2. Download: rojo-7.6.1-windows.zip (or newer)
echo 3. Extract rojo.exe
echo 4. Replace the old rojo.exe in this folder
echo.
echo OPTION 2: Automatic Download (if you have curl)
echo ================================================
echo Press 'A' to try automatic download
echo Press any other key to skip
echo.
choice /C AC /N /M "Your choice: "

if errorlevel 2 goto skip
if errorlevel 1 goto download

:download
echo.
echo Downloading latest Rojo...
cd /d "%~dp0"

:: Backup old version
if exist rojo.exe (
    echo Backing up old rojo.exe to rojo.exe.old
    copy /Y rojo.exe rojo.exe.old >nul
)

:: Try downloading with PowerShell
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $latest = (Invoke-RestMethod 'https://api.github.com/repos/rojo-rbx/rojo/releases/latest').tag_name; $url = \"https://github.com/rojo-rbx/rojo/releases/download/$latest/rojo-$($latest.TrimStart('v'))-windows.zip\"; Write-Host \"Downloading from: $url\"; Invoke-WebRequest -Uri $url -OutFile 'rojo-latest.zip'; Expand-Archive -Path 'rojo-latest.zip' -DestinationPath 'rojo-temp' -Force; Copy-Item 'rojo-temp\rojo.exe' -Destination '.' -Force; Remove-Item 'rojo-latest.zip'; Remove-Item 'rojo-temp' -Recurse}"

if exist rojo.exe (
    echo.
    echo SUCCESS! Rojo updated.
    rojo.exe --version
    echo.
    echo Now run START_GAME.bat again!
) else (
    echo.
    echo Download failed. Please use OPTION 1 (manual download).
)

pause
exit /b

:skip
echo.
echo Manual download instructions:
echo 1. Visit: https://github.com/rojo-rbx/rojo/releases/latest
echo 2. Download the Windows .zip file
echo 3. Extract rojo.exe to this folder
echo 4. Run START_GAME.bat again
echo.
pause
