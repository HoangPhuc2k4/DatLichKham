import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../database/db_helper.dart';
import '../models/user.dart' as app;

class AuthController {
  AuthController._internal();
  static final AuthController instance = AuthController._internal();

  Future<app.User?> login(String email, String password) async {
    final db = DbHelper.instance.db;

    final row = await (db.select(db.users)
          ..where((u) => u.email.equals(email) & u.password.equals(password))
          ..limit(1))
        .getSingleOrNull();

    if (row == null) return null;
    return _toAppUser(row);
  }

  Future<app.User> register(app.User user) async {
    final db = DbHelper.instance.db;
    final existed = await (db.select(db.users)
          ..where((u) => u.email.equals(user.email))
          ..limit(1))
        .getSingleOrNull();
    if (existed != null) {
      throw StateError('EMAIL_EXISTS');
    }
    final id = await db.into(db.users).insert(
          UsersCompanion.insert(
            name: user.name,
            email: user.email,
            password: user.password,
            phone: Value(user.phone),
            role: Value(user.role),
          ),
        );
    return user.copyWith(id: id);
  }

  app.User _toAppUser(dynamic row) {
    // row is DbUser
    return app.User(
      id: row.id as int?,
      name: row.name as String,
      email: row.email as String,
      password: row.password as String,
      phone: row.phone as String,
      role: row.role as String,
    );
  }
}

