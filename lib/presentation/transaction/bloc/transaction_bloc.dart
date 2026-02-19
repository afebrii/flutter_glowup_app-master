import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/transaction_remote_datasource.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRemoteDatasource _datasource;

  TransactionBloc({required TransactionRemoteDatasource datasource})
      : _datasource = datasource,
        super(const TransactionState()) {
    on<FetchTransactions>(_onFetchTransactions);
    on<FetchTransactionById>(_onFetchById);
    on<CreateTransaction>(_onCreate);
    on<AddPayment>(_onAddPayment);
    on<CancelTransaction>(_onCancel);
    on<FetchReceipt>(_onFetchReceipt);
    on<FetchTodaySummary>(_onFetchTodaySummary);
    on<ClearTransactionError>(_onClearError);
    on<ClearTransactionSuccess>(_onClearSuccess);
  }

  Future<void> _onFetchTransactions(
    FetchTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _datasource.getTransactions(
      customerId: event.customerId,
      status: event.status,
      dateFrom: event.dateFrom,
      dateTo: event.dateTo,
      page: event.page,
    );

    result.fold(
      (error) => emit(state.copyWith(isLoading: false, error: error)),
      (response) {
        final transactions = event.page == 1
            ? response.data
            : [...state.transactions, ...response.data];
        emit(state.copyWith(
          isLoading: false,
          transactions: transactions,
          meta: response.meta,
        ));
      },
    );
  }

  Future<void> _onFetchById(
    FetchTransactionById event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(isLoadingDetail: true, clearError: true));

    final result = await _datasource.getTransactionById(event.transactionId);

    result.fold(
      (error) => emit(state.copyWith(isLoadingDetail: false, error: error)),
      (transaction) => emit(state.copyWith(
        isLoadingDetail: false,
        selectedTransaction: transaction,
      )),
    );
  }

  Future<void> _onCreate(
    CreateTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(
        isCreating: true, clearError: true, clearSuccess: true));

    final result = await _datasource.createTransaction(
      customerId: event.customerId,
      appointmentId: event.appointmentId,
      items: event.items,
      discountType: event.discountType,
      discountAmount: event.discountAmount,
      pointsUsed: event.pointsUsed,
      notes: event.notes,
    );

    result.fold(
      (error) => emit(state.copyWith(isCreating: false, error: error)),
      (transaction) => emit(state.copyWith(
        isCreating: false,
        selectedTransaction: transaction,
        successMessage: 'Transaksi berhasil dibuat!',
      )),
    );
  }

  Future<void> _onAddPayment(
    AddPayment event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(
        isAddingPayment: true, clearError: true, clearSuccess: true));

    final result = await _datasource.addPayment(
      event.transactionId,
      amount: event.amount,
      paymentMethod: event.paymentMethod,
      referenceNumber: event.referenceNumber,
      notes: event.notes,
    );

    result.fold(
      (error) => emit(state.copyWith(isAddingPayment: false, error: error)),
      (transaction) {
        final updatedList = state.transactions.map((t) {
          return t.id == event.transactionId ? transaction : t;
        }).toList();
        emit(state.copyWith(
          isAddingPayment: false,
          transactions: updatedList,
          selectedTransaction: transaction,
          successMessage: 'Pembayaran berhasil ditambahkan!',
        ));
      },
    );
  }

  Future<void> _onCancel(
    CancelTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(
        isCancelling: true, clearError: true, clearSuccess: true));

    final result = await _datasource.cancelTransaction(
      event.transactionId,
      reason: event.reason,
    );

    result.fold(
      (error) => emit(state.copyWith(isCancelling: false, error: error)),
      (transaction) {
        final updatedList = state.transactions.map((t) {
          return t.id == event.transactionId ? transaction : t;
        }).toList();
        emit(state.copyWith(
          isCancelling: false,
          transactions: updatedList,
          selectedTransaction: transaction,
          successMessage: 'Transaksi berhasil dibatalkan.',
        ));
      },
    );
  }

  Future<void> _onFetchReceipt(
    FetchReceipt event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(isLoadingReceipt: true, clearError: true));

    final result = await _datasource.getReceipt(event.transactionId);

    result.fold(
      (error) => emit(state.copyWith(isLoadingReceipt: false, error: error)),
      (receipt) =>
          emit(state.copyWith(isLoadingReceipt: false, receipt: receipt)),
    );
  }

  Future<void> _onFetchTodaySummary(
    FetchTodaySummary event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(isLoadingSummary: true, clearError: true));

    final result = await _datasource.getTodaySummary();

    result.fold(
      (error) => emit(state.copyWith(isLoadingSummary: false, error: error)),
      (summary) =>
          emit(state.copyWith(isLoadingSummary: false, todaySummary: summary)),
    );
  }

  void _onClearError(
      ClearTransactionError event, Emitter<TransactionState> emit) {
    emit(state.copyWith(clearError: true));
  }

  void _onClearSuccess(
      ClearTransactionSuccess event, Emitter<TransactionState> emit) {
    emit(state.copyWith(clearSuccess: true));
  }
}
