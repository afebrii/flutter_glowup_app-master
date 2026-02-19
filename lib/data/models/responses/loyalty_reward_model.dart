import 'service_model.dart';
import 'product_model.dart';

/// Model for loyalty rewards that can be redeemed
class LoyaltyRewardModel {
  final int id;
  final String name;
  final String? description;
  final int pointsRequired;
  final String rewardType;
  final String rewardTypeLabel;
  final double rewardValue;
  final String formattedRewardValue;
  final int? serviceId;
  final int? productId;
  final int? stock;
  final int? maxPerCustomer;
  final DateTime? validFrom;
  final DateTime? validUntil;
  final bool isActive;
  final bool isAvailable;
  final ServiceModel? service;
  final ProductModel? product;

  LoyaltyRewardModel({
    required this.id,
    required this.name,
    this.description,
    required this.pointsRequired,
    required this.rewardType,
    required this.rewardTypeLabel,
    required this.rewardValue,
    required this.formattedRewardValue,
    this.serviceId,
    this.productId,
    this.stock,
    this.maxPerCustomer,
    this.validFrom,
    this.validUntil,
    required this.isActive,
    required this.isAvailable,
    this.service,
    this.product,
  });

  factory LoyaltyRewardModel.fromJson(Map<String, dynamic> json) {
    return LoyaltyRewardModel(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      pointsRequired: json['points_required'] ?? 0,
      rewardType: json['reward_type'] ?? '',
      rewardTypeLabel: json['reward_type_label'] ?? '',
      rewardValue: (json['reward_value'] ?? 0).toDouble(),
      formattedRewardValue: json['formatted_reward_value'] ?? '',
      serviceId: json['service_id'],
      productId: json['product_id'],
      stock: json['stock'],
      maxPerCustomer: json['max_per_customer'],
      validFrom: json['valid_from'] != null
          ? DateTime.parse(json['valid_from'])
          : null,
      validUntil: json['valid_until'] != null
          ? DateTime.parse(json['valid_until'])
          : null,
      isActive: json['is_active'] ?? false,
      isAvailable: json['is_available'] ?? false,
      service: json['service'] != null
          ? ServiceModel.fromJson(json['service'])
          : null,
      product: json['product'] != null
          ? ProductModel.fromJson(json['product'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'points_required': pointsRequired,
        'reward_type': rewardType,
        'reward_type_label': rewardTypeLabel,
        'reward_value': rewardValue,
        'formatted_reward_value': formattedRewardValue,
        'service_id': serviceId,
        'product_id': productId,
        'stock': stock,
        'max_per_customer': maxPerCustomer,
        'valid_from': validFrom?.toIso8601String(),
        'valid_until': validUntil?.toIso8601String(),
        'is_active': isActive,
        'is_available': isAvailable,
      };

  /// Check if this is a discount type reward
  bool get isDiscountPercent => rewardType == 'discount_percent';
  bool get isDiscountAmount => rewardType == 'discount_amount';
  bool get isFreeService => rewardType == 'free_service';
  bool get isFreeProduct => rewardType == 'free_product';

  /// Check if reward is still valid by date
  bool get isValidByDate {
    final now = DateTime.now();
    if (validFrom != null && now.isBefore(validFrom!)) return false;
    if (validUntil != null && now.isAfter(validUntil!)) return false;
    return true;
  }

  /// Check if reward has stock
  bool get hasStock => stock == null || stock! > 0;

  /// Check if reward can be redeemed
  bool get canRedeem => isActive && isAvailable && isValidByDate && hasStock;
}
