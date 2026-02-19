import 'appointment_model.dart';
import 'customer_model.dart';
import 'user_model.dart';

/// Transaction model
class TransactionModel {
  final int id;
  final String invoiceNumber;
  final int customerId;
  final int? appointmentId;
  final int? cashierId;
  final double subtotal;
  final String? formattedSubtotal;
  final double discountAmount;
  final String? formattedDiscountAmount;
  final String? discountType;
  final int? pointsUsed;
  final double? pointsDiscount;
  final double taxAmount;
  final double totalAmount;
  final String? formattedTotalAmount;
  final double paidAmount;
  final String? formattedPaidAmount;
  final double? changeAmount;
  final double? outstandingAmount;
  final String? formattedOutstandingAmount;
  final String status;
  final String? statusLabel;
  final bool isPaid;
  final String? notes;
  final DateTime? paidAt;
  final CustomerModel? customer;
  final AppointmentModel? appointment;
  final UserModel? cashier;
  final List<TransactionItemModel>? items;
  final List<PaymentModel>? payments;
  final DateTime? createdAt;

  TransactionModel({
    required this.id,
    required this.invoiceNumber,
    required this.customerId,
    this.appointmentId,
    this.cashierId,
    required this.subtotal,
    this.formattedSubtotal,
    required this.discountAmount,
    this.formattedDiscountAmount,
    this.discountType,
    this.pointsUsed,
    this.pointsDiscount,
    required this.taxAmount,
    required this.totalAmount,
    this.formattedTotalAmount,
    required this.paidAmount,
    this.formattedPaidAmount,
    this.changeAmount,
    this.outstandingAmount,
    this.formattedOutstandingAmount,
    required this.status,
    this.statusLabel,
    required this.isPaid,
    this.notes,
    this.paidAt,
    this.customer,
    this.appointment,
    this.cashier,
    this.items,
    this.payments,
    this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      invoiceNumber: json['invoice_number'] ?? '',
      customerId: json['customer_id'],
      appointmentId: json['appointment_id'],
      cashierId: json['cashier_id'],
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      formattedSubtotal: json['formatted_subtotal'],
      discountAmount: (json['discount_amount'] ?? 0).toDouble(),
      formattedDiscountAmount: json['formatted_discount_amount'],
      discountType: json['discount_type'],
      pointsUsed: json['points_used'],
      pointsDiscount: json['points_discount']?.toDouble(),
      taxAmount: (json['tax_amount'] ?? 0).toDouble(),
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      formattedTotalAmount: json['formatted_total_amount'],
      paidAmount: (json['paid_amount'] ?? 0).toDouble(),
      formattedPaidAmount: json['formatted_paid_amount'],
      changeAmount: json['change_amount']?.toDouble(),
      outstandingAmount: json['outstanding_amount']?.toDouble(),
      formattedOutstandingAmount: json['formatted_outstanding_amount'],
      status: json['status'] ?? 'pending',
      statusLabel: json['status_label'],
      isPaid: json['is_paid'] ?? false,
      notes: json['notes'],
      paidAt:
          json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null,
      customer: json['customer'] != null
          ? CustomerModel.fromJson(json['customer'])
          : null,
      appointment: json['appointment'] != null
          ? AppointmentModel.fromJson(json['appointment'])
          : null,
      cashier:
          json['cashier'] != null ? UserModel.fromJson(json['cashier']) : null,
      items: json['items'] != null
          ? (json['items'] as List)
              .map((e) => TransactionItemModel.fromJson(e))
              .toList()
          : null,
      payments: json['payments'] != null
          ? (json['payments'] as List)
              .map((e) => PaymentModel.fromJson(e))
              .toList()
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'invoice_number': invoiceNumber,
        'customer_id': customerId,
        'appointment_id': appointmentId,
        'cashier_id': cashierId,
        'subtotal': subtotal,
        'discount_amount': discountAmount,
        'discount_type': discountType,
        'points_used': pointsUsed,
        'points_discount': pointsDiscount,
        'tax_amount': taxAmount,
        'total_amount': totalAmount,
        'paid_amount': paidAmount,
        'change_amount': changeAmount,
        'outstanding_amount': outstandingAmount,
        'status': status,
        'is_paid': isPaid,
        'notes': notes,
        'paid_at': paidAt?.toIso8601String(),
        'created_at': createdAt?.toIso8601String(),
      };

  /// Check if transaction is pending
  bool get isPending => status == 'pending';

  /// Check if transaction is partially paid
  bool get isPartiallyPaid => status == 'partial';

  /// Check if transaction is cancelled
  bool get isCancelled => status == 'cancelled';

  /// Check if has discount
  bool get hasDiscount => discountAmount > 0;

  /// Check if used loyalty points
  bool get usedPoints => pointsUsed != null && pointsUsed! > 0;

  /// Get total discount (including points)
  double get totalDiscount => discountAmount + (pointsDiscount ?? 0);

  /// Get display total
  String get displayTotal =>
      formattedTotalAmount ?? 'Rp ${totalAmount.toStringAsFixed(0)}';

  /// Get items count
  int get itemsCount => items?.length ?? 0;
}

/// Transaction item model
class TransactionItemModel {
  final int id;
  final int transactionId;
  final String itemType;
  final int? itemId;
  final String itemName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? notes;

