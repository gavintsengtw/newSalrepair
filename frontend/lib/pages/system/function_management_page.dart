import 'package:flutter/material.dart';
import '../../models/app_function.dart';
import '../../services/function_service.dart';
import '../../helpers/icon_mapper.dart';

class FunctionManagementPage extends StatefulWidget {
  const FunctionManagementPage({super.key});

  @override
  State<FunctionManagementPage> createState() => _FunctionManagementPageState();
}

class _FunctionManagementPageState extends State<FunctionManagementPage> {
  final FunctionService _service = FunctionService();
  List<AppFunction> _functions = [];
  bool _isLoading = true;
  // Set to store expanded node IDs
  final Set<int> _expandedNodes = {};

  @override
  void initState() {
    super.initState();
    _loadFunctions();
  }

  Future<void> _loadFunctions() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.getFunctions();
      setState(() {
        _functions = data;
        _isLoading = false;
        // Auto-expand all for now
        // _expandAll(_functions);
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading functions: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('選單維護'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '新增根功能',
            onPressed: () => _showEditDialog(null),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFunctions,
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _functions.length,
        itemBuilder: (context, index) {
          return _buildFunctionNode(_functions[index]);
        },
      ),
    );
  }

  Widget _buildFunctionNode(AppFunction function, {int depth = 0}) {
    final hasChildren = function.children.isNotEmpty;
    final isExpanded = _expandedNodes.contains(function.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildListTile(function, depth, hasChildren, isExpanded),
        if (hasChildren && isExpanded)
          ...function.children
              .map((child) => _buildFunctionNode(child, depth: depth + 1)),
      ],
    );
  }

  Widget _buildListTile(
      AppFunction function, int depth, bool hasChildren, bool isExpanded) {
    return Card(
      margin: EdgeInsets.only(left: depth * 24.0, bottom: 8, top: 4),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasChildren)
              IconButton(
                icon:
                    Icon(isExpanded ? Icons.expand_more : Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    if (isExpanded) {
                      _expandedNodes.remove(function.id);
                    } else {
                      _expandedNodes.add(function.id);
                    }
                  });
                },
              )
            else
              const SizedBox(width: 48), // Spacing alignment
            Icon(IconMapper.getIcon(function.icon)),
          ],
        ),
        title: Text('${function.name} (${function.code})'),
        subtitle: Text('Route: ${function.route} | Sort: ${function.sort}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.green),
              tooltip: '新增子功能',
              onPressed: () => _showEditDialog(null, parentId: function.id),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              tooltip: '編輯',
              onPressed: () => _showEditDialog(function),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: '刪除',
              onPressed: () => _confirmDelete(function),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(AppFunction? function, {int? parentId}) {
    final isEditing = function != null;
    // Set initial parentId: if editing use existing, else use passed parentId
    int? currentParentId = isEditing ? function.parentId : parentId;

    final nameController = TextEditingController(text: function?.name ?? '');
    final codeController = TextEditingController(text: function?.code ?? '');
    final iconController = TextEditingController(text: function?.icon ?? '');
    final routeController = TextEditingController(text: function?.route ?? '');
    final sortController =
        TextEditingController(text: (function?.sort ?? 0).toString());
    bool status = function?.status ?? true;

    // Flatten functions for dropdown
    final List<AppFunction> flatFunctions = [];
    void flatten(List<AppFunction> list) {
      for (var f in list) {
        flatFunctions.add(f);
        if (f.children.isNotEmpty) flatten(f.children);
      }
    }

    flatten(_functions);

    // Remove self from parent options to avoid cycles if editing
    if (isEditing) {
      flatFunctions.removeWhere((f) => f.id == function.id);
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(isEditing ? '編輯功能' : '新增功能'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int?>(
                    initialValue: currentParentId,
                    decoration: const InputDecoration(labelText: '父層功能'),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('(無 - 根功能)'),
                      ),
                      ...flatFunctions.map((f) => DropdownMenuItem<int?>(
                            value: f.id,
                            child: Text(f.name),
                          )),
                    ],
                    onChanged: (val) {
                      setState(() => currentParentId = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: '名稱'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: codeController,
                    decoration: const InputDecoration(labelText: '代碼 (Code)'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: iconController,
                    decoration: const InputDecoration(
                      labelText: '圖示 (Icon Name)',
                      helperText: 'e.g. construction, person',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: routeController,
                    decoration: const InputDecoration(labelText: '路徑 (Route)'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: sortController,
                    decoration: const InputDecoration(labelText: '排序 (Sort)'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('狀態: '),
                      Switch(
                        value: status,
                        onChanged: (val) {
                          setState(() => status = val);
                        },
                      ),
                      Text(status ? '啟用' : '停用'),
                    ],
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
                  final newFunction = AppFunction(
                    id: function?.id ?? 0, // 0 means new
                    parentId: currentParentId,
                    name: nameController.text,
                    code: codeController.text,
                    icon: iconController.text,
                    route: routeController.text,
                    sort: int.tryParse(sortController.text) ?? 0,
                    status: status,
                  );

                  try {
                    if (isEditing) {
                      await _service.updateFunction(newFunction);
                    } else {
                      await _service.createFunction(newFunction);
                    }

                    if (context.mounted) {
                      Navigator.pop(context);
                      _loadFunctions(); // Refresh list
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
          );
        },
      ),
    );
  }

  void _confirmDelete(AppFunction function) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認刪除'),
        content: Text('確定要刪除 ${function.name} 嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await _service.deleteFunction(function.id);
                if (context.mounted) {
                  Navigator.pop(context);
                  _loadFunctions();
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
