import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/booking.dart';
import '../screens/booking_history_screen.dart';

class ConfirmationModal extends StatelessWidget {
  final Booking booking;

  const ConfirmationModal({Key? key, required this.booking}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Color(0xFF1a1f35),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Color(0xFF00ff88),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF00ff88).withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            // Success Icon
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF00ff88), Color(0xFF00d9ff)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF00ff88).withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Icon(
                Icons.check,
                size: 50,
                color: Color(0xFF0a0e1a),
              ),
            ),
            SizedBox(height: 20),

            // Success Message
            Text(
              'Booking Confirmed!',
              style: TextStyle(
                color: Color(0xFF00ff88),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your shooting session has been booked successfully',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 24),

            // Booking Details
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF0a0e1a),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Color(0xFF00d9ff).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    Icons.calendar_today,
                    'Date',
                    DateFormat('EEEE, MMM d, yyyy').format(booking.date),
                  ),
                  SizedBox(height: 12),
                  _buildDetailRow(
                    Icons.access_time,
                    'Time',
                    '${booking.startTime} - ${booking.endTime}',
                  ),
                  SizedBox(height: 12),
                  _buildDetailRow(
                    Icons.schedule,
                    'Duration',
                    '${booking.duration.toStringAsFixed(1)} hours',
                  ),
                  SizedBox(height: 12),
                  _buildDetailRow(
                    Icons.track_changes,
                    'Lane',
                    'Lane ${booking.lane}',
                  ),
                  SizedBox(height: 12),
                  _buildDetailRow(
                    Icons.gps_fixed,
                    'Weapon',
                    booking.weapon,
                  ),
                  if (booking.coach != null) ...[
                    SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.person,
                      'Coach',
                      booking.coach!,
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Color(0xFF00d9ff),
                      side: BorderSide(color: Color(0xFF00d9ff), width: 2),
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Book Another',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF00ff88), Color(0xFF00d9ff)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF00ff88).withOpacity(0.5),
                          blurRadius: 15,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => BookingHistoryScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'View Details',
                        style: TextStyle(
                          color: Color(0xFF0a0e1a),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Color(0xFF00d9ff), size: 20),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
