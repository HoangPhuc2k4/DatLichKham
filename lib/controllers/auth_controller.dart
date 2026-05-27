import '../api/api_client.dart';
import '../models/user.dart' as app;

class AuthController {
  AuthController._internal();
  static final AuthController instance = AuthController._internal();

  Future<app.User?> login(String email, String password) async {
    try {
      final data = await ApiClient.instance.postJson('/auth/login', {
        'email': email,
        'password': password,
      });
      if (data is! Map<String, dynamic>) return null;
      return app.User.fromMap(data);
    } on ApiException catch (e) {
      if (e.status == 401) return null;
      rethrow;
    }
  }

  Future<app.User> register(app.User user) async {
    final data = await ApiClient.instance.postJson('/auth/register', user.toMap());
    if (data is! Map<String, dynamic>) {
      throw StateError('REGISTER_FAILED');
    }
    return app.User.fromMap(data);
  }
}
/// code cua tuan
