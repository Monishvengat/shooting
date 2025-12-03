import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/booking_provider.dart';
import '../models/booking.dart';

class EditBookingScreen extends StatefulWidget {
  final Booking booking;

  const EditBookingScreen({Key? key, required this.booking}) : super(key: key);

  @override
  _EditBookingScreenState createState() => _EditBookingScreenState();
}

class _EditBookingScreenState extends State<EditBookingScreen> {
  late DateTime _selectedDate;
  late String _selectedStartTime;
  late String _selectedEndTime;
  late int _selectedLane;
  late String _selectedWeapon;
  String? _selectedCoach;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.booking.date;
    _selectedStartTime = widget.booking.startTime;
    _selectedEndTime = widget.booking.endTime;
    _selectedLane = widget.booking.lane;
    _selectedWeapon = widget.booking.weapon;
    _selectedCoach = widget.booking.coach;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BookingProvider>(context);

    return Scaffold(
      backgroundColor: Color(0xFF0a0e1a),
      appBar: AppBar(
        backgroundColor: Color(0xFF1a1f35),
        elevation: 0,
        title: Text(
          'Edit Booking',
          style: TextStyle(
            color: Color(0xFF00ff88),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: IconThemeData(color: Color(0xFF00d9ff)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Original booking info
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF1a1f35),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Color(0xFF00d9ff).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Color(0xFF00d9ff), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Current Booking Details',
                        style: TextStyle(
                          color: Color(0xFF00d9ff),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    '${DateFormat('MMM d, yyyy').format(widget.booking.date)} • ${widget.booking.startTime} - ${widget.booking.endTime}',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    'Lane ${widget.booking.lane} • ${widget.booking.weapon}',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),

            _buildSectionTitle('Update Date'),
            SizedBox(height: 10),
            _buildDateSelector(),
            SizedBox(height: 25),

            _buildSectionTitle('Update Time Slot'),
            SizedBox(height: 10),
            _buildTimeSlotSelectors(provider),
            SizedBox(height: 25),

            _buildSectionTitle('Update Lane'),
            SizedBox(height: 10),
            _buildLaneSelector(provider),
            SizedBox(height: 25),

            _buildSectionTitle('Update Weapon'),
            SizedBox(height: 10),
            _buildWeaponSelector(provider),
            SizedBox(height: 25),

            _buildSectionTitle('Update Coach (Optional)'),
            SizedBox(height: 10),
            _buildCoachSelector(provider),
            SizedBox(height: 40),

            _buildUpdateButton(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Color(0xFF00d9ff),
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(Duration(days: 90)),
          builder: (context, child) {
            return Theme(
              data: ThemeData.dark().copyWith(
                colorScheme: ColorScheme.dark(
                  primary: Color(0xFF00ff88),
                  onPrimary: Color(0xFF0a0e1a),
                  surface: Color(0xFF1a1f35),
                  onSurface: Colors.white,
                ),
              ),
              child: child!,
            );
          },
        );
        if (date != null) {
          setState(() {
            _selectedDate = date;
          });
        }
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFF1a1f35),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Color(0xFF00ff88).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Color(0xFF00ff88)),
            SizedBox(width: 12),
            Text(
              DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlotSelectors(BookingProvider provider) {
    final duration = provider.calculateDuration(_selectedStartTime, _selectedEndTime);
    final isValidDuration = duration > 0 && duration <= 3;

    return Column(
      children: [
        _buildDropdown(
          value: _selectedStartTime,
          hint: 'Start Time',
          icon: Icons.access_time,
          items: provider.timeSlots,
          onChanged: (value) {
            setState(() {
              _selectedStartTime = value!;
              // Reset end time if it becomes invalid
              final availableEndTimes = provider.getAvailableEndTimes(_selectedStartTime);
              if (!availableEndTimes.contains(_selectedEndTime)) {
                _selectedEndTime = availableEndTimes.first;
              }
            });
          },
        ),
        SizedBox(height: 15),

        _buildDropdown(
          value: _selectedEndTime,
          hint: 'End Time',
          icon: Icons.access_time_filled,
          items: provider.getAvailableEndTimes(_selectedStartTime),
          onChanged: (value) {
            setState(() {
              _selectedEndTime = value!;
            });
          },
        ),

        if (duration > 0) ...[
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isValidDuration
                  ? Color(0xFF00ff88).withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isValidDuration ? Color(0xFF00ff88) : Colors.red,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isValidDuration ? Icons.check_circle : Icons.error,
                  color: isValidDuration ? Color(0xFF00ff88) : Colors.red,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Duration: ${duration.toStringAsFixed(1)} hours',
                  style: TextStyle(
                    color: isValidDuration ? Color(0xFF00ff88) : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!isValidDuration)
                  Text(
                    ' (Max 3 hours)',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLaneSelector(BookingProvider provider) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: provider.lanes.map((lane) {
        final isSelected = _selectedLane == lane;
        final isAvailable = provider.isSlotAvailable(
          _selectedDate,
          _selectedStartTime,
          _selectedEndTime,
          lane,
          excludeBookingId: widget.booking.id,
        );

        return InkWell(
          onTap: isAvailable
              ? () {
                  setState(() {
                    _selectedLane = lane;
                  });
                }
              : null,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: !isAvailable
                  ? Colors.red.withOpacity(0.2)
                  : isSelected
                      ? Color(0xFF00ff88)
                      : Color(0xFF1a1f35),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: !isAvailable
                    ? Colors.red
                    : isSelected
                        ? Color(0xFF00ff88)
                        : Color(0xFF00ff88).withOpacity(0.3),
                width: 2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Color(0xFF00ff88).withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.track_changes,
                  color: !isAvailable
                      ? Colors.red
                      : isSelected
                          ? Color(0xFF0a0e1a)
                          : Color(0xFF00ff88),
                  size: 24,
                ),
                SizedBox(height: 4),
                Text(
                  'Lane $lane',
                  style: TextStyle(
                    color: !isAvailable
                        ? Colors.red
                        : isSelected
                            ? Color(0xFF0a0e1a)
                            : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                if (!isAvailable)
                  Text(
                    'Booked',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 9,
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWeaponSelector(BookingProvider provider) {
    return Column(
      children: provider.weapons.map((weapon) {
        final isSelected = _selectedWeapon == weapon.name;
        return Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedWeapon = weapon.name;
              });
            },
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? Color(0xFF00ff88).withOpacity(0.2) : Color(0xFF1a1f35),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Color(0xFF00ff88) : Color(0xFF00ff88).withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.gps_fixed,
                    color: isSelected ? Color(0xFF00ff88) : Colors.white54,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          weapon.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          weapon.type,
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: Color(0xFF00ff88),
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCoachSelector(BookingProvider provider) {
    return _buildDropdown(
      value: _selectedCoach ?? 'No Coach',
      hint: 'No Coach',
      icon: Icons.person,
      items: ['No Coach', ...provider.coaches.map((c) => c.name).toList()],
      onChanged: (value) {
        setState(() {
          _selectedCoach = value == 'No Coach' ? null : value;
        });
      },
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required IconData icon,
    required List<String> items,
    required Function(String?)? onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Color(0xFF1a1f35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(0xFF00ff88).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF00ff88)),
          SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                hint: Text(
                  hint,
                  style: TextStyle(color: Colors.white54),
                ),
                isExpanded: true,
                dropdownColor: Color(0xFF1a1f35),
                style: TextStyle(color: Colors.white, fontSize: 16),
                items: items.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateButton(BookingProvider provider) {
    final isValid = provider.calculateDuration(_selectedStartTime, _selectedEndTime) <= 3;

    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        gradient: isValid
            ? LinearGradient(
                colors: [Color(0xFF00ff88), Color(0xFF00d9ff)],
              )
            : null,
        color: isValid ? null : Colors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isValid
            ? [
                BoxShadow(
                  color: Color(0xFF00ff88).withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: isValid ? () => _updateBooking(provider) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'UPDATE BOOKING',
          style: TextStyle(
            color: isValid ? Color(0xFF0a0e1a) : Colors.white38,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  void _updateBooking(BookingProvider provider) {
    final updatedBooking = widget.booking.copyWith(
      date: _selectedDate,
      startTime: _selectedStartTime,
      endTime: _selectedEndTime,
      lane: _selectedLane,
      weapon: _selectedWeapon,
      coach: _selectedCoach,
    );

    provider.updateBooking(widget.booking.id, updatedBooking);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Booking updated successfully'),
        backgroundColor: Color(0xFF00ff88),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context);
  }
}
