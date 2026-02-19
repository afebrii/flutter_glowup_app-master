import 'referral_model.dart';

class CustomerModel {
  final int id;
  final String name;
  final String phone;
  final String? email;
  final DateTime? birthdate;
  final String? gender; // male, female
  final String? address;
  final String? skinType; // normal, oily, dry, combination, sensitive
  final List<String>? skinConcerns;
  final String? allergies;
  final String? notes;
  final int totalVisits;
  final int totalSpent;
  final DateTime? lastVisit;
  final DateTime createdAt;

  // Loyalty fields
  final int loyaltyPoints;
  final int lifetimePoints;
  final String? loyaltyTier;
  final String? loyaltyTierLabel;

  // Referral fields
  final String? referralCode;
  final int? referredById;
  final CustomerModel? referrer;
  final ReferralStats? referralStats;

  CustomerModel({
    required this.id,
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
    this.totalVisits = 0,
    this.totalSpent = 0,
    this.lastVisit,
    required this.createdAt,
    this.loyaltyPoints = 0,
    this.lifetimePoints = 0,
    this.loyaltyTier,
    this.loyaltyTierLabel,
    this.referralCode,
    this.referredById,
    this.referrer,
    this.referralStats,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String get skinTypeLabel {
    switch (skinType) {
      case 'normal':
        return 'Normal';
      case 'oily':
        return 'Berminyak';
      case 'dry':
        return 'Kering';
      case 'combination':
        return 'Kombinasi';
      case 'sensitive':
        return 'Sensitif';
      default:
        return '-';
    }
  }

  String get genderLabel {
    switch (gender) {
      case 'male':
        return 'Laki-laki';
      case 'female':
        return 'Perempuan';
      default:
        return '-';
    }
  }

  int? get age {
    if (birthdate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthdate!.year;
    if (now.month < birthdate!.month ||
        (now.month == birthdate!.month && now.day < birthdate!.day)) {
      age--;
    }
    return age;
  }

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      birthdate: json['birthdate'] != null
          ? DateTime.parse(json['birthdate'])
          : null,
      gender: json['gender'],
      address: json['address'],
      skinType: json['skin_type'],
      skinConcerns: json['skin_concerns'] != null
          ? List<String>.from(json['skin_concerns'])
          : null,
      allergies: json['allergies'],
      notes: json['notes'],
      totalVisits: json['total_visits'] ?? 0,
      totalSpent: (json['total_spent'] ?? 0) is double
          ? (json['total_spent'] as double).toInt()
          : json['total_spent'] ?? 0,
      lastVisit: json['last_visit'] != null
          ? DateTime.parse(json['last_visit'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      // Loyalty fields
      loyaltyPoints: json['loyalty_points'] ?? 0,
      lifetimePoints: json['lifetime_points'] ?? 0,
      loyaltyTier: json['loyalty_tier'],
      loyaltyTierLabel: json['loyalty_tier_label'],
      // Referral fields
      referralCode: json['referral_code'],
      referredById: json['referred_by_id'],
      referrer: json['referrer'] != null
          ? CustomerModel.fromJson(json['referrer'])
          : null,
      referralStats: json['referral_stats'] != null
          ? ReferralStats.fromJson(json['referral_stats'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'birthdate': birthdate?.toIso8601String().split('T').first,
        'gender': gender,
        'address': address,
        'skin_type': skinType,
        'skin_concerns': skinConcerns,
        'allergies': allergies,
        'notes': notes,
        'total_visits': totalVisits,
        'total_spent': totalSpent,
        'last_visit': lastVisit?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'loyalty_points': loyaltyPoints,
        'lifetime_points': lifetimePoints,
        'loyalty_tier': loyaltyTier,
        'loyalty_tier_label': loyaltyTierLabel,
        'referral_code': referralCode,
        'referred_by_id': referredById,
      };

  CustomerModel copyWith({
    int? id,
    String? name,
    String? phone,
    String? email,
    DateTime? birthdate,
    String? gender,
    String? address,
    String? skinType,
    List<String>? skinConcerns,
    String? allergies,
    String? notes,
    int? totalVisits,
    int? totalSpent,
    DateTime? lastVisit,
    DateTime? createdAt,
    int? loyaltyPoints,
    int? lifetimePoints,
    String? loyaltyTier,
    String? loyaltyTierLabel,
    String? referralCode,
    int? referredById,
    CustomerModel? referrer,
    ReferralStats? referralStats,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      birthdate: birthdate ?? this.birthdate,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      skinType: skinType ?? this.skinType,
      skinConcerns: skinConcerns ?? this.skinConcerns,
      allergies: allergies ?? this.allergies,
      notes: notes ?? this.notes,
      totalVisits: totalVisits ?? this.totalVisits,
      totalSpent: totalSpent ?? this.totalSpent,
      lastVisit: lastVisit ?? this.lastVisit,
      createdAt: createdAt ?? this.createdAt,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      lifetimePoints: lifetimePoints ?? this.lifetimePoints,
      loyaltyTier: loyaltyTier ?? this.loyaltyTier,
      loyaltyTierLabel: loyaltyTierLabel ?? this.loyaltyTierLabel,
      referralCode: referralCode ?? this.referralCode,
      referredById: referredById ?? this.referredById,
      referrer: referrer ?? this.referrer,
      referralStats: referralStats ?? this.referralStats,
    );
  }

  /// Check if customer has loyalty points
  bool get hasLoyaltyPoints => loyaltyPoints > 0;

  /// Check if customer was referred by someone
  bool get wasReferred => referredById != null;

  /// Check if customer has referral code
  bool get hasReferralCode => referralCode != null && referralCode!.isNotEmpty;
}

/// Customer stats model for detailed analytics
class CustomerStats {
  final int totalAppointments;
  final int completedAppointments;
  final int cancelledAppointments;
  final int totalTransactions;
  final double totalSpent;
  final String? formattedTotalSpent;
  final int activePackages;
  final double averageTransactionValue;
  final String? formattedAverageValue;

  CustomerStats({
    required this.totalAppointments,
    required this.completedAppointments,
    required this.cancelledAppointments,
    required this.totalTransactions,
    required this.totalSpent,
    this.formattedTotalSpent,
    required this.activePackages,
    required this.averageTransactionValue,
    this.formattedAverageValue,
  });

  factory CustomerStats.fromJson(Map<String, dynamic> json) {
    return CustomerStats(
      totalAppointments: json['total_appointments'] ?? 0,
      completedAppointments: json['completed_appointments'] ?? 0,
      cancelledAppointments: json['cancelled_appointments'] ?? 0,
      totalTransactions: json['total_transactions'] ?? 0,
      totalSpent: (json['total_spent'] ?? 0).toDouble(),
      formattedTotalSpent: json['formatted_total_spent'],
      activePackages: json['active_packages'] ?? 0,
      averageTransactionValue: (json['average_transaction_value'] ?? 0).toDouble(),
      formattedAverageValue: json['formatted_average_value'],
    );
  }

  Map<String, dynamic> toJson() => {
        'total_appointments': totalAppointments,
        'completed_appointments': completedAppointments,
        'cancelled_appointments': cancelledAppointments,
        'total_transactions': totalTransactions,
        'total_spent': totalSpent,
        'formatted_total_spent': formattedTotalSpent,
        'active_packages': activePackages,
        'average_transaction_value': averageTransactionValue,
        'formatted_average_value': formattedAverageValue,
      };
}
