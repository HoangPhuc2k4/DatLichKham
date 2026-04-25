import 'appointment.dart';

class AppointmentDetails {
  final Appointment appointment;
  final String userName;
  final String doctorName;
  final String specialty;
  final String date;
  final String startTime;
  final String endTime;

  AppointmentDetails({
    required this.appointment,
    this.userName = '',
    required this.doctorName,
    required this.specialty,
    required this.date,
    required this.startTime,
    required this.endTime,
  });
}

