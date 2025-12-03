import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/booking_provider.dart';
import '../models/booking.dart';
import 'booking_page.dart';
import 'edit_booking_screen.dart';

class BookingHistoryScreen extends StatefulWidget {
  @override
  _BookingHistoryScreenState createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  String _filterStatus = 'all';

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
          IconButton(
            icon: Icon(Icons.filter_list, color: Color(0xFF00d9ff)),
            onPressed: _showFilterDialog,
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
}
