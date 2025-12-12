import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/booking.dart';
import '../models/weapon.dart';
import '../models/coach.dart';

class BookingProvider with ChangeNotifier {
  List<Booking> _bookings = [];
  List<Weapon> _weapons = [];
  List<Coach> _coaches = [];
  final List<int> _lanes = [1, 2, 3, 4, 5, 6, 7, 8];
  final List<String> _gunNames = [];

  final List<String> _timeSlots = [
    '8:00 AM',
    '8:30 AM',
    '9:00 AM',
    '9:30 AM',
    '10:00 AM',
    '10:30 AM',
    '11:00 AM',
    '11:30 AM',
    '12:00 PM',
    '12:30 PM',
    '1:00 PM',
    '1:30 PM',
    '2:00 PM',
    '2:30 PM',
    '3:00 PM',
    '3:30 PM',
    '4:00 PM',
    '4:30 PM',
    '5:00 PM',
    '5:30 PM',
    '6:00 PM',
    '6:30 PM',
    '7:00 PM',
    '7:30 PM',
    '8:00 PM',
  ];

  BookingProvider() {
    _initializeMockData();
    fetchCoachesAndGuns();
  }

  Future<void> fetchCoachesAndGuns() async {
    try {
      // Fetch coaches from API
      final coachesResponse = await http.get(
        Uri.parse('http://localhost:3000/v1/resources/coaches'),
      );

      // Fetch gun names from API
      final gunsResponse = await http.get(
        Uri.parse('http://localhost:3000/v1/resources/gun-names'),
      );

      if (coachesResponse.statusCode == 200) {
        final data = json.decode(coachesResponse.body);
        final List<dynamic> coachesData = data['coaches'] ?? [];
        _coaches = coachesData.map((c) => Coach(
          id: c['_id'],
          name: c['name'],
          specialty: (c['specialization'] as List).join(', '),
        )).toList();
        notifyListeners();
      }

      if (gunsResponse.statusCode == 200) {
        final data = json.decode(gunsResponse.body);
        final List<dynamic> gunsData = data['gunNames'] ?? [];
        _gunNames.clear();
        _gunNames.addAll(gunsData.map((g) => g['name'] as String).toList());
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching coaches and guns: $e');
    }
  }

  List<Booking> get bookings => _bookings;
  List<Weapon> get weapons => _weapons;
  List<Coach> get coaches => _coaches;
  List<int> get lanes => _lanes;
  List<String> get timeSlots => _timeSlots;
  List<String> get gunNames => _gunNames;

  void _initializeMockData() {
    _weapons = [
      Weapon(id: '1', name: 'Pistol', type: 'Select from gun list'),
      Weapon(id: '2', name: 'Rifle', type: 'Select from gun list'),
    ];

    _coaches = [];

    _bookings = [
      Booking(
        id: '1',
        date: DateTime.now().add(Duration(days: 2)),
        startTime: '10:00 AM',
        endTime: '11:30 AM',
        lane: 3,
        weapon: 'Pistol',
        coach: 'John Smith',
        status: BookingStatus.upcoming,
      ),
      Booking(
        id: '2',
        date: DateTime.now().subtract(Duration(days: 5)),
        startTime: '2:00 PM',
        endTime: '4:00 PM',
        lane: 5,
        weapon: 'Rifle',
        coach: 'Sarah Johnson',
        status: BookingStatus.completed,
      ),
      Booking(
        id: '3',
        date: DateTime.now().add(Duration(days: 7)),
        startTime: '9:00 AM',
        endTime: '10:30 AM',
        lane: 1,
        weapon: 'Air Gun',
        status: BookingStatus.upcoming,
      ),
    ];
  }

  void addBooking(Booking booking) {
    _bookings.add(booking);
    notifyListeners();
  }

  void updateBooking(String id, Booking updatedBooking) {
    final index = _bookings.indexWhere((b) => b.id == id);
    if (index != -1) {
      _bookings[index] = updatedBooking;
      notifyListeners();
    }
  }

  void cancelBooking(String id) {
    final index = _bookings.indexWhere((b) => b.id == id);
    if (index != -1) {
      _bookings[index] = _bookings[index].copyWith(status: BookingStatus.cancelled);
      notifyListeners();
    }
  }

  bool isSlotAvailable(DateTime date, String startTime, String endTime, int lane,
      {String? excludeBookingId}) {
    return !_bookings.any((booking) {
      if (booking.id == excludeBookingId) return false;
      if (booking.status == BookingStatus.cancelled) return false;
      if (booking.lane != lane) return false;
      if (!_isSameDate(booking.date, date)) return false;

      return _timesOverlap(
        booking.startTime,
        booking.endTime,
        startTime,
        endTime,
      );
    });
  }

  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool _timesOverlap(String start1, String end1, String start2, String end2) {
    final s1 = _timeToMinutes(start1);
    final e1 = _timeToMinutes(end1);
    final s2 = _timeToMinutes(start2);
    final e2 = _timeToMinutes(end2);

    return s1 < e2 && s2 < e1;
  }

  int _timeToMinutes(String time) {
    final parts = time.split(' ');
    var timeParts = parts[0].split(':');
    var hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    if (parts[1] == 'PM' && hour != 12) hour += 12;
    if (parts[1] == 'AM' && hour == 12) hour = 0;

    return hour * 60 + minute;
  }

  List<String> getAvailableEndTimes(String startTime) {
    final startIndex = _timeSlots.indexOf(startTime);
    if (startIndex == -1) return [];

    final maxDuration = 3 * 60; // 3 hours in minutes
    final startMinutes = _timeToMinutes(startTime);

    return _timeSlots.skip(startIndex + 1).where((endTime) {
      final endMinutes = _timeToMinutes(endTime);
      final duration = endMinutes - startMinutes;
      return duration > 0 && duration <= maxDuration;
    }).toList();
  }

  double calculateDuration(String startTime, String endTime) {
    final startMinutes = _timeToMinutes(startTime);
    final endMinutes = _timeToMinutes(endTime);
    return (endMinutes - startMinutes) / 60.0;
  }
}
