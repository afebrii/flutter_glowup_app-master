import 'package:equatable/equatable.dart';
import '../../../data/models/responses/customer_model.dart';

abstract class CheckoutEvent extends Equatable {
  const CheckoutEvent();

  @override
  List<Object?> get props => [];
}

class AddCartItem extends CheckoutEvent {
  final int itemId;
  final String name;
  final double price;
  final String itemType; // 'service' or 'package'

  const AddCartItem({
    required this.itemId,
    required this.name,
    required this.price,
    this.itemType = 'service',
  });

  @override
  List<Object?> get props => [itemId, name, price, itemType];
}

class RemoveCartItem extends CheckoutEvent {
  final int index;

  const RemoveCartItem(this.index);

  @override
  List<Object?> get props => [index];
}

class UpdateCartItemQty extends CheckoutEvent {
  final int index;
  final int delta;

  const UpdateCartItemQty(this.index, this.delta);

  @override
  List<Object?> get props => [index, delta];
}

class SelectCustomer extends CheckoutEvent {
  final CustomerModel customer;

  const SelectCustomer(this.customer);

  @override
  List<Object?> get props => [customer];
}

class ClearCustomer extends CheckoutEvent {
  const ClearCustomer();
}

class SetPaymentMethod extends CheckoutEvent {
  final String method;

  const SetPaymentMethod(this.method);

  @override
  List<Object?> get props => [method];
}

class SetDiscount extends CheckoutEvent {
  final String? discountType;
  final double? discountValue;

  const SetDiscount({this.discountType, this.discountValue});

  @override
  List<Object?> get props => [discountType, discountValue];
}

class SetNotes extends CheckoutEvent {
  final String notes;

  const SetNotes(this.notes);

  @override
  List<Object?> get props => [notes];
}

class SubmitCheckout extends CheckoutEvent {
  const SubmitCheckout();
}

class ClearCheckout extends CheckoutEvent {
  const ClearCheckout();
}

class ClearCheckoutError extends CheckoutEvent {
  const ClearCheckoutError();
}

class ApplyLoyaltyCode extends CheckoutEvent {
  final String code;
  final String rewardName;
  final double discountAmount;

  const ApplyLoyaltyCode({
    required this.code,
    required this.rewardName,
    required this.discountAmount,
  });

  @override
  List<Object?> get props => [code, rewardName, discountAmount];
}

class ClearLoyaltyCode extends CheckoutEvent {
  const ClearLoyaltyCode();
}
