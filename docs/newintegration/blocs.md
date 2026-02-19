# Flutter BLoC Implementation - GlowUp Integration

Implementasi BLoC patterns untuk state management fitur-fitur baru.

## Table of Contents
1. [Loyalty BLoC](#loyalty-bloc)
2. [Referral BLoC](#referral-bloc)
3. [Product BLoC](#product-bloc)
4. [Settings BLoC](#settings-bloc)
5. [Dashboard BLoC (Updated)](#dashboard-bloc)

---

## Loyalty BLoC

### Events

```dart
// lib/presentation/loyalty/bloc/loyalty_event.dart

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
```

### States

```dart
// lib/presentation/loyalty/bloc/loyalty_state.dart

import 'package:equatable/equatable.dart';

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
      checkedRedemption: clearChecked ? null : (checkedRedemption ?? this.checkedRedemption),
      error: clearError ? null : (error ?? this.error),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

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
```

### BLoC

```dart
// lib/presentation/loyalty/bloc/loyalty_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
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
      (summary) => emit(state.copyWith(isLoadingSummary: false, summary: summary)),
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
      (rewards) => emit(state.copyWith(isLoadingRewards: false, rewards: rewards)),
    );
  }

  Future<void> _onRedeemReward(
    RedeemReward event,
    Emitter<LoyaltyState> emit,
  ) async {
    emit(state.copyWith(isRedeeming: true, clearError: true, clearSuccess: true));

    final result = await _loyaltyDatasource.redeemReward(
      event.customerId,
      event.rewardId,
    );

    result.fold(
      (error) => emit(state.copyWith(isRedeeming: false, error: error)),
      (redemption) {
        // Update summary points
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
      (error) => emit(state.copyWith(isLoadingRedemptions: false, error: error)),
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
    emit(state.copyWith(isCheckingCode: true, clearError: true, clearChecked: true));

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
            error: data['message'] ?? 'Code not found',
          ));
        }
      },
    );
  }

  Future<void> _onUseCode(
    UseRedemptionCode event,
    Emitter<LoyaltyState> emit,
  ) async {
    emit(state.copyWith(isUsingCode: true, clearError: true, clearSuccess: true));

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
    emit(state.copyWith(isCancelling: true, clearError: true, clearSuccess: true));

    final result = await _loyaltyDatasource.cancelRedemption(event.redemptionId);

    result.fold(
      (error) => emit(state.copyWith(isCancelling: false, error: error)),
      (redemption) {
        // Update redemptions list
        final updatedRedemptions = state.redemptions.map((r) {
          return r.id == event.redemptionId ? redemption : r;
        }).toList();
        emit(state.copyWith(
          isCancelling: false,
          redemptions: updatedRedemptions,
          successMessage: 'Penukaran dibatalkan, poin dikembalikan.',
        ));
      },
    );
  }

  Future<void> _onAdjustPoints(
    AdjustPoints event,
    Emitter<LoyaltyState> emit,
  ) async {
    emit(state.copyWith(isAdjusting: true, clearError: true, clearSuccess: true));

    final result = await _loyaltyDatasource.adjustPoints(
      event.customerId,
      points: event.points,
      description: event.description,
    );

    result.fold(
      (error) => emit(state.copyWith(isAdjusting: false, error: error)),
      (data) {
        final newBalance = data['new_balance'] as int;
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
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }
}
```

---

## Referral BLoC

### Events

```dart
// lib/presentation/referral/bloc/referral_event.dart

import 'package:equatable/equatable.dart';

abstract class ReferralEvent extends Equatable {
  const ReferralEvent();

  @override
  List<Object?> get props => [];
}

class FetchReferralInfo extends ReferralEvent {
  final int customerId;

  const FetchReferralInfo(this.customerId);

  @override
  List<Object?> get props => [customerId];
}

class FetchReferralHistory extends ReferralEvent {
  final int customerId;
  final int page;

  const FetchReferralHistory(this.customerId, {this.page = 1});

  @override
  List<Object?> get props => [customerId, page];
}

class FetchReferredCustomers extends ReferralEvent {
  final int customerId;
  final int page;

  const FetchReferredCustomers(this.customerId, {this.page = 1});

  @override
  List<Object?> get props => [customerId, page];
}

class ValidateReferralCode extends ReferralEvent {
  final String code;

  const ValidateReferralCode(this.code);

  @override
  List<Object?> get props => [code];
}

class ApplyReferralCode extends ReferralEvent {
  final int customerId;
  final String code;

  const ApplyReferralCode(this.customerId, this.code);

  @override
  List<Object?> get props => [customerId, code];
}

class FetchProgramInfo extends ReferralEvent {
  const FetchProgramInfo();
}

class ClearReferralError extends ReferralEvent {
  const ClearReferralError();
}
```

### States

```dart
// lib/presentation/referral/bloc/referral_state.dart

import 'package:equatable/equatable.dart';

class ReferralState extends Equatable {
  final ReferralInfo? referralInfo;
  final ReferralProgramInfo? programInfo;
  final List<ReferralLogModel> history;
  final List<CustomerModel> referredCustomers;
  final PaginationMeta? historyMeta;
  final PaginationMeta? referredMeta;
  final bool isLoadingInfo;
  final bool isLoadingHistory;
  final bool isLoadingReferred;
  final bool isLoadingProgram;
  final bool isValidating;
  final bool isApplying;
  final Map<String, dynamic>? validationResult;
  final String? error;
  final String? successMessage;

  const ReferralState({
    this.referralInfo,
    this.programInfo,
    this.history = const [],
    this.referredCustomers = const [],
    this.historyMeta,
    this.referredMeta,
    this.isLoadingInfo = false,
    this.isLoadingHistory = false,
    this.isLoadingReferred = false,
    this.isLoadingProgram = false,
    this.isValidating = false,
    this.isApplying = false,
    this.validationResult,
    this.error,
    this.successMessage,
  });

  ReferralState copyWith({
    ReferralInfo? referralInfo,
    ReferralProgramInfo? programInfo,
    List<ReferralLogModel>? history,
    List<CustomerModel>? referredCustomers,
    PaginationMeta? historyMeta,
    PaginationMeta? referredMeta,
    bool? isLoadingInfo,
    bool? isLoadingHistory,
    bool? isLoadingReferred,
    bool? isLoadingProgram,
    bool? isValidating,
    bool? isApplying,
    Map<String, dynamic>? validationResult,
    String? error,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearValidation = false,
  }) {
    return ReferralState(
      referralInfo: referralInfo ?? this.referralInfo,
      programInfo: programInfo ?? this.programInfo,
      history: history ?? this.history,
      referredCustomers: referredCustomers ?? this.referredCustomers,
      historyMeta: historyMeta ?? this.historyMeta,
      referredMeta: referredMeta ?? this.referredMeta,
      isLoadingInfo: isLoadingInfo ?? this.isLoadingInfo,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      isLoadingReferred: isLoadingReferred ?? this.isLoadingReferred,
      isLoadingProgram: isLoadingProgram ?? this.isLoadingProgram,
      isValidating: isValidating ?? this.isValidating,
      isApplying: isApplying ?? this.isApplying,
      validationResult: clearValidation ? null : (validationResult ?? this.validationResult),
      error: clearError ? null : (error ?? this.error),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
    referralInfo,
    programInfo,
    history,
    referredCustomers,
    historyMeta,
    referredMeta,
    isLoadingInfo,
    isLoadingHistory,
    isLoadingReferred,
    isLoadingProgram,
    isValidating,
    isApplying,
    validationResult,
    error,
    successMessage,
  ];
}
```

### BLoC

```dart
// lib/presentation/referral/bloc/referral_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'referral_event.dart';
import 'referral_state.dart';

class ReferralBloc extends Bloc<ReferralEvent, ReferralState> {
  final ReferralRemoteDatasource _referralDatasource;

  ReferralBloc({required ReferralRemoteDatasource referralDatasource})
      : _referralDatasource = referralDatasource,
        super(const ReferralState()) {
    on<FetchReferralInfo>(_onFetchInfo);
    on<FetchReferralHistory>(_onFetchHistory);
    on<FetchReferredCustomers>(_onFetchReferred);
    on<ValidateReferralCode>(_onValidate);
    on<ApplyReferralCode>(_onApply);
    on<FetchProgramInfo>(_onFetchProgram);
    on<ClearReferralError>(_onClearError);
  }

  Future<void> _onFetchInfo(
    FetchReferralInfo event,
    Emitter<ReferralState> emit,
  ) async {
    emit(state.copyWith(isLoadingInfo: true, clearError: true));

    final result = await _referralDatasource.getCustomerReferral(event.customerId);

    result.fold(
      (error) => emit(state.copyWith(isLoadingInfo: false, error: error)),
      (info) => emit(state.copyWith(isLoadingInfo: false, referralInfo: info)),
    );
  }

  Future<void> _onFetchHistory(
    FetchReferralHistory event,
    Emitter<ReferralState> emit,
  ) async {
    emit(state.copyWith(isLoadingHistory: true, clearError: true));

    final result = await _referralDatasource.getReferralHistory(
      event.customerId,
      page: event.page,
    );

    result.fold(
      (error) => emit(state.copyWith(isLoadingHistory: false, error: error)),
      (response) {
        final history = event.page == 1
            ? response.data
            : [...state.history, ...response.data];
        emit(state.copyWith(
          isLoadingHistory: false,
          history: history,
          historyMeta: response.meta,
        ));
      },
    );
  }

  Future<void> _onFetchReferred(
    FetchReferredCustomers event,
    Emitter<ReferralState> emit,
  ) async {
    emit(state.copyWith(isLoadingReferred: true, clearError: true));

    final result = await _referralDatasource.getReferredCustomers(
      event.customerId,
      page: event.page,
    );

    result.fold(
      (error) => emit(state.copyWith(isLoadingReferred: false, error: error)),
      (response) {
        final customers = event.page == 1
            ? response.data
            : [...state.referredCustomers, ...response.data];
        emit(state.copyWith(
          isLoadingReferred: false,
          referredCustomers: customers,
          referredMeta: response.meta,
        ));
      },
    );
  }

  Future<void> _onValidate(
    ValidateReferralCode event,
    Emitter<ReferralState> emit,
  ) async {
    emit(state.copyWith(isValidating: true, clearError: true, clearValidation: true));

    final result = await _referralDatasource.validateCode(event.code);

    result.fold(
      (error) => emit(state.copyWith(isValidating: false, error: error)),
      (data) => emit(state.copyWith(isValidating: false, validationResult: data)),
    );
  }

  Future<void> _onApply(
    ApplyReferralCode event,
    Emitter<ReferralState> emit,
  ) async {
    emit(state.copyWith(isApplying: true, clearError: true, clearSuccess: true));

    final result = await _referralDatasource.applyReferralCode(
      event.customerId,
      event.code,
    );

    result.fold(
      (error) => emit(state.copyWith(isApplying: false, error: error)),
      (data) => emit(state.copyWith(
        isApplying: false,
        successMessage: 'Kode referral berhasil diterapkan!',
      )),
    );
  }

  Future<void> _onFetchProgram(
    FetchProgramInfo event,
    Emitter<ReferralState> emit,
  ) async {
    emit(state.copyWith(isLoadingProgram: true, clearError: true));

    final result = await _referralDatasource.getProgramInfo();

    result.fold(
      (error) => emit(state.copyWith(isLoadingProgram: false, error: error)),
      (info) => emit(state.copyWith(isLoadingProgram: false, programInfo: info)),
    );
  }

  void _onClearError(ClearReferralError event, Emitter<ReferralState> emit) {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }
}
```

---

## Product BLoC

### Events

```dart
// lib/presentation/product/bloc/product_event.dart

import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class FetchProductCategories extends ProductEvent {
  final bool withProducts;
  final bool withCount;

  const FetchProductCategories({
    this.withProducts = false,
    this.withCount = true,
  });

  @override
  List<Object?> get props => [withProducts, withCount];
}

class FetchProducts extends ProductEvent {
  final int? categoryId;
  final String? search;
  final bool inStockOnly;
  final int page;

  const FetchProducts({
    this.categoryId,
    this.search,
    this.inStockOnly = true,
    this.page = 1,
  });

  @override
  List<Object?> get props => [categoryId, search, inStockOnly, page];
}

class SelectProductCategory extends ProductEvent {
  final int? categoryId;

  const SelectProductCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class SearchProducts extends ProductEvent {
  final String query;

  const SearchProducts(this.query);

  @override
  List<Object?> get props => [query];
}

class ClearProductSearch extends ProductEvent {
  const ClearProductSearch();
}
```

### States

```dart
// lib/presentation/product/bloc/product_state.dart

import 'package:equatable/equatable.dart';

class ProductState extends Equatable {
  final List<ProductCategoryModel> categories;
  final List<ProductModel> products;
  final int? selectedCategoryId;
  final String searchQuery;
  final PaginationMeta? productsMeta;
  final bool isLoadingCategories;
  final bool isLoadingProducts;
  final String? error;

  const ProductState({
    this.categories = const [],
    this.products = const [],
    this.selectedCategoryId,
    this.searchQuery = '',
    this.productsMeta,
    this.isLoadingCategories = false,
    this.isLoadingProducts = false,
    this.error,
  });

  ProductState copyWith({
    List<ProductCategoryModel>? categories,
    List<ProductModel>? products,
    int? selectedCategoryId,
    String? searchQuery,
    PaginationMeta? productsMeta,
    bool? isLoadingCategories,
    bool? isLoadingProducts,
    String? error,
    bool clearCategory = false,
    bool clearError = false,
  }) {
    return ProductState(
      categories: categories ?? this.categories,
      products: products ?? this.products,
      selectedCategoryId: clearCategory ? null : (selectedCategoryId ?? this.selectedCategoryId),
      searchQuery: searchQuery ?? this.searchQuery,
      productsMeta: productsMeta ?? this.productsMeta,
      isLoadingCategories: isLoadingCategories ?? this.isLoadingCategories,
      isLoadingProducts: isLoadingProducts ?? this.isLoadingProducts,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
    categories,
    products,
    selectedCategoryId,
    searchQuery,
    productsMeta,
    isLoadingCategories,
    isLoadingProducts,
    error,
  ];
}
```

### BLoC

```dart
// lib/presentation/product/bloc/product_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRemoteDatasource _productDatasource;

  ProductBloc({required ProductRemoteDatasource productDatasource})
      : _productDatasource = productDatasource,
        super(const ProductState()) {
    on<FetchProductCategories>(_onFetchCategories);
    on<FetchProducts>(_onFetchProducts);
    on<SelectProductCategory>(_onSelectCategory);
    on<SearchProducts>(_onSearch);
    on<ClearProductSearch>(_onClearSearch);
  }

  Future<void> _onFetchCategories(
    FetchProductCategories event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(isLoadingCategories: true, clearError: true));

    final result = await _productDatasource.getCategories(
      withProducts: event.withProducts,
      withCount: event.withCount,
    );

    result.fold(
      (error) => emit(state.copyWith(isLoadingCategories: false, error: error)),
      (categories) => emit(state.copyWith(
        isLoadingCategories: false,
        categories: categories,
      )),
    );
  }

  Future<void> _onFetchProducts(
    FetchProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(isLoadingProducts: true, clearError: true));

    final result = await _productDatasource.getProducts(
      categoryId: event.categoryId ?? state.selectedCategoryId,
      search: event.search ?? state.searchQuery,
      inStockOnly: event.inStockOnly,
      page: event.page,
    );

    result.fold(
      (error) => emit(state.copyWith(isLoadingProducts: false, error: error)),
      (response) {
        final products = event.page == 1
            ? response.data
            : [...state.products, ...response.data];
        emit(state.copyWith(
          isLoadingProducts: false,
          products: products,
          productsMeta: response.meta,
        ));
      },
    );
  }

  void _onSelectCategory(
    SelectProductCategory event,
    Emitter<ProductState> emit,
  ) {
    emit(state.copyWith(
      selectedCategoryId: event.categoryId,
      clearCategory: event.categoryId == null,
    ));
    add(const FetchProducts(page: 1));
  }

  void _onSearch(SearchProducts event, Emitter<ProductState> emit) {
    emit(state.copyWith(searchQuery: event.query));
    add(const FetchProducts(page: 1));
  }

  void _onClearSearch(ClearProductSearch event, Emitter<ProductState> emit) {
    emit(state.copyWith(searchQuery: ''));
    add(const FetchProducts(page: 1));
  }
}
```

---

## Settings BLoC

```dart
// lib/presentation/settings/bloc/settings_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object?> get props => [];
}

class FetchSettings extends SettingsEvent {
  const FetchSettings();
}

class FetchBranding extends SettingsEvent {
  const FetchBranding();
}

// State
class SettingsState extends Equatable {
  final SettingsModel? settings;
  final BrandingInfo? branding;
  final bool isLoading;
  final String? error;

  const SettingsState({
    this.settings,
    this.branding,
    this.isLoading = false,
    this.error,
  });

  SettingsState copyWith({
    SettingsModel? settings,
    BrandingInfo? branding,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
      branding: branding ?? this.branding,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  bool hasFeature(String feature) => settings?.hasFeature(feature) ?? false;

  @override
  List<Object?> get props => [settings, branding, isLoading, error];
}

// BLoC
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRemoteDatasource _settingsDatasource;

  SettingsBloc({required SettingsRemoteDatasource settingsDatasource})
      : _settingsDatasource = settingsDatasource,
        super(const SettingsState()) {
    on<FetchSettings>(_onFetchSettings);
    on<FetchBranding>(_onFetchBranding);
  }

  Future<void> _onFetchSettings(
    FetchSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _settingsDatasource.getSettings();

    result.fold(
      (error) => emit(state.copyWith(isLoading: false, error: error)),
      (settings) => emit(state.copyWith(isLoading: false, settings: settings)),
    );
  }

  Future<void> _onFetchBranding(
    FetchBranding event,
    Emitter<SettingsState> emit,
  ) async {
    final result = await _settingsDatasource.getBranding();

    result.fold(
      (error) => emit(state.copyWith(error: error)),
      (branding) => emit(state.copyWith(branding: branding)),
    );
  }
}
```

---

## Dashboard BLoC (Updated)

```dart
// lib/presentation/dashboard/bloc/dashboard_bloc.dart (updated)

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class DashboardEvent extends Equatable {
  const DashboardEvent();
  @override
  List<Object?> get props => [];
}

class FetchDashboard extends DashboardEvent {
  const FetchDashboard();
}

class RefreshDashboard extends DashboardEvent {
  const RefreshDashboard();
}

class FetchDashboardSummary extends DashboardEvent {
  const FetchDashboardSummary();
}

// State
class DashboardState extends Equatable {
  final DashboardModel? dashboard;
  final DashboardSummary? summary;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;

  const DashboardState({
    this.dashboard,
    this.summary,
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
  });

  DashboardState copyWith({
    DashboardModel? dashboard,
    DashboardSummary? summary,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    bool clearError = false,
  }) {
    return DashboardState(
      dashboard: dashboard ?? this.dashboard,
      summary: summary ?? this.summary,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [dashboard, summary, isLoading, isRefreshing, error];
}

// BLoC
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRemoteDatasource _dashboardDatasource;

  DashboardBloc({required DashboardRemoteDatasource dashboardDatasource})
      : _dashboardDatasource = dashboardDatasource,
        super(const DashboardState()) {
    on<FetchDashboard>(_onFetchDashboard);
    on<RefreshDashboard>(_onRefreshDashboard);
    on<FetchDashboardSummary>(_onFetchSummary);
  }

  Future<void> _onFetchDashboard(
    FetchDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _dashboardDatasource.getDashboard();

    result.fold(
      (error) => emit(state.copyWith(isLoading: false, error: error)),
      (dashboard) => emit(state.copyWith(isLoading: false, dashboard: dashboard)),
    );
  }

  Future<void> _onRefreshDashboard(
    RefreshDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(isRefreshing: true, clearError: true));

    final result = await _dashboardDatasource.getDashboard();

    result.fold(
      (error) => emit(state.copyWith(isRefreshing: false, error: error)),
      (dashboard) => emit(state.copyWith(isRefreshing: false, dashboard: dashboard)),
    );
  }

  Future<void> _onFetchSummary(
    FetchDashboardSummary event,
    Emitter<DashboardState> emit,
  ) async {
    final result = await _dashboardDatasource.getSummary();

    result.fold(
      (error) => emit(state.copyWith(error: error)),
      (summary) => emit(state.copyWith(summary: summary)),
    );
  }
}
```

---

## Dependency Injection

```dart
// lib/injection.dart

import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // Auth Local
  getIt.registerLazySingleton<AuthLocalDatasource>(
    () => AuthLocalDatasource(),
  );

  // API Service
  getIt.registerLazySingleton<ApiService>(
    () => ApiService(authLocal: getIt()),
  );

  // Remote Datasources
  getIt.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasource(api: getIt(), authLocal: getIt()),
  );

  getIt.registerLazySingleton<DashboardRemoteDatasource>(
    () => DashboardRemoteDatasource(api: getIt()),
  );

  getIt.registerLazySingleton<SettingsRemoteDatasource>(
    () => SettingsRemoteDatasource(api: getIt()),
  );

  getIt.registerLazySingleton<CustomerRemoteDatasource>(
    () => CustomerRemoteDatasource(api: getIt()),
  );

  getIt.registerLazySingleton<LoyaltyRemoteDatasource>(
    () => LoyaltyRemoteDatasource(api: getIt()),
  );

  getIt.registerLazySingleton<ReferralRemoteDatasource>(
    () => ReferralRemoteDatasource(api: getIt()),
  );

  getIt.registerLazySingleton<ProductRemoteDatasource>(
    () => ProductRemoteDatasource(api: getIt()),
  );

  getIt.registerLazySingleton<StaffRemoteDatasource>(
    () => StaffRemoteDatasource(api: getIt()),
  );

  getIt.registerLazySingleton<ServiceRemoteDatasource>(
    () => ServiceRemoteDatasource(api: getIt()),
  );

  getIt.registerLazySingleton<AppointmentRemoteDatasource>(
    () => AppointmentRemoteDatasource(api: getIt()),
  );

  getIt.registerLazySingleton<TreatmentRemoteDatasource>(
    () => TreatmentRemoteDatasource(api: getIt()),
  );

  getIt.registerLazySingleton<PackageRemoteDatasource>(
    () => PackageRemoteDatasource(api: getIt()),
  );

  getIt.registerLazySingleton<TransactionRemoteDatasource>(
    () => TransactionRemoteDatasource(api: getIt()),
  );
}
```

---

## Usage in App

```dart
// lib/main.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Intl.defaultLocale = 'id_ID';
  setupDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SettingsBloc(settingsDatasource: getIt())..add(const FetchSettings())),
        BlocProvider(create: (_) => DashboardBloc(dashboardDatasource: getIt())),
        BlocProvider(create: (_) => CustomerBloc(customerDatasource: getIt())),
        BlocProvider(create: (_) => LoyaltyBloc(loyaltyDatasource: getIt())),
        BlocProvider(create: (_) => ReferralBloc(referralDatasource: getIt())),
        BlocProvider(create: (_) => ProductBloc(productDatasource: getIt())),
        BlocProvider(create: (_) => ServiceBloc(serviceDatasource: getIt())),
        BlocProvider(create: (_) => AppointmentBloc(appointmentDatasource: getIt())),
      ],
      child: MaterialApp(
        title: 'GlowUp',
        // ...
      ),
    );
  }
}
```
