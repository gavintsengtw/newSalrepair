import 'package:flutter/material.dart';
import '../../models/app_role.dart';
import '../../models/app_function.dart';
import '../../services/role_permission_service.dart';
import '../../services/function_service.dart';

class RolePermissionPage extends StatefulWidget {
  const RolePermissionPage({super.key});

  @override
  State<RolePermissionPage> createState() => _RolePermissionPageState();
}

class _RolePermissionPageState extends State<RolePermissionPage> {
  final RolePermissionService _roleService = RolePermissionService();
  final FunctionService _functionService = FunctionService();

  List<AppRole> _roles = [];
  List<AppFunction> _functions = [];
  AppRole? _selectedRole;
  List<int> _selectedFunctionIds = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final roles = await _roleService.getRoles();
      final functions = await _functionService.getFunctions();
      setState(() {
        _roles = roles;
        _functions = functions;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectRole(AppRole role) async {
    setState(() {
      _selectedRole = role;
      _isLoading = true;
    });
    try {
      final ids = await _roleService.getRolePermissions(role.id);
      setState(() {
        _selectedFunctionIds = ids;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        // Clear selection on error or handle gracefully
        _selectedFunctionIds = [];
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading permissions: $e')));
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _savePermissions() async {
    if (_selectedRole == null) return;
    setState(() => _isSaving = true);
    try {
      await _roleService.updateRolePermissions(
          _selectedRole!.id, _selectedFunctionIds);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permissions saved successfully!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving permissions: $e')));
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _togglePermission(int functionId, bool? value) {
    if (value == true) {
      if (!_selectedFunctionIds.contains(functionId)) {
        setState(() {
          _selectedFunctionIds.add(functionId);
        });
      }
    } else {
      setState(() {
        _selectedFunctionIds.remove(functionId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _roles.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Row(
        children: [
          // Left: Role List (Master)
          Expanded(
            flex: 2,
            child: _buildRoleList(),
          ),
          const VerticalDivider(width: 1),
          // Right: Permission Matrix (Detail)
          Expanded(
            flex: 5,
            child: _buildPermissionDetail(),
          ),
        ],
      ),
      floatingActionButton: _selectedRole != null
          ? FloatingActionButton(
              onPressed: _isSaving ? null : _savePermissions,
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Icon(Icons.save),
            )
          : null,
    );
  }

  Widget _buildRoleList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('角色列表',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: '新增角色',
                onPressed: () => _showRoleDialog(null),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            itemCount: _roles.length,
            separatorBuilder: (ctx, idx) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final role = _roles[index];
              final isSelected = _selectedRole?.id == role.id;
              return ListTile(
                title: Text(role.name),
                subtitle: Text(role.description,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                selected: isSelected,
                selectedTileColor:
                    Theme.of(context).primaryColor.withValues(alpha: 0.1),
                onTap: () => _selectRole(role),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon:
                          const Icon(Icons.edit, size: 20, color: Colors.blue),
                      onPressed: () => _showRoleDialog(role),
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.delete, size: 20, color: Colors.red),
                      onPressed: () => _confirmDeleteRole(role),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionDetail() {
    if (_selectedRole == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.touch_app, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('請從左側選擇一個角色以設定權限',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Text('權限設定: ${_selectedRole!.name}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // Select All Logic
                  setState(() {
                    _addAllRecursive(_functions);
                  });
                },
                child: const Text('全選'),
              ),
              TextButton(
                onPressed: () {
                  // Clear All Logic
                  setState(() {
                    _selectedFunctionIds.clear();
                  });
                },
                child: const Text('全不選'),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _functions.length,
            itemBuilder: (context, index) {
              return _buildPermissionNode(_functions[index]);
            },
          ),
        ),
      ],
    );
  }

  void _addAllRecursive(List<AppFunction> nodes) {
    for (var node in nodes) {
      if (!_selectedFunctionIds.contains(node.id)) {
        _selectedFunctionIds.add(node.id);
      }
      if (node.children.isNotEmpty) {
        _addAllRecursive(node.children);
      }
    }
  }

  Widget _buildPermissionNode(AppFunction function, {int depth = 0}) {
    final isChecked = _selectedFunctionIds.contains(function.id);
    final hasChildren = function.children.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: depth * 24.0),
          child: CheckboxListTile(
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(function.name),
            subtitle: Text(function.code),
            value: isChecked,
            onChanged: (val) {
              _togglePermission(function.id, val);
              // Optional: Auto-select/deselect children logic could go here
            },
          ),
        ),
        if (hasChildren)
          ...function.children
              .map((child) => _buildPermissionNode(child, depth: depth + 1)),
      ],
    );
  }

  // Dialog for Adding or Editing Role
  void _showRoleDialog(AppRole? role) {
    final isEditing = role != null;
    final nameController = TextEditingController(text: role?.name ?? '');
    final descController = TextEditingController(text: role?.description ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? '編輯角色' : '新增角色'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: '角色名稱'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: descController,
              decoration: const InputDecoration(labelText: '描述'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newRole = AppRole(
                id: role?.id ?? 0,
                name: nameController.text,
                description: descController.text,
              );

              try {
                if (isEditing) {
                  await _roleService.updateRole(newRole);
                } else {
                  await _roleService.createRole(newRole);
                }
                if (context.mounted) {
                  Navigator.pop(context);
                  _loadData(); // Refresh list
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isEditing ? '更新成功' : '新增成功')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('儲存'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteRole(AppRole role) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認刪除'),
        content: Text('確定要刪除角色 ${role.name} 嗎？此操作可能影響現有用戶權限。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await _roleService.deleteRole(role.id);
                if (context.mounted) {
                  Navigator.pop(context);
                  // Check if deleted role was selected
                  if (_selectedRole?.id == role.id) {
                    setState(() {
                      _selectedRole = null;
                      _selectedFunctionIds = [];
                    });
                  }
                  _loadData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('刪除成功')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('刪除失敗: $e')),
                  );
                }
              }
            },
            child: const Text('刪除', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
