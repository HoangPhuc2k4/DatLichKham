import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../database/db_helper.dart';
import '../models/appointment.dart' as app;
import '../models/appointment_details.dart';

class AppointmentController {
  AppointmentController._internal();
  static final AppointmentController instance = AppointmentController._internal();

  Future<List<app.Appointment>> getAppointmentsByUser(int userId) async {
    final db = DbHelper.instance.db;
    final rows = await (db.select(db.appointments)
          ..where((a) => a.userId.equals(userId))
          ..orderBy([(a) => OrderingTerm.desc(a.createdAt)]))
        .get();
    return rows.map(_toAppAppointment).toList();
  }

  Future<List<AppointmentDetails>> getAppointmentsByUserDetails(int userId) async {
    final db = DbHelper.instance.db;
    final query = db.select(db.appointments).join([
      innerJoin(db.doctors, db.doctors.id.equalsExp(db.appointments.doctorId)),
      innerJoin(db.schedules, db.schedules.id.equalsExp(db.appointments.scheduleId)),
      innerJoin(db.users, db.users.id.equalsExp(db.appointments.userId)),
    ])
      ..where(db.appointments.userId.equals(userId))
      ..orderBy([OrderingTerm.desc(db.appointments.createdAt)]);

    final rows = await query.get();
    return rows.map((r) {
      final a = r.readTable(db.appointments);
      final d = r.readTable(db.doctors);
      final s = r.readTable(db.schedules);
      final u = r.readTable(db.users);
      return AppointmentDetails(
        appointment: _toAppAppointment(a),
        userName: u.name,
        doctorName: d.name,
        specialty: d.specialty,
        date: s.date,
        startTime: s.startTime,
        endTime: s.endTime,
      );
    }).toList();
  }

  Future<int> createAppointment(app.Appointment appointment) async {
    final db = DbHelper.instance.db;

    return db.transaction(() async {
      final schedule = await (db.select(db.schedules)
            ..where((s) =>
                s.id.equals(appointment.scheduleId) & s.isBooked.equals(false))
            ..limit(1))
          .getSingleOrNull();

      if (schedule == null) {
        throw StateError('Lịch đã được đặt hoặc không tồn tại.');
      }

      final id = await db.into(db.appointments).insert(
            AppointmentsCompanion.insert(
              userId: appointment.userId,
              doctorId: appointment.doctorId,
              scheduleId: appointment.scheduleId,
              symptom: Value(appointment.symptom),
              status: Value(appointment.status),
              createdAt: appointment.createdAt,
            ),
          );

      await (db.update(db.schedules)
            ..where((s) => s.id.equals(appointment.scheduleId)))
          .write(SchedulesCompanion(isBooked: const Value(true)));

      return id;
    });
  }

  Future<void> cancelAppointment(app.Appointment appointment) async {
    final db = DbHelper.instance.db;
    if (appointment.id == null) {
      throw ArgumentError('Appointment id is required');
    }

    await db.transaction(() async {
      await (db.update(db.appointments)
            ..where((a) => a.id.equals(appointment.id!)))
          .write(AppointmentsCompanion(status: const Value('cancelled')));

      await (db.update(db.schedules)
            ..where((s) => s.id.equals(appointment.scheduleId)))
          .write(SchedulesCompanion(isBooked: const Value(false)));
    });
  }

  Future<List<app.Appointment>> getAllAppointments() async {
    final db = DbHelper.instance.db;
    final rows = await (db.select(db.appointments)
          ..orderBy([(a) => OrderingTerm.desc(a.createdAt)]))
        .get();
    return rows.map(_toAppAppointment).toList();
  }

  Future<List<AppointmentDetails>> getAllAppointmentsDetails() async {
    final db = DbHelper.instance.db;
    final query = db.select(db.appointments).join([
      innerJoin(db.doctors, db.doctors.id.equalsExp(db.appointments.doctorId)),
      innerJoin(db.schedules, db.schedules.id.equalsExp(db.appointments.scheduleId)),
      innerJoin(db.users, db.users.id.equalsExp(db.appointments.userId)),
    ])
      ..orderBy([OrderingTerm.desc(db.appointments.createdAt)]);

    final rows = await query.get();
    return rows.map((r) {
      final a = r.readTable(db.appointments);
      final d = r.readTable(db.doctors);
      final s = r.readTable(db.schedules);
      final u = r.readTable(db.users);
      return AppointmentDetails(
        appointment: _toAppAppointment(a),
        userName: u.name,
        doctorName: d.name,
        specialty: d.specialty,
        date: s.date,
        startTime: s.startTime,
        endTime: s.endTime,
      );
    }).toList();
  }

  Future<void> confirmAppointment(int appointmentId) async {
    final db = DbHelper.instance.db;
    await (db.update(db.appointments)..where((a) => a.id.equals(appointmentId)))
        .write(AppointmentsCompanion(status: const Value('confirmed')));
  }

  Future<void> deleteAppointment(int appointmentId) async {
    final db = DbHelper.instance.db;
    await db.transaction(() async {
      final a = await (db.select(db.appointments)
            ..where((x) => x.id.equals(appointmentId))
            ..limit(1))
          .getSingleOrNull();
      if (a == null) return;

      // trả slot về open
      await (db.update(db.schedules)..where((s) => s.id.equals(a.scheduleId)))
          .write(const SchedulesCompanion(isBooked: Value(false)));

      await (db.delete(db.appointments)..where((x) => x.id.equals(appointmentId)))
          .go();
    });
  }

  app.Appointment _toAppAppointment(dynamic row) {
    return app.Appointment(
      id: row.id as int?,
      userId: row.userId as int,
      doctorId: row.doctorId as int,
      scheduleId: row.scheduleId as int,
      symptom: row.symptom as String,
      status: row.status as String,
      createdAt: row.createdAt as String,
    );
  }
}

