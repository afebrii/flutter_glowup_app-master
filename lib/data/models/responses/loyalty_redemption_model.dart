import 'customer_model.dart';
import 'loyalty_reward_model.dart';

/// Model for loyalty redemption records
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
      pointsUsed: json['points_used'] ?? 0,
      status: json['status'] ?? '',
      statusLabel: json['status_label'] ?? '',
      code: json['code'] ?? '',
      validUntil: json['valid_until'] != null
          ? DateTime.parse(json['valid_until'])
          : null,
      usedAt: json['used_at'] != null ? DateTime.parse(json['used_at']) : null,
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'customer_id': customerId,
        'loyalty_reward_id': loyaltyRewardId,
        'transaction_id': transactionId,
        'points_used': pointsUsed,
        'status': status,
        'status_label': statusLabel,
        'code': code,
        'valid_until': validUntil?.toIso8601String(),
        'used_at': usedAt?.toIso8601String(),
        'is_valid': isValid,
        'created_at': createdAt?.toIso8601String(),
      };

  /// Check if redemption is pending
  bool get isPending => status == 'pending';

  /// Check if redemption has been used
  bool get isUsed => status == 'used';

  /// Check if redemption is cancelled
  bool get isCancelled => status == 'cancelled';

  /// Check if redemption is expired
  bool get isExpired => status == 'expired';

  /// Check if redemption can be used
  bool get canUse => isPending && isValid && !isExpiredByDate;

  /// Check if expired by date
  bool get isExpiredByDate {
    if (validUntil == null) return false;
    return DateTime.now().isAfter(validUntil!);
  }

  /// Get days until expiry
  int? get daysUntilExpiry {
    if (validUntil == null) return null;
    return validUntil!.difference(DateTime.now()).inDays;
  }
}
