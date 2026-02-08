import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import '../config.dart';

class ApiClient {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: '${AppConfig.apiUrl}/api',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));

  ApiClient() {
    final proxy = AppConfig.httpProxy;
    if (proxy != null) {
      (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.findProxy = (uri) {
          return "PROXY $proxy";
        };
        // Verify SSL certificate (optional, remove for production if strict security needed)
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      };
    }
  }

  Future<dynamic> get(String path, {String? tenantId}) async {
    try {
      final options = Options(
        headers: tenantId != null ? {'X-Tenant-ID': tenantId} : {},
      );

      final response = await _dio.get(path, options: options);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Add post, put, delete methods as needed
}
