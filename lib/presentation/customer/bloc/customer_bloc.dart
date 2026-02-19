import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/customer_remote_datasource.dart';
import '../../../data/models/responses/customer_model.dart';
import 'customer_event.dart';
import 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final CustomerRemoteDatasource _datasource;
  List<CustomerModel> _allCustomers = [];

  CustomerBloc() : _datasource = CustomerRemoteDatasource(), super(CustomerInitial()) {
    on<FetchCustomers>(_onFetchCustomers);
    on<SearchCustomers>(_onSearchCustomers);
    on<RefreshCustomers>(_onRefreshCustomers);
    on<SelectCustomer>(_onSelectCustomer);
    on<ClearSelectedCustomer>(_onClearSelectedCustomer);
    on<CreateCustomer>(_onCreateCustomer);
    on<UpdateCustomer>(_onUpdateCustomer);
    on<DeleteCustomer>(_onDeleteCustomer);
  }

  Future<void> _onFetchCustomers(
    FetchCustomers event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerLoading());

    final result = await _datasource.getCustomers();

    result.fold(
      (error) => emit(CustomerError(error)),
      (customers) {
        _allCustomers = customers;
        emit(CustomerLoaded(
          customers: customers,
          filteredCustomers: customers,
        ));
      },
    );
  }

  void _onSearchCustomers(
    SearchCustomers event,
    Emitter<CustomerState> emit,
  ) {
    if (state is CustomerLoaded) {
      final currentState = state as CustomerLoaded;
      final query = event.query.toLowerCase();

      final filtered = query.isEmpty
          ? _allCustomers
          : _allCustomers.where((c) {
              return c.name.toLowerCase().contains(query) ||
                  c.phone.contains(query) ||
                  (c.email?.toLowerCase().contains(query) ?? false);
            }).toList();

      emit(currentState.copyWith(
        filteredCustomers: filtered,
        searchQuery: event.query,
      ));
    }
  }

  Future<void> _onRefreshCustomers(
    RefreshCustomers event,
    Emitter<CustomerState> emit,
  ) async {
    final result = await _datasource.getCustomers();

    result.fold(
      (error) => emit(CustomerError(error)),
      (customers) {
        _allCustomers = customers;
        if (state is CustomerLoaded) {
          final currentState = state as CustomerLoaded;
          final query = currentState.searchQuery.toLowerCase();

          final filtered = query.isEmpty
              ? customers
              : customers.where((c) {
                  return c.name.toLowerCase().contains(query) ||
                      c.phone.contains(query) ||
                      (c.email?.toLowerCase().contains(query) ?? false);
                }).toList();

          emit(currentState.copyWith(
            customers: customers,
            filteredCustomers: filtered,
          ));
        } else {
          emit(CustomerLoaded(
            customers: customers,
            filteredCustomers: customers,
          ));
        }
      },
    );
  }

  Future<void> _onSelectCustomer(
    SelectCustomer event,
    Emitter<CustomerState> emit,
  ) async {
    if (state is CustomerLoaded) {
      final currentState = state as CustomerLoaded;
      final customer = _allCustomers.where((c) => c.id == event.customerId).firstOrNull;

      if (customer != null) {
        emit(currentState.copyWith(selectedCustomer: customer));
      }
    }
  }

  void _onClearSelectedCustomer(
    ClearSelectedCustomer event,
    Emitter<CustomerState> emit,
  ) {
    if (state is CustomerLoaded) {
      final currentState = state as CustomerLoaded;
      emit(currentState.copyWith(clearSelected: true));
    }
  }

  Future<void> _onCreateCustomer(
    CreateCustomer event,
    Emitter<CustomerState> emit,
  ) async {
    if (state is CustomerLoaded) {
      final currentState = state as CustomerLoaded;
      emit(currentState.copyWith(isCreating: true));

      final result = await _datasource.createCustomer(event.request);

      result.fold(
        (error) {
          emit(currentState.copyWith(isCreating: false));
          emit(CustomerError(error));
        },
        (newCustomer) {
          _allCustomers.insert(0, newCustomer);

          emit(CustomerCreated(newCustomer));
          emit(currentState.copyWith(
            customers: List.from(_allCustomers),
            filteredCustomers: List.from(_allCustomers),
            isCreating: false,
          ));
        },
      );
    }
  }

  Future<void> _onUpdateCustomer(
    UpdateCustomer event,
    Emitter<CustomerState> emit,
  ) async {
    if (state is CustomerLoaded) {
      final currentState = state as CustomerLoaded;
      emit(currentState.copyWith(isUpdating: true));

      final result = await _datasource.updateCustomer(event.customerId, event.request);

      result.fold(
        (error) {
          emit(currentState.copyWith(isUpdating: false));
          emit(CustomerError(error));
        },
        (updatedCustomer) {
          final index = _allCustomers.indexWhere((c) => c.id == event.customerId);
          if (index != -1) {
            _allCustomers[index] = updatedCustomer;
          }

          emit(CustomerUpdated(updatedCustomer));
          emit(currentState.copyWith(
            customers: List.from(_allCustomers),
            filteredCustomers: List.from(_allCustomers),
            selectedCustomer: updatedCustomer,
            isUpdating: false,
          ));
        },
      );
    }
  }

  Future<void> _onDeleteCustomer(
    DeleteCustomer event,
    Emitter<CustomerState> emit,
  ) async {
    if (state is CustomerLoaded) {
      final currentState = state as CustomerLoaded;
      emit(currentState.copyWith(isDeleting: true));

      final result = await _datasource.deleteCustomer(event.customerId);

      result.fold(
        (error) {
          emit(currentState.copyWith(isDeleting: false));
          emit(CustomerError(error));
        },
        (_) {
          _allCustomers.removeWhere((c) => c.id == event.customerId);

          emit(CustomerDeleted(event.customerId));
          emit(currentState.copyWith(
            customers: List.from(_allCustomers),
            filteredCustomers: List.from(_allCustomers),
            clearSelected: true,
            isDeleting: false,
          ));
        },
      );
    }
  }
}