  TransactionItemModel({
    required this.id,
    required this.transactionId,
    required this.itemType,
    this.itemId,
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.notes,
  });

  factory TransactionItemModel.fromJson(Map<String, dynamic> json) {
    return TransactionItemModel(
      id: json['id'],
      transactionId: json['transaction_id'],
      itemType: json['item_type'] ?? 'service',
      itemId: json['item_id'],
      itemName: json['item_name'] ?? '',
      quantity: json['quantity'] ?? 1,
      unitPrice: (json['unit_price'] ?? 0).toDouble(),
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'transaction_id': transactionId,
        'item_type': itemType,
        'item_id': itemId,
        'item_name': itemName,
        'quantity': quantity,
        'unit_price': unitPrice,
        'total_price': totalPrice,
        'notes': notes,
      };

  /// Check if item is a service
  bool get isService => itemType == 'service';

  /// Check if item is a product
  bool get isProduct => itemType == 'product';

  /// Check if item is a package
  bool get isPackage => itemType == 'package';
}

/// Payment model
class PaymentModel {
  final int id;
  final int transactionId;
  final double amount;
  final String paymentMethod;
  final String? paymentMethodLabel;
  final String? referenceNumber;
  final String? notes;
  final int? receivedBy;
  final UserModel? receiver;
  final DateTime paidAt;

  PaymentModel({
    required this.id,
    required this.transactionId,
    required this.amount,
    required this.paymentMethod,
    this.paymentMethodLabel,
    this.referenceNumber,
    this.notes,
    this.receivedBy,
    this.receiver,
    required this.paidAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      transactionId: json['transaction_id'],
      amount: (json['amount'] ?? 0).toDouble(),
      paymentMethod: json['payment_method'] ?? 'cash',
      paymentMethodLabel: json['payment_method_label'],
      referenceNumber: json['reference_number'],
      notes: json['notes'],
      receivedBy: json['received_by'],
      receiver: json['receiver'] != null
          ? UserModel.fromJson(json['receiver'])
          : null,
      paidAt: DateTime.parse(json['paid_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'transaction_id': transactionId,
        'amount': amount,
        'payment_method': paymentMethod,
        'payment_method_label': paymentMethodLabel,
        'reference_number': referenceNumber,
        'notes': notes,
        'received_by': receivedBy,
        'paid_at': paidAt.toIso8601String(),
      };

  /// Check if paid by cash
  bool get isCash => paymentMethod == 'cash';

  /// Check if paid by card
  bool get isCard =>
      paymentMethod == 'debit_card' || paymentMethod == 'credit_card';

  /// Check if paid by transfer
  bool get isTransfer => paymentMethod == 'bank_transfer';

  /// Check if paid by e-wallet
  bool get isEwallet =>
      paymentMethod == 'ovo' ||
      paymentMethod == 'gopay' ||
      paymentMethod == 'dana';
}
