import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/booking_provider.dart';
import '../models/booking.dart';
import 'booking_page.dart';
import 'edit_booking_screen.dart';
import 'login_screen.dart';
import 'member_notifications_screen.dart';

/// Main screen that displays the user's booking history for the shooting arena.
///
/// This screen shows a list of all bookings (past, present, and future) with the ability
/// to filter by status (all, upcoming, completed, cancelled). Users can create new bookings,
/// edit or cancel upcoming bookings, and view location information.
///
/// AUTHENTICATION: Requires JWT token to fetch notifications and display unread count badge.
class BookingHistoryScreen extends StatefulWidget {
  /// JWT authentication token from login
  final String? token;

  const BookingHistoryScreen({
    Key? key,
    this.token,
  }) : super(key: key);

  @override
  _BookingHistoryScreenState createState() => _BookingHistoryScreenState();
}

/// State class for [BookingHistoryScreen] that manages the booking list display and filtering.
///
/// Maintains the current filter status and handles all user interactions including
/// filtering, editing, cancelling bookings, and navigation to other screens.
class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  /// Current filter status for displaying bookings.
  /// Can be 'all', 'upcoming', 'completed', or 'cancelled'.
  String _filterStatus = 'all';

  /// Unread notification count fetched from the API
  /// Displayed as a badge on the notification bell icon
  int _unreadNotificationCount = 0;

  @override
  void initState() {
    super.initState();
    // Fetch unread notification count when screen loads
    if (widget.token != null) {
      _fetchUnreadNotificationCount();
    }
  }

  /// Fetches the unread notification count from the backend API
  ///
  /// Makes an authenticated GET request to /v1/members/notifications
  /// Updates the [_unreadNotificationCount] state variable with the result
  Future<void> _fetchUnreadNotificationCount() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/v1/members/notifications'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _unreadNotificationCount = data['unreadCount'] ?? 0;
        });
      }
    } catch (e) {
      // Silently fail - notification count is not critical
      print('Error fetching notification count: $e');
    }
  }

  /// Builds the main UI for the booking history screen.
  ///
  /// Creates a scaffold with an app bar containing filter and location buttons,
  /// a filterable list of booking cards, and a floating action button to create new bookings.
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BookingProvider>(context);
    final bookings = _getFilteredBookings(provider.bookings);

    return Scaffold(
      backgroundColor: Color(0xFF0a0e1a),
      appBar: AppBar(
        backgroundColor: Color(0xFF1a1f35),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'My Bookings',
          style: TextStyle(
            color: Color(0xFF00ff88),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          // Notification bell icon with unread badge
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications, color: Color(0xFFff6b00)),
                onPressed: () {
                  if (widget.token != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MemberNotificationsScreen(
                          token: widget.token!,
                        ),
                      ),
                    ).then((_) {
                      // Refresh notification count when returning from notification screen
                      _fetchUnreadNotificationCount();
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Authentication required'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                tooltip: 'Notifications',
              ),
              // Unread badge
              if (_unreadNotificationCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Color(0xFFff0844),
                      shape: BoxShape.circle,
                      border: Border.all(color: Color(0xFF1a1f35), width: 2),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Center(
                      child: Text(
                        _unreadNotificationCount > 99
                            ? '99+'
                            : '$_unreadNotificationCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.location_on, color: Color(0xFF00ff88)),
            onPressed: _showLocationDialog,
            tooltip: 'Location',
          ),
          IconButton(
            icon: Icon(Icons.filter_list, color: Color(0xFF00d9ff)),
            onPressed: _showFilterDialog,
            tooltip: 'Filter',
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.redAccent),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          _buildFilterChips(),

          // Bookings list
          Expanded(
            child: bookings.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      return _buildBookingCard(bookings[index], provider);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BookingPage()),
          );
        },
        backgroundColor: Color(0xFF00ff88),
        icon: Icon(Icons.add, color: Color(0xFF0a0e1a)),
        label: Text(
          'New Booking',
          style: TextStyle(
            color: Color(0xFF0a0e1a),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Filters the bookings list based on the current filter status.
  ///
  /// [bookings] The complete list of bookings to filter.
  /// Returns a filtered list containing only bookings matching the current [_filterStatus].
  /// If [_filterStatus] is 'all', returns the complete unfiltered list.
  List<Booking> _getFilteredBookings(List<Booking> bookings) {
    if (_filterStatus == 'all') return bookings;

    return bookings.where((booking) {
      switch (_filterStatus) {
        case 'upcoming':
          return booking.status == BookingStatus.upcoming;
        case 'completed':
          return booking.status == BookingStatus.completed;
        case 'cancelled':
          return booking.status == BookingStatus.cancelled;
        default:
          return true;
      }
    }).toList();
  }

  /// Builds a horizontal scrollable row of filter chips.
  ///
  /// Creates four filter chips: All, Upcoming, Completed, and Cancelled.
  /// The chips allow users to filter the booking list by status.
  Widget _buildFilterChips() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('All', 'all'),
            SizedBox(width: 8),
            _buildFilterChip('Upcoming', 'upcoming'),
            SizedBox(width: 8),
            _buildFilterChip('Completed', 'completed'),
            SizedBox(width: 8),
            _buildFilterChip('Cancelled', 'cancelled'),
          ],
        ),
      ),
    );
  }

  /// Builds an individual filter chip button.
  ///
  /// [label] The text to display on the chip.
  /// [status] The status value this chip represents ('all', 'upcoming', 'completed', 'cancelled').
  ///
  /// The chip is highlighted with different styling when it matches the current [_filterStatus].
  /// Tapping the chip updates the filter and refreshes the booking list.
  Widget _buildFilterChip(String label, String status) {
    final isSelected = _filterStatus == status;
    return InkWell(
      onTap: () {
        setState(() {
          _filterStatus = status;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF00ff88) : Color(0xFF1a1f35),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Color(0xFF00ff88) : Color(0xFF00ff88).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Color(0xFF0a0e1a) : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  /// Builds a card widget displaying details of a single booking.
  ///
  /// [booking] The booking object containing all booking details to display.
  /// [provider] The BookingProvider instance for handling booking actions (edit, cancel).
  ///
  /// The card displays the booking status, date, time, duration, lane, weapon, and optional coach.
  /// For upcoming bookings, includes a menu with options to edit or cancel the booking.
  /// Status-specific colors and icons are applied based on the booking's current status.
  Widget _buildBookingCard(Booking booking, BookingProvider provider) {
    Color statusColor;
    IconData statusIcon;

    switch (booking.status) {
      case BookingStatus.upcoming:
        statusColor = Color(0xFF00d9ff);
        statusIcon = Icons.upcoming;
        break;
      case BookingStatus.completed:
        statusColor = Color(0xFF00ff88);
        statusIcon = Icons.check_circle;
        break;
      case BookingStatus.cancelled:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF1a1f35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 20),
                  SizedBox(width: 8),
                  Text(
                    booking.status.toString().split('.').last.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              if (booking.status == BookingStatus.upcoming)
                PopupMenuButton(
                  icon: Icon(Icons.more_vert, color: Colors.white54),
                  color: Color(0xFF1a1f35),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Color(0xFF00d9ff), size: 20),
                          SizedBox(width: 8),
                          Text('Edit', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                      value: 'edit',
                    ),
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(Icons.cancel, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text('Cancel', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                      value: 'cancel',
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditBookingScreen(booking: booking),
                        ),
                      );
                    } else if (value == 'cancel') {
                      _showCancelDialog(booking.id, provider);
                    }
                  },
                ),
            ],
          ),
          SizedBox(height: 16),

          // Date and Time
          Row(
            children: [
              Icon(Icons.calendar_today, color: Color(0xFF00ff88), size: 18),
              SizedBox(width: 8),
              Text(
                DateFormat('EEE, MMM d, yyyy').format(booking.date),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time, color: Color(0xFF00d9ff), size: 18),
              SizedBox(width: 8),
              Text(
                '${booking.startTime} - ${booking.endTime}',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              SizedBox(width: 12),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Color(0xFF00d9ff).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${booking.duration.toStringAsFixed(1)}h',
                  style: TextStyle(
                    color: Color(0xFF00d9ff),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),

          Divider(color: Colors.white12),
          SizedBox(height: 12),

          // Details
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  Icons.track_changes,
                  'Lane',
                  'Lane ${booking.lane}',
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  Icons.gps_fixed,
                  'Weapon',
                  booking.weapon,
                ),
              ),
            ],
          ),
          if (booking.coach != null) ...[
            SizedBox(height: 12),
            _buildDetailItem(
              Icons.person,
              'Coach',
              booking.coach!,
            ),
          ],
        ],
      ),
    );
  }

  /// Builds a detail item widget showing an icon, label, and value.
  ///
  /// [icon] The icon to display for this detail item.
  /// [label] The label text (e.g., "Lane", "Weapon", "Coach").
  /// [value] The value text to display below the label.
  ///
  /// Used to display booking details like lane number, weapon type, and coach name
  /// in a consistent format within the booking card.
  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Color(0xFF00ff88), size: 16),
        SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 11,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds the empty state widget displayed when no bookings match the current filter.
  ///
  /// Shows an icon, title, and subtitle prompting the user to create their first booking.
  /// This is displayed in place of the booking list when the filtered results are empty.
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 80,
            color: Colors.white24,
          ),
          SizedBox(height: 16),
          Text(
            'No bookings found',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Start by creating your first booking',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Shows a dialog with filter options for booking status.
  ///
  /// Displays a modal dialog with radio button options to filter bookings by:
  /// All, Upcoming, Completed, or Cancelled status.
  /// Selecting an option updates [_filterStatus] and closes the dialog.
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1a1f35),
        title: Text(
          'Filter Bookings',
          style: TextStyle(color: Color(0xFF00ff88)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogOption('All Bookings', 'all'),
            _buildDialogOption('Upcoming', 'upcoming'),
            _buildDialogOption('Completed', 'completed'),
            _buildDialogOption('Cancelled', 'cancelled'),
          ],
        ),
      ),
    );
  }

  /// Builds a radio button option for the filter dialog.
  ///
  /// [label] The display text for this filter option.
  /// [status] The status value this option represents.
  ///
  /// Creates a list tile with a radio button that updates the filter when selected.
  /// The selected option is highlighted in the app's accent color.
  Widget _buildDialogOption(String label, String status) {
    final isSelected = _filterStatus == status;
    return ListTile(
      title: Text(
        label,
        style: TextStyle(color: isSelected ? Color(0xFF00ff88) : Colors.white),
      ),
      leading: Radio<String>(
        value: status,
        groupValue: _filterStatus,
        onChanged: (value) {
          setState(() {
            _filterStatus = value!;
          });
          Navigator.pop(context);
        },
        activeColor: Color(0xFF00ff88),
      ),
    );
  }

  /// Shows a confirmation dialog before cancelling a booking.
  ///
  /// [bookingId] The unique identifier of the booking to cancel.
  /// [provider] The BookingProvider instance used to perform the cancellation.
  ///
  /// Displays a confirmation dialog asking the user to confirm booking cancellation.
  /// If confirmed, cancels the booking and shows a success snackbar message.
  void _showCancelDialog(String bookingId, BookingProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1a1f35),
        title: Text(
          'Cancel Booking',
          style: TextStyle(color: Color(0xFF00ff88)),
        ),
        content: Text(
          'Are you sure you want to cancel this booking?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'No',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              provider.cancelBooking(bookingId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Booking cancelled successfully'),
                  backgroundColor: Color(0xFF00ff88),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  /// Shows a dialog displaying the shooting arena's location and contact information.
  ///
  /// Displays the arena name, full address, phone number, and operating hours.
  /// Includes a "Get Directions" button that shows a snackbar notification
  /// (placeholder for future map integration).
  void _showLocationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1a1f35),
        title: Row(
          children: [
            Icon(Icons.location_on, color: Color(0xFF00ff88)),
            SizedBox(width: 8),
            Text(
              'Arena Location',
              style: TextStyle(color: Color(0xFF00ff88)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Elite Shooting Arena',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.place, color: Color(0xFF00d9ff), size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '123 Range Road, Sport City,\nMetro Area 560001',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.phone, color: Color(0xFF00d9ff), size: 20),
                SizedBox(width: 8),
                Text(
                  '+1 234-567-8900',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, color: Color(0xFF00d9ff), size: 20),
                SizedBox(width: 8),
                Text(
                  '8:00 AM - 8:00 PM',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(color: Color(0xFF00ff88)),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Opening maps...'),
                  backgroundColor: Color(0xFF00d9ff),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF00ff88),
            ),
            icon: Icon(Icons.map, color: Color(0xFF0a0e1a)),
            label: Text(
              'Get Directions',
              style: TextStyle(color: Color(0xFF0a0e1a)),
            ),
          ),
        ],
      ),
    );
  }

  /// Handles the user logout action with confirmation.
  ///
  /// Displays a confirmation dialog asking the user to confirm logout.
  /// If confirmed, navigates to the login screen (clearing navigation stack)
  /// and shows a logout success snackbar message.
  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1a1f35),
        title: Row(
          children: [
            Icon(Icons.logout, color: Colors.redAccent),
            SizedBox(width: 8),
            Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (route) => false,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Logged out successfully'),
                  backgroundColor: Color(0xFF00ff88),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }
}
