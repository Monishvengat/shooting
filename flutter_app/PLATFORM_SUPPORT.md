# Multi-Platform Support Guide

The Elite Shooting Arena Flutter app now supports **6 platforms**:

- ✅ **Android** (Phones & Tablets)
- ✅ **iOS** (iPhone & iPad)
- ✅ **macOS** (Desktop)
- ✅ **Windows** (Desktop)
- ✅ **Web** (Chrome, Edge, Safari, Firefox)
- ✅ **Linux** (Optional - can be added if needed)

## Platform-Specific Files

### Android
```
android/
├── app/
│   ├── build.gradle.kts          # Build configuration
│   └── src/
│       └── main/
│           ├── AndroidManifest.xml   # App permissions & settings
│           └── kotlin/              # Native code entry point
└── build.gradle.kts
```

**Key Configuration:**
- App ID: `com.example.my_flutter_app`
- Min SDK: 21 (Android 5.0)
- Target SDK: Latest

### iOS
```
ios/
├── Runner/
│   ├── Info.plist               # App permissions & settings
│   ├── AppDelegate.swift        # App lifecycle
│   └── Assets.xcassets/         # App icons & images
└── Runner.xcodeproj/            # Xcode project
```

**Key Configuration:**
- Bundle ID: `com.example.myFlutterApp`
- Min iOS Version: 12.0
- Requires Xcode to build

### macOS
```
macos/
├── Runner/
│   ├── Info.plist               # App permissions & settings
│   ├── AppDelegate.swift        # App lifecycle
│   ├── DebugProfile.entitlements   # Debug permissions
│   └── Release.entitlements     # Release permissions
└── Runner.xcodeproj/            # Xcode project
```

**Key Configuration:**
- Bundle ID: `com.example.myFlutterApp`
- Min macOS Version: 10.14
- Requires Xcode to build

### Windows
```
windows/
├── runner/
│   ├── main.cpp                 # App entry point
│   └── Runner.rc                # App resources
└── CMakeLists.txt               # Build configuration
```

**Key Configuration:**
- Requires Visual Studio 2019+ with C++ desktop development
- Supports Windows 10+

### Web
```
web/
├── index.html                   # Main HTML file
├── manifest.json                # PWA manifest
└── icons/                       # App icons
```

**Key Configuration:**
- Supports all modern browsers
- Can be deployed as a Progressive Web App (PWA)

## Running on Different Platforms

### Android

**Prerequisites:**
- Android Studio installed
- Android SDK configured
- Android emulator or physical device

**Run Command:**
```bash
# List Android devices
flutter devices

# Run on Android
flutter run -d <device-id>

# Or select Android from available devices
flutter run
```

**Build APK:**
```bash
flutter build apk
# Output: build/app/outputs/flutter-apk/app-release.apk
```

**Build App Bundle (for Play Store):**
```bash
flutter build appbundle
# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS

**Prerequisites:**
- macOS with Xcode installed
- iOS Simulator or physical iPhone/iPad
- Apple Developer account (for physical device)

**Run Command:**
```bash
# List iOS devices
flutter devices

# Run on iOS Simulator
flutter run -d <simulator-id>

# Run on iPhone
flutter run -d <device-id>
```

**Build IPA (for App Store):**
```bash
flutter build ios --release
# Then archive in Xcode
```

### macOS

**Prerequisites:**
- macOS with Xcode installed

**Run Command:**
```bash
# Run on macOS
flutter run -d macos
```

**Build App:**
```bash
flutter build macos
# Output: build/macos/Build/Products/Release/my_flutter_app.app
```

### Windows

**Prerequisites:**
- Visual Studio 2019+ with C++ desktop development
- Windows 10 or later

**Run Command:**
```bash
# Run on Windows
flutter run -d windows
```

**Build Executable:**
```bash
flutter build windows
# Output: build\windows\x64\runner\Release\my_flutter_app.exe
```

### Web

**Prerequisites:**
- Modern web browser (Chrome recommended for development)

**Run Command:**
```bash
# Run on Chrome
flutter run -d chrome

# Run on Edge
flutter run -d edge

