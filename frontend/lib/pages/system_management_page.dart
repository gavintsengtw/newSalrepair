import 'package:flutter/material.dart';
import 'system/function_management_page.dart';
import 'system/role_permission_page.dart';
import 'system/user_management_page.dart';

class SystemManagementPage extends StatefulWidget {
  final int initialIndex;
  const SystemManagementPage({super.key, this.initialIndex = 0});

  @override
  State<SystemManagementPage> createState() => _SystemManagementPageState();
}

class _SystemManagementPageState extends State<SystemManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 3, vsync: this, initialIndex: widget.initialIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('系統管理'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '選單維護', icon: Icon(Icons.menu)),
            Tab(text: '角色權限', icon: Icon(Icons.admin_panel_settings)),
            Tab(text: '用戶管理', icon: Icon(Icons.people)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          FunctionManagementPage(),
          RolePermissionPage(),
          UserManagementPage(),
        ],
      ),
    );
  }
}
