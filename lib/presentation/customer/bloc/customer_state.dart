import '../../../data/models/responses/customer_model.dart';

abstract class CustomerState {}

class CustomerInitial extends CustomerState {}

class CustomerLoading extends CustomerState {}

class CustomerLoaded extends CustomerState {
  final List<CustomerModel> customers;
  final List<CustomerModel> filteredCustomers;
  final CustomerModel? selectedCustomer;
  final String searchQuery;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;

  CustomerLoaded({
    required this.customers,
    required this.filteredCustomers,
    this.selectedCustomer,
    this.searchQuery = '',
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
  });

  CustomerLoaded copyWith({
    List<CustomerModel>? customers,
    List<CustomerModel>? filteredCustomers,
    CustomerModel? selectedCustomer,
    String? searchQuery,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    bool clearSelected = false,
  }) {
    return CustomerLoaded(
      customers: customers ?? this.customers,
      filteredCustomers: filteredCustomers ?? this.filteredCustomers,
      selectedCustomer: clearSelected ? null : (selectedCustomer ?? this.selectedCustomer),
      searchQuery: searchQuery ?? this.searchQuery,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }
}

class CustomerError extends CustomerState {
  final String message;
  CustomerError(this.message);
}

class CustomerCreated extends CustomerState {
  final CustomerModel customer;
  CustomerCreated(this.customer);
}

class CustomerUpdated extends CustomerState {
  final CustomerModel customer;
  CustomerUpdated(this.customer);
}

class CustomerDeleted extends CustomerState {
  final int customerId;
  CustomerDeleted(this.customerId);
}
