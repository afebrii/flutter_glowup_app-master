import '../../../core/constants/variables.dart';
import 'service_category_model.dart';

class ServiceModel {
  final int id;
  final int categoryId;
  final String name;
  final String? description;
  final int durationMinutes;
  final int price;
  final String? image;
  final String? imageUrl;
  final bool isActive;
  final ServiceCategoryModel? category;

  ServiceModel({
    required this.id,
    required this.categoryId,
    required this.name,
    this.description,
    this.durationMinutes = 60,
    required this.price,
    this.image,
    this.imageUrl,
    this.isActive = true,
    this.category,
  });

  String get durationFormatted {
    if (durationMinutes >= 60) {
      final hours = durationMinutes ~/ 60;
      final minutes = durationMinutes % 60;
      if (minutes == 0) {
        return '$hours jam';
      }
      return '$hours jam $minutes menit';
    }
    return '$durationMinutes menit';
  }

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      categoryId: json['category_id'] ?? 0,
      name: json['name'],
      description: json['description'],
      durationMinutes: json['duration_minutes'] ?? 60,
      price: (json['price'] ?? 0) is double
          ? (json['price'] as double).toInt()
          : json['price'] ?? 0,
      image: json['image'],
      imageUrl: json['image_url'] ??
          (json['image'] != null
              ? '${Variables.baseUrl}/storage/${json['image']}'
              : null),
      isActive: json['is_active'] ?? true,
      category: json['category'] != null
          ? ServiceCategoryModel.fromJson(json['category'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category_id': categoryId,
        'name': name,
        'description': description,
        'duration_minutes': durationMinutes,
        'price': price,
        'image': image,
        'is_active': isActive,
      };
}
