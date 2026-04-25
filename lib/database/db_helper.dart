import 'app_database.dart';

/// Wrapper singleton để controllers dùng chung 1 DB instance.
class DbHelper {
  DbHelper._internal();
  static final DbHelper instance = DbHelper._internal();

  final AppDatabase db = AppDatabase.instance;
}

