@echo off
REM Project Drishti - Backend Server Startup Script
echo ================================================================================
echo PROJECT DRISHTI - TB DETECTION BACKEND SERVER
echo ================================================================================
echo.

REM Check if virtual environment exists
if not exist "backend\venv" (
    echo Virtual environment not found. Creating one...
    python -m venv backend\venv
    echo.
    echo Virtual environment created!
    echo.
)

REM Activate virtual environment
echo Activating virtual environment...
call backend\venv\Scripts\activate.bat
echo.

REM Install requirements
echo Installing Python dependencies...
pip install -r backend\requirements.txt
echo.

REM Start server
echo Starting backend server...
echo Server will be available at: http://localhost:5000
echo.
echo Press Ctrl+C to stop the server
echo ================================================================================
echo.

cd backend
python model_server.py

pause
