import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'repair_page.dart';
import 'member_page.dart';
import 'project_selector_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<UserProvider>(
          builder: (context, provider, child) {
            final pjno =
                provider.currentPjno.isNotEmpty ? provider.currentPjno : '選擇案場';
            final unit = provider.currentUnit;
            // 如果都沒選，顯示預設標題 (但照理說會強制選)
            final displayText =
                (provider.currentPjno.isNotEmpty) ? '$pjno $unit' : '豐邑客服系統';

            return GestureDetector(
              onTap: () {
                // 回到選擇頁清空選擇 (或是直接回去讓使用者重選)
                // 這裡選擇直接跳轉ProjectSelectorPage，在裡面選擇後會覆蓋
                provider.clearProjectSelection();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (_) => const ProjectSelectorPage()),
                  (route) => false,
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(displayText, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: '登出',
            onPressed: () async {
              await context.read<UserProvider>().logout();
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '歡迎回來',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ).animate().fadeIn().slideX(begin: -0.1, end: 0),
                  const SizedBox(height: 32),
                  Expanded(
                    child: LayoutBuilder(builder: (context, constraints) {
                      // 取得當前可用寬度
                      final width = constraints.maxWidth;
                      // 設定斷點：寬度 > 800 顯示 4 列，否則顯示 2 列
                      final int crossAxisCount = width > 800 ? 4 : 2;

                      final rolesString = context.watch<UserProvider>().roles;
                      // 解析角色字串為列表，避免字串包含導致的誤判 (如 AFTER_SALES 包含 SALES)
                      final roles =
                          rolesString.split(',').map((e) => e.trim()).toList();

                      return GridView.count(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 24,
                        crossAxisSpacing: 24,
                        childAspectRatio: width > 800 ? 1.2 : 1.0,
                        children: [
                          if (roles.contains('SALES')) ...[
                            _buildMenuButton(
                              context,
                              '工程進度',
                              Icons.construction,
                              Colors.orange,
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        _buildPlaceholderPage('工程進度'),
                                  ),
                                );
                              },
                            ),
                            _buildMenuButton(
                              context,
                              '繳款查詢',
                              Icons.receipt_long,
                              Colors.blue,
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        _buildPlaceholderPage('繳款查詢'),
                                  ),
                                );
                              },
                            ),
                          ],
                          if (roles.contains('AFTER_SALES')) ...[
                            _buildMenuButton(
                              context,
                              '報修服務',
                              Icons.handyman,
                              Colors.green,
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const RepairPage(),
                                  ),
                                );
                              },
                            ),
                          ],
                          if (roles.contains('SALES') ||
                              roles.contains('AFTER_SALES')) ...[
                            _buildMenuButton(
                              context,
                              '會員中心',
                              Icons.person,
                              Colors.purple,
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MemberPage(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderPage(String title) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title - 功能開發中')),
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack);
  }
}
