import '../models/user.dart';

class SessionController {
  SessionController._internal();
  static final SessionController instance = SessionController._internal();

  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.role == 'admin';

  void setUser(User user) {
    _currentUser = user;
  }

  void logout() {
    _currentUser = null;
  }
}

