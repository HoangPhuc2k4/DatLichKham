import '../api/api_client.dart';
import '../models/doctor.dart' as app;

class DoctorController {
  DoctorController._internal();
  static final DoctorController instance = DoctorController._internal();

  Future<List<app.Doctor>> getAllDoctors() async {
    final data = await ApiClient.instance.getJson('/doctors');
    if (data is! List) return const <app.Doctor>[];
    return data
        .whereType<Map>()
        .map((m) => app.Doctor.fromMap(Map<String, dynamic>.from(m)))
        .toList();
  }

  Future<int> upsertDoctor(app.Doctor doctor) async {
    if (doctor.id == null) {
      final res = await ApiClient.instance.postJson('/doctors', doctor.toMap());
      if (res is Map && res['id'] is int) return res['id'] as int;
      if (res is Map && res['id'] is num) return (res['id'] as num).toInt();
      return 0;
    }

    await ApiClient.instance.putJson('/doctors/${doctor.id}', doctor.toMap());
    return doctor.id ?? 0;
  }

  Future<int> deleteDoctor(int id) async {
    await ApiClient.instance.deleteJson('/doctors/$id');
    return 1;
  }
}
/// code cua tuan
