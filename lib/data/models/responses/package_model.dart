import 'customer_model.dart';
import 'service_model.dart';
import 'user_model.dart';

/// Package model (service package template)
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
      name: json['name'] ?? '',
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'service_id': serviceId,
        'total_sessions': totalSessions,
        'original_price': originalPrice,
        'package_price': packagePrice,
        'discount_percentage': discountPercentage,
        'savings': savings,
        'price_per_session': pricePerSession,
        'validity_days': validityDays,
        'is_active': isActive,
      };

  /// Get display price
  String get displayPrice =>
      formattedPackagePrice ?? 'Rp ${packagePrice.toStringAsFixed(0)}';

  /// Get validity display
  String get validityDisplay {
    if (validityDays >= 365) {
      final years = validityDays ~/ 365;
      return '$years tahun';
    } else if (validityDays >= 30) {
      final months = validityDays ~/ 30;
      return '$months bulan';
    }
    return '$validityDays hari';
  }
}

/// Customer package model (purchased package)
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
      seller:
          json['seller'] != null ? UserModel.fromJson(json['seller']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'customer_id': customerId,
        'package_id': packageId,
        'sold_by': soldBy,
        'price_paid': pricePaid,
        'sessions_total': sessionsTotal,
        'sessions_used': sessionsUsed,
        'sessions_remaining': sessionsRemaining,
        'usage_percentage': usagePercentage,
        'purchased_at': purchasedAt.toIso8601String(),
        'expires_at': expiresAt?.toIso8601String(),
        'days_remaining': daysRemaining,
        'is_expired': isExpired,
        'is_usable': isUsable,
        'status': status,
        'notes': notes,
      };

  /// Check if package is active
  bool get isActive => status == 'active';

  /// Check if all sessions have been used
  bool get isFullyUsed => sessionsRemaining <= 0;

  /// Get usage display text
  String get usageDisplay => '$sessionsUsed / $sessionsTotal sesi';

  /// Get expiry status text
  String get expiryStatus {
    if (isExpired) return 'Kadaluarsa';
    if (daysRemaining != null) {
      if (daysRemaining! <= 7) return 'Segera berakhir';
      return '$daysRemaining hari lagi';
    }
    return '-';
  }

  /// Get status color name for UI
  String get statusColorName {
    if (status == 'cancelled') return 'cancelled';
    if (isExpired) return 'red';
    if (isFullyUsed) return 'grey';
    if (daysRemaining != null && daysRemaining! <= 7) return 'orange';
    return 'green';
  }
}
