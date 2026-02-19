import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/loyalty_remote_datasource.dart';
import '../../../data/models/responses/loyalty_redemption_model.dart';
import 'loyalty_event.dart';
import 'loyalty_state.dart';

class LoyaltyBloc extends Bloc<LoyaltyEvent, LoyaltyState> {
  final LoyaltyRemoteDatasource _loyaltyDatasource;

  LoyaltyBloc({required LoyaltyRemoteDatasource loyaltyDatasource})
      : _loyaltyDatasource = loyaltyDatasource,
        super(const LoyaltyState()) {
    on<FetchLoyaltySummary>(_onFetchSummary);
    on<FetchPointsHistory>(_onFetchPointsHistory);
    on<FetchRewards>(_onFetchRewards);
    on<RedeemReward>(_onRedeemReward);
    on<FetchRedemptions>(_onFetchRedemptions);
    on<CheckRedemptionCode>(_onCheckCode);
    on<UseRedemptionCode>(_onUseCode);
    on<CancelRedemption>(_onCancelRedemption);
    on<AdjustPoints>(_onAdjustPoints);
    on<ClearLoyaltyError>(_onClearError);
    on<ClearLoyaltySuccess>(_onClearSuccess);
    on<ClearCheckedRedemption>(_onClearChecked);
  }

  Future<void> _onFetchSummary(
    FetchLoyaltySummary event,
    Emitter<LoyaltyState> emit,
  ) async {
    emit(state.copyWith(isLoadingSummary: true, clearError: true));

    final result = await _loyaltyDatasource.getCustomerLoyaltySummary(
      event.customerId,
    );

    result.fold(
      (error) => emit(state.copyWith(isLoadingSummary: false, error: error)),
      (summary) =>
          emit(state.copyWith(isLoadingSummary: false, summary: summary)),
    );
  }

  Future<void> _onFetchPointsHistory(
    FetchPointsHistory event,
    Emitter<LoyaltyState> emit,
  ) async {
    emit(state.copyWith(isLoadingPoints: true, clearError: true));

    final result = await _loyaltyDatasource.getCustomerPoints(
      event.customerId,
      page: event.page,
    );

    result.fold(
      (error) => emit(state.copyWith(isLoadingPoints: false, error: error)),
      (response) {
        final points = event.page == 1
            ? response.data
            : [...state.pointsHistory, ...response.data];
        emit(state.copyWith(
          isLoadingPoints: false,
          pointsHistory: points,
          pointsMeta: response.meta,
        ));
      },
    );
  }

  Future<void> _onFetchRewards(
    FetchRewards event,
    Emitter<LoyaltyState> emit,
  ) async {
    emit(state.copyWith(isLoadingRewards: true, clearError: true));

    final result = await _loyaltyDatasource.getRewards();

    result.fold(
      (error) => emit(state.copyWith(isLoadingRewards: false, error: error)),
      (rewards) =>
          emit(state.copyWith(isLoadingRewards: false, rewards: rewards)),
    );
  }

  Future<void> _onRedeemReward(
    RedeemReward event,
    Emitter<LoyaltyState> emit,
  ) async {
    emit(state.copyWith(
        isRedeeming: true, clearError: true, clearSuccess: true));

    final result = await _loyaltyDatasource.redeemReward(
      event.customerId,
      event.rewardId,
    );

    result.fold(
      (error) => emit(state.copyWith(isRedeeming: false, error: error)),
      (redemption) {
        final newSummary = state.summary?.copyWith(
          currentPoints: state.summary!.currentPoints - redemption.pointsUsed,
        );
        emit(state.copyWith(
          isRedeeming: false,
          summary: newSummary,
          successMessage: 'Reward berhasil ditukar! Kode: ${redemption.code}',
        ));
      },
    );
  }

