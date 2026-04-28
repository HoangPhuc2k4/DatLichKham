import '../api/api_client.dart';
import '../models/schedule.dart' as app;

class ScheduleController {
  ScheduleController._internal();
  static final ScheduleController instance = ScheduleController._internal();

  Future<List<app.Schedule>> getSchedulesByDoctorAndDate({
    required int doctorId,
    required String date,
  }) async {
    final data = await ApiClient.instance.getJson(
      '/schedules',
      query: {'doctorId': '$doctorId', 'date': date},
    );
    if (data is! List) return const <app.Schedule>[];
    return data
        .whereType<Map>()
        .map((m) => app.Schedule.fromMap(Map<String, dynamic>.from(m)))
        .toList();
  }

  Future<int> createSchedule(app.Schedule schedule) async {
    final res = await ApiClient.instance.postJson('/schedules', schedule.toMap());
    if (res is Map && res['id'] is num) return (res['id'] as num).toInt();
    return 0;
  }

  Future<int> updateSchedule(app.Schedule schedule) async {
    if (schedule.id == null) {
      throw ArgumentError('Schedule id is required for update');
    }
    await ApiClient.instance.putJson('/schedules/${schedule.id}', schedule.toMap());
    return schedule.id ?? 0;
  }

  Future<int> deleteSchedule(int id) async {
    await ApiClient.instance.deleteJson('/schedules/$id');
    return 1;
  }
}

