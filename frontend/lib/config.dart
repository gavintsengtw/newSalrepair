// lib/config.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get apiUrl {
    // 1. Try .env
    String? envUrl = dotenv.env['API_URL'];
    if (envUrl != null && envUrl.isNotEmpty) return envUrl;

    // 2. If Web, use current origin (relative path support)
    if (kIsWeb) {
      // Use Uri.base to get current window location in a cross-platform way
      return Uri.base.origin;
    }

    // 3. Fallback for Local Dev (Android Emulator / Desktop)
    return 'http://10.0.2.2:8080';
  }
}
