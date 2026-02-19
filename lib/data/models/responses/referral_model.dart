import 'customer_model.dart';

/// Model for referral log/history
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
      status: json['status'] ?? '',
      statusLabel: json['status_label'] ?? '',
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'referrer_id': referrerId,
        'referee_id': refereeId,
        'referrer_points': referrerPoints,
        'referee_points': refereePoints,
        'transaction_id': transactionId,
        'status': status,
        'status_label': statusLabel,
        'rewarded_at': rewardedAt?.toIso8601String(),
        'created_at': createdAt?.toIso8601String(),
      };

  /// Check if referral is pending
  bool get isPending => status == 'pending';

  /// Check if referral has been rewarded
  bool get isRewarded => status == 'rewarded';
}

/// Customer referral stats
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

  Map<String, dynamic> toJson() => {
        'total_referrals': totalReferrals,
        'pending_referrals': pendingReferrals,
        'rewarded_referrals': rewardedReferrals,
        'total_points_earned': totalPointsEarned,
      };
}

/// Customer referral info
class ReferralInfo {
  final String referralCode;
  final int totalReferrals;
  final int totalPointsEarned;
  final CustomerModel? referredBy;

  ReferralInfo({
    required this.referralCode,
    required this.totalReferrals,
    required this.totalPointsEarned,
    this.referredBy,
  });

  factory ReferralInfo.fromJson(Map<String, dynamic> json) {
    // API returns flat: referral_code, total_referrals, total_points_earned, referred_by
    return ReferralInfo(
      referralCode: json['referral_code'] ?? '',
      totalReferrals: json['total_referrals'] ?? 0,
      totalPointsEarned: json['total_points_earned'] ?? 0,
      referredBy: json['referred_by'] != null
          ? CustomerModel.fromJson(json['referred_by'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'referral_code': referralCode,
        'total_referrals': totalReferrals,
        'total_points_earned': totalPointsEarned,
      };

  /// Check if customer has been referred by someone
  bool get hasReferrer => referredBy != null;
}

/// Referral program settings info
class ReferralProgramInfo {
  final bool enabled;
  final int referrerPoints;
  final int refereePoints;
  final String? description;

  ReferralProgramInfo({
    required this.enabled,
    required this.referrerPoints,
    required this.refereePoints,
    this.description,
  });

  factory ReferralProgramInfo.fromJson(Map<String, dynamic> json) {
    return ReferralProgramInfo(
      enabled: json['enabled'] ?? false,
      referrerPoints: json['referrer_points'] ?? 0,
      refereePoints: json['referee_points'] ?? 0,
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'referrer_points': referrerPoints,
        'referee_points': refereePoints,
        'description': description,
      };
}
