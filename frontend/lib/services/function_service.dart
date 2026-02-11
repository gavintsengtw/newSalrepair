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
    await _api.put('$_endpoint/${function.id}', function.toJson());
  }

  Future<void> deleteFunction(int id) async {
    await _api.delete('$_endpoint/$id');
  }
}
