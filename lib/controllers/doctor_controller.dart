import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../database/db_helper.dart';
import '../models/doctor.dart' as app;

class DoctorController {
  DoctorController._internal();
  static final DoctorController instance = DoctorController._internal();

  String _encodeSpecs(List<String> specs) =>
      specs.map((s) => s.trim()).where((s) => s.isNotEmpty).join('|');

  List<String> _decodeSpecs(String raw) =>
      raw.split('|').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

  Future<List<app.Doctor>> getAllDoctors() async {
    final db = DbHelper.instance.db;
    final rows = await db.select(db.doctors).get();
    return rows.map(_toAppDoctor).toList();
  }

  Future<int> upsertDoctor(app.Doctor doctor) async {
    final db = DbHelper.instance.db;
    if (doctor.id == null) {
      return db.into(db.doctors).insert(
            DoctorsCompanion.insert(
              name: doctor.name,
              specialty: doctor.specialty,
              specializations: Value(_encodeSpecs(doctor.specializations)),
              experience: Value(doctor.experience),
              description: Value(doctor.description),
              image: Value(doctor.image),
            ),
          );
    }

    await (db.update(db.doctors)..where((d) => d.id.equals(doctor.id!))).write(
      DoctorsCompanion(
        name: Value(doctor.name),
        specialty: Value(doctor.specialty),
        specializations: Value(_encodeSpecs(doctor.specializations)),
        experience: Value(doctor.experience),
        description: Value(doctor.description),
        image: Value(doctor.image),
      ),
    );
    return doctor.id!;
  }

  Future<int> deleteDoctor(int id) async {
    final db = DbHelper.instance.db;
    return (db.delete(db.doctors)..where((d) => d.id.equals(id))).go();
  }

  app.Doctor _toAppDoctor(dynamic row) {
    return app.Doctor(
      id: row.id as int?,
      name: row.name as String,
      specialty: row.specialty as String,
      specializations: _decodeSpecs(row.specializations as String),
      experience: row.experience as int,
      description: row.description as String,
      image: row.image as String,
    );
  }
}

