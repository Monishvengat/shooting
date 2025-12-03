@echo off
echo ============================================
echo Flutter Setup Script for Shooting Arena App
echo ============================================
echo.

REM Check if Flutter is in PATH
flutter --version >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Flutter is already installed!
    flutter --version
    echo.
    goto :setup_project
) else (
    echo [!] Flutter is not in PATH
    echo.
)

REM Check if Flutter exists at C:\src\flutter
if exist "C:\src\flutter\bin\flutter.bat" (
    echo [FOUND] Flutter installation detected at C:\src\flutter
    echo Adding Flutter to PATH for this session...
    set PATH=C:\src\flutter\bin;%PATH%
    echo.
    goto :setup_project
) else (
    echo [ERROR] Flutter not found at C:\src\flutter
    echo.
    echo Please install Flutter manually:
    echo 1. Download from: https://docs.flutter.dev/get-started/install/windows
    echo 2. Extract to C:\src\flutter
    echo 3. Add C:\src\flutter\bin to your PATH
    echo.
    echo Or see FLUTTER_INSTALLATION_GUIDE.md for detailed instructions
    pause
    exit /b 1
)

:setup_project
echo ============================================
echo Setting up Shooting Arena Booking App
echo ============================================
echo.

echo [1/5] Checking Flutter Doctor...
flutter doctor
echo.

echo [2/5] Navigating to project directory...
cd "%~dp0flutter_app"
if %errorlevel% neq 0 (
    echo [ERROR] Could not find flutter_app directory
    pause
    exit /b 1
)
echo [OK] In project directory
echo.

echo [3/5] Getting Flutter dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo [ERROR] Failed to get dependencies
    pause
    exit /b 1
)
echo [OK] Dependencies installed
echo.

echo [4/5] Checking for connected devices...
flutter devices
echo.

echo [5/5] Setup complete!
echo.
echo ============================================
echo Next Steps:
echo ============================================
echo 1. Make sure you have an emulator running or device connected
echo 2. Run: flutter run
echo.
echo Or simply run: run_app.bat
echo.
echo For first-time setup:
echo - Run: flutter doctor --android-licenses (to accept Android licenses)
echo - Install Android Studio if not already installed
echo.
pause
