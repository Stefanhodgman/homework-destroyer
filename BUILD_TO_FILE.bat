@echo off
echo ============================================
echo   BUILD TO ROBLOX PLACE FILE
echo ============================================
echo.
echo This will build your src/ code into HomeworkDestroyer.rbxl
echo.

cd /d "%~dp0"

if not exist "rojo.exe" (
    echo ERROR: rojo.exe not found!
    pause
    exit /b 1
)

if not exist "HomeworkDestroyer.rbxl" (
    echo ERROR: HomeworkDestroyer.rbxl not found!
    pause
    exit /b 1
)

echo Building...
rojo.exe build -o HomeworkDestroyer.rbxl

if %errorlevel% equ 0 (
    echo.
    echo ============================================
    echo BUILD SUCCESSFUL!
    echo ============================================
    echo Your place file has been updated.
    echo You can now open HomeworkDestroyer.rbxl in Studio.
    echo.
) else (
    echo.
    echo ============================================
    echo BUILD FAILED!
    echo ============================================
    echo Check the error messages above.
    echo.
)

pause
