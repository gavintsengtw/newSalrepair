class MenuModel {
  final int id;
  final String name;
  final String code;
  final String icon;
  final String route;
  final int order;

  MenuModel({
    required this.id,
    required this.name,
    required this.code,
    required this.icon,
    required this.route,
    required this.order,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      id: json['id'] as int,
      name: json['name'] as String,
      code: json['code'] as String,
      icon: json['icon'] as String,
      route: json['route'] as String,
      order: json['order'] as int,
    );
  }
}
