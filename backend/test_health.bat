@echo off
REM Test backend without stopping it
echo.
echo ======================================================================
echo TESTING BACKEND SERVER
echo ======================================================================
echo.
echo Testing health endpoint...
curl -s http://localhost:5000/health
echo.
echo.
echo ======================================================================
echo Backend test complete!
echo ======================================================================
pause
