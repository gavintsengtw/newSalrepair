// lib/config.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get apiUrl {
    // 1. Try .env
    String? envUrl = dotenv.env['API_URL'];

    // If Web, apply forced HTTPS logic
    if (kIsWeb) {
      if (envUrl != null && envUrl.startsWith('http://')) {
        return envUrl.replaceFirst('http://', 'https://');
      }

      // Force HTTPS for production domain
      if (Uri.base.host.contains('fong-yi.com.tw')) {
        return 'https://repair.fong-yi.com.tw';
      }

      // If envUrl is missing, fallback to current origin
      return envUrl ?? Uri.base.origin;
    }

    // If not web, return envUrl if present
    if (envUrl != null && envUrl.isNotEmpty) return envUrl;

    // 3. Fallback for Local Dev (Android Emulator / Desktop)
    String url = 'https://10.0.2.2:8080';
    return url;
  }

  static String? get httpProxy {
    final proxy = dotenv.env['HTTP_PROXY'];
    if (proxy != null && proxy.isNotEmpty) {
      return proxy;
    }
    return null;
  }
}