  Future<void> _onFetchRedemptions(
    FetchRedemptions event,
    Emitter<LoyaltyState> emit,
  ) async {
    emit(state.copyWith(isLoadingRedemptions: true, clearError: true));

    final result = await _loyaltyDatasource.getCustomerRedemptions(
      event.customerId,
      status: event.status,
      page: event.page,
    );

    result.fold(
      (error) =>
          emit(state.copyWith(isLoadingRedemptions: false, error: error)),
      (response) {
        final redemptions = event.page == 1
            ? response.data
            : [...state.redemptions, ...response.data];
        emit(state.copyWith(
          isLoadingRedemptions: false,
          redemptions: redemptions,
          redemptionsMeta: response.meta,
        ));
      },
    );
  }

  Future<void> _onCheckCode(
    CheckRedemptionCode event,
    Emitter<LoyaltyState> emit,
  ) async {
    emit(state.copyWith(
        isCheckingCode: true, clearError: true, clearChecked: true));

    final result = await _loyaltyDatasource.checkCode(event.code);

    result.fold(
      (error) => emit(state.copyWith(isCheckingCode: false, error: error)),
      (data) {
        if (data['data'] != null) {
          final redemption = LoyaltyRedemptionModel.fromJson(data['data']);
          emit(state.copyWith(
            isCheckingCode: false,
            checkedRedemption: redemption,
          ));
        } else {
          emit(state.copyWith(
            isCheckingCode: false,
            error: data['message'] ?? 'Kode tidak ditemukan',
          ));
        }
      },
    );
  }

  Future<void> _onUseCode(
    UseRedemptionCode event,
    Emitter<LoyaltyState> emit,
  ) async {
    emit(
        state.copyWith(isUsingCode: true, clearError: true, clearSuccess: true));

    final result = await _loyaltyDatasource.useCode(
      event.code,
      transactionId: event.transactionId,
    );

    result.fold(
      (error) => emit(state.copyWith(isUsingCode: false, error: error)),
      (redemption) => emit(state.copyWith(
        isUsingCode: false,
        checkedRedemption: redemption,
        successMessage: 'Kode berhasil digunakan!',
      )),
    );
  }

  Future<void> _onCancelRedemption(
    CancelRedemption event,
    Emitter<LoyaltyState> emit,
  ) async {
    emit(state.copyWith(
        isCancelling: true, clearError: true, clearSuccess: true));

    final result = await _loyaltyDatasource.cancelRedemption(event.redemptionId);

    result.fold(
      (error) => emit(state.copyWith(isCancelling: false, error: error)),
      (data) {
        // API returns {message, points_refunded}, remove item from list
        final updatedRedemptions = state.redemptions
            .where((r) => r.id != event.redemptionId)
            .toList();
        final pointsRefunded = data['points_refunded'] as int? ?? 0;
        final newSummary = state.summary?.copyWith(
          currentPoints: (state.summary?.currentPoints ?? 0) + pointsRefunded,
        );
        emit(state.copyWith(
          isCancelling: false,
          redemptions: updatedRedemptions,
          summary: newSummary,
          successMessage: 'Penukaran dibatalkan, $pointsRefunded poin dikembalikan.',
        ));
      },
    );
  }

  Future<void> _onAdjustPoints(
    AdjustPoints event,
    Emitter<LoyaltyState> emit,
  ) async {
    emit(state.copyWith(
        isAdjusting: true, clearError: true, clearSuccess: true));

    final result = await _loyaltyDatasource.adjustPoints(
      event.customerId,
      points: event.points,
      description: event.description,
    );

    result.fold(
      (error) => emit(state.copyWith(isAdjusting: false, error: error)),
      (data) {
        final newBalance = data['new_balance'] as int? ?? state.summary?.currentPoints ?? 0;
        final newSummary = state.summary?.copyWith(currentPoints: newBalance);
        emit(state.copyWith(
          isAdjusting: false,
          summary: newSummary,
          successMessage: 'Poin berhasil disesuaikan.',
        ));
      },
    );
  }

  void _onClearError(ClearLoyaltyError event, Emitter<LoyaltyState> emit) {
    emit(state.copyWith(clearError: true));
  }

  void _onClearSuccess(ClearLoyaltySuccess event, Emitter<LoyaltyState> emit) {
    emit(state.copyWith(clearSuccess: true));
  }

  void _onClearChecked(
      ClearCheckedRedemption event, Emitter<LoyaltyState> emit) {
    emit(state.copyWith(clearChecked: true));
  }
}
