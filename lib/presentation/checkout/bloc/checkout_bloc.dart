import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/transaction_remote_datasource.dart';
import 'checkout_event.dart';
import 'checkout_state.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final TransactionRemoteDatasource _transactionDatasource;

  CheckoutBloc({
    required TransactionRemoteDatasource transactionDatasource,
  })  : _transactionDatasource = transactionDatasource,
        super(const CheckoutState()) {
    on<AddCartItem>(_onAddCartItem);
    on<RemoveCartItem>(_onRemoveCartItem);
    on<UpdateCartItemQty>(_onUpdateQty);
    on<SelectCustomer>(_onSelectCustomer);
    on<ClearCustomer>(_onClearCustomer);
    on<SetPaymentMethod>(_onSetPaymentMethod);
    on<SetDiscount>(_onSetDiscount);
    on<SetNotes>(_onSetNotes);
    on<SubmitCheckout>(_onSubmit);
    on<ClearCheckout>(_onClearCheckout);
    on<ClearCheckoutError>(_onClearError);
    on<ApplyLoyaltyCode>(_onApplyLoyaltyCode);
    on<ClearLoyaltyCode>(_onClearLoyaltyCode);
  }

  void _onAddCartItem(AddCartItem event, Emitter<CheckoutState> emit) {
    final items = List<CheckoutCartItem>.from(state.cartItems);
    final existingIndex = items.indexWhere(
      (item) => item.itemId == event.itemId && item.itemType == event.itemType,
    );

    if (existingIndex >= 0) {
      items[existingIndex] = items[existingIndex].copyWith(
        quantity: items[existingIndex].quantity + 1,
      );
    } else {
      items.add(CheckoutCartItem(
        itemId: event.itemId,
        name: event.name,
        price: event.price,
        itemType: event.itemType,
      ));
    }

    emit(state.copyWith(cartItems: items));
  }

  void _onRemoveCartItem(RemoveCartItem event, Emitter<CheckoutState> emit) {
    final items = List<CheckoutCartItem>.from(state.cartItems);
    if (event.index >= 0 && event.index < items.length) {
      items.removeAt(event.index);
    }
    emit(state.copyWith(cartItems: items));
  }

  void _onUpdateQty(UpdateCartItemQty event, Emitter<CheckoutState> emit) {
    final items = List<CheckoutCartItem>.from(state.cartItems);
    if (event.index >= 0 && event.index < items.length) {
      final newQty = items[event.index].quantity + event.delta;
      if (newQty <= 0) {
        items.removeAt(event.index);
      } else {
        items[event.index] = items[event.index].copyWith(quantity: newQty);
      }
    }
    emit(state.copyWith(cartItems: items));
  }

  void _onSelectCustomer(SelectCustomer event, Emitter<CheckoutState> emit) {
    emit(state.copyWith(selectedCustomer: event.customer));
  }

  void _onClearCustomer(ClearCustomer event, Emitter<CheckoutState> emit) {
    emit(state.copyWith(clearCustomer: true));
  }

  void _onSetPaymentMethod(
      SetPaymentMethod event, Emitter<CheckoutState> emit) {
    emit(state.copyWith(paymentMethod: event.method));
  }

  void _onSetDiscount(SetDiscount event, Emitter<CheckoutState> emit) {
    if (event.discountType == null && event.discountValue == null) {
      emit(state.copyWith(clearDiscount: true));
    } else {
      emit(state.copyWith(
        discountType: event.discountType,
        discountValue: event.discountValue,
      ));
    }
  }

  void _onSetNotes(SetNotes event, Emitter<CheckoutState> emit) {
    emit(state.copyWith(notes: event.notes));
  }

  Future<void> _onSubmit(
      SubmitCheckout event, Emitter<CheckoutState> emit) async {
    if (!state.canSubmit) return;

    emit(state.copyWith(
        isSubmitting: true, clearError: true, clearSuccess: true));

    final items = state.cartItems.map((item) {
      final map = <String, dynamic>{
        'item_type': item.itemType,
        'item_name': item.name,
        'quantity': item.quantity,
        'unit_price': item.price,
      };
      // Use the correct ID field based on item_type
      switch (item.itemType) {
        case 'service':
          map['service_id'] = item.itemId;
          break;
        case 'product':
          map['product_id'] = item.itemId;
          break;
        case 'package':
          map['package_id'] = item.itemId;
          break;
      }
      return map;
    }).toList();

    // Step 1: Create transaction
    final result = await _transactionDatasource.createTransaction(
      customerId: state.selectedCustomer!.id,
      items: items,
      discountType: state.discountType,
      discountAmount: state.totalDiscount > 0 ? state.totalDiscount : null,
      notes: state.notes.isNotEmpty ? state.notes : null,
    );

    await result.fold(
      (error) async =>
          emit(state.copyWith(isSubmitting: false, error: error)),
      (transaction) async {
        // Step 2: Record payment
        final payResult = await _transactionDatasource.addPayment(
          transaction.id,
          amount: state.total,
          paymentMethod: state.paymentMethod,
        );

        payResult.fold(
          (error) => emit(state.copyWith(
            isSubmitting: false,
            createdTransaction: transaction,
            error: 'Transaksi dibuat tapi gagal bayar: $error',
          )),
          (paidTransaction) => emit(state.copyWith(
            isSubmitting: false,
            createdTransaction: paidTransaction,
            successMessage:
                'Transaksi ${paidTransaction.invoiceNumber} berhasil!',
          )),
        );
      },
    );
  }

  void _onClearCheckout(ClearCheckout event, Emitter<CheckoutState> emit) {
    emit(const CheckoutState());
  }

  void _onClearError(ClearCheckoutError event, Emitter<CheckoutState> emit) {
    emit(state.copyWith(clearError: true));
  }

  void _onApplyLoyaltyCode(
      ApplyLoyaltyCode event, Emitter<CheckoutState> emit) {
    emit(state.copyWith(
      loyaltyCode: event.code,
      loyaltyRewardName: event.rewardName,
      loyaltyDiscount: event.discountAmount,
    ));
  }

  void _onClearLoyaltyCode(
      ClearLoyaltyCode event, Emitter<CheckoutState> emit) {
    emit(state.copyWith(clearLoyalty: true));
  }
}
