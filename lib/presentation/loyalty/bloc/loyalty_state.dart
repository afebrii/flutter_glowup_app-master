import 'package:equatable/equatable.dart';
import '../../../data/models/responses/api_response.dart';
import '../../../data/models/responses/loyalty_point_model.dart';
import '../../../data/models/responses/loyalty_redemption_model.dart';
import '../../../data/models/responses/loyalty_reward_model.dart';

class LoyaltyState extends Equatable {
  final LoyaltySummary? summary;
  final List<LoyaltyPointModel> pointsHistory;
  final List<LoyaltyRewardModel> rewards;
  final List<LoyaltyRedemptionModel> redemptions;
  final PaginationMeta? pointsMeta;
  final PaginationMeta? redemptionsMeta;
  final bool isLoadingSummary;
  final bool isLoadingPoints;
  final bool isLoadingRewards;
  final bool isLoadingRedemptions;
  final bool isRedeeming;
  final bool isCheckingCode;
  final bool isUsingCode;
  final bool isCancelling;
  final bool isAdjusting;
  final LoyaltyRedemptionModel? checkedRedemption;
  final String? error;
  final String? successMessage;

  const LoyaltyState({
    this.summary,
    this.pointsHistory = const [],
    this.rewards = const [],
    this.redemptions = const [],
    this.pointsMeta,
    this.redemptionsMeta,
    this.isLoadingSummary = false,
    this.isLoadingPoints = false,
    this.isLoadingRewards = false,
    this.isLoadingRedemptions = false,
    this.isRedeeming = false,
    this.isCheckingCode = false,
    this.isUsingCode = false,
    this.isCancelling = false,
    this.isAdjusting = false,
    this.checkedRedemption,
    this.error,
    this.successMessage,
  });

  LoyaltyState copyWith({
    LoyaltySummary? summary,
    List<LoyaltyPointModel>? pointsHistory,
    List<LoyaltyRewardModel>? rewards,
    List<LoyaltyRedemptionModel>? redemptions,
    PaginationMeta? pointsMeta,
    PaginationMeta? redemptionsMeta,
    bool? isLoadingSummary,
    bool? isLoadingPoints,
    bool? isLoadingRewards,
    bool? isLoadingRedemptions,
    bool? isRedeeming,
    bool? isCheckingCode,
    bool? isUsingCode,
    bool? isCancelling,
    bool? isAdjusting,
    LoyaltyRedemptionModel? checkedRedemption,
    String? error,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearChecked = false,
  }) {
    return LoyaltyState(
      summary: summary ?? this.summary,
      pointsHistory: pointsHistory ?? this.pointsHistory,
      rewards: rewards ?? this.rewards,
      redemptions: redemptions ?? this.redemptions,
      pointsMeta: pointsMeta ?? this.pointsMeta,
      redemptionsMeta: redemptionsMeta ?? this.redemptionsMeta,
      isLoadingSummary: isLoadingSummary ?? this.isLoadingSummary,
      isLoadingPoints: isLoadingPoints ?? this.isLoadingPoints,
      isLoadingRewards: isLoadingRewards ?? this.isLoadingRewards,
      isLoadingRedemptions: isLoadingRedemptions ?? this.isLoadingRedemptions,
      isRedeeming: isRedeeming ?? this.isRedeeming,
      isCheckingCode: isCheckingCode ?? this.isCheckingCode,
      isUsingCode: isUsingCode ?? this.isUsingCode,
      isCancelling: isCancelling ?? this.isCancelling,
      isAdjusting: isAdjusting ?? this.isAdjusting,
      checkedRedemption:
          clearChecked ? null : (checkedRedemption ?? this.checkedRedemption),
      error: clearError ? null : (error ?? this.error),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  bool get isLoading =>
      isLoadingSummary ||
      isLoadingPoints ||
      isLoadingRewards ||
      isLoadingRedemptions;

  bool get hasMorePoints => pointsMeta?.hasMore ?? false;
  bool get hasMoreRedemptions => redemptionsMeta?.hasMore ?? false;

  @override
  List<Object?> get props => [
        summary,
        pointsHistory,
        rewards,
        redemptions,
        pointsMeta,
        redemptionsMeta,
        isLoadingSummary,
        isLoadingPoints,
        isLoadingRewards,
        isLoadingRedemptions,
        isRedeeming,
        isCheckingCode,
        isUsingCode,
        isCancelling,
        isAdjusting,
        checkedRedemption,
        error,
        successMessage,
      ];
}
