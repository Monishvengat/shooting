# Flutter Installation Guide for Windows

## Method 1: Download and Install Manually (Recommended)

### Step 1: Download Flutter SDK

1. Visit the official Flutter website: https://docs.flutter.dev/get-started/install/windows
2. Click on "Download Flutter SDK" button
3. Or download directly from: https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.5-stable.zip

### Step 2: Extract Flutter

1. Create a folder for Flutter (avoid spaces in path):
   - Recommended: `C:\src\flutter`
   - **DO NOT** install in `C:\Program Files\` (requires elevated privileges)

2. Extract the downloaded ZIP file to your chosen location:
   - Extract to `C:\src\` so you have `C:\src\flutter`

### Step 3: Add Flutter to PATH

**Option A: Using System Settings (GUI)**

1. Open "Edit environment variables for your account"
   - Press `Win + R`
   - Type `sysdm.cpl`
   - Press Enter
   - Go to "Advanced" tab → "Environment Variables"

2. Under "User variables", find `Path` and click "Edit"

3. Click "New" and add the Flutter bin directory:
   ```
   C:\src\flutter\bin
   ```

4. Click "OK" on all windows

**Option B: Using PowerShell (Command Line)**

Open PowerShell and run:
```powershell
[System.Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\src\flutter\bin", [System.EnvironmentVariableTarget]::User)
```

### Step 4: Verify Installation

1. Close and reopen your terminal/command prompt
2. Run:
   ```bash
   flutter --version
   ```

3. Run Flutter Doctor:
   ```bash
   flutter doctor
   ```

## Method 2: Using Chocolatey (Alternative)

If you have Chocolatey installed:

```bash
choco install flutter
```

## Step 5: Install Additional Dependencies

Flutter Doctor will show you what's missing. Here's what you typically need:

### Android Studio (for Android development)

1. Download from: https://developer.android.com/studio
2. Install Android Studio
3. During installation, make sure to install:
   - Android SDK
   - Android SDK Platform
   - Android Virtual Device (AVD)

4. Open Android Studio:
   - Go to Settings → Plugins
   - Install "Flutter" and "Dart" plugins

5. Accept Android licenses:
   ```bash
   flutter doctor --android-licenses
   ```

### Git (Required)

Download and install Git: https://git-scm.com/download/win

### Visual Studio Code (Optional but Recommended)

1. Download from: https://code.visualstudio.com/
2. Install Flutter and Dart extensions

## Step 6: Configure Flutter

Run Flutter Doctor and follow any remaining instructions:

```bash
flutter doctor -v
```

This will show detailed information about any missing dependencies.

## Quick Setup Commands

After installing Flutter, run these commands in order:

```bash
# Check Flutter installation
flutter --version

# Run comprehensive check
flutter doctor

# Accept Android licenses (if using Android)
flutter doctor --android-licenses

# Update Flutter to latest version
flutter upgrade

# Check for any issues
flutter doctor -v
```

## Verify Installation for Your Project

Once Flutter is installed, navigate to your project and run:

```bash
cd "C:\Users\monis\OneDrive\Documents\my-flutter-app\flutter_app"

# Get dependencies
flutter pub get

# Check for any issues
flutter doctor

# List available devices
flutter devices

# Run the app (make sure a device/emulator is running)
flutter run
```

## Setting Up an Emulator

### Android Emulator

1. Open Android Studio
2. Click "More Actions" → "Virtual Device Manager"
3. Click "Create Device"
4. Select a device (e.g., Pixel 5)
5. Select a system image (e.g., latest Android version)
6. Click "Finish"
7. Start the emulator by clicking the play button

### Alternative: Use Your Physical Device

1. Enable Developer Options on your Android phone:
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times

2. Enable USB Debugging:
   - Settings → Developer Options → USB Debugging

3. Connect your phone via USB

4. Run `flutter devices` to verify

## Common Issues and Solutions

### Issue 1: Flutter not recognized
**Solution**: Restart your terminal or computer after adding to PATH

### Issue 2: Android licenses not accepted
**Solution**: Run `flutter doctor --android-licenses` and accept all

### Issue 3: No devices available
**Solution**: Start an Android emulator or connect a physical device

### Issue 4: Gradle build errors
**Solution**:
- Make sure Android SDK is installed
- Run `flutter clean` and `flutter pub get`

### Issue 5: Long path names on Windows
**Solution**: Enable long path support:
```powershell
# Run PowerShell as Administrator
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value 1 -PropertyType DWORD -Force
```

## Testing Your Installation

Create and run a test project:

```bash
# Create a new Flutter project
flutter create test_app

# Navigate to the project
cd test_app

# Run the app
flutter run
```

## Running Your Shooting Arena App

Once everything is set up:

```bash
cd "C:\Users\monis\OneDrive\Documents\my-flutter-app\flutter_app"

# Install dependencies
flutter pub get

# Start an emulator or connect a device
# Then run:
flutter run
```

## Useful Flutter Commands

```bash
# Check Flutter version
flutter --version

# Update Flutter
flutter upgrade

# Clean build cache
flutter clean

# Get dependencies
flutter pub get

# Run app
flutter run

# Run app with hot reload disabled
flutter run --no-hot

# Build APK (Android)
flutter build apk

# Build for release
flutter build apk --release

# Analyze code
flutter analyze

# Format code
flutter format .

# Show connected devices
flutter devices

# Create new project
flutter create project_name
```

## Next Steps After Installation

1. Install dependencies:
   ```bash
   cd flutter_app
   flutter pub get
   ```

2. Start an emulator or connect a device

3. Run the app:
   ```bash
   flutter run
   ```

4. Enjoy your Shooting Arena Booking App!

## Resources

- Official Flutter Documentation: https://docs.flutter.dev
- Flutter Installation Guide: https://docs.flutter.dev/get-started/install/windows
- Flutter YouTube Channel: https://www.youtube.com/flutterdev
- Flutter Community: https://flutter.dev/community

## Need Help?

If you encounter any issues:
1. Run `flutter doctor -v` and check the output
2. Search for the error message on Stack Overflow
3. Check Flutter's GitHub issues: https://github.com/flutter/flutter/issues
4. Visit Flutter's Discord community: https://discord.gg/flutter

---

**Quick Start Summary:**

1. Download Flutter from https://docs.flutter.dev/get-started/install/windows
2. Extract to `C:\src\flutter`
3. Add `C:\src\flutter\bin` to your PATH
4. Run `flutter doctor`
5. Install Android Studio
6. Run `flutter doctor --android-licenses`
7. Navigate to your project: `cd flutter_app`
8. Run `flutter pub get`
9. Run `flutter run`

Happy coding!
