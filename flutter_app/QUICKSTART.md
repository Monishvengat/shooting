# Quick Start Guide

## Get the App Running in 3 Steps

### Step 1: Install Dependencies
Open your terminal in the `flutter_app` directory and run:
```bash
flutter pub get
```

### Step 2: Run the App
Make sure you have an emulator running or a device connected, then:
```bash
flutter run
```

### Step 3: Test the App
1. **Login Screen**: Enter any email/password and click LOGIN (mock authentication)
2. **Booking History**: You'll see 3 pre-populated bookings
3. **Create New Booking**: Click the floating "New Booking" button
4. **Make a Booking**:
   - Select a date
   - Choose start time (e.g., 10:00 AM)
   - Choose end time (e.g., 11:30 AM) - max 3 hours
   - Pick an available lane
   - Select a weapon
   - Optionally select a coach
   - Click CONFIRM BOOKING
5. **Success!**: You'll see the confirmation modal

## Project Files Overview

### Core Files You Should Know
- **[main.dart](lib/main.dart)** - App entry point with Provider setup
- **[login_screen.dart](lib/screens/login_screen.dart)** - Login/Sign-up UI
- **[booking_page.dart](lib/screens/booking_page.dart)** - Main booking form
- **[booking_history_screen.dart](lib/screens/booking_history_screen.dart)** - View/manage bookings
- **[edit_booking_screen.dart](lib/screens/edit_booking_screen.dart)** - Edit existing bookings
- **[booking_provider.dart](lib/providers/booking_provider.dart)** - State management & mock data

### Models
- **[booking.dart](lib/models/booking.dart)** - Booking model with status enum
- **[weapon.dart](lib/models/weapon.dart)** - Weapon model
- **[coach.dart](lib/models/coach.dart)** - Coach model

### Widgets
- **[confirmation_modal.dart](lib/widgets/confirmation_modal.dart)** - Success popup

## Key Features to Try

### 1. Time Duration Validation
- Try selecting a start time and end time more than 3 hours apart
- You'll see a red warning message
- The confirm button will be disabled

### 2. Lane Availability
- Create a booking for a specific lane and time
- Try creating another booking for the same lane and time
- The lane will show as "Booked" and be unselectable

### 3. Edit Booking
- Go to Booking History
- Click the three dots on an "UPCOMING" booking
- Select "Edit"
- Change any details and click UPDATE BOOKING

### 4. Filter Bookings
- In Booking History, use the filter chips at the top
- Filter by: All, Upcoming, Completed, Cancelled

### 5. Cancel Booking
- Click the three dots on an upcoming booking
- Select "Cancel"
- Confirm the cancellation

## Customization Tips

### Change Colors
Edit these constants in any screen file:
```dart
Color(0xFF0a0e1a)  // Dark background
Color(0xFF1a1f35)  // Card background
Color(0xFF00ff88)  // Neon green
Color(0xFF00d9ff)  // Neon blue
```

### Add More Weapons
Edit [booking_provider.dart](lib/providers/booking_provider.dart):
```dart
_weapons = [
  Weapon(id: '6', name: 'Your Weapon', type: 'Type'),
  // ... existing weapons
];
```

### Add More Lanes
Edit [booking_provider.dart](lib/providers/booking_provider.dart):
```dart
final List<int> _lanes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]; // Add more
```

### Change Time Slots
Edit the `_timeSlots` list in [booking_provider.dart](lib/providers/booking_provider.dart) to add/remove times.

## Troubleshooting

### Error: "Provider not found"
- Make sure `ChangeNotifierProvider` is wrapping `MaterialApp` in [main.dart](lib/main.dart)

### Error: "Duplicate GlobalKey"
- Hot reload the app (press 'r' in terminal)
- If that doesn't work, restart the app (press 'R' in terminal)

### UI not updating after changes
- Use hot reload: `r` (for UI changes)
- Use hot restart: `R` (for logic changes)

### Date picker not showing
- Make sure you're running on a physical device or properly configured emulator

## Next Steps

1. **Connect to Backend**: Replace mock data with real API calls
2. **Add Authentication**: Implement Firebase Auth or your own auth system
3. **Add Persistence**: Use SQLite or Hive to store bookings locally
4. **Enhance UI**: Add animations, custom fonts, illustrations
5. **Add Features**: Payment, notifications, QR codes, etc.

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Provider Package](https://pub.dev/packages/provider)
- [Intl Package](https://pub.dev/packages/intl)
- [Material Design](https://material.io/design)

Happy coding!
