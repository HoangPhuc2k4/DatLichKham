import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../database/db_helper.dart';
import '../models/schedule.dart' as app;

class ScheduleController {
  ScheduleController._internal();
  static final ScheduleController instance = ScheduleController._internal();

  Future<List<app.Schedule>> getSchedulesByDoctorAndDate({
    required int doctorId,
    required String date,
  }) async {
    final db = DbHelper.instance.db;
    final rows = await (db.select(db.schedules)
          ..where((s) => s.doctorId.equals(doctorId) & s.date.equals(date)))
        .get();
    return rows.map(_toAppSchedule).toList();
  }

  Future<int> createSchedule(app.Schedule schedule) async {
    final db = DbHelper.instance.db;
    return db.into(db.schedules).insert(
          SchedulesCompanion.insert(
            doctorId: schedule.doctorId,
            date: schedule.date,
            startTime: schedule.startTime,
            endTime: schedule.endTime,
            isBooked: Value(schedule.isBooked),
          ),
        );
  }

  Future<int> updateSchedule(app.Schedule schedule) async {
    final db = DbHelper.instance.db;
    if (schedule.id == null) {
      throw ArgumentError('Schedule id is required for update');
    }
    await (db.update(db.schedules)..where((s) => s.id.equals(schedule.id!)))
        .write(
      SchedulesCompanion(
        doctorId: Value(schedule.doctorId),
        date: Value(schedule.date),
        startTime: Value(schedule.startTime),
        endTime: Value(schedule.endTime),
        isBooked: Value(schedule.isBooked),
      ),
    );
    return schedule.id!;
  }

  Future<int> deleteSchedule(int id) async {
    final db = DbHelper.instance.db;
    return (db.delete(db.schedules)..where((s) => s.id.equals(id))).go();
  }

  app.Schedule _toAppSchedule(dynamic row) {
    return app.Schedule(
      id: row.id as int?,
      doctorId: row.doctorId as int,
      date: row.date as String,
      startTime: row.startTime as String,
      endTime: row.endTime as String,
      isBooked: row.isBooked as bool,
    );
  }
}

