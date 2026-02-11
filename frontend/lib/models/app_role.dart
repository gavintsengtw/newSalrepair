class AppRole {
  final int id;
  final String name;
  final String description;

  AppRole({
    required this.id,
    required this.name,
    required this.description,
  });

  factory AppRole.fromJson(Map<String, dynamic> json) {
    return AppRole(
      id: json['roleId'] ?? json['id'] ?? 0,
      name: json['roleName'] ?? json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roleId': id,
      'roleName': name,
      'description': description,
    };
  }
}
