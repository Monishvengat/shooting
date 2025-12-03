class Booking {
  final String id;
  final DateTime date;
  final String startTime;
  final String endTime;
  final int lane;
  final String weapon;
  final String? coach;
  final BookingStatus status;

  Booking({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.lane,
    required this.weapon,
    this.coach,
    required this.status,
  });

  double get duration {
    final start = _parseTime(startTime);
    final end = _parseTime(endTime);
    return end.difference(start).inMinutes / 60.0;
  }

  DateTime _parseTime(String time) {
    final parts = time.split(' ');
    var timeParts = parts[0].split(':');
    var hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    if (parts[1] == 'PM' && hour != 12) hour += 12;
    if (parts[1] == 'AM' && hour == 12) hour = 0;

    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  Booking copyWith({
    String? id,
    DateTime? date,
    String? startTime,
    String? endTime,
    int? lane,
    String? weapon,
    String? coach,
    BookingStatus? status,
  }) {
    return Booking(
      id: id ?? this.id,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      lane: lane ?? this.lane,
      weapon: weapon ?? this.weapon,
      coach: coach ?? this.coach,
      status: status ?? this.status,
    );
  }
}

enum BookingStatus {
  upcoming,
  completed,
  cancelled,
}
