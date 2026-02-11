import 'package:flutter/material.dart';
import '../../models/app_role.dart';
import '../../services/user_service.dart';
import '../../services/role_permission_service.dart';

import '../../models/app_user.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final RolePermissionService _roleService = RolePermissionService();
  final UserService _userService = UserService();

  List<AppUser> _users = [];
  List<AppRole> _allRoles = [];
  bool _isLoading = true;

  // Search & Selection State
  String _searchQuery = '';
  final Set<String> _selectedUserIds = {};
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final roles = await _roleService.getRoles();
      // Delay slightly ensures smoother UI transition if needed, but not strictly necessary
      final users = await _userService.getUsers();

      if (mounted) {
        setState(() {
          _allRoles = roles;
          _users = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error loading data: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  List<AppUser> get _filteredUsers {
    if (_searchQuery.isEmpty) {
      return _users;
    }
    final query = _searchQuery.toLowerCase();
    return _users.where((user) {
      return user.name.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query);
    }).toList();
  }

  void _toggleSelection(String userId) {
    setState(() {
      if (_selectedUserIds.contains(userId)) {
        _selectedUserIds.remove(userId);
      } else {
        _selectedUserIds.add(userId);
      }
      _isSelectionMode = _selectedUserIds.isNotEmpty;
    });
  }

  void _selectAll(bool select) {
    setState(() {
      if (select) {
        _selectedUserIds.addAll(_filteredUsers.map((u) => u.id));
      } else {
        _selectedUserIds.clear();
      }
      _isSelectionMode = _selectedUserIds.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredUsers = _filteredUsers;
    final allSelected = filteredUsers.isNotEmpty &&
        _selectedUserIds.length >= filteredUsers.length &&
        filteredUsers.every((u) => _selectedUserIds.contains(u.id));

    return Scaffold(
      body: Column(
        children: [
          // Toolbar: Search or Batch Actions
          Container(
            padding: const EdgeInsets.all(8.0),
            color: _isSelectionMode
                ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                : null,
            child: Row(
              children: [
                if (_isSelectionMode) ...[
                  Checkbox(
                    value: allSelected,
                    onChanged: (val) => _selectAll(val ?? false),
                  ),
                  Text('已選 ${_selectedUserIds.length} 人'),
                  const Spacer(),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.group_add),
                    label: const Text('批次設定角色'),
                    onPressed: _showBatchRoleAssignDialog,
                  ),
                ] else ...[
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: '搜尋姓名或 Email...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          // User List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                final user = filteredUsers[index];
                final isSelected = _selectedUserIds.contains(user.id);

                // Find role names
                final userRoleNames = user.roleIds.map((id) {
                  final role = _allRoles.firstWhere((r) => r.id == id,
                      orElse: () =>
                          AppRole(id: 0, name: 'Unknown', description: ''));
                  return role.name;
                }).join(', ');

                return Card(
                  color: isSelected
                      ? Theme.of(context).primaryColor.withValues(alpha: 0.05)
                      : null,
                  child: ListTile(
                    leading: Checkbox(
                      value: isSelected,
                      onChanged: (val) => _toggleSelection(user.id),
                    ),
                    title: Text('${user.name} (${user.email})'),
                    subtitle: Text('角色: $userRoleNames'),
                    trailing: _isSelectionMode
                        ? null // Clean look in selection mode
                        : ElevatedButton.icon(
                            icon: const Icon(Icons.edit, size: 16),
                            label: const Text('設定'),
                            onPressed: () => _showRoleAssignDialog(user),
                          ),
                    onTap: () => _toggleSelection(user.id),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showBatchRoleAssignDialog() {
    if (_selectedUserIds.isEmpty) return;

    List<int> selectedRoleIds = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('批次設定 ${_selectedUserIds.length} 位用戶的角色'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('注意：此操作將會覆蓋用戶原本的所有角色。',
                      style: TextStyle(color: Colors.red)),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _allRoles.length,
                      itemBuilder: (context, index) {
                        final role = _allRoles[index];
                        final isChecked = selectedRoleIds.contains(role.id);
                        return CheckboxListTile(
                          title: Text(role.name),
                          value: isChecked,
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                selectedRoleIds.add(role.id);
                              } else {
                                selectedRoleIds.remove(role.id);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    // Call API to update users roles
                    await _userService.updateUsersRoles(
                        _selectedUserIds.toList(), selectedRoleIds);

                    if (context.mounted) {
                      _loadData(); // Reload to refresh list
                      setState(() {
                        _selectedUserIds.clear(); // Clear selection
                        _isSelectionMode = false;
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('批次設定完成')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error batch updating: $e')),
                      );
                    }
                  }
                },
                child: const Text('儲存'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showRoleAssignDialog(AppUser user) {
    // Clone current roles to avoid direct mutation
    List<int> selectedRoleIds = List.from(user.roleIds);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('設定角色 - ${user.name}'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _allRoles.length,
                itemBuilder: (context, index) {
                  final role = _allRoles[index];
                  final isChecked = selectedRoleIds.contains(role.id);
                  return CheckboxListTile(
                    title: Text(role.name),
                    subtitle: Text(role.description),
                    value: isChecked,
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          selectedRoleIds.add(role.id);
                        } else {
                          selectedRoleIds.remove(role.id);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    // Call API to update user roles
                    await _userService.updateUserRoles(
                        user.id, selectedRoleIds);

                    if (context.mounted) {
                      setState(() {
                        // Update local state
                        final index = _users.indexWhere((u) => u.id == user.id);
                        if (index != -1) {
                          _users[index] = AppUser(
                            id: user.id,
                            name: user.name,
                            email: user.email,
                            roleIds: selectedRoleIds,
                          );
                        }
                      });

                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('已更新 ${user.name} 的角色')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Error updating user roles: $e')),
                      );
                    }
                  }
                },
                child: const Text('儲存'),
              ),
            ],
          );
        },
      ),
    );
  }
}
