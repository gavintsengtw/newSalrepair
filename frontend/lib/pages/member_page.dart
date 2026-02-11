import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../helpers/icon_mapper.dart';

class MemberPage extends StatefulWidget {
  const MemberPage({super.key});

  @override
  State<MemberPage> createState() => _MemberPageState();
}

class _MemberPageState extends State<MemberPage> {
  @override
  Widget build(BuildContext context) {
    // 監聽 isDefaultPassword 狀態
    final isDefaultPassword =
        context.select<UserProvider, bool>((p) => p.isDefaultPassword);

    return Scaffold(
      appBar: AppBar(
        title: const Text('會員中心'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<UserProvider>().logout();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isDefaultPassword)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.amber),
                    SizedBox(width: 12),
                    Expanded(child: Text('您的密碼為預設密碼，為了帳戶安全，請立即變更密碼。')),
                  ],
                ),
              ),
            Expanded(
              child: Builder(builder: (context) {
                final menus = context.watch<UserProvider>().menus;
                // Find Member Center menu (FunctionID 5)
                // Use 'MEMBER' code or route '/member'
                final memberMenu = menus.firstWhere(
                    (m) => m['code'] == 'MEMBER' || m['route'] == '/member',
                    orElse: () => null);

                if (memberMenu == null ||
                    memberMenu['children'] == null ||
                    (memberMenu['children'] as List).isEmpty) {
                  return const Center(child: Text('無可用功能'));
                }

                final children = memberMenu['children'] as List;

                return LayoutBuilder(
                  builder: (context, constraints) {
                    // Adjust grid columns based on width
                    // Minimum width per item: 150
                    final availableWidth = constraints.maxWidth;
                    int crossAxisCount = (availableWidth / 160).floor();
                    if (crossAxisCount < 2) {
                      crossAxisCount = 2; // Min 2 columns usually
                    }
                    if (crossAxisCount > 4) {
                      crossAxisCount = 4; // Max 4 columns
                    }

                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.3, // Rectangular (Wider ratio)
                      ),
                      itemCount: children.length,
                      itemBuilder: (context, index) {
                        final child = children[index];
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          child: InkWell(
                            onTap: () => _handleSubMenuClick(context, child),
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(IconMapper.getIcon(child['icon']),
                                      size: 40,
                                      color: Theme.of(context).primaryColor),
                                  const SizedBox(height: 12),
                                  Text(
                                    child['name'],
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/privacy');
                },
                child:
                    const Text('隱私權政策', style: TextStyle(color: Colors.grey)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubMenuClick(BuildContext context, dynamic menu) {
    final route = menu['route'];
    final code = menu['code'];

    if (code == 'LOGOUT') {
      context.read<UserProvider>().logout();
      return;
    }

    // Dynamic routing
    if (route != null && route.isNotEmpty) {
      // 嘗試跳轉
      try {
        Navigator.pushNamed(context, route);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('無法前往功能: ${menu['name']} (路由: $route)')));
      }
      return;
    }

    // Fallback for missing route
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('功能: ${menu['name']} (無路由設定)')));
  }
}
