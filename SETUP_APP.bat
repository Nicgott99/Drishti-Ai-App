@echo off
echo.
echo ========================================
echo   DRISHTI AI - COMPLETE APP SETUP
echo ========================================
echo.
echo This will:
echo 1. Install Flutter packages
echo 2. Generate localization files
echo 3. Show you how to run the app
echo.
pause

echo.
echo [1/2] Installing Flutter packages...
echo.
call flutter pub get
if %errorlevel% neq 0 (
    echo.
    echo ERROR: Flutter not found in PATH!
    echo.
    echo Please add Flutter to your PATH or use full path:
    echo   C:\flutter\bin\flutter pub get
    echo.
    pause
    exit /b 1
)

echo.
echo [2/2] Generating localization files...
echo.
call flutter gen-l10n

echo.
echo ========================================
echo   SETUP COMPLETE!
echo ========================================
echo.
echo Next steps:
echo.
echo FOR BROWSER (Quick Test):
echo   flutter run -d chrome --web-port=8080
echo.
echo FOR ANDROID (Competition):
echo   flutter build apk --release
echo   (APK will be at: build\app\outputs\flutter-apk\app-release.apk)
echo.
echo IMPORTANT: Make sure backend is running first!
echo   cd backend
echo   python model_server.py
echo.
pause
