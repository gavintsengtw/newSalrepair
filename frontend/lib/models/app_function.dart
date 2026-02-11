class AppFunction {
  final int id;
  final int? parentId;
  final String name;
  final String code;
  final String icon;
  final String route;
  final int sort;
  final bool status;
  final List<AppFunction> children;

  AppFunction({
    required this.id,
    this.parentId,
    required this.name,
    required this.code,
    required this.icon,
    required this.route,
    required this.sort,
    required this.status,
    this.children = const [],
  });

  factory AppFunction.fromJson(Map<String, dynamic> json) {
    var childrenJson = json['children'] as List?;
    List<AppFunction> childrenList = childrenJson != null
        ? childrenJson.map((i) => AppFunction.fromJson(i)).toList()
        : [];

    return AppFunction(
      id: json['functionId'] ??
          json['id'] ??
          0, // Fallback to 'id' just in case
      parentId: json['parentId'] ?? json['parent_id'],
      name: json['functionName'] ?? json['name'] ?? '',
      code: json['functionCode'] ?? json['code'] ?? '',
      icon: json['iconKey'] ?? json['icon'] ?? '',
      route: json['routePath'] ?? json['route'] ?? '',
      sort: json['sortOrder'] ?? json['sort'] ?? 0,
      status: json['isActive'] == true ||
          json['status'] == 1 ||
          json['status'] == true,
      children: childrenList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'functionId': id,
      'parentId': parentId,
      'functionName': name,
      'functionCode': code,
      'iconKey': icon,
      'routePath': route,
      'sortOrder': sort,
      'isActive': status,
      'children': children.map((e) => e.toJson()).toList(),
    };
  }
}
