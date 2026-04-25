class Appointment {
  final int? id;
  final int userId;
  final int doctorId;
  final int scheduleId;
  final String symptom;
  final String status;
  final String createdAt;

  Appointment({
    this.id,
    required this.userId,
    required this.doctorId,
    required this.scheduleId,
    required this.symptom,
    required this.status,
    required this.createdAt,
  });

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'] as int?,
      userId: map['user_id'] as int? ?? 0,
      doctorId: map['doctor_id'] as int? ?? 0,
      scheduleId: map['schedule_id'] as int? ?? 0,
      symptom: map['symptom'] as String? ?? '',
      status: map['status'] as String? ?? '',
      createdAt: map['created_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'doctor_id': doctorId,
      'schedule_id': scheduleId,
      'symptom': symptom,
      'status': status,
      'created_at': createdAt,
    };
  }
}

