@echo off
echo ============================================
echo   QUICK TEST - Build and Open
echo ============================================
echo.

cd /d "%~dp0"

echo [1/2] Building to place file...
rojo.exe build -o HomeworkDestroyer.rbxl

if %errorlevel% neq 0 (
    echo Build failed!
    pause
    exit /b 1
)

echo [2/2] Opening in Studio...

:: Check multiple possible Studio locations
set "STUDIO_PATH="

if exist "C:\Program Files (x86)\Roblox\Versions" set "STUDIO_PATH=C:\Program Files (x86)\Roblox\Versions"
if exist "C:\Program Files\Roblox\Versions" set "STUDIO_PATH=C:\Program Files\Roblox\Versions"
if exist "%LOCALAPPDATA%\Roblox\Versions" set "STUDIO_PATH=%LOCALAPPDATA%\Roblox\Versions"

if "%STUDIO_PATH%"=="" (
    echo Could not find Studio installation.
    echo Please open HomeworkDestroyer.rbxl manually.
    pause
    exit /b 1
)

:: Find latest version
for /f "delims=" %%i in ('dir /b /ad /o-n "%STUDIO_PATH%"') do (
    set "LATEST_VERSION=%%i"
    goto :found
)
:found

set "STUDIO_EXE=%STUDIO_PATH%\%LATEST_VERSION%\RobloxStudioBeta.exe"

if exist "%STUDIO_EXE%" (
    start "" "%STUDIO_EXE%" "%~dp0HomeworkDestroyer.rbxl"
    echo.
    echo Studio is opening...
    echo Press any key to close this window.
) else (
    echo Could not find Studio. Please open manually.
)

pause >nul