# Run with custom port
flutter run -d web-server --web-port=8080
```

**Build for Production:**
```bash
flutter build web
# Output: build/web/
```

**Deploy Options:**
- Firebase Hosting
- GitHub Pages
- Netlify
- Vercel
- Any static hosting service

## Platform-Specific Considerations

### Android
- **Permissions**: Add required permissions in `android/app/src/main/AndroidManifest.xml`
- **Icons**: Replace default icons in `android/app/src/main/res/mipmap-*/`
- **Package Name**: Update in `android/app/build.gradle.kts`

### iOS
- **Permissions**: Add permission descriptions in `ios/Runner/Info.plist`
- **Icons**: Replace in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- **Bundle ID**: Update in Xcode project settings
- **Signing**: Configure in Xcode for physical devices

### macOS
- **Permissions**: Add entitlements in `macos/Runner/DebugProfile.entitlements` and `Release.entitlements`
- **Icons**: Replace in `macos/Runner/Assets.xcassets/AppIcon.appiconset/`
- **Bundle ID**: Update in Xcode project settings

### Windows
- **Icons**: Update in `windows/runner/resources/app_icon.ico`
- **App Name**: Update in `windows/runner/Runner.rc`

### Web
- **Icons**: Replace in `web/icons/`
- **Manifest**: Update `web/manifest.json` for PWA
- **Title**: Update in `web/index.html`

## Testing on Multiple Platforms

### Check Available Devices
```bash
flutter devices
```

### Run Tests
```bash
# Run unit tests
flutter test

# Run integration tests on specific platform
flutter drive --target=test_driver/app.dart -d <device-id>
```

## Building for Release

### Create Release Builds for All Platforms

```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS (requires macOS)
flutter build ios --release

# macOS
flutter build macos --release

# Windows
flutter build windows --release

# Web
flutter build web --release
```

## Common Issues & Solutions

### Android
**Issue**: SDK not found
**Solution**: Install Android Studio and run `flutter doctor --android-licenses`

**Issue**: Gradle build fails
**Solution**: Update Gradle in `android/gradle/wrapper/gradle-wrapper.properties`

### iOS
**Issue**: Provisioning profile error
**Solution**: Configure signing in Xcode

**Issue**: CocoaPods issues
**Solution**: Run `cd ios && pod install --repo-update`

### macOS
**Issue**: Entitlements error
**Solution**: Add required entitlements in `.entitlements` files

### Windows
**Issue**: Visual Studio not found
**Solution**: Install Visual Studio with C++ desktop development

### Web
**Issue**: CORS errors with API
**Solution**: Configure CORS on backend server (already configured in node-app)

## Platform-Specific Features

### Mobile (Android/iOS)
- Push notifications
- Camera access
- Location services
- Biometric authentication
- Native sharing

### Desktop (Windows/macOS)
- File system access
- Multiple windows
- System tray integration
- Keyboard shortcuts

### Web
- Progressive Web App (PWA)
- Offline support
- Push notifications (limited)
- Browser storage

## Recommended Development Setup

1. **Primary Development**: Web (fastest hot reload)
2. **Mobile Testing**: Android Emulator or iOS Simulator
3. **Desktop Testing**: Your native platform (Windows/macOS)
4. **Final Testing**: All target platforms before release

## App Store Deployment

### Google Play Store (Android)
1. Build app bundle: `flutter build appbundle`
2. Create Play Console account
3. Upload AAB file
4. Complete store listing
5. Submit for review

### Apple App Store (iOS)
1. Build in Xcode
2. Archive app
3. Upload to App Store Connect
4. Complete app information
5. Submit for review

### macOS App Store
1. Build in Xcode
2. Archive app
3. Upload to App Store Connect
4. Complete app information
5. Submit for review

### Microsoft Store (Windows)
1. Create MSIX package
2. Create Microsoft Partner account
3. Upload package
4. Complete store listing
5. Submit for review

### Web
- Deploy `build/web/` to any static hosting
- Configure domain and SSL
- Set up CDN (optional)

## Next Steps

1. **Customize App Icons**: Replace default icons for each platform
2. **Update App Name**: Change display name in platform-specific config
3. **Configure Permissions**: Add required permissions for each platform
4. **Test on Real Devices**: Test on actual phones/tablets/desktops
5. **Set up CI/CD**: Automate builds for all platforms

## Resources

- [Flutter Platform Documentation](https://docs.flutter.dev/platform-integration)
- [Android Setup](https://docs.flutter.dev/get-started/install/windows#android-setup)
- [iOS Setup](https://docs.flutter.dev/get-started/install/macos#ios-setup)
- [Desktop Setup](https://docs.flutter.dev/desktop)
- [Web Setup](https://docs.flutter.dev/get-started/web)
