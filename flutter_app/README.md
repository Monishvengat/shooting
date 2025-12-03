# Shooting Arena Slot & Lane Booking App

A modern, clean mobile application for booking shooting range slots and lanes with a dark theme featuring neon green and blue highlights.

## Features

### 1. Login / Sign-Up Screen
- Minimal, professional UI
- Email and Password authentication
- "Continue with Google" option
- Shooting-themed dark gradient background
- Neon green and blue accents

### 2. Slot & Lane Booking Page
- Date picker for selecting shooting session date
- Start and End time selection with 30-minute intervals
- Maximum 3-hour session duration with validation
- Visual duration calculator
- Lane selection with availability checking (8 lanes)
- Weapon selection (Pistol, Rifle, Air Gun, Shotgun, Revolver)
- Optional coach selection
- Real-time availability checking to prevent double bookings

### 3. Slot Confirmation Modal
- Animated success popup with neon glow effect
- Complete booking summary display
- Options to book another session or view booking history

### 4. Booking History Page
- List view of all bookings (past, upcoming, and cancelled)
- Filter bookings by status (All, Upcoming, Completed, Cancelled)
- Each booking card displays:
  - Status badge with color coding
  - Date and time with duration
  - Lane and weapon information
  - Coach details (if applicable)
- Edit and cancel options for upcoming bookings
- Floating action button to create new bookings

### 5. Edit Booking Page
- Shows original booking details
- Allows modification of:
  - Date
  - Start and end time
  - Lane
  - Weapon
  - Coach
- Real-time availability checking (excludes current booking)
- Prevents selecting already booked slots
- Duration validation

## Design Style

- **Theme**: Dark theme with sporty aesthetics
- **Colors**:
  - Primary Background: `#0a0e1a`
  - Secondary Background: `#1a1f35`
  - Neon Green: `#00ff88`
  - Neon Blue: `#00d9ff`
- **UI Elements**: Rounded corners, soft shadows, gradient buttons
- **Icons**: Simple, modern icons representing weapons and lanes
- **Typography**: Bold headers with letter spacing for impact

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── models/
│   ├── booking.dart                   # Booking data model
│   ├── weapon.dart                    # Weapon data model
│   └── coach.dart                     # Coach data model
├── providers/
│   └── booking_provider.dart          # State management with mock data
├── screens/
│   ├── login_screen.dart              # Login/Sign-up screen
│   ├── booking_page.dart              # Main booking screen
│   ├── booking_history_screen.dart    # Booking history with filters
│   └── edit_booking_screen.dart       # Edit existing bookings
└── widgets/
    └── confirmation_modal.dart        # Success confirmation popup
```

## Installation & Setup

1. **Prerequisites**
   - Flutter SDK (2.12.0 or higher)
   - Dart SDK
   - Android Studio / Xcode (for emulators)
   - VS Code with Flutter extension (optional)

2. **Install Dependencies**
   ```bash
   cd flutter_app
   flutter pub get
   ```

3. **Run the App**
   ```bash
   flutter run
   ```

4. **Build for Production**
   - Android:
     ```bash
     flutter build apk --release
     ```
   - iOS:
     ```bash
     flutter build ios --release
     ```

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^5.0.0      # State management
  intl: ^0.17.0         # Date formatting
  google_fonts: ^2.1.0  # Custom fonts
  http: ^0.13.3         # HTTP requests
```

## Key Features Implementation

### Time Slot System
- 30-minute intervals from 8:00 AM to 8:00 PM
- Start and End time selection
- Automatic validation for 3-hour maximum duration
- Visual feedback with color-coded duration display

### Lane Availability
- Real-time checking to prevent double bookings
- Visual indicators for available/booked lanes
- Excludes current booking when editing

### Mock Data
The app includes pre-populated mock data:
- 5 weapon types (Pistol, Rifle, Air Gun, Shotgun, Revolver)
- 4 coaches with different specialties
- 8 shooting lanes
- 3 sample bookings (upcoming, completed, cancelled)

### Booking Status
- **Upcoming**: Green/Blue - Editable and cancellable
- **Completed**: Green - Past sessions
- **Cancelled**: Red - Cancelled bookings

## Usage Notes

### Login
- Use any email/password to login (mock authentication)
- Or click "Continue with Google" (currently navigates directly)

### Creating a Booking
1. Select a date from the date picker
2. Choose start and end times (max 3 hours)
3. Pick an available lane
4. Select a weapon type
5. Optionally choose a coach
6. Click "CONFIRM BOOKING"

### Managing Bookings
- View all bookings in the history page
- Filter by status using the filter chips
- Edit upcoming bookings via the menu
- Cancel bookings with confirmation dialog

## Color Palette Reference

| Color Name | Hex Code | Usage |
|------------|----------|-------|
| Dark Background | #0a0e1a | Main background |
| Card Background | #1a1f35 | Cards, containers |
| Neon Green | #00ff88 | Primary accent, CTAs |
| Neon Blue | #00d9ff | Secondary accent |
| White | #FFFFFF | Text (primary) |
| White 70% | #FFFFFF B3 | Text (secondary) |
| White 54% | #FFFFFF 8A | Text (disabled) |

## Future Enhancements

- Backend API integration
- Real Google Sign-In authentication
- Push notifications for upcoming bookings
- Payment integration
- User profile management
- Booking receipts and invoices
- Admin panel for range management
- Real-time lane availability updates
- QR code check-in system