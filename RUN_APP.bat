@echo off
echo ================================================================================
echo PROJECT DRISHTI - COMPLETE APP LAUNCHER
echo ================================================================================
echo.

REM Add Flutter to PATH
set PATH=%PATH%;C:\flutter\bin

echo [1/3] Starting Backend Server...
echo.
start "Drishti Backend" cmd /k "cd backend && python simple_server.py"

echo Waiting 15 seconds for backend to initialize...
timeout /t 15 /nobreak >nul
echo.

echo [2/3] Starting Flutter App on Chrome...
echo.
cd "h:\Project Drishti A Multi-Modal AI Platform to Close the TB Diagnostic Gap in Bangladesh\Drishti-AI-mobile_app"
start "Drishti Flutter App" cmd /k "flutter run -d chrome --web-port=8080"

echo.
echo [3/3] App is launching...
echo.
echo ================================================================================
echo DRISHTI AI TB DETECTION APP
echo ================================================================================
echo.
echo Backend API: http://localhost:5000
echo Flutter Web App: http://localhost:8080
echo.
echo Press any key to exit (apps will continue running in separate windows)
pause >nul
