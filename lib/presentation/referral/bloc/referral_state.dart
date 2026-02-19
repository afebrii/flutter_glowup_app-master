import 'package:equatable/equatable.dart';
import '../../../data/models/responses/api_response.dart';
import '../../../data/models/responses/referral_model.dart';

class ReferralState extends Equatable {
  final ReferralInfo? referralInfo;
  final ReferralProgramInfo? programInfo;
  final List<ReferralLogModel> history;
  final List<ReferralLogModel> referredCustomers;
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
    List<ReferralLogModel>? referredCustomers,
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
      validationResult:
          clearValidation ? null : (validationResult ?? this.validationResult),
      error: clearError ? null : (error ?? this.error),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  bool get isLoading =>
      isLoadingInfo || isLoadingHistory || isLoadingReferred || isLoadingProgram;

  bool get hasMoreHistory => historyMeta?.hasMore ?? false;
  bool get hasMoreReferred => referredMeta?.hasMore ?? false;

  bool get isCodeValid => validationResult?['valid'] == true;
  String? get validationMessage => validationResult?['message'];

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
