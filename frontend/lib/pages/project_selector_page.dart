import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class ProjectSelectorPage extends StatefulWidget {
  const ProjectSelectorPage({super.key});

  @override
  State<ProjectSelectorPage> createState() => _ProjectSelectorPageState();
}

class _ProjectSelectorPageState extends State<ProjectSelectorPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    final userProvider = context.read<UserProvider>();

    // Fetch if not already fetched
    if (userProvider.projects.isEmpty) {
      await userProvider.fetchUserProjects();
    }

    // If only one project, UserProvider already selected it.
    // However, if we are specifically here, maybe user wants to see it?
    // But if auto-select logic worked, we might have been redirected already.
    // Let's assume this page shows the list regardless.

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      // Auto-redirect if only one project and not explicitly navigating back to selector
      // But for now let's show the list to be safe or if auto-select didn't redirect.
      if (userProvider.projects.length == 1) {
        // Optionally auto-redirect here if not done in Provider
        // userProvider.selectProject(userProvider.projects[0]);
        // Navigator.of(context).pushReplacement(
        //   MaterialPageRoute(builder: (_) => const HomePage()),
        // );
      }
    }
  }

  void _onProjectSelected(Map<String, dynamic> project) {
    context.read<UserProvider>().selectProject(project);
    // AuthCheckWrapper 會自動切換到 HomePage
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final projects = userProvider.projects;

    // Group projects by pjnoid
    final Map<String, List<dynamic>> groupedProjects = {};
    for (var project in projects) {
      final pjno = project['pjnoid'] ?? 'Unknown';
      // Use projectName if available
      final pjnName = project['projectName'];
      final headerTitle = pjnName != null && pjnName.toString().isNotEmpty
          ? '$pjno $pjnName'
          : pjno;

      if (!groupedProjects.containsKey(headerTitle)) {
        groupedProjects[headerTitle] = [];
      }
      groupedProjects[headerTitle]!.add(project);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('請選擇服務社區'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : projects.isEmpty
              ? const Center(child: Text('查無案場資料'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: groupedProjects.length,
                  itemBuilder: (context, index) {
                    final headerTitle = groupedProjects.keys.elementAt(index);
                    final projectList = groupedProjects[headerTitle]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 4.0),
                          child: Text(
                            '社區: $headerTitle',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ),
                        ...projectList.map((project) => Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                title: Text(
                                  '戶別: ${project['unoid'] ?? ''}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                    '${project['buildid'] ?? ''} - ${project['floorid'] ?? ''}'),
                                trailing: const Icon(Icons.arrow_forward_ios,
                                    size: 16),
                                onTap: () => _onProjectSelected(project),
                              ),
                            )),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                ),
    );
  }
}
