# Flutter Models - GlowUp API Integration

Dart models untuk semua data types dari API.

## Table of Contents
1. [Base Response Models](#base-response-models)
2. [Auth Models](#auth-models)
3. [Customer Models](#customer-models)
4. [Loyalty Models](#loyalty-models)
5. [Referral Models](#referral-models)
6. [Service Models](#service-models)
7. [Product Models](#product-models)
8. [Appointment Models](#appointment-models)
9. [Treatment Models](#treatment-models)
10. [Package Models](#package-models)
11. [Transaction Models](#transaction-models)
12. [Staff Models](#staff-models)
13. [Settings Models](#settings-models)
14. [Dashboard Models](#dashboard-models)

---

## Base Response Models

```dart
// lib/data/models/responses/api_response.dart

class ApiResponse<T> {
  final T? data;
  final String? message;
  final Map<String, List<String>>? errors;

  ApiResponse({this.data, this.message, this.errors});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse(
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
      message: json['message'],
      errors: json['errors'] != null
          ? Map<String, List<String>>.from(
              json['errors'].map((k, v) => MapEntry(k, List<String>.from(v))))
          : null,
    );
  }
}

class PaginatedResponse<T> {
  final List<T> data;
  final PaginationMeta meta;

  PaginatedResponse({required this.data, required this.meta});

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse(
      data: (json['data'] as List).map((e) => fromJsonT(e)).toList(),
      meta: PaginationMeta.fromJson(json['meta']),
    );
  }
}

class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 15,
      total: json['total'] ?? 0,
    );
  }

  bool get hasMore => currentPage < lastPage;
}
```

---

## Auth Models

```dart
// lib/data/models/responses/user_model.dart

class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final String? avatar;
  final bool isActive;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.avatar,
    required this.isActive,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'],
      avatar: json['avatar'],
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'role': role,
    'avatar': avatar,
    'is_active': isActive,
  };

  bool get isOwner => role == 'owner';
  bool get isAdmin => role == 'admin';
  bool get isBeautician => role == 'beautician';
  bool get hasAdminAccess => isOwner || isAdmin;

  String get roleDisplayName {
    switch (role) {
      case 'owner': return 'Owner';
      case 'admin': return 'Admin';
      case 'beautician': return 'Beautician';
      default: return role;
    }
  }

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }
}

// lib/data/models/responses/auth_response_model.dart

class AuthResponseModel {
  final UserModel user;
  final String token;

  AuthResponseModel({required this.user, required this.token});

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      user: UserModel.fromJson(json['user']),
      token: json['token'],
    );
  }
}
```

---

## Customer Models

```dart
// lib/data/models/responses/customer_model.dart

class CustomerModel {
  final int id;
  final String name;
  final String phone;
  final String? email;
  final DateTime? birthdate;
  final int? age;
  final String? gender;
  final String? address;
  final String? skinType;
  final List<String>? skinConcerns;
  final String? allergies;
  final String? notes;
  final int totalVisits;
  final double totalSpent;
  final String? formattedTotalSpent;
  final DateTime? lastVisit;
  // Loyalty fields
  final int loyaltyPoints;
  final int lifetimePoints;
  final String loyaltyTier;
  final String? loyaltyTierLabel;
  // Referral fields
  final String? referralCode;
  final int? referredById;
  final CustomerModel? referrer;
  final ReferralStats? referralStats;
  final DateTime? createdAt;

  CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.birthdate,
    this.age,
    this.gender,
    this.address,
    this.skinType,
    this.skinConcerns,
    this.allergies,
    this.notes,
    this.totalVisits = 0,
    this.totalSpent = 0,
    this.formattedTotalSpent,
    this.lastVisit,
    this.loyaltyPoints = 0,
    this.lifetimePoints = 0,
    this.loyaltyTier = 'bronze',
    this.loyaltyTierLabel,
    this.referralCode,
    this.referredById,
    this.referrer,
    this.referralStats,
    this.createdAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      birthdate: json['birthdate'] != null
          ? DateTime.parse(json['birthdate'])
          : null,
      age: json['age'],
      gender: json['gender'],
      address: json['address'],
      skinType: json['skin_type'],
      skinConcerns: json['skin_concerns'] != null
          ? List<String>.from(json['skin_concerns'])
          : null,
      allergies: json['allergies'],
      notes: json['notes'],
      totalVisits: json['total_visits'] ?? 0,
      totalSpent: (json['total_spent'] ?? 0).toDouble(),
      formattedTotalSpent: json['formatted_total_spent'],
      lastVisit: json['last_visit'] != null
          ? DateTime.parse(json['last_visit'])
          : null,
      loyaltyPoints: json['loyalty_points'] ?? 0,
      lifetimePoints: json['lifetime_points'] ?? 0,
      loyaltyTier: json['loyalty_tier'] ?? 'bronze',
      loyaltyTierLabel: json['loyalty_tier_label'],
      referralCode: json['referral_code'],
      referredById: json['referred_by_id'],
      referrer: json['referrer'] != null
          ? CustomerModel.fromJson(json['referrer'])
          : null,
      referralStats: json['referral_stats'] != null
          ? ReferralStats.fromJson(json['referral_stats'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
    'email': email,
    'birthdate': birthdate?.toIso8601String().split('T')[0],
    'gender': gender,
    'address': address,
    'skin_type': skinType,
    'skin_concerns': skinConcerns,
    'allergies': allergies,
    'notes': notes,
  };

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }

  String get genderLabel {
    switch (gender) {
      case 'male': return 'Laki-laki';
      case 'female': return 'Perempuan';
      default: return '-';
    }
  }

  String get skinTypeLabel {
    switch (skinType) {
      case 'normal': return 'Normal';
      case 'dry': return 'Kering';
      case 'oily': return 'Berminyak';
      case 'combination': return 'Kombinasi';
      case 'sensitive': return 'Sensitif';
      default: return '-';
    }
  }
}

class ReferralStats {
  final int totalReferrals;
  final int pendingReferrals;
  final int rewardedReferrals;
  final int totalPointsEarned;

  ReferralStats({
    required this.totalReferrals,
    required this.pendingReferrals,
    required this.rewardedReferrals,
    required this.totalPointsEarned,
  });

  factory ReferralStats.fromJson(Map<String, dynamic> json) {
    return ReferralStats(
      totalReferrals: json['total_referrals'] ?? 0,
      pendingReferrals: json['pending_referrals'] ?? 0,
      rewardedReferrals: json['rewarded_referrals'] ?? 0,
      totalPointsEarned: json['total_points_earned'] ?? 0,
    );
  }
}

class CustomerStats {
  final int totalVisits;
  final double totalSpent;
  final int totalPackages;
  final int activePackages;
  final DateTime? lastVisit;

  CustomerStats({
    required this.totalVisits,
    required this.totalSpent,
    required this.totalPackages,
    required this.activePackages,
    this.lastVisit,
  });

  factory CustomerStats.fromJson(Map<String, dynamic> json) {
    return CustomerStats(
      totalVisits: json['total_visits'] ?? 0,
      totalSpent: (json['total_spent'] ?? 0).toDouble(),
      totalPackages: json['total_packages'] ?? 0,
      activePackages: json['active_packages'] ?? 0,
      lastVisit: json['last_visit'] != null
          ? DateTime.parse(json['last_visit'])
          : null,
    );
  }
}
```

---

## Loyalty Models

```dart
// lib/data/models/responses/loyalty_point_model.dart

class LoyaltyPointModel {
  final int id;
  final int customerId;
  final int? transactionId;
  final String type;
  final String typeLabel;
  final int points;
  final int balanceAfter;
  final String? description;
  final DateTime? expiresAt;
  final bool isEarn;
  final bool isRedeem;
  final DateTime? createdAt;

  LoyaltyPointModel({
    required this.id,
    required this.customerId,
    this.transactionId,
    required this.type,
    required this.typeLabel,
    required this.points,
    required this.balanceAfter,
    this.description,
    this.expiresAt,
    required this.isEarn,
    required this.isRedeem,
    this.createdAt,
  });

  factory LoyaltyPointModel.fromJson(Map<String, dynamic> json) {
    return LoyaltyPointModel(
      id: json['id'],
      customerId: json['customer_id'],
      transactionId: json['transaction_id'],
      type: json['type'],
      typeLabel: json['type_label'],
      points: json['points'],
      balanceAfter: json['balance_after'],
      description: json['description'],
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : null,
      isEarn: json['is_earn'] ?? false,
      isRedeem: json['is_redeem'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }
}

// lib/data/models/responses/loyalty_reward_model.dart

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
      name: json['name'],
      description: json['description'],
      pointsRequired: json['points_required'],
      rewardType: json['reward_type'],
      rewardTypeLabel: json['reward_type_label'],
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
}

// lib/data/models/responses/loyalty_redemption_model.dart

class LoyaltyRedemptionModel {
  final int id;
  final int customerId;
  final int loyaltyRewardId;
  final int? transactionId;
  final int pointsUsed;
  final String status;
  final String statusLabel;
  final String code;
  final DateTime? validUntil;
  final DateTime? usedAt;
  final bool isValid;
  final CustomerModel? customer;
  final LoyaltyRewardModel? reward;
  final DateTime? createdAt;

  LoyaltyRedemptionModel({
    required this.id,
    required this.customerId,
    required this.loyaltyRewardId,
    this.transactionId,
    required this.pointsUsed,
    required this.status,
    required this.statusLabel,
    required this.code,
    this.validUntil,
    this.usedAt,
    required this.isValid,
    this.customer,
    this.reward,
    this.createdAt,
  });

  factory LoyaltyRedemptionModel.fromJson(Map<String, dynamic> json) {
    return LoyaltyRedemptionModel(
      id: json['id'],
      customerId: json['customer_id'],
      loyaltyRewardId: json['loyalty_reward_id'],
      transactionId: json['transaction_id'],
      pointsUsed: json['points_used'],
      status: json['status'],
      statusLabel: json['status_label'],
      code: json['code'],
      validUntil: json['valid_until'] != null
          ? DateTime.parse(json['valid_until'])
          : null,
      usedAt: json['used_at'] != null
          ? DateTime.parse(json['used_at'])
          : null,
      isValid: json['is_valid'] ?? false,
      customer: json['customer'] != null
          ? CustomerModel.fromJson(json['customer'])
          : null,
      reward: json['reward'] != null
          ? LoyaltyRewardModel.fromJson(json['reward'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }
}

class LoyaltySummary {
  final int currentPoints;
  final int lifetimePoints;
  final String tier;
  final String tierLabel;
  final int totalEarned;
  final int totalRedeemed;
  final int pendingRedemptions;

  LoyaltySummary({
    required this.currentPoints,
    required this.lifetimePoints,
    required this.tier,
    required this.tierLabel,
    required this.totalEarned,
    required this.totalRedeemed,
    required this.pendingRedemptions,
  });

  factory LoyaltySummary.fromJson(Map<String, dynamic> json) {
    return LoyaltySummary(
      currentPoints: json['current_points'] ?? 0,
      lifetimePoints: json['lifetime_points'] ?? 0,
      tier: json['tier'] ?? 'bronze',
      tierLabel: json['tier_label'] ?? 'Bronze',
      totalEarned: json['total_earned'] ?? 0,
      totalRedeemed: json['total_redeemed'] ?? 0,
      pendingRedemptions: json['pending_redemptions'] ?? 0,
    );
  }
}
```

---

## Referral Models

```dart
// lib/data/models/responses/referral_log_model.dart

class ReferralLogModel {
  final int id;
  final int referrerId;
  final int refereeId;
  final int referrerPoints;
  final int refereePoints;
  final int? transactionId;
  final String status;
  final String statusLabel;
  final DateTime? rewardedAt;
  final CustomerModel? referrer;
  final CustomerModel? referee;
  final DateTime? createdAt;

  ReferralLogModel({
    required this.id,
    required this.referrerId,
    required this.refereeId,
    required this.referrerPoints,
    required this.refereePoints,
    this.transactionId,
    required this.status,
    required this.statusLabel,
    this.rewardedAt,
    this.referrer,
    this.referee,
    this.createdAt,
  });

  factory ReferralLogModel.fromJson(Map<String, dynamic> json) {
    return ReferralLogModel(
      id: json['id'],
      referrerId: json['referrer_id'],
      refereeId: json['referee_id'],
      referrerPoints: json['referrer_points'] ?? 0,
      refereePoints: json['referee_points'] ?? 0,
      transactionId: json['transaction_id'],
      status: json['status'],
      statusLabel: json['status_label'],
      rewardedAt: json['rewarded_at'] != null
          ? DateTime.parse(json['rewarded_at'])
          : null,
      referrer: json['referrer'] != null
          ? CustomerModel.fromJson(json['referrer'])
          : null,
      referee: json['referee'] != null
          ? CustomerModel.fromJson(json['referee'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }
}

class ReferralInfo {
  final String referralCode;
  final String referralLink;
  final ReferralStats stats;
  final CustomerModel? referrer;

  ReferralInfo({
    required this.referralCode,
    required this.referralLink,
    required this.stats,
    this.referrer,
  });

  factory ReferralInfo.fromJson(Map<String, dynamic> json) {
    return ReferralInfo(
      referralCode: json['referral_code'] ?? '',
      referralLink: json['referral_link'] ?? '',
      stats: ReferralStats.fromJson(json['stats'] ?? {}),
      referrer: json['referrer'] != null
          ? CustomerModel.fromJson(json['referrer'])
          : null,
    );
  }
}

class ReferralProgramInfo {
  final int referrerPoints;
  final int refereePoints;
  final String codePrefix;
  final List<String> terms;

  ReferralProgramInfo({
    required this.referrerPoints,
    required this.refereePoints,
    required this.codePrefix,
    required this.terms,
  });

  factory ReferralProgramInfo.fromJson(Map<String, dynamic> json) {
    return ReferralProgramInfo(
      referrerPoints: json['referrer_points'] ?? 0,
      refereePoints: json['referee_points'] ?? 0,
      codePrefix: json['code_prefix'] ?? 'REF',
      terms: json['terms'] != null
          ? List<String>.from(json['terms'])
          : [],
    );
  }
}
```

---

## Service Models

```dart
// lib/data/models/responses/service_category_model.dart

class ServiceCategoryModel {
  final int id;
  final String name;
  final String? description;
  final String? icon;
  final int sortOrder;
  final bool isActive;
  final int? servicesCount;
  final List<ServiceModel>? services;

  ServiceCategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    required this.sortOrder,
    required this.isActive,
    this.servicesCount,
    this.services,
  });

  factory ServiceCategoryModel.fromJson(Map<String, dynamic> json) {
    return ServiceCategoryModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      sortOrder: json['sort_order'] ?? 0,
      isActive: json['is_active'] ?? true,
      servicesCount: json['services_count'],
      services: json['services'] != null
          ? (json['services'] as List)
              .map((e) => ServiceModel.fromJson(e))
              .toList()
          : null,
    );
  }
}

// lib/data/models/responses/service_model.dart

class ServiceModel {
  final int id;
  final int categoryId;
  final String name;
  final String? description;
  final int durationMinutes;
  final double price;
  final String? formattedPrice;
  final String? image;
  final String? imageUrl;
  final bool isActive;
  final ServiceCategoryModel? category;

  ServiceModel({
    required this.id,
    required this.categoryId,
    required this.name,
    this.description,
    required this.durationMinutes,
    required this.price,
    this.formattedPrice,
    this.image,
    this.imageUrl,
    required this.isActive,
    this.category,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      categoryId: json['category_id'],
      name: json['name'],
      description: json['description'],
      durationMinutes: json['duration_minutes'] ?? 60,
      price: (json['price'] ?? 0).toDouble(),
      formattedPrice: json['formatted_price'],
      image: json['image'],
      imageUrl: json['image_url'],
      isActive: json['is_active'] ?? true,
      category: json['category'] != null
          ? ServiceCategoryModel.fromJson(json['category'])
          : null,
    );
  }

  String get durationFormatted {
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    if (hours > 0 && minutes > 0) {
      return '$hours jam $minutes menit';
    } else if (hours > 0) {
      return '$hours jam';
    } else {
      return '$minutes menit';
    }
  }
}
```

---

## Product Models

```dart
// lib/data/models/responses/product_category_model.dart

class ProductCategoryModel {
  final int id;
  final String name;
  final String? description;
  final int sortOrder;
  final bool isActive;
  final int? productsCount;
  final List<ProductModel>? products;

  ProductCategoryModel({
    required this.id,
    required this.name,
    this.description,
    required this.sortOrder,
    required this.isActive,
    this.productsCount,
    this.products,
  });

  factory ProductCategoryModel.fromJson(Map<String, dynamic> json) {
    return ProductCategoryModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      sortOrder: json['sort_order'] ?? 0,
      isActive: json['is_active'] ?? true,
      productsCount: json['products_count'],
      products: json['products'] != null
          ? (json['products'] as List)
              .map((e) => ProductModel.fromJson(e))
              .toList()
          : null,
    );
  }
}

// lib/data/models/responses/product_model.dart

class ProductModel {
  final int id;
  final int categoryId;
  final String name;
  final String? sku;
  final String? description;
  final double price;
  final String? formattedPrice;
  final double? costPrice;
  final String? formattedCostPrice;
  final int stock;
  final int minStock;
  final String? unit;
  final String? image;
  final String? imageUrl;
  final bool isActive;
  final bool trackStock;
  final bool isLowStock;
  final bool isOutOfStock;
  final ProductCategoryModel? category;

  ProductModel({
    required this.id,
    required this.categoryId,
    required this.name,
    this.sku,
    this.description,
    required this.price,
    this.formattedPrice,
    this.costPrice,
    this.formattedCostPrice,
    required this.stock,
    required this.minStock,
    this.unit,
    this.image,
    this.imageUrl,
    required this.isActive,
    required this.trackStock,
    required this.isLowStock,
    required this.isOutOfStock,
    this.category,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      categoryId: json['category_id'],
      name: json['name'],
      sku: json['sku'],
      description: json['description'],
      price: (json['price'] ?? 0).toDouble(),
      formattedPrice: json['formatted_price'],
      costPrice: json['cost_price']?.toDouble(),
      formattedCostPrice: json['formatted_cost_price'],
      stock: json['stock'] ?? 0,
      minStock: json['min_stock'] ?? 0,
      unit: json['unit'],
      image: json['image'],
      imageUrl: json['image_url'],
      isActive: json['is_active'] ?? true,
      trackStock: json['track_stock'] ?? false,
      isLowStock: json['is_low_stock'] ?? false,
      isOutOfStock: json['is_out_of_stock'] ?? false,
      category: json['category'] != null
          ? ProductCategoryModel.fromJson(json['category'])
          : null,
    );
  }
}
```

---

## Appointment Models

```dart
// lib/data/models/responses/appointment_model.dart

enum AppointmentStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled,
  noShow;

  static AppointmentStatus fromString(String value) {
    switch (value) {
      case 'pending': return AppointmentStatus.pending;
      case 'confirmed': return AppointmentStatus.confirmed;
      case 'in_progress': return AppointmentStatus.inProgress;
      case 'completed': return AppointmentStatus.completed;
      case 'cancelled': return AppointmentStatus.cancelled;
      case 'no_show': return AppointmentStatus.noShow;
      default: return AppointmentStatus.pending;
    }
  }

  String get value {
    switch (this) {
      case AppointmentStatus.pending: return 'pending';
      case AppointmentStatus.confirmed: return 'confirmed';
      case AppointmentStatus.inProgress: return 'in_progress';
      case AppointmentStatus.completed: return 'completed';
      case AppointmentStatus.cancelled: return 'cancelled';
      case AppointmentStatus.noShow: return 'no_show';
    }
  }
}

enum AppointmentSource {
  walkIn,
  phone,
  whatsapp,
  online;

  static AppointmentSource fromString(String value) {
    switch (value) {
      case 'walk_in': return AppointmentSource.walkIn;
      case 'phone': return AppointmentSource.phone;
      case 'whatsapp': return AppointmentSource.whatsapp;
      case 'online': return AppointmentSource.online;
      default: return AppointmentSource.walkIn;
    }
  }

  String get value {
    switch (this) {
      case AppointmentSource.walkIn: return 'walk_in';
      case AppointmentSource.phone: return 'phone';
      case AppointmentSource.whatsapp: return 'whatsapp';
      case AppointmentSource.online: return 'online';
    }
  }
}

class AppointmentModel {
  final int id;
  final int customerId;
  final int serviceId;
  final int? staffId;
  final int? customerPackageId;
  final DateTime appointmentDate;
  final String startTime;
  final String endTime;
  final AppointmentStatus status;
  final String? statusLabel;
  final String? statusColor;
  final AppointmentSource source;
  final String? sourceLabel;
  final String? notes;
  final DateTime? cancelledAt;
  final String? cancelledReason;
  final CustomerModel? customer;
  final ServiceModel? service;
  final UserModel? staff;
  final TreatmentRecordModel? treatmentRecord;
  final DateTime? createdAt;

  AppointmentModel({
    required this.id,
    required this.customerId,
    required this.serviceId,
    this.staffId,
    this.customerPackageId,
    required this.appointmentDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.statusLabel,
    this.statusColor,
    required this.source,
    this.sourceLabel,
    this.notes,
    this.cancelledAt,
    this.cancelledReason,
    this.customer,
    this.service,
    this.staff,
    this.treatmentRecord,
    this.createdAt,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'],
      customerId: json['customer_id'],
      serviceId: json['service_id'],
      staffId: json['staff_id'],
      customerPackageId: json['customer_package_id'],
      appointmentDate: DateTime.parse(json['appointment_date']),
      startTime: json['start_time'],
      endTime: json['end_time'],
      status: AppointmentStatus.fromString(json['status']),
      statusLabel: json['status_label'],
      statusColor: json['status_color'],
      source: AppointmentSource.fromString(json['source'] ?? 'walk_in'),
      sourceLabel: json['source_label'],
      notes: json['notes'],
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'])
          : null,
      cancelledReason: json['cancelled_reason'],
      customer: json['customer'] != null
          ? CustomerModel.fromJson(json['customer'])
          : null,
      service: json['service'] != null
          ? ServiceModel.fromJson(json['service'])
          : null,
      staff: json['staff'] != null
          ? UserModel.fromJson(json['staff'])
          : null,
      treatmentRecord: json['treatment_record'] != null
          ? TreatmentRecordModel.fromJson(json['treatment_record'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  String get timeRange => '$startTime - $endTime';

  bool get isToday {
    final now = DateTime.now();
    return appointmentDate.year == now.year &&
        appointmentDate.month == now.month &&
        appointmentDate.day == now.day;
  }

  bool get isPast {
    return appointmentDate.isBefore(DateTime.now());
  }

  bool get canCancel {
    return status == AppointmentStatus.pending ||
        status == AppointmentStatus.confirmed;
  }

  bool get canStart {
    return status == AppointmentStatus.confirmed;
  }

  bool get canComplete {
    return status == AppointmentStatus.inProgress;
  }
}

class TimeSlot {
  final String time;
  final bool isAvailable;

  TimeSlot({required this.time, required this.isAvailable});

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      time: json['time'],
      isAvailable: json['is_available'] ?? false,
    );
  }
}
```

---

## Treatment Models

```dart
// lib/data/models/responses/treatment_record_model.dart

class TreatmentRecordModel {
  final int id;
  final int appointmentId;
  final int customerId;
  final int staffId;
  final String? notes;
  final List<String>? beforePhotos;
  final List<String>? beforePhotoUrls;
  final List<String>? afterPhotos;
  final List<String>? afterPhotoUrls;
  final String? recommendations;
  final DateTime? followUpDate;
  final AppointmentModel? appointment;
  final CustomerModel? customer;
  final UserModel? staff;
  final DateTime? createdAt;

  TreatmentRecordModel({
    required this.id,
    required this.appointmentId,
    required this.customerId,
    required this.staffId,
    this.notes,
    this.beforePhotos,
    this.beforePhotoUrls,
    this.afterPhotos,
    this.afterPhotoUrls,
    this.recommendations,
    this.followUpDate,
    this.appointment,
    this.customer,
    this.staff,
    this.createdAt,
  });

  factory TreatmentRecordModel.fromJson(Map<String, dynamic> json) {
    return TreatmentRecordModel(
      id: json['id'],
      appointmentId: json['appointment_id'],
      customerId: json['customer_id'],
      staffId: json['staff_id'],
      notes: json['notes'],
      beforePhotos: json['before_photos'] != null
          ? List<String>.from(json['before_photos'])
          : null,
      beforePhotoUrls: json['before_photo_urls'] != null
          ? List<String>.from(json['before_photo_urls'])
          : null,
      afterPhotos: json['after_photos'] != null
          ? List<String>.from(json['after_photos'])
          : null,
      afterPhotoUrls: json['after_photo_urls'] != null
          ? List<String>.from(json['after_photo_urls'])
          : null,
      recommendations: json['recommendations'],
      followUpDate: json['follow_up_date'] != null
          ? DateTime.parse(json['follow_up_date'])
          : null,
      appointment: json['appointment'] != null
          ? AppointmentModel.fromJson(json['appointment'])
          : null,
      customer: json['customer'] != null
          ? CustomerModel.fromJson(json['customer'])
          : null,
      staff: json['staff'] != null
          ? UserModel.fromJson(json['staff'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  bool get hasBeforePhotos =>
      beforePhotoUrls != null && beforePhotoUrls!.isNotEmpty;

  bool get hasAfterPhotos =>
      afterPhotoUrls != null && afterPhotoUrls!.isNotEmpty;
}
```

---

## Package Models

```dart
// lib/data/models/responses/package_model.dart

class PackageModel {
  final int id;
  final String name;
  final String? description;
  final int? serviceId;
  final int totalSessions;
  final double originalPrice;
  final String? formattedOriginalPrice;
  final double packagePrice;
  final String? formattedPackagePrice;
  final double? discountPercentage;
  final double? savings;
  final String? formattedSavings;
  final double? pricePerSession;
  final String? formattedPricePerSession;
  final int validityDays;
  final bool isActive;
  final ServiceModel? service;

  PackageModel({
    required this.id,
    required this.name,
    this.description,
    this.serviceId,
    required this.totalSessions,
    required this.originalPrice,
    this.formattedOriginalPrice,
    required this.packagePrice,
    this.formattedPackagePrice,
    this.discountPercentage,
    this.savings,
    this.formattedSavings,
    this.pricePerSession,
    this.formattedPricePerSession,
    required this.validityDays,
    required this.isActive,
    this.service,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      serviceId: json['service_id'],
      totalSessions: json['total_sessions'] ?? 1,
      originalPrice: (json['original_price'] ?? 0).toDouble(),
      formattedOriginalPrice: json['formatted_original_price'],
      packagePrice: (json['package_price'] ?? 0).toDouble(),
      formattedPackagePrice: json['formatted_package_price'],
      discountPercentage: json['discount_percentage']?.toDouble(),
      savings: json['savings']?.toDouble(),
      formattedSavings: json['formatted_savings'],
      pricePerSession: json['price_per_session']?.toDouble(),
      formattedPricePerSession: json['formatted_price_per_session'],
      validityDays: json['validity_days'] ?? 30,
      isActive: json['is_active'] ?? true,
      service: json['service'] != null
          ? ServiceModel.fromJson(json['service'])
          : null,
    );
  }
}

// lib/data/models/responses/customer_package_model.dart

class CustomerPackageModel {
  final int id;
  final int customerId;
  final int packageId;
  final int? soldBy;
  final double pricePaid;
  final String? formattedPricePaid;
  final int sessionsTotal;
  final int sessionsUsed;
  final int sessionsRemaining;
  final double? usagePercentage;
  final DateTime purchasedAt;
  final DateTime? expiresAt;
  final int? daysRemaining;
  final bool isExpired;
  final bool isUsable;
  final String status;
  final String? statusLabel;
  final String? notes;
  final CustomerModel? customer;
  final PackageModel? package;
  final UserModel? seller;

  CustomerPackageModel({
    required this.id,
    required this.customerId,
    required this.packageId,
    this.soldBy,
    required this.pricePaid,
    this.formattedPricePaid,
    required this.sessionsTotal,
    required this.sessionsUsed,
    required this.sessionsRemaining,
    this.usagePercentage,
    required this.purchasedAt,
    this.expiresAt,
    this.daysRemaining,
    required this.isExpired,
    required this.isUsable,
    required this.status,
    this.statusLabel,
    this.notes,
    this.customer,
    this.package,
    this.seller,
  });

  factory CustomerPackageModel.fromJson(Map<String, dynamic> json) {
    return CustomerPackageModel(
      id: json['id'],
      customerId: json['customer_id'],
      packageId: json['package_id'],
      soldBy: json['sold_by'],
      pricePaid: (json['price_paid'] ?? 0).toDouble(),
      formattedPricePaid: json['formatted_price_paid'],
      sessionsTotal: json['sessions_total'] ?? 0,
      sessionsUsed: json['sessions_used'] ?? 0,
      sessionsRemaining: json['sessions_remaining'] ?? 0,
      usagePercentage: json['usage_percentage']?.toDouble(),
      purchasedAt: DateTime.parse(json['purchased_at']),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : null,
      daysRemaining: json['days_remaining'],
      isExpired: json['is_expired'] ?? false,
      isUsable: json['is_usable'] ?? false,
      status: json['status'] ?? 'active',
      statusLabel: json['status_label'],
      notes: json['notes'],
      customer: json['customer'] != null
          ? CustomerModel.fromJson(json['customer'])
          : null,
      package: json['package'] != null
          ? PackageModel.fromJson(json['package'])
          : null,
      seller: json['seller'] != null
          ? UserModel.fromJson(json['seller'])
          : null,
    );
  }
}
```

---

## Transaction Models

```dart
// lib/data/models/responses/transaction_model.dart

class TransactionModel {
  final int id;
  final String invoiceNumber;
  final int customerId;
  final int? appointmentId;
  final int? cashierId;
  final double subtotal;
  final String? formattedSubtotal;
  final double discountAmount;
  final String? formattedDiscountAmount;
  final String? discountType;
  final int? pointsUsed;
  final double? pointsDiscount;
  final double taxAmount;
  final double totalAmount;
  final String? formattedTotalAmount;
  final double paidAmount;
  final String? formattedPaidAmount;
  final double? changeAmount;
  final double? outstandingAmount;
  final String? formattedOutstandingAmount;
  final String status;
  final String? statusLabel;
  final bool isPaid;
  final String? notes;
  final DateTime? paidAt;
  final CustomerModel? customer;
  final AppointmentModel? appointment;
  final UserModel? cashier;
  final List<TransactionItemModel>? items;
  final List<PaymentModel>? payments;
  final DateTime? createdAt;

  TransactionModel({
    required this.id,
    required this.invoiceNumber,
    required this.customerId,
    this.appointmentId,
    this.cashierId,
    required this.subtotal,
    this.formattedSubtotal,
    required this.discountAmount,
    this.formattedDiscountAmount,
    this.discountType,
    this.pointsUsed,
    this.pointsDiscount,
    required this.taxAmount,
    required this.totalAmount,
    this.formattedTotalAmount,
    required this.paidAmount,
    this.formattedPaidAmount,
    this.changeAmount,
    this.outstandingAmount,
    this.formattedOutstandingAmount,
    required this.status,
    this.statusLabel,
    required this.isPaid,
    this.notes,
    this.paidAt,
    this.customer,
    this.appointment,
    this.cashier,
    this.items,
    this.payments,
    this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      invoiceNumber: json['invoice_number'],
      customerId: json['customer_id'],
      appointmentId: json['appointment_id'],
      cashierId: json['cashier_id'],
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      formattedSubtotal: json['formatted_subtotal'],
      discountAmount: (json['discount_amount'] ?? 0).toDouble(),
      formattedDiscountAmount: json['formatted_discount_amount'],
      discountType: json['discount_type'],
      pointsUsed: json['points_used'],
      pointsDiscount: json['points_discount']?.toDouble(),
      taxAmount: (json['tax_amount'] ?? 0).toDouble(),
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      formattedTotalAmount: json['formatted_total_amount'],
      paidAmount: (json['paid_amount'] ?? 0).toDouble(),
      formattedPaidAmount: json['formatted_paid_amount'],
      changeAmount: json['change_amount']?.toDouble(),
      outstandingAmount: json['outstanding_amount']?.toDouble(),
      formattedOutstandingAmount: json['formatted_outstanding_amount'],
      status: json['status'] ?? 'pending',
      statusLabel: json['status_label'],
      isPaid: json['is_paid'] ?? false,
      notes: json['notes'],
      paidAt: json['paid_at'] != null
          ? DateTime.parse(json['paid_at'])
          : null,
      customer: json['customer'] != null
          ? CustomerModel.fromJson(json['customer'])
          : null,
      appointment: json['appointment'] != null
          ? AppointmentModel.fromJson(json['appointment'])
          : null,
      cashier: json['cashier'] != null
          ? UserModel.fromJson(json['cashier'])
          : null,
      items: json['items'] != null
          ? (json['items'] as List)
              .map((e) => TransactionItemModel.fromJson(e))
              .toList()
          : null,
      payments: json['payments'] != null
          ? (json['payments'] as List)
              .map((e) => PaymentModel.fromJson(e))
              .toList()
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }
}

class TransactionItemModel {
  final int id;
  final int transactionId;
  final String itemType;
  final int? itemId;
  final String itemName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? notes;

  TransactionItemModel({
    required this.id,
    required this.transactionId,
    required this.itemType,
    this.itemId,
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.notes,
  });

  factory TransactionItemModel.fromJson(Map<String, dynamic> json) {
    return TransactionItemModel(
      id: json['id'],
      transactionId: json['transaction_id'],
      itemType: json['item_type'] ?? 'service',
      itemId: json['item_id'],
      itemName: json['item_name'],
      quantity: json['quantity'] ?? 1,
      unitPrice: (json['unit_price'] ?? 0).toDouble(),
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      notes: json['notes'],
    );
  }
}

class PaymentModel {
  final int id;
  final int transactionId;
  final double amount;
  final String paymentMethod;
  final String? paymentMethodLabel;
  final String? referenceNumber;
  final String? notes;
  final int? receivedBy;
  final UserModel? receiver;
  final DateTime paidAt;

  PaymentModel({
    required this.id,
    required this.transactionId,
    required this.amount,
    required this.paymentMethod,
    this.paymentMethodLabel,
    this.referenceNumber,
    this.notes,
    this.receivedBy,
    this.receiver,
    required this.paidAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      transactionId: json['transaction_id'],
      amount: (json['amount'] ?? 0).toDouble(),
      paymentMethod: json['payment_method'] ?? 'cash',
      paymentMethodLabel: json['payment_method_label'],
      referenceNumber: json['reference_number'],
      notes: json['notes'],
      receivedBy: json['received_by'],
      receiver: json['receiver'] != null
          ? UserModel.fromJson(json['receiver'])
          : null,
      paidAt: DateTime.parse(json['paid_at']),
    );
  }
}
```

---

## Settings Models

```dart
// lib/data/models/responses/settings_model.dart

class SettingsModel {
  final ClinicInfo clinic;
  final List<OperatingHourModel> operatingHours;
  final Map<String, bool> features;
  final String businessType;

  SettingsModel({
    required this.clinic,
    required this.operatingHours,
    required this.features,
    required this.businessType,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      clinic: ClinicInfo.fromJson(json['clinic'] ?? {}),
      operatingHours: json['operating_hours'] != null
          ? (json['operating_hours'] as List)
              .map((e) => OperatingHourModel.fromJson(e))
              .toList()
          : [],
      features: json['features'] != null
          ? Map<String, bool>.from(json['features'])
          : {},
      businessType: json['business_type'] ?? 'clinic',
    );
  }

  bool hasFeature(String feature) => features[feature] ?? false;
}

class ClinicInfo {
  final String? name;
  final String? phone;
  final String? email;
  final String? address;
  final String? city;
  final String? province;
  final String? postalCode;
  final String? description;
  final String? whatsapp;
  final String? instagram;
  final String? facebook;
  final String? website;

  ClinicInfo({
    this.name,
    this.phone,
    this.email,
    this.address,
    this.city,
    this.province,
    this.postalCode,
    this.description,
    this.whatsapp,
    this.instagram,
    this.facebook,
    this.website,
  });

  factory ClinicInfo.fromJson(Map<String, dynamic> json) {
    return ClinicInfo(
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      city: json['city'],
      province: json['province'],
      postalCode: json['postal_code'],
      description: json['description'],
      whatsapp: json['whatsapp'],
      instagram: json['instagram'],
      facebook: json['facebook'],
      website: json['website'],
    );
  }
}

class OperatingHourModel {
  final int id;
  final int dayOfWeek;
  final String dayName;
  final String dayNameId;
  final String? openTime;
  final String? closeTime;
  final bool isClosed;

  OperatingHourModel({
    required this.id,
    required this.dayOfWeek,
    required this.dayName,
    required this.dayNameId,
    this.openTime,
    this.closeTime,
    required this.isClosed,
  });

  factory OperatingHourModel.fromJson(Map<String, dynamic> json) {
    return OperatingHourModel(
      id: json['id'] ?? 0,
      dayOfWeek: json['day_of_week'] ?? 0,
      dayName: json['day_name'] ?? '',
      dayNameId: json['day_name_id'] ?? '',
      openTime: json['open_time'],
      closeTime: json['close_time'],
      isClosed: json['is_closed'] ?? false,
    );
  }

  String get hoursDisplay {
    if (isClosed) return 'Tutup';
    return '$openTime - $closeTime';
  }
}

class BrandingInfo {
  final String? logo;
  final String? logoUrl;
  final String primaryColor;
  final String secondaryColor;

  BrandingInfo({
    this.logo,
    this.logoUrl,
    required this.primaryColor,
    required this.secondaryColor,
  });

  factory BrandingInfo.fromJson(Map<String, dynamic> json) {
    return BrandingInfo(
      logo: json['logo'],
      logoUrl: json['logo_url'],
      primaryColor: json['primary_color'] ?? '#f43f5e',
      secondaryColor: json['secondary_color'] ?? '#cc4637',
    );
  }
}

class LoyaltyConfig {
  final bool enabled;
  final int pointsPerAmount;
  final Map<String, int> tiers;
  final int redemptionValidityDays;

  LoyaltyConfig({
    required this.enabled,
    required this.pointsPerAmount,
    required this.tiers,
    required this.redemptionValidityDays,
  });

  factory LoyaltyConfig.fromJson(Map<String, dynamic> json) {
    return LoyaltyConfig(
      enabled: json['enabled'] ?? false,
      pointsPerAmount: json['points_per_amount'] ?? 10000,
      tiers: json['tiers'] != null
          ? Map<String, int>.from(json['tiers'])
          : {'bronze': 0, 'silver': 1000, 'gold': 5000, 'platinum': 10000},
      redemptionValidityDays: json['redemption_validity_days'] ?? 30,
    );
  }
}
```

---

## Dashboard Models

```dart
// lib/data/models/responses/dashboard_model.dart

class DashboardModel {
  final DashboardStats today;
  final DashboardStats month;
  final List<AppointmentModel> todayAppointments;
  final List<RevenueChartData> revenueChart;

  DashboardModel({
    required this.today,
    required this.month,
    required this.todayAppointments,
    required this.revenueChart,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      today: DashboardStats.fromJson(json['today'] ?? {}),
      month: DashboardStats.fromJson(json['month'] ?? {}),
      todayAppointments: json['today_appointments'] != null
          ? (json['today_appointments'] as List)
              .map((e) => AppointmentModel.fromJson(e))
              .toList()
          : [],
      revenueChart: json['revenue_chart'] != null
          ? (json['revenue_chart'] as List)
              .map((e) => RevenueChartData.fromJson(e))
              .toList()
          : [],
    );
  }
}

class DashboardStats {
  final double revenue;
  final int appointments;
  final int completedAppointments;
  final int newCustomers;
  final int? totalCustomers;

  DashboardStats({
    required this.revenue,
    required this.appointments,
    required this.completedAppointments,
    required this.newCustomers,
    this.totalCustomers,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      revenue: (json['revenue'] ?? 0).toDouble(),
      appointments: json['appointments'] ?? 0,
      completedAppointments: json['completed_appointments'] ?? 0,
      newCustomers: json['new_customers'] ?? 0,
      totalCustomers: json['total_customers'],
    );
  }
}

class RevenueChartData {
  final String date;
  final String day;
  final double revenue;

  RevenueChartData({
    required this.date,
    required this.day,
    required this.revenue,
  });

  factory RevenueChartData.fromJson(Map<String, dynamic> json) {
    return RevenueChartData(
      date: json['date'] ?? '',
      day: json['day'] ?? '',
      revenue: (json['revenue'] ?? 0).toDouble(),
    );
  }
}

class DashboardSummary {
  final int totalCustomers;
  final int totalAppointments;
  final double totalRevenue;
  final List<PopularService> popularServices;

  DashboardSummary({
    required this.totalCustomers,
    required this.totalAppointments,
    required this.totalRevenue,
    required this.popularServices,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalCustomers: json['total_customers'] ?? 0,
      totalAppointments: json['total_appointments'] ?? 0,
      totalRevenue: (json['total_revenue'] ?? 0).toDouble(),
      popularServices: json['popular_services'] != null
          ? (json['popular_services'] as List)
              .map((e) => PopularService.fromJson(e))
              .toList()
          : [],
    );
  }
}

class PopularService {
  final int serviceId;
  final String? serviceName;
  final int total;

  PopularService({
    required this.serviceId,
    this.serviceName,
    required this.total,
  });

  factory PopularService.fromJson(Map<String, dynamic> json) {
    return PopularService(
      serviceId: json['service_id'] ?? 0,
      serviceName: json['service_name'],
      total: json['total'] ?? 0,
    );
  }
}
```

---

## Request Models

```dart
// lib/data/models/requests/login_request_model.dart

class LoginRequestModel {
  final String email;
  final String password;

  LoginRequestModel({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
  };
}

// lib/data/models/requests/customer_request_model.dart

class CustomerRequestModel {
  final String name;
  final String phone;
  final String? email;
  final String? birthdate;
  final String? gender;
  final String? address;
  final String? skinType;
  final List<String>? skinConcerns;
  final String? allergies;
  final String? notes;

  CustomerRequestModel({
    required this.name,
    required this.phone,
    this.email,
    this.birthdate,
    this.gender,
    this.address,
    this.skinType,
    this.skinConcerns,
    this.allergies,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
    if (email != null) 'email': email,
    if (birthdate != null) 'birthdate': birthdate,
    if (gender != null) 'gender': gender,
    if (address != null) 'address': address,
    if (skinType != null) 'skin_type': skinType,
    if (skinConcerns != null) 'skin_concerns': skinConcerns,
    if (allergies != null) 'allergies': allergies,
    if (notes != null) 'notes': notes,
  };
}

// lib/data/models/requests/appointment_request_model.dart

class AppointmentRequestModel {
  final int customerId;
  final int serviceId;
  final int? staffId;
  final int? customerPackageId;
  final String appointmentDate;
  final String startTime;
  final String? notes;
  final String source;

  AppointmentRequestModel({
    required this.customerId,
    required this.serviceId,
    this.staffId,
    this.customerPackageId,
    required this.appointmentDate,
    required this.startTime,
    this.notes,
    this.source = 'walk_in',
  });

  Map<String, dynamic> toJson() => {
    'customer_id': customerId,
    'service_id': serviceId,
    if (staffId != null) 'staff_id': staffId,
    if (customerPackageId != null) 'customer_package_id': customerPackageId,
    'appointment_date': appointmentDate,
    'start_time': startTime,
    if (notes != null) 'notes': notes,
    'source': source,
  };
}

class UpdateAppointmentStatusRequest {
  final String status;
  final String? cancelledReason;

  UpdateAppointmentStatusRequest({
    required this.status,
    this.cancelledReason,
  });

  Map<String, dynamic> toJson() => {
    'status': status,
    if (cancelledReason != null) 'cancelled_reason': cancelledReason,
  };
}

// lib/data/models/requests/redeem_reward_request.dart

class RedeemRewardRequest {
  final int rewardId;

  RedeemRewardRequest({required this.rewardId});

  Map<String, dynamic> toJson() => {'reward_id': rewardId};
}

// lib/data/models/requests/adjust_points_request.dart

class AdjustPointsRequest {
  final int points;
  final String description;

  AdjustPointsRequest({required this.points, required this.description});

  Map<String, dynamic> toJson() => {
    'points': points,
    'description': description,
  };
}
```
