import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class ApiService {
  late String
      baseUrl; // Removed final to allow updating if needed, though usually static
  String? _token;

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal() {
    baseUrl = AppConfig.apiUrl;
  }

  void setToken(String? token) {
    _token = token;
  }

  // Helper to get headers with token
  Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<dynamic> get(String endpoint) async {
    final response =
        await http.get(Uri.parse('$baseUrl$endpoint'), headers: _getHeaders());
    return _handleResponse(response);
  }

  Future<dynamic> post(String endpoint, dynamic data) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: _getHeaders(),
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  Future<dynamic> put(String endpoint, dynamic data) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: _getHeaders(),
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  Future<dynamic> delete(String endpoint) async {
    final response = await http.delete(Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders());
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else {
      throw Exception('API Error: ${response.statusCode} ${response.body}');
    }
  }
}
