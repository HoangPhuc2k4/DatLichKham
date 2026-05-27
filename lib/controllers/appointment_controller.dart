import '../api/api_client.dart';
import '../models/appointment.dart' as app;
import '../models/appointment_details.dart';

class AppointmentController {
  AppointmentController._internal();
  static final AppointmentController instance = AppointmentController._internal();

  Future<List<app.Appointment>> getAppointmentsByUser(int userId) async {
    final data = await ApiClient.instance.getJson(
      '/appointments',
      query: {'userId': '$userId'},
    );
    if (data is! List) return const <app.Appointment>[];
    return data
        .whereType<Map>()
        .map((m) => app.Appointment.fromMap(Map<String, dynamic>.from(m)))
        .toList();
  }

  Future<List<AppointmentDetails>> getAppointmentsByUserDetails(int userId) async {
    final data = await ApiClient.instance.getJson(
      '/appointments/details',
      query: {'userId': '$userId'},
    );
    return _parseDetailsList(data);
  }

  Future<int> createAppointment(app.Appointment appointment) async {
    final res = await ApiClient.instance.postJson('/appointments', appointment.toMap());
    if (res is Map && res['id'] is num) return (res['id'] as num).toInt();
    return 0;
  }

  Future<void> cancelAppointment(app.Appointment appointment) async {
    if (appointment.id == null) {
      throw ArgumentError('Appointment id is required');
    }
    await ApiClient.instance.postJson('/appointments/${appointment.id}/cancel', {});
  }

  Future<List<app.Appointment>> getAllAppointments() async {
    final data = await ApiClient.instance.getJson('/appointments');
    if (data is! List) return const <app.Appointment>[];
    return data
        .whereType<Map>()
        .map((m) => app.Appointment.fromMap(Map<String, dynamic>.from(m)))
        .toList();
  }

  Future<List<AppointmentDetails>> getAllAppointmentsDetails() async {
    final data = await ApiClient.instance.getJson('/appointments/details');
    return _parseDetailsList(data);
  }

  Future<void> confirmAppointment(int appointmentId) async {
    await ApiClient.instance.postJson('/appointments/$appointmentId/confirm', {});
  }

  Future<void> deleteAppointment(int appointmentId) async {
    await ApiClient.instance.deleteJson('/appointments/$appointmentId');
  }

  List<AppointmentDetails> _parseDetailsList(dynamic data) {
    if (data is! List) return const <AppointmentDetails>[];
    return data.whereType<Map>().map((m) {
      final mm = Map<String, dynamic>.from(m);
      final apptMap = mm['appointment'];
      final appt = apptMap is Map
          ? app.Appointment.fromMap(Map<String, dynamic>.from(apptMap))
          : app.Appointment.fromMap(const {});
      return AppointmentDetails(
        appointment: appt,
        userName: (mm['userName'] as String?) ?? '',
        doctorName: (mm['doctorName'] as String?) ?? '',
        specialty: (mm['specialty'] as String?) ?? '',
        date: (mm['date'] as String?) ?? '',
        startTime: (mm['startTime'] as String?) ?? '',
        endTime: (mm['endTime'] as String?) ?? '',
      );
    }).toList();
  }
}
/// code cua tuan
