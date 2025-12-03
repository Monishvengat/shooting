# 🎯 Shooting Arena Slot & Lane Booking App

A modern, mobile-first Flutter application for booking shooting range slots and lanes. Features a sleek dark theme with neon green and blue accents, real-time availability checking, and comprehensive booking management.

![Flutter](https://img.shields.io/badge/Flutter-3.38.3-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.10.1-0175C2?logo=dart)
![License](https://img.shields.io/badge/license-MIT-green)

## 📱 Screenshots & Features

### 🔐 Login Screen
- Dark gradient background with neon accents
- Email/Password authentication
- Google Sign-In option
- Shooting-themed design

### 📅 Booking System
- Date picker for session selection
- **Start/End time selection** (30-minute intervals)
- **3-hour maximum duration** with validation
- **8 shooting lanes** with real-time availability
- **5 weapon types**: Pistol, Rifle, Air Gun, Shotgun, Revolver
- **4 coaches** for optional training sessions

### 📋 Booking Management
- View all bookings (past, upcoming, cancelled)
- **Filter by status**: All, Upcoming, Completed, Cancelled
- **Edit upcoming bookings**
- **Cancel bookings** with confirmation
- Animated success confirmation modal

## 🚀 Quick Start

### Prerequisites

- Flutter SDK 3.38.3 or higher
- Dart 3.10.1 or higher
- Chrome browser (for web) or Android/iOS emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Monishvengat/shooting.git
   cd shooting
   ```

2. **Navigate to the Flutter app**
   ```bash
   cd flutter_app
   ```

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Run the app**

   **Web (Chrome):**
   ```bash
   flutter run -d chrome
   ```

   **Windows:**
   ```bash
   flutter run -d windows
   ```

   **Android/iOS:**
   ```bash
   flutter run
   ```

### Quick Run Scripts

For convenience, use the provided batch scripts:

- **`run_chrome.bat`** - Launch in Chrome browser
- **`run_app.bat`** - Launch on any available device
- **`setup_flutter.bat`** - Complete setup and dependency installation

## 📂 Project Structure

```
shooting/
├── flutter_app/                    # Main Flutter application
│   ├── lib/
│   │   ├── main.dart              # App entry point
│   │   ├── models/                # Data models
│   │   │   ├── booking.dart
│   │   │   ├── weapon.dart
│   │   │   └── coach.dart
│   │   ├── providers/             # State management
│   │   │   └── booking_provider.dart
│   │   ├── screens/               # UI screens
│   │   │   ├── login_screen.dart
│   │   │   ├── booking_page.dart
│   │   │   ├── booking_history_screen.dart
│   │   │   └── edit_booking_screen.dart
│   │   └── widgets/               # Reusable widgets
│   │       └── confirmation_modal.dart
│   ├── pubspec.yaml               # Dependencies
│   ├── README.md                  # App documentation
│   └── QUICKSTART.md              # Quick start guide
├── FLUTTER_INSTALLATION_GUIDE.md  # Flutter setup guide
├── SETUP_SUMMARY.md               # Complete setup summary
└── README.md                      # This file
```

## 🎨 Design Specifications

### Color Palette

| Color | Hex Code | Usage |
|-------|----------|-------|
| Dark Background | `#0a0e1a` | Main background |
| Card Background | `#1a1f35` | Cards, containers |
| Neon Green | `#00ff88` | Primary accent, CTAs |
| Neon Blue | `#00d9ff` | Secondary accent |
| White | `#FFFFFF` | Primary text |
| White 70% | `#FFFFFFB3` | Secondary text |
| White 54% | `#FFFFFF8A` | Disabled text |

### UI Elements

- **Theme**: Dark with sporty aesthetics
- **Rounded corners** on all components
- **Soft shadows** with neon glow effects
- **Gradient buttons** for CTAs
- **Simple icons** representing weapons and lanes
- **Bold typography** with letter spacing

## ✨ Features

### Time Slot Management
- ⏰ 30-minute time intervals (8:00 AM - 8:00 PM)
- ⏱️ Start and End time selection
- ✅ 3-hour maximum session duration
- 🔴 Visual validation with color-coded feedback
- 📊 Duration calculator

### Lane Availability System
- 🎯 8 shooting lanes
- ✅ Real-time availability checking
- 🚫 Prevents double bookings
- 🔄 Excludes current booking when editing
- 👁️ Visual indicators (available/booked)

### Booking Status Tracking
- 🟢 **Upcoming**: Editable and cancellable
- ✅ **Completed**: Past sessions
- 🔴 **Cancelled**: Cancelled bookings
- 🔍 Filter by any status

### Mock Data (for testing)
- 5 weapon types
- 4 coaches with specialties
- 8 shooting lanes
- 3 sample bookings pre-loaded

## 🛠️ Tech Stack

- **Framework**: Flutter 3.38.3
- **Language**: Dart 3.10.1
- **State Management**: Provider ^5.0.0
- **Date Formatting**: intl ^0.17.0
- **Fonts**: google_fonts ^2.1.0
- **HTTP**: http ^0.13.3 (for future backend integration)

## 📖 Usage Guide

### Login
1. Enter any email and password (mock authentication)
2. Or click "Continue with Google"
3. Navigate to Booking History

### Create a Booking
1. Click the floating green "New Booking" button
2. Select a date
3. Choose start time (e.g., 10:00 AM)
4. Choose end time (e.g., 11:30 AM) - max 3 hours
5. Pick an available lane
6. Select a weapon
7. Optionally select a coach
8. Click "CONFIRM BOOKING"
9. See the success popup!

### Edit a Booking
1. Go to Booking History
2. Find an "UPCOMING" booking
3. Click the three-dot menu
4. Select "Edit"
5. Modify any details
6. Click "UPDATE BOOKING"

### Filter Bookings
- Use filter chips: **All**, **Upcoming**, **Completed**, **Cancelled**
- View bookings by status

### Cancel a Booking
1. Click the three-dot menu on an upcoming booking
2. Select "Cancel"
3. Confirm the cancellation

## 🔧 Development

### Hot Reload
While the app is running:
- Press **`r`** - Hot reload (instant UI updates)
- Press **`R`** - Hot restart (full restart)
- Press **`q`** - Quit the app
- Press **`h`** - Show all commands

### Build for Production

**Android APK:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

**Web:**
```bash
flutter build web
```

## 📝 Documentation

- **[QUICKSTART.md](flutter_app/QUICKSTART.md)** - Quick start guide with tips
- **[App README](flutter_app/README.md)** - Detailed app documentation
- **[Flutter Installation Guide](FLUTTER_INSTALLATION_GUIDE.md)** - Complete Flutter setup
- **[Setup Summary](SETUP_SUMMARY.md)** - Project setup overview

## 🚀 Future Enhancements

- [ ] Backend API integration (Node.js + MongoDB)
- [ ] Real Google Sign-In authentication
- [ ] Push notifications for upcoming sessions
- [ ] Payment gateway integration
- [ ] User profile management
- [ ] Booking receipts and invoices
- [ ] Admin panel for range management
- [ ] QR code check-in system
- [ ] Multi-language support
- [ ] Dark/Light theme toggle

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Author

**Monish Vengat**
- GitHub: [@Monishvengat](https://github.com/Monishvengat)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Material Design for UI inspiration
- Claude Code for development assistance

---

**Built with ❤️ using Flutter**

🤖 Generated with [Claude Code](https://claude.com/claude-code)
