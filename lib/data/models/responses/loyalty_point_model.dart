/// Model for loyalty point transaction history
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
      type: json['type'] ?? '',
      typeLabel: json['type_label'] ?? '',
      points: json['points'] ?? 0,
      balanceAfter: json['balance_after'] ?? 0,
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'customer_id': customerId,
        'transaction_id': transactionId,
        'type': type,
        'type_label': typeLabel,
        'points': points,
        'balance_after': balanceAfter,
        'description': description,
        'expires_at': expiresAt?.toIso8601String(),
        'is_earn': isEarn,
        'is_redeem': isRedeem,
        'created_at': createdAt?.toIso8601String(),
      };

  /// Check if this is a positive points transaction
  bool get isPositive => points > 0;

  /// Get display text for points change
  String get pointsDisplay => isPositive ? '+$points' : '$points';
}

/// Customer loyalty summary
class LoyaltySummary {
  final int currentPoints;
  final int lifetimePoints;
  final String tier;
  final String tierLabel;
  final int pointsToNextTier;
  final int totalRedemptions;
  final int totalPointsRedeemed;

  LoyaltySummary({
    required this.currentPoints,
    required this.lifetimePoints,
    required this.tier,
    required this.tierLabel,
    required this.pointsToNextTier,
    required this.totalRedemptions,
    required this.totalPointsRedeemed,
  });

  factory LoyaltySummary.fromJson(Map<String, dynamic> json) {
    return LoyaltySummary(
      currentPoints: json['current_points'] ?? 0,
      lifetimePoints: json['lifetime_points'] ?? 0,
      tier: json['tier'] ?? 'bronze',
      tierLabel: json['tier_label'] ?? 'Bronze',
      pointsToNextTier: json['points_to_next_tier'] ?? 0,
      totalRedemptions: json['total_redemptions'] ?? 0,
      totalPointsRedeemed: json['total_points_redeemed'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'current_points': currentPoints,
        'lifetime_points': lifetimePoints,
        'tier': tier,
        'tier_label': tierLabel,
        'points_to_next_tier': pointsToNextTier,
        'total_redemptions': totalRedemptions,
        'total_points_redeemed': totalPointsRedeemed,
      };

  LoyaltySummary copyWith({
    int? currentPoints,
    int? lifetimePoints,
    String? tier,
    String? tierLabel,
    int? pointsToNextTier,
    int? totalRedemptions,
    int? totalPointsRedeemed,
  }) {
    return LoyaltySummary(
      currentPoints: currentPoints ?? this.currentPoints,
      lifetimePoints: lifetimePoints ?? this.lifetimePoints,
      tier: tier ?? this.tier,
      tierLabel: tierLabel ?? this.tierLabel,
      pointsToNextTier: pointsToNextTier ?? this.pointsToNextTier,
      totalRedemptions: totalRedemptions ?? this.totalRedemptions,
      totalPointsRedeemed: totalPointsRedeemed ?? this.totalPointsRedeemed,
    );
  }
}
