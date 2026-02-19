class ServiceCategoryModel {
  final int id;
  final String name;
  final String? description;
  final String? icon;
  final int sortOrder;
  final bool isActive;

  ServiceCategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.sortOrder = 0,
    this.isActive = true,
  });

  factory ServiceCategoryModel.fromJson(Map<String, dynamic> json) {
    return ServiceCategoryModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      sortOrder: json['sort_order'] ?? 0,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'icon': icon,
        'sort_order': sortOrder,
        'is_active': isActive,
      };
}
