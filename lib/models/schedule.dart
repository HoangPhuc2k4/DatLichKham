class Schedule {
  final int? id;
  final int doctorId;
  final String date; // lưu TEXT yyyy-MM-dd
  final String startTime; // HH:mm
  final String endTime; // HH:mm
  final bool isBooked;

  Schedule({
    this.id,
    required this.doctorId,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.isBooked = false,
  });

  factory Schedule.fromMap(Map<String, dynamic> map) {
    return Schedule(
      id: map['id'] as int?,
      doctorId: map['doctor_id'] as int? ?? 0,
      date: map['date'] as String? ?? '',
      startTime: map['start_time'] as String? ?? '',
      endTime: map['end_time'] as String? ?? '',
      isBooked: (map['is_booked'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'doctor_id': doctorId,
      'date': date,
      'start_time': startTime,
      'end_time': endTime,
      'is_booked': isBooked ? 1 : 0,
    };
  }
}

