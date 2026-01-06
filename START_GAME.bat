@echo off
echo ============================================
echo   HOMEWORK DESTROYER - AUTOMATIC SETUP
echo ============================================
echo.

:: Set working directory
cd /d "%~dp0"

echo [1/5] Finding Roblox Studio...

:: Check multiple possible Studio locations
set "STUDIO_PATH="

if exist "C:\Program Files (x86)\Roblox\Versions" (
    set "STUDIO_PATH=C:\Program Files (x86)\Roblox\Versions"
    echo Found Studio in Program Files ^(x86^)
)

if exist "C:\Program Files\Roblox\Versions" (
    set "STUDIO_PATH=C:\Program Files\Roblox\Versions"
    echo Found Studio in Program Files
)

if exist "%LOCALAPPDATA%\Roblox\Versions" (
    set "STUDIO_PATH=%LOCALAPPDATA%\Roblox\Versions"
    echo Found Studio in AppData
)

if "%STUDIO_PATH%"=="" (
    echo ERROR: Roblox Studio not found!
    echo Please install Roblox Studio first.
    echo.
    pause
    exit /b 1
)

echo [2/5] Starting MCP Server...
set "MCP_DIR=C:\Users\blackbox\Documents\Github\roblox-mcp"
if exist "%MCP_DIR%\START_MCP_SERVER.bat" (
    start "MCP Server" /D "%MCP_DIR%" cmd /k START_MCP_SERVER.bat
    echo MCP Server starting...
    timeout /t 2 /nobreak >nul
) else (
    echo WARNING: MCP Server not found at %MCP_DIR%
    echo Continuing without MCP...
)

echo [3/5] Starting Rojo server...
start "Rojo Server" cmd /k "echo ROJO SERVER RUNNING && echo Connect Studio to: http://localhost:34872 && echo. && rojo.exe serve"

:: Wait for Rojo to start
timeout /t 3 /nobreak >nul

echo [4/5] Opening Roblox Studio with place file...
set "PLACE_FILE=%~dp0HomeworkDestroyer.rbxl"

:: Find latest Studio version
for /f "delims=" %%i in ('dir /b /ad /o-n "%STUDIO_PATH%"') do (
    set "LATEST_VERSION=%%i"
    goto :found_version
)
:found_version

set "STUDIO_EXE=%STUDIO_PATH%\%LATEST_VERSION%\RobloxStudioBeta.exe"

if exist "%STUDIO_EXE%" (
    echo Opening: %PLACE_FILE%
    start "" "%STUDIO_EXE%" "%PLACE_FILE%"
) else (
    echo WARNING: Could not auto-open Studio
    echo Please manually open: HomeworkDestroyer.rbxl
)

echo.
echo [5/5] Setup Complete!
echo.
echo ============================================
echo   NEXT STEPS IN ROBLOX STUDIO:
echo ============================================
echo 1. Wait for Studio to open
echo 2. Click the ROJO plugin button in toolbar
echo 3. Click "Connect" (should connect to localhost:34872)
echo 4. Click "Sync In" to sync all code
echo 5. Hit PLAY to test the game!
echo.
echo SERVERS RUNNING:
echo   - MCP Server: http://localhost:8000
echo   - Rojo Server: http://localhost:34872
echo.
echo CONTROLS IN GAME:
echo   - Click homework to destroy
echo   - S = Shop
echo   - U = Upgrades
echo   - P = Pets
echo   - H = Toggle HUD
echo   - ESC = Settings
echo.
echo ============================================
echo.
echo Press any key to close this window...
echo (Keep the server windows open!)
echo ============================================
pause >nul
