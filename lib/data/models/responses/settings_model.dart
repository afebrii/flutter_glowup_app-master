/// Main settings model containing all clinic settings
class SettingsModel {
  final ClinicInfo clinic;
  final List<OperatingHourModel> operatingHours;
  final AppointmentSettings appointment;
  final Map<String, bool> features;
  final String businessType;

  SettingsModel({
    required this.clinic,
    required this.operatingHours,
    required this.appointment,
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
      appointment: AppointmentSettings.fromJson(json['appointment'] ?? {}),
      features: json['features'] != null
          ? Map<String, bool>.from(json['features'])
          : {},
      businessType: json['business_type'] ?? 'clinic',
    );
  }

  Map<String, dynamic> toJson() => {
        'clinic': clinic.toJson(),
        'operating_hours': operatingHours.map((e) => e.toJson()).toList(),
        'appointment': appointment.toJson(),
        'features': features,
        'business_type': businessType,
      };

  /// Check if a feature is enabled
  bool hasFeature(String feature) => features[feature] ?? false;

  /// Common feature checks
  bool get hasProducts => hasFeature('products');
  bool get hasTreatmentRecords => hasFeature('treatment_records');
  bool get hasPackages => hasFeature('packages');
  bool get hasCustomerPackages => hasFeature('customer_packages');
  bool get hasLoyalty => hasFeature('loyalty');
  bool get hasOnlineBooking => hasFeature('online_booking');
  bool get hasCustomerPortal => hasFeature('customer_portal');
  bool get hasWalkInQueue => hasFeature('walk_in_queue');
}

/// Clinic information
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

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'email': email,
        'address': address,
        'city': city,
        'province': province,
        'postal_code': postalCode,
        'description': description,
        'whatsapp': whatsapp,
        'instagram': instagram,
        'facebook': facebook,
        'website': website,
      };

  /// Get full address
  String get fullAddress {
    final parts = <String>[];
    if (address != null && address!.isNotEmpty) parts.add(address!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (province != null && province!.isNotEmpty) parts.add(province!);
    if (postalCode != null && postalCode!.isNotEmpty) parts.add(postalCode!);
    return parts.join(', ');
  }

  /// Get WhatsApp URL
  String? get whatsappUrl {
    if (whatsapp == null || whatsapp!.isEmpty) return null;
    final number = whatsapp!.replaceAll(RegExp(r'[^0-9]'), '');
    return 'https://wa.me/$number';
  }

  /// Get Instagram URL
  String? get instagramUrl {
    if (instagram == null || instagram!.isEmpty) return null;
    final handle = instagram!.replaceAll('@', '');
    return 'https://instagram.com/$handle';
  }
}

/// Operating hours model
class OperatingHourModel {
  final int? id;
  final int dayOfWeek;
  final String dayName;
  final String dayNameId;
  final String? openTime;
  final String? closeTime;
  final bool isClosed;

  OperatingHourModel({
    this.id,
    required this.dayOfWeek,
    required this.dayName,
    required this.dayNameId,
    this.openTime,
    this.closeTime,
    required this.isClosed,
  });

  factory OperatingHourModel.fromJson(Map<String, dynamic> json) {
    return OperatingHourModel(
      id: json['id'],
      dayOfWeek: json['day_of_week'] ?? 0,
      dayName: json['day_name'] ?? '',
      dayNameId: json['day_name_id'] ?? '',
      openTime: json['open_time'],
      closeTime: json['close_time'],
      isClosed: json['is_closed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'day_of_week': dayOfWeek,
        'day_name': dayName,
        'day_name_id': dayNameId,
        'open_time': openTime,
        'close_time': closeTime,
        'is_closed': isClosed,
      };

  /// Get display text for hours
  String get hoursDisplay {
    if (isClosed) return 'Tutup';
    if (openTime == null || closeTime == null) return '-';
    return '$openTime - $closeTime';
  }
}

/// Branding information
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

  Map<String, dynamic> toJson() => {
        'logo': logo,
        'logo_url': logoUrl,
        'primary_color': primaryColor,
        'secondary_color': secondaryColor,
      };
}

/// Appointment settings
class AppointmentSettings {
  final int slotDuration;
  final int maxBookingDays;
  final int minBookingHours;
  final bool allowWalkIn;
  final bool requireDeposit;
  final int depositAmount;

  AppointmentSettings({
    required this.slotDuration,
    required this.maxBookingDays,
    required this.minBookingHours,
    required this.allowWalkIn,
    required this.requireDeposit,
    required this.depositAmount,
  });

  factory AppointmentSettings.fromJson(Map<String, dynamic> json) {
    return AppointmentSettings(
      slotDuration: json['slot_duration'] ?? 30,
      maxBookingDays: json['max_booking_days'] ?? 90,
      minBookingHours: json['min_booking_hours'] ?? 2,
      allowWalkIn: json['allow_walk_in'] ?? true,
      requireDeposit: json['require_deposit'] ?? false,
      depositAmount: json['deposit_amount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'slot_duration': slotDuration,
        'max_booking_days': maxBookingDays,
        'min_booking_hours': minBookingHours,
        'allow_walk_in': allowWalkIn,
        'require_deposit': requireDeposit,
        'deposit_amount': depositAmount,
      };
}

/// Loyalty program configuration
class LoyaltyConfig {
  final bool enabled;
  final int pointsPerAmount;
  final int amountPerPoint;
  final int minRedeemPoints;

  LoyaltyConfig({
    required this.enabled,
    required this.pointsPerAmount,
    required this.amountPerPoint,
    required this.minRedeemPoints,
  });

  factory LoyaltyConfig.fromJson(Map<String, dynamic> json) {
    return LoyaltyConfig(
      enabled: json['enabled'] ?? false,
      pointsPerAmount: json['points_per_amount'] ?? 10000,
      amountPerPoint: json['amount_per_point'] ?? 1,
      minRedeemPoints: json['min_redeem_points'] ?? 100,
    );
  }

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'points_per_amount': pointsPerAmount,
        'amount_per_point': amountPerPoint,
        'min_redeem_points': minRedeemPoints,
      };
}
