import 'package:flutter/foundation.dart';

class AppConfig {
  static String get apiBaseUrl {
    const defined = String.fromEnvironment('API_BASE_URL');
    if (defined.isNotEmpty) return defined;

    // Web chạy cùng máy: dùng localhost
    if (kIsWeb) return 'http://localhost:3000';

    // Android emulator: localhost của máy host là 10.0.2.2
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }

    // Các nền tảng khác (Windows/macOS/Linux, Android device cắm USB + port forward)
    return 'http://localhost:3000';
  }
}

