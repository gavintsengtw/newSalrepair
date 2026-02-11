import 'api_service.dart';
import '../models/app_user.dart';

class UserService {
  final ApiService _api = ApiService();
  final String _endpoint = '/api/users';
  final String _userRolesEndpoint = '/api/user-roles';

  Future<List<AppUser>> getUsers() async {
    // Fetch users and all user-roles in parallel
    final results = await Future.wait([
      _api.get(_endpoint),
      _api.get(_userRolesEndpoint),
    ]);

    final usersResponse = results[0];
    final rolesResponse = results[1];

    if (usersResponse == null) {
      return [];
    }

    final List<dynamic> usersData =
        (usersResponse is Map && usersResponse.containsKey('data'))
            ? usersResponse['data']
            : usersResponse;

    final List<dynamic> rolesData =
        (rolesResponse is Map && rolesResponse.containsKey('data'))
            ? rolesResponse['data']
            : rolesResponse ?? [];

    // Create a map of userId -> List<int> roleIds
    Map<String, List<int>> userRolesMap = {};
    for (var ur in rolesData) {
      String? uId;
      int? rId;

      // Check structure: { user: { uid: ... }, role: { roleId: ... } }
      // Assuming User entity in AppUserRole is fully serialized
      if (ur['user'] != null) {
        if (ur['user']['uid'] != null) {
          uId = ur['user']['uid'].toString();
        } else if (ur['user']['id'] != null) {
          uId = ur['user']['id'].toString();
        }
      }

      if (ur['role'] != null) {
        if (ur['role']['roleId'] != null) {
          rId = ur['role']['roleId'] as int;
        } else if (ur['role']['id'] != null) {
          rId = ur['role']['id'] as int;
        }
      }

      if (uId != null && rId != null) {
        if (!userRolesMap.containsKey(uId)) {
          userRolesMap[uId] = [];
        }
        userRolesMap[uId]!.add(rId);
      }
    }

    return usersData.map((json) {
      final userId = (json['uid'] ?? json['id'] ?? '').toString();

      return AppUser(
        id: userId,
        name: json['accountid'] ?? json['username'] ?? '',
        email: json['email'] ??
            '', // Email might be missing in User entity, defaulting to empty
        roleIds: userRolesMap[userId] ?? [],
      );
    }).toList();
  }

  // Helper to fetch roles for a user
  Future<List<int>> getUserRoles(String userId) async {
    final response = await _api.get('$_userRolesEndpoint?userId=$userId');
    if (response == null) {
      return [];
    }

    final List<dynamic> data = (response is Map && response.containsKey('data'))
        ? response['data']
        : response;

    return data
        .map<int>((json) {
          // AppUserRole: { user:..., role: { roleId: ... } }
          if (json['role'] != null && json['role']['roleId'] != null) {
            return json['role']['roleId'] as int;
          }
          return 0;
        })
        .where((id) => id != 0)
        .toList();
  }

  Future<void> updateUserRoles(String userIdStr, List<int> newRoleIds) async {
    // userId is String in AppUser, but Long in backend.
    final userId = int.parse(userIdStr);

    // 1. Get current roles
    List<int> currentRoleIds = await getUserRoles(userIdStr);

    // 2. Identify Additions
    List<int> toAdd =
        newRoleIds.where((id) => !currentRoleIds.contains(id)).toList();

    // 3. Identify Removals
    List<int> toRemove =
        currentRoleIds.where((id) => !newRoleIds.contains(id)).toList();

    // 4. Execute Additions
    for (int roleId in toAdd) {
      await _api.post(_userRolesEndpoint, {'userId': userId, 'roleId': roleId});
    }

    // 5. Execute Removals
    for (int roleId in toRemove) {
      await _api.delete('$_userRolesEndpoint/$userId/$roleId');
    }
  }

  // Batch update users' roles (Overwrite)
  Future<void> updateUsersRoles(
      List<String> userIds, List<int> newRoleIds) async {
    // Execute updates in parallel
    await Future.wait(
      userIds.map((uid) => updateUserRoles(uid, newRoleIds)),
    );
  }
}
