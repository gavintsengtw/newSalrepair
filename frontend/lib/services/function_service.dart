import '../models/app_function.dart';
import 'api_service.dart';

class FunctionService {
  final ApiService _api = ApiService();
  final String _endpoint = '/api/functions';

  Future<List<AppFunction>> getFunctions() async {
    final response = await _api.get(_endpoint);
    if (response == null) return [];

    // Expecting response to be a List or { "data": List }
    // Adjust based on your API format. Assuming List<Map> for now.
    final List<dynamic> data = (response is Map && response.containsKey('data'))
        ? response['data']
        : response;

    return data.map((json) => AppFunction.fromJson(json)).toList();
  }

  Future<void> createFunction(AppFunction function) async {
    await _api.post(_endpoint, function.toJson());
  }

  Future<void> updateFunction(AppFunction function) async {
    // Assuming PUT /api/functions/{id} or PUT /api/functions with ID in body
    // Let's assume standard REST: PUT /api/functions/{id}
    // BUT the prompt said PUT /api/functions
    // I'll stick to PUT /api/functions for now as requested, but usually ID is in URL

    // Option A: PUT /api/functions (ID in body)
    await _api.put(_endpoint, function.toJson());
  }

  Future<void> deleteFunction(int id) async {
    await _api.delete('$_endpoint/$id');
  }
}
