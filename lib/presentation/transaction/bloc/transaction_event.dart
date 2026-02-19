import 'package:equatable/equatable.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class FetchTransactions extends TransactionEvent {
  final int? customerId;
  final String? status;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final int page;

  const FetchTransactions({
    this.customerId,
    this.status,
    this.dateFrom,
    this.dateTo,
    this.page = 1,
  });

  @override
  List<Object?> get props => [customerId, status, dateFrom, dateTo, page];
}

class FetchTransactionById extends TransactionEvent {
  final int transactionId;

  const FetchTransactionById(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}

class CreateTransaction extends TransactionEvent {
  final int customerId;
  final int? appointmentId;
  final List<Map<String, dynamic>> items;
  final String? discountType;
  final double? discountAmount;
  final int? pointsUsed;
  final String? notes;

  const CreateTransaction({
    required this.customerId,
    this.appointmentId,
    required this.items,
    this.discountType,
    this.discountAmount,
    this.pointsUsed,
    this.notes,
  });

  @override
  List<Object?> get props => [customerId, appointmentId, items, discountType, discountAmount, pointsUsed, notes];
}

class AddPayment extends TransactionEvent {
  final int transactionId;
  final double amount;
  final String paymentMethod;
  final String? referenceNumber;
  final String? notes;

  const AddPayment({
    required this.transactionId,
    required this.amount,
    required this.paymentMethod,
    this.referenceNumber,
    this.notes,
  });

  @override
  List<Object?> get props => [transactionId, amount, paymentMethod, referenceNumber, notes];
}

class CancelTransaction extends TransactionEvent {
  final int transactionId;
  final String? reason;

  const CancelTransaction(this.transactionId, {this.reason});

  @override
  List<Object?> get props => [transactionId, reason];
}

class FetchReceipt extends TransactionEvent {
  final int transactionId;

  const FetchReceipt(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}

class FetchTodaySummary extends TransactionEvent {
  const FetchTodaySummary();
}

class ClearTransactionError extends TransactionEvent {
  const ClearTransactionError();
}

class ClearTransactionSuccess extends TransactionEvent {
  const ClearTransactionSuccess();
}
