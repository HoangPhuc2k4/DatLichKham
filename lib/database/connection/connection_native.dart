import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

DatabaseConnection openAppConnectionImpl() {
  return DatabaseConnection.delayed(
    Future(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'clinic_booking.sqlite'));
      final executor = NativeDatabase.createInBackground(file);
      return DatabaseConnection.fromExecutor(executor);
    }),
  );
}

