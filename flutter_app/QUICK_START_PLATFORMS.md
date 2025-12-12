# Quick Start - Running on Different Platforms

## 🚀 Fastest Way to Run

### 1. Web (Recommended for Development)
```bash
cd ui-app/flutter_app
flutter run -d chrome
```

### 2. Windows
```bash
cd ui-app/flutter_app
flutter run -d windows
```

### 3. Android (Requires Android Studio & Emulator)
```bash
# Start Android emulator first
cd ui-app/flutter_app
flutter run
# Select Android device when prompted
```

### 4. iOS (Requires macOS & Xcode)
```bash
cd ui-app/flutter_app
flutter run -d "iPhone Simulator"
```

### 5. macOS (Requires macOS & Xcode)
```bash
cd ui-app/flutter_app
flutter run -d macos
```

## 📱 Available Platforms

| Platform | Status | Requirements |
|----------|--------|--------------|
| **Android** | ✅ Ready | Android Studio, Android SDK |
| **iOS** | ✅ Ready | macOS, Xcode, iOS Simulator |
| **macOS** | ✅ Ready | macOS, Xcode |
| **Windows** | ✅ Ready | Visual Studio with C++ |
| **Web** | ✅ Ready | Chrome/Edge browser |

## 🔧 Check Available Devices

```bash
flutter devices
```

Example output:
```
Found 5 connected devices:
  Windows (desktop) • windows • windows-x64    • Microsoft Windows
  Chrome (web)      • chrome  • web-javascript • Google Chrome
  Edge (web)        • edge    • web-javascript • Microsoft Edge
  Android SDK       • android • android-arm64  • Android Emulator
  iPhone 15         • ios     • ios            • iOS Simulator
```

## 🏗️ Building for Production

### Android APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (Google Play)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS (macOS only)
```bash
flutter build ios --release
# Then open in Xcode to archive
```

### macOS
```bash
flutter build macos --release
# Output: build/macos/Build/Products/Release/
```

### Windows
```bash
flutter build windows --release
# Output: build/windows/x64/runner/Release/
```

### Web
```bash
flutter build web --release
# Output: build/web/
```

## 🐛 Troubleshooting

### "No devices found"
```bash
flutter doctor
# Follow the suggestions to install missing components
```

### Android: SDK not found
```bash
# Install Android Studio first
flutter doctor --android-licenses
```

### iOS/macOS: Xcode required
- Install Xcode from Mac App Store
- Run: `sudo xcode-select --switch /Applications/Xcode.app`

### Windows: Visual Studio required
- Install Visual Studio 2019 or later
- Include "Desktop development with C++" workload

## 💡 Development Tips

1. **Hot Reload**: Press `r` while app is running
2. **Hot Restart**: Press `R` while app is running
3. **Quit**: Press `q` to stop the app
4. **Multiple Devices**: Run on multiple devices simultaneously:
   ```bash
   flutter run -d chrome &
   flutter run -d windows &
   ```

## 📦 Install Dependencies

```bash
cd ui-app/flutter_app
flutter pub get
```

## 🔄 Clean Build (if issues occur)

```bash
flutter clean
flutter pub get
flutter run
```

## 🌐 Connect to Backend API

The app connects to: `http://localhost:3000/v1`

Make sure the Node.js backend is running:
```bash
cd node-app
npm start
```

## 📚 More Information

- See [PLATFORM_SUPPORT.md](PLATFORM_SUPPORT.md) for detailed platform documentation
- See [README.md](README.md) for general app information
- See [QUICKSTART.md](QUICKSTART.md) for development guide
