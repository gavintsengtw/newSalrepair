class AppUser {
  final String id;
  final String name;
  final String email;
  final List<int> roleIds;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.roleIds,
  });
}
