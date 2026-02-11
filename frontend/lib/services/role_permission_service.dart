import '../models/app_role.dart';
import 'api_service.dart';

class RolePermissionService {
  final ApiService _api = ApiService();
  final String _endpoint = '/api/roles';
  final String _accessEndpoint = '/api/role-access';

  Future<List<AppRole>> getRoles() async {
    final response = await _api.get(_endpoint);
    if (response == null) return [];

    // Expecting response to be a List or { "data": List }
    final List<dynamic> data = (response is Map && response.containsKey('data'))
        ? response['data']
        : response;

    return data.map((json) => AppRole.fromJson(json)).toList();
  }

  Future<void> createRole(AppRole role) async {
    await _api.post(_endpoint, role.toJson());
  }

  Future<void> updateRole(AppRole role) async {
    await _api.put('$_endpoint/${role.id}', role.toJson());
  }

  Future<void> deleteRole(int id) async {
    await _api.delete('$_endpoint/$id');
  }

  // Get list of function IDs assigned to a role
  Future<List<int>> getRolePermissions(int roleId) async {
    // Backend returns List<AppRoleFunctionAccess>
    final response = await _api.get('$_accessEndpoint?roleId=$roleId');
    if (response == null) return [];

    final List<dynamic> data = (response is Map && response.containsKey('data'))
        ? response['data']
        : response;

    // Map AppRoleFunctionAccess to functionId
    // Access object has { "function": { "functionId": ... } } or similar
    return data
        .map<int>((json) {
          // Check structure based on AppRoleFunctionAccess entity
          if (json['function'] != null &&
              json['function']['functionId'] != null) {
            return json['function']['functionId'] as int;
          }
          return 0; // Should not happen
        })
        .where((id) => id != 0)
        .toList();
  }

  Future<void> updateRolePermissions(
      int roleId, List<int> newFunctionIds) async {
    // 1. Get current permissions
    List<int> currentFunctionIds = await getRolePermissions(roleId);

    // 2. Identify Additions
    List<int> toAdd =
        newFunctionIds.where((id) => !currentFunctionIds.contains(id)).toList();

    // 3. Identify Removals
    List<int> toRemove =
        currentFunctionIds.where((id) => !newFunctionIds.contains(id)).toList();

    // 4. Execute Additions (Default to Read/Edit = true)
    for (int functionId in toAdd) {
      await _api.post(_accessEndpoint, {
        'roleId': roleId,
        'functionId': functionId,
        'canRead': true,
        'canEdit': true
      });
    }

    // 5. Execute Removals
    for (int functionId in toRemove) {
      await _api.delete('$_accessEndpoint/$roleId/$functionId');
    }
  }
}
