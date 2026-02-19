import '../../../data/models/requests/customer_request_model.dart';

abstract class CustomerEvent {}

class FetchCustomers extends CustomerEvent {}

class SearchCustomers extends CustomerEvent {
  final String query;
  SearchCustomers(this.query);
}

class RefreshCustomers extends CustomerEvent {}

class SelectCustomer extends CustomerEvent {
  final int customerId;
  SelectCustomer(this.customerId);
}

class ClearSelectedCustomer extends CustomerEvent {}

class CreateCustomer extends CustomerEvent {
  final CustomerRequestModel request;
  CreateCustomer(this.request);
}

class UpdateCustomer extends CustomerEvent {
  final int customerId;
  final CustomerRequestModel request;
  UpdateCustomer(this.customerId, this.request);
}

class DeleteCustomer extends CustomerEvent {
  final int customerId;
  DeleteCustomer(this.customerId);
}
