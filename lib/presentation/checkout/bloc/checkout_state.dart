import 'package:equatable/equatable.dart';
import '../../../data/models/responses/customer_model.dart';
import '../../../data/models/responses/transaction_model.dart';

class CheckoutCartItem extends Equatable {
  final int itemId;
  final String name;
  final double price;
  final int quantity;
  final String itemType;

  const CheckoutCartItem({
    required this.itemId,
    required this.name,
    required this.price,
    this.quantity = 1,
    this.itemType = 'service',
  });

  CheckoutCartItem copyWith({int? quantity}) {
    return CheckoutCartItem(
      itemId: itemId,
      name: name,
      price: price,
      quantity: quantity ?? this.quantity,
      itemType: itemType,
    );
  }

  double get totalPrice => price * quantity;

  bool get isPackage => itemType == 'package';

  @override
  List<Object?> get props => [itemId, name, price, quantity, itemType];
}

class CheckoutState extends Equatable {
  final List<CheckoutCartItem> cartItems;
  final CustomerModel? selectedCustomer;
  final String paymentMethod;
  final String? discountType;
  final double? discountValue;
  final String notes;
  final bool isSubmitting;
  final TransactionModel? createdTransaction;
  final String? error;
  final String? successMessage;
  final String? loyaltyCode;
  final String? loyaltyRewardName;
  final double? loyaltyDiscount;

  const CheckoutState({
    this.cartItems = const [],
    this.selectedCustomer,
    this.paymentMethod = 'cash',
    this.discountType,
    this.discountValue,
    this.notes = '',
    this.isSubmitting = false,
    this.createdTransaction,
    this.error,
    this.successMessage,
    this.loyaltyCode,
    this.loyaltyRewardName,
    this.loyaltyDiscount,
  });

  CheckoutState copyWith({
    List<CheckoutCartItem>? cartItems,
    CustomerModel? selectedCustomer,
    String? paymentMethod,
    String? discountType,
    double? discountValue,
    String? notes,
    bool? isSubmitting,
    TransactionModel? createdTransaction,
    String? error,
    String? successMessage,
    String? loyaltyCode,
    String? loyaltyRewardName,
    double? loyaltyDiscount,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearCustomer = false,
    bool clearDiscount = false,
    bool clearTransaction = false,
    bool clearLoyalty = false,
  }) {
    return CheckoutState(
      cartItems: cartItems ?? this.cartItems,
      selectedCustomer:
          clearCustomer ? null : (selectedCustomer ?? this.selectedCustomer),
      paymentMethod: paymentMethod ?? this.paymentMethod,
      discountType: clearDiscount ? null : (discountType ?? this.discountType),
      discountValue:
          clearDiscount ? null : (discountValue ?? this.discountValue),
      notes: notes ?? this.notes,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      createdTransaction: clearTransaction
          ? null
          : (createdTransaction ?? this.createdTransaction),
      error: clearError ? null : (error ?? this.error),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
      loyaltyCode:
          clearLoyalty ? null : (loyaltyCode ?? this.loyaltyCode),
      loyaltyRewardName:
          clearLoyalty ? null : (loyaltyRewardName ?? this.loyaltyRewardName),
      loyaltyDiscount:
          clearLoyalty ? null : (loyaltyDiscount ?? this.loyaltyDiscount),
    );
  }

  double get subtotal =>
      cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get discountAmount {
    if (discountType == null || discountValue == null) return 0;
    if (discountType == 'percentage') {
      return subtotal * (discountValue! / 100);
    }
    return discountValue!;
  }

  double get totalDiscount => discountAmount + (loyaltyDiscount ?? 0);

  double get total => subtotal - totalDiscount;

  bool get hasItems => cartItems.isNotEmpty;
  bool get hasCustomer => selectedCustomer != null;
  bool get hasLoyaltyCode => loyaltyCode != null;
  bool get canSubmit => hasItems && hasCustomer && !isSubmitting;

  int get itemCount =>
      cartItems.fold(0, (sum, item) => sum + item.quantity);

  @override
  List<Object?> get props => [
        cartItems,
        selectedCustomer,
        paymentMethod,
        discountType,
        discountValue,
        notes,
        isSubmitting,
        createdTransaction,
        error,
        successMessage,
        loyaltyCode,
        loyaltyRewardName,
        loyaltyDiscount,
      ];
}
