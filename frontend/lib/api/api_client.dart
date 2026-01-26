import 'package:dio/dio.dart';

class ApiClient {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8080/api', // Change to your server URL
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));

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
