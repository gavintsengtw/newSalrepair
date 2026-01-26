import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Responsive Navigation Rail for larger screens
          if (MediaQuery.of(context).size.width > 800)
            NavigationRail(
              selectedIndex: 0,
              onDestinationSelected: (int index) {},
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: Text('Dashboard'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.build_outlined),
                  selectedIcon: Icon(Icons.build),
                  label: Text('Repairs'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: Text('Profile'),
                ),
              ],
            ),

          // Main Content Area
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverAppBar.large(
                  title: const Text('Dashboard')
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideX(begin: -0.2, end: 0),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 16),
                    const CircleAvatar(
                      backgroundImage:
                          NetworkImage('https://i.pravatar.cc/150?img=12'),
                    ),
                    const SizedBox(width: 24),
                  ],
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(24),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 300,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.2,
                    ),
                    delegate: SliverChildListDelegate([
                      _buildDashboardCard(
                        context,
                        'Active Repairs',
                        '3',
                        Icons.handyman,
                        Colors.orange,
                      ),
                      _buildDashboardCard(
                        context,
                        'Pending Approval',
                        '1',
                        Icons.pending_actions,
                        Colors.blue,
                      ),
                      _buildDashboardCard(
                        context,
                        'Completed',
                        '12',
                        Icons.check_circle_outline,
                        Colors.green,
                      ),
                      _buildDashboardCard(
                        context,
                        'Total Cost',
                        '\$4,250',
                        Icons.attach_money,
                        Colors.purple,
                      ),
                    ]),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recent Activity',
                          style: Theme.of(context).textTheme.titleLarge,
                        ).animate().fadeIn().slideY(begin: 0.2, end: 0),
                        const SizedBox(height: 16),
                        _buildRecentActivityItem(
                            context, 'Leak Repair', 'Kitchen', '2 hours ago'),
                        _buildRecentActivityItem(
                            context, 'Paint Job', 'Living Room', 'Yesterday'),
                        _buildRecentActivityItem(
                            context, 'Electric Wiring', 'Garage', '2 days ago'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: MediaQuery.of(context).size.width <= 800
          ? NavigationBar(
              selectedIndex: 0,
              onDestinationSelected: (index) {},
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.build_outlined),
                  selectedIcon: Icon(Icons.build),
                  label: 'Repairs',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildDashboardCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    return Card(
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack);
  }

  Widget _buildRecentActivityItem(
      BuildContext context, String title, String subtitle, String time) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(Icons.history,
              color: Theme.of(context).colorScheme.onPrimaryContainer),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: Text(time, style: Theme.of(context).textTheme.bodySmall),
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }
}
