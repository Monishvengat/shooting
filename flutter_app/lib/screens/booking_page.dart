import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/booking_provider.dart';
import '../models/booking.dart';
import '../widgets/confirmation_modal.dart';

class BookingPage extends StatefulWidget {
  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime? _selectedDate;
  double _rangeMeters = 25.0; // Default range in meters
  String? _selectedStartTime;
  String? _selectedEndTime;
  int? _selectedLane;
  String? _selectedWeapon;
  String? _selectedGunName;
  String? _selectedCoach;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BookingProvider>(context);

    return Scaffold(
      backgroundColor: Color(0xFF0a0e1a),
      appBar: AppBar(
        backgroundColor: Color(0xFF1a1f35),
        elevation: 0,
        title: Text(
          'Book Your Shooting Session',
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
            _buildSectionTitle('Select Date'),
            SizedBox(height: 10),
            _buildDateSelector(),
            SizedBox(height: 25),

            _buildSectionTitle('Select Range Distance'),
            SizedBox(height: 10),
            _buildRangeSelector(),
            SizedBox(height: 25),

            _buildSectionTitle('Select Time Slot'),
            SizedBox(height: 10),
            _buildTimeSlotSelectors(provider),
            SizedBox(height: 25),

            _buildSectionTitle('Select Lane'),
            SizedBox(height: 10),
            _buildLaneSelector(provider),
            SizedBox(height: 25),

            _buildSectionTitle('Select Weapon Type'),
            SizedBox(height: 10),
            _buildWeaponSelector(provider),
            SizedBox(height: 25),

            if (_selectedWeapon != null) ...[
              _buildSectionTitle('Select Gun Name'),
              SizedBox(height: 10),
              _buildGunNameSelector(provider),
              SizedBox(height: 25),
            ],

            _buildSectionTitle('Select Coach (Optional)'),
            SizedBox(height: 10),
            _buildCoachSelector(provider),
            SizedBox(height: 40),

            _buildConfirmButton(provider),
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
          initialDate: _selectedDate ?? DateTime.now(),
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
              _selectedDate != null
                  ? DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate!)
                  : 'Select Date',
              style: TextStyle(
                color: _selectedDate != null ? Colors.white : Colors.white54,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRangeSelector() {
    final ranges = [10.0, 25.0, 50.0];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: ranges.map((range) {
        final isSelected = _rangeMeters == range;
        return InkWell(
          onTap: () {
            setState(() {
              _rangeMeters = range;
            });
          },
          child: Container(
            width: 100,
            height: 80,
            decoration: BoxDecoration(
              color: isSelected ? Color(0xFF00ff88).withOpacity(0.2) : Color(0xFF1a1f35),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Color(0xFF00ff88) : Color(0xFF00ff88).withOpacity(0.3),
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
                  Icons.straighten,
                  color: isSelected ? Color(0xFF00ff88) : Colors.white54,
                  size: 28,
                ),
                SizedBox(height: 8),
                Text(
                  '${range.toInt()} m',
                  style: TextStyle(
                    color: isSelected ? Color(0xFF00ff88) : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: Color(0xFF00ff88),
                    size: 16,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimeSlotSelectors(BookingProvider provider) {
    final duration = _selectedStartTime != null && _selectedEndTime != null
        ? provider.calculateDuration(_selectedStartTime!, _selectedEndTime!)
        : 0.0;

    final isValidDuration = duration > 0 && duration <= 3;

    return Column(
      children: [
        // Start Time
        _buildDropdown(
          value: _selectedStartTime,
          hint: 'Start Time',
          icon: Icons.access_time,
          items: provider.timeSlots,
          onChanged: (value) {
            setState(() {
              _selectedStartTime = value;
              _selectedEndTime = null; // Reset end time
            });
          },
        ),
        SizedBox(height: 15),

        // End Time
        _buildDropdown(
          value: _selectedEndTime,
          hint: 'End Time',
          icon: Icons.access_time_filled,
          items: _selectedStartTime != null
              ? provider.getAvailableEndTimes(_selectedStartTime!)
              : [],
          onChanged: _selectedStartTime != null
              ? (value) {
                  setState(() {
                    _selectedEndTime = value;
                  });
                }
              : null,
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
        final isAvailable = _selectedDate != null &&
                _selectedStartTime != null &&
                _selectedEndTime != null
            ? provider.isSlotAvailable(
                _selectedDate!,
                _selectedStartTime!,
                _selectedEndTime!,
                lane,
              )
            : true;

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
                _selectedGunName = null; // Reset gun name when weapon type changes
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

  Widget _buildGunNameSelector(BookingProvider provider) {
    return _buildDropdown(
      value: _selectedGunName,
      hint: 'Select Gun Name',
      icon: Icons.gps_fixed,
      items: provider.gunNames,
      onChanged: (value) {
        setState(() {
          _selectedGunName = value;
        });
      },
    );
  }

  Widget _buildCoachSelector(BookingProvider provider) {
    return _buildDropdown(
      value: _selectedCoach,
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

  Widget _buildConfirmButton(BookingProvider provider) {
    final isValid = _selectedDate != null &&
        _selectedStartTime != null &&
        _selectedEndTime != null &&
        _selectedLane != null &&
        _selectedWeapon != null &&
        _selectedGunName != null &&
        (_selectedStartTime != null && _selectedEndTime != null
            ? provider.calculateDuration(_selectedStartTime!, _selectedEndTime!) <= 3
            : false);

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
        onPressed: isValid ? () => _confirmBooking(provider) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'CONFIRM BOOKING',
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

  void _confirmBooking(BookingProvider provider) {
    final booking = Booking(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: _selectedDate!,
      startTime: _selectedStartTime!,
      endTime: _selectedEndTime!,
      lane: _selectedLane!,
      weapon: '$_selectedWeapon - $_selectedGunName',
      coach: _selectedCoach,
      status: BookingStatus.upcoming,
    );

    provider.addBooking(booking);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConfirmationModal(booking: booking),
    );
  }
}
