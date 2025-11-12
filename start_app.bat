@echo off
REM Project Drishti - Complete App Startup Script
echo ================================================================================
echo PROJECT DRISHTI - STARTING COMPLETE APPLICATION
echo ================================================================================
echo.

echo Step 1: Starting Backend Server...
echo.
start "Drishti Backend Server" cmd /k "start_backend.bat"

echo Waiting 10 seconds for backend to initialize...
timeout /t 10 /nobreak >nul
echo.

echo Step 2: Starting Flutter App...
echo.
echo Choose platform:
echo   1. Web (Chrome)
echo   2. Windows Desktop
echo   3. Android (if connected)
echo.
set /p choice="Enter choice (1-3): "

if "%choice%"=="1" (
    echo Starting Flutter Web App...
    start "Drishti Flutter Web" cmd /k "flutter run -d chrome"
) else if "%choice%"=="2" (
    echo Starting Flutter Windows App...
    start "Drishti Flutter Windows" cmd /k "flutter run -d windows"
) else if "%choice%"=="3" (
    echo Starting Flutter Android App...
    start "Drishti Flutter Android" cmd /k "flutter run"
) else (
    echo Invalid choice. Starting Web by default...
    start "Drishti Flutter Web" cmd /k "flutter run -d chrome"
)

echo.
echo ================================================================================
echo APPLICATION STARTED!
echo ================================================================================
echo.
echo Backend Server: http://localhost:5000
echo Flutter App: Running in separate window
echo.
echo Press any key to exit this window (apps will continue running)
pause >nul
