import 'package:equatable/equatable.dart';
import '../../../data/models/responses/api_response.dart';
import '../../../data/models/responses/transaction_model.dart';

class TransactionState extends Equatable {
  final List<TransactionModel> transactions;
  final TransactionModel? selectedTransaction;
  final Map<String, dynamic>? receipt;
  final Map<String, dynamic>? todaySummary;
  final PaginationMeta? meta;
  final bool isLoading;
  final bool isLoadingDetail;
  final bool isCreating;
  final bool isAddingPayment;
  final bool isCancelling;
  final bool isLoadingReceipt;
  final bool isLoadingSummary;
  final String? error;
  final String? successMessage;

  const TransactionState({
    this.transactions = const [],
    this.selectedTransaction,
    this.receipt,
    this.todaySummary,
    this.meta,
    this.isLoading = false,
    this.isLoadingDetail = false,
    this.isCreating = false,
    this.isAddingPayment = false,
    this.isCancelling = false,
    this.isLoadingReceipt = false,
    this.isLoadingSummary = false,
    this.error,
    this.successMessage,
  });

  TransactionState copyWith({
    List<TransactionModel>? transactions,
    TransactionModel? selectedTransaction,
    Map<String, dynamic>? receipt,
    Map<String, dynamic>? todaySummary,
    PaginationMeta? meta,
    bool? isLoading,
    bool? isLoadingDetail,
    bool? isCreating,
    bool? isAddingPayment,
    bool? isCancelling,
    bool? isLoadingReceipt,
    bool? isLoadingSummary,
    String? error,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearSelected = false,
    bool clearReceipt = false,
  }) {
    return TransactionState(
      transactions: transactions ?? this.transactions,
      selectedTransaction: clearSelected
          ? null
          : (selectedTransaction ?? this.selectedTransaction),
      receipt: clearReceipt ? null : (receipt ?? this.receipt),
      todaySummary: todaySummary ?? this.todaySummary,
      meta: meta ?? this.meta,
      isLoading: isLoading ?? this.isLoading,
      isLoadingDetail: isLoadingDetail ?? this.isLoadingDetail,
      isCreating: isCreating ?? this.isCreating,
      isAddingPayment: isAddingPayment ?? this.isAddingPayment,
      isCancelling: isCancelling ?? this.isCancelling,
      isLoadingReceipt: isLoadingReceipt ?? this.isLoadingReceipt,
      isLoadingSummary: isLoadingSummary ?? this.isLoadingSummary,
      error: clearError ? null : (error ?? this.error),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  bool get hasMore => meta?.hasMore ?? false;

  @override
  List<Object?> get props => [
        transactions,
        selectedTransaction,
        receipt,
        todaySummary,
        meta,
        isLoading,
        isLoadingDetail,
        isCreating,
        isAddingPayment,
        isCancelling,
        isLoadingReceipt,
        isLoadingSummary,
        error,
        successMessage,
      ];
}
