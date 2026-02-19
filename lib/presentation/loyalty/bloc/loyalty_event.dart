import 'package:equatable/equatable.dart';

abstract class LoyaltyEvent extends Equatable {
  const LoyaltyEvent();

  @override
  List<Object?> get props => [];
}

class FetchLoyaltySummary extends LoyaltyEvent {
  final int customerId;

  const FetchLoyaltySummary(this.customerId);

  @override
  List<Object?> get props => [customerId];
}

class FetchPointsHistory extends LoyaltyEvent {
  final int customerId;
  final int page;

  const FetchPointsHistory(this.customerId, {this.page = 1});

  @override
  List<Object?> get props => [customerId, page];
}

class FetchRewards extends LoyaltyEvent {
  const FetchRewards();
}

class RedeemReward extends LoyaltyEvent {
  final int customerId;
  final int rewardId;

  const RedeemReward(this.customerId, this.rewardId);

  @override
  List<Object?> get props => [customerId, rewardId];
}

class FetchRedemptions extends LoyaltyEvent {
  final int customerId;
  final String? status;
  final int page;

  const FetchRedemptions(this.customerId, {this.status, this.page = 1});

  @override
  List<Object?> get props => [customerId, status, page];
}

class CheckRedemptionCode extends LoyaltyEvent {
  final String code;

  const CheckRedemptionCode(this.code);

  @override
  List<Object?> get props => [code];
}

class UseRedemptionCode extends LoyaltyEvent {
  final String code;
  final int? transactionId;

  const UseRedemptionCode(this.code, {this.transactionId});

  @override
  List<Object?> get props => [code, transactionId];
}

class CancelRedemption extends LoyaltyEvent {
  final int redemptionId;

  const CancelRedemption(this.redemptionId);

  @override
  List<Object?> get props => [redemptionId];
}

class AdjustPoints extends LoyaltyEvent {
  final int customerId;
  final int points;
  final String description;

  const AdjustPoints(this.customerId, this.points, this.description);

  @override
  List<Object?> get props => [customerId, points, description];
}

class ClearLoyaltyError extends LoyaltyEvent {
  const ClearLoyaltyError();
}

class ClearLoyaltySuccess extends LoyaltyEvent {
  const ClearLoyaltySuccess();
}

class ClearCheckedRedemption extends LoyaltyEvent {
  const ClearCheckedRedemption();
}
