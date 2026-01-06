@echo off
echo ============================================
echo   STOPPING ALL SERVERS
echo ============================================
echo.

echo [1/2] Stopping Rojo Server...
taskkill /FI "WINDOWTITLE eq Rojo Server*" /T /F 2>nul
if %errorlevel% equ 0 (
    echo Rojo server stopped.
) else (
    echo No Rojo server found.
)

echo [2/2] Stopping MCP Server...
set "MCP_DIR=C:\Users\blackbox\Documents\Github\roblox-mcp"
if exist "%MCP_DIR%\STOP_MCP_SERVER.bat" (
    call "%MCP_DIR%\STOP_MCP_SERVER.bat"
) else (
    echo MCP server script not found.
    taskkill /FI "WINDOWTITLE eq MCP Server*" /T /F 2>nul
)

echo.
echo ============================================
echo   ALL SERVERS STOPPED
echo ============================================
pause
