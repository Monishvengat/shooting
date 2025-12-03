@echo off
echo ============================================
echo Running Shooting Arena Booking App
echo ============================================
echo.

REM Check if Flutter is in PATH
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Flutter not found in PATH
    echo Checking C:\src\flutter...

    if exist "C:\src\flutter\bin\flutter.bat" (
        echo [FOUND] Adding Flutter to PATH for this session...
        set PATH=C:\src\flutter\bin;%PATH%
    ) else (
        echo [ERROR] Flutter not installed. Please run setup_flutter.bat first
        pause
        exit /b 1
    )
)

echo [OK] Flutter found:
flutter --version
echo.

echo Navigating to project...
cd "%~dp0flutter_app"
echo.

echo Checking for devices...
flutter devices
echo.

echo Starting app...
echo (Press 'r' to hot reload, 'R' to hot restart, 'q' to quit)
echo.
flutter run

pause
