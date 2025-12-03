@echo off
echo ========================================
echo Shooting Arena Booking App - Chrome
echo ========================================
echo.

cd "%~dp0flutter_app"

echo Cleaning previous builds...
rmdir /s /q build 2>nul
rmdir /s /q .dart_tool 2>nul
timeout /t 2 >nul

echo.
echo Starting app in Chrome...
echo (This may take a minute on first run)
echo.
echo Press Ctrl+C to stop the app
echo.

C:\src\flutter\bin\flutter run -d chrome

pause
