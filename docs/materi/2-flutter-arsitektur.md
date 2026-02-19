# Flutter GlowUp Clinic - Arsitektur

## Daftar Isi
1. [Arsitektur Overview](#arsitektur-overview)
2. [Clean Architecture](#clean-architecture)
3. [BLoC Pattern](#bloc-pattern)
4. [Struktur Folder](#struktur-folder)
5. [Data Layer](#data-layer)
6. [Presentation Layer](#presentation-layer)
7. [Core Layer](#core-layer)
8. [Dependency Injection](#dependency-injection)
9. [Error Handling](#error-handling)
10. [Responsive Design](#responsive-design)
11. [State Management Flow](#state-management-flow)
12. [Best Practices](#best-practices)

---

## Arsitektur Overview

Aplikasi GlowUp Clinic menggunakan **Clean Architecture** dengan **BLoC Pattern** untuk state management.

```
┌─────────────────────────────────────────────────────────────────────┐
│                         PRESENTATION LAYER                          │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                          UI WIDGETS                          │   │
│  │   Pages, Layouts (Phone/Tablet), Reusable Components        │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                              │                                       │
│                              ▼                                       │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                            BLOC                              │   │
│  │        Events → Business Logic → States                      │   │
│  └─────────────────────────────────────────────────────────────┘   │
└────────────────────────────────┼────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────┐
│                           DATA LAYER                                │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                       DATASOURCES                            │   │
│  │    Remote (API)              │              Local (Storage)  │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                              │                                       │
│                              ▼                                       │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                          MODELS                              │   │
│  │        Request Models    │    Response Models                │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────┐
│                           CORE LAYER                                │
│  ┌───────────────┐ ┌───────────────┐ ┌───────────────┐             │
│  │  Components   │ │   Constants   │ │  Extensions   │             │
│  └───────────────┘ └───────────────┘ └───────────────┘             │
│  ┌───────────────┐ ┌───────────────┐ ┌───────────────┐             │
│  │    Utils      │ │   Services    │ │    Widgets    │             │
│  └───────────────┘ └───────────────┘ └───────────────┘             │
└─────────────────────────────────────────────────────────────────────┘
```

### Prinsip Arsitektur

| Prinsip | Penjelasan |
|---------|------------|
| **Separation of Concerns** | Setiap layer punya tanggung jawab spesifik |
| **Dependency Rule** | Layer atas bergantung pada layer bawah, tidak sebaliknya |
| **Single Responsibility** | Setiap class/file punya satu tanggung jawab |
| **DRY (Don't Repeat Yourself)** | Kode reusable ada di Core layer |

---

## Clean Architecture

### 3 Layer Utama

#### 1. Presentation Layer
```
📁 lib/presentation/
├── auth/
├── customer/
├── appointment/
├── dashboard/
├── ... (fitur lainnya)
```

**Tanggung jawab**:
- UI rendering (Pages, Widgets)
- User interaction handling
- State management (BLoC)
- Navigation

#### 2. Data Layer
```
📁 lib/data/
├── datasources/
│   ├── auth_remote_datasource.dart
│   ├── auth_local_datasource.dart
│   ├── customer_remote_datasource.dart
│   └── ...
└── models/
    ├── requests/
    └── responses/
```

**Tanggung jawab**:
- API communication
- Local storage (SharedPreferences)
- Data transformation (JSON ↔ Model)

#### 3. Core Layer
```
📁 lib/core/
├── components/    # Reusable UI components
├── constants/     # Colors, Variables
├── extensions/    # Dart extensions
├── services/      # External services
├── utils/         # Utilities
└── widgets/       # Complex reusable widgets
```

**Tanggung jawab**:
- Shared utilities
- Common constants
- Reusable widgets
- External service integrations

---

## BLoC Pattern

### Konsep BLoC

```
┌─────────────────────────────────────────────────────────────┐
│                         BLoC FLOW                            │
│                                                              │
│    ┌──────────┐         ┌──────────┐         ┌──────────┐   │
│    │   UI     │         │   BLOC   │         │   DATA   │   │
│    │ (Widget) │         │ (Logic)  │         │ (Source) │   │
│    └────┬─────┘         └────┬─────┘         └────┬─────┘   │
│         │                    │                    │          │
│    1. User Action            │                    │          │
│         │                    │                    │          │
│         ▼                    │                    │          │
│    ┌─────────┐              │                    │          │
│    │  EVENT  │──────────────▶                    │          │
│    └─────────┘              │                    │          │
│                             │                    │          │
│                        2. Process Event          │          │
│                             │                    │          │
│                             ▼                    │          │
│                        ┌─────────┐              │          │
│                        │ Handler │──────────────▶          │
│                        └─────────┘         3. Fetch Data   │
│                             │                    │          │
│                             │◀───────────────────┤          │
│                             │           4. Return Data     │
│                        5. Emit State            │          │
│                             │                    │          │
│                             ▼                    │          │
│    ┌─────────┐         ┌─────────┐              │          │
│    │   UI    │◀────────│  STATE  │              │          │
│    │ Rebuild │         └─────────┘              │          │
│    └─────────┘                                   │          │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Struktur File BLoC

Setiap fitur memiliki 3 file BLoC:

```
📁 presentation/customer/bloc/
├── customer_bloc.dart     # Business logic
├── customer_event.dart    # Input events
└── customer_state.dart    # Output states
```

### 1. Event (Input)

```dart
// lib/presentation/customer/bloc/customer_event.dart

import 'package:equatable/equatable.dart';
import '../../../data/models/requests/customer_request_model.dart';

/// Base class untuk semua Customer events
abstract class CustomerEvent extends Equatable {
  const CustomerEvent();

  @override
  List<Object?> get props => [];
}

/// Event: Ambil semua customer
class FetchCustomers extends CustomerEvent {}

/// Event: Cari customer berdasarkan query
class SearchCustomers extends CustomerEvent {
  final String query;

  const SearchCustomers(this.query);

  @override
  List<Object?> get props => [query];
}

/// Event: Pilih customer (untuk detail view)
class SelectCustomer extends CustomerEvent {
  final int customerId;

  const SelectCustomer(this.customerId);

  @override
  List<Object?> get props => [customerId];
}

/// Event: Buat customer baru
class CreateCustomer extends CustomerEvent {
  final CustomerRequestModel request;

  const CreateCustomer(this.request);

  @override
  List<Object?> get props => [request];
}

/// Event: Update customer existing
class UpdateCustomer extends CustomerEvent {
  final int customerId;
  final CustomerRequestModel request;

  const UpdateCustomer(this.customerId, this.request);

  @override
  List<Object?> get props => [customerId, request];
}

/// Event: Hapus customer
class DeleteCustomer extends CustomerEvent {
  final int customerId;

  const DeleteCustomer(this.customerId);

  @override
  List<Object?> get props => [customerId];
}
```

### 2. State (Output)

```dart
// lib/presentation/customer/bloc/customer_state.dart

import 'package:equatable/equatable.dart';
import '../../../data/models/responses/customer_model.dart';

/// Base class untuk semua Customer states
abstract class CustomerState extends Equatable {
  const CustomerState();

  @override
  List<Object?> get props => [];
}

/// State: Initial state sebelum ada aksi
class CustomerInitial extends CustomerState {}

/// State: Sedang loading data
class CustomerLoading extends CustomerState {}

/// State: Data berhasil dimuat
class CustomerLoaded extends CustomerState {
  final List<CustomerModel> customers;
  final List<CustomerModel> filteredCustomers;
  final CustomerModel? selectedCustomer;
  final String searchQuery;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;

  const CustomerLoaded({
    required this.customers,
    required this.filteredCustomers,
    this.selectedCustomer,
    this.searchQuery = '',
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
  });

  /// Method untuk membuat copy dengan nilai baru
  CustomerLoaded copyWith({
    List<CustomerModel>? customers,
    List<CustomerModel>? filteredCustomers,
    CustomerModel? selectedCustomer,
    String? searchQuery,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    bool clearSelection = false,
  }) {
    return CustomerLoaded(
      customers: customers ?? this.customers,
      filteredCustomers: filteredCustomers ?? this.filteredCustomers,
      selectedCustomer: clearSelection ? null : (selectedCustomer ?? this.selectedCustomer),
      searchQuery: searchQuery ?? this.searchQuery,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }

  @override
  List<Object?> get props => [
    customers,
    filteredCustomers,
    selectedCustomer,
    searchQuery,
    isCreating,
    isUpdating,
    isDeleting,
  ];
}

/// State: Terjadi error
class CustomerError extends CustomerState {
  final String message;

  const CustomerError(this.message);

  @override
  List<Object?> get props => [message];
}

/// State: Customer berhasil dibuat (untuk trigger notifikasi)
class CustomerCreated extends CustomerState {
  final CustomerModel customer;

  const CustomerCreated(this.customer);

  @override
  List<Object?> get props => [customer];
}

/// State: Customer berhasil diupdate
class CustomerUpdated extends CustomerState {
  final CustomerModel customer;

  const CustomerUpdated(this.customer);

  @override
  List<Object?> get props => [customer];
}

/// State: Customer berhasil dihapus
class CustomerDeleted extends CustomerState {
  final int customerId;

  const CustomerDeleted(this.customerId);

  @override
  List<Object?> get props => [customerId];
}
```

### 3. BLoC (Business Logic)

```dart
// lib/presentation/customer/bloc/customer_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/customer_remote_datasource.dart';
import '../../../data/models/responses/customer_model.dart';
import 'customer_event.dart';
import 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final CustomerRemoteDatasource _datasource;

  // Cache untuk data lokal
  List<CustomerModel> _allCustomers = [];

  CustomerBloc()
      : _datasource = CustomerRemoteDatasource(),
        super(CustomerInitial()) {
    // Register event handlers
    on<FetchCustomers>(_onFetchCustomers);
    on<SearchCustomers>(_onSearchCustomers);
    on<SelectCustomer>(_onSelectCustomer);
    on<CreateCustomer>(_onCreateCustomer);
    on<UpdateCustomer>(_onUpdateCustomer);
    on<DeleteCustomer>(_onDeleteCustomer);
  }

  /// Handler: Fetch semua customer
  Future<void> _onFetchCustomers(
    FetchCustomers event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerLoading());

    final result = await _datasource.getCustomers();

    result.fold(
      // Left = Error
      (error) => emit(CustomerError(error)),
      // Right = Success
      (customers) {
        _allCustomers = customers;
        emit(CustomerLoaded(
          customers: customers,
          filteredCustomers: customers,
        ));
      },
    );
  }

  /// Handler: Search customer
  Future<void> _onSearchCustomers(
    SearchCustomers event,
    Emitter<CustomerState> emit,
  ) async {
    if (state is! CustomerLoaded) return;

    final currentState = state as CustomerLoaded;
    final query = event.query.toLowerCase();

    final filtered = _allCustomers.where((customer) {
      final name = customer.name.toLowerCase();
      final phone = customer.phone?.toLowerCase() ?? '';
      return name.contains(query) || phone.contains(query);
    }).toList();

    emit(currentState.copyWith(
      filteredCustomers: filtered,
      searchQuery: event.query,
    ));
  }

  /// Handler: Select customer untuk detail
  Future<void> _onSelectCustomer(
    SelectCustomer event,
    Emitter<CustomerState> emit,
  ) async {
    if (state is! CustomerLoaded) return;

    final currentState = state as CustomerLoaded;
    final selected = _allCustomers.firstWhere(
      (c) => c.id == event.customerId,
    );

    emit(currentState.copyWith(selectedCustomer: selected));
  }

  /// Handler: Create new customer
  Future<void> _onCreateCustomer(
    CreateCustomer event,
    Emitter<CustomerState> emit,
  ) async {
    if (state is! CustomerLoaded) return;

    final currentState = state as CustomerLoaded;

    // Set loading state
    emit(currentState.copyWith(isCreating: true));

    final result = await _datasource.createCustomer(event.request);

    result.fold(
      (error) {
        emit(CustomerError(error));
        emit(currentState.copyWith(isCreating: false));
      },
      (newCustomer) {
        // Insert ke awal list
        _allCustomers.insert(0, newCustomer);

        // Emit success notification state
        emit(CustomerCreated(newCustomer));

        // Emit updated loaded state
        emit(currentState.copyWith(
          customers: List.from(_allCustomers),
          filteredCustomers: List.from(_allCustomers),
          isCreating: false,
        ));
      },
    );
  }

  /// Handler: Update existing customer
  Future<void> _onUpdateCustomer(
    UpdateCustomer event,
    Emitter<CustomerState> emit,
  ) async {
    if (state is! CustomerLoaded) return;

    final currentState = state as CustomerLoaded;
    emit(currentState.copyWith(isUpdating: true));

    final result = await _datasource.updateCustomer(
      event.customerId,
      event.request,
    );

    result.fold(
      (error) {
        emit(CustomerError(error));
        emit(currentState.copyWith(isUpdating: false));
      },
      (updatedCustomer) {
        // Update di list
        final index = _allCustomers.indexWhere(
          (c) => c.id == event.customerId,
        );
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

  /// Handler: Delete customer
  Future<void> _onDeleteCustomer(
    DeleteCustomer event,
    Emitter<CustomerState> emit,
  ) async {
    if (state is! CustomerLoaded) return;

    final currentState = state as CustomerLoaded;
    emit(currentState.copyWith(isDeleting: true));

    final result = await _datasource.deleteCustomer(event.customerId);

    result.fold(
      (error) {
        emit(CustomerError(error));
        emit(currentState.copyWith(isDeleting: false));
      },
      (_) {
        // Remove dari list
        _allCustomers.removeWhere((c) => c.id == event.customerId);

        emit(CustomerDeleted(event.customerId));
        emit(currentState.copyWith(
          customers: List.from(_allCustomers),
          filteredCustomers: List.from(_allCustomers),
          isDeleting: false,
          clearSelection: true,
        ));
      },
    );
  }
}
```

### Penggunaan BLoC di Widget

```dart
// Di Widget

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomerListPage extends StatelessWidget {
  const CustomerListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pelanggan')),
      body: BlocConsumer<CustomerBloc, CustomerState>(
        // Listener untuk side effects (snackbar, navigation, dll)
        listener: (context, state) {
          if (state is CustomerError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state is CustomerCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Customer ${state.customer.name} berhasil ditambahkan'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        // Builder untuk UI
        builder: (context, state) {
          if (state is CustomerLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CustomerLoaded) {
            if (state.filteredCustomers.isEmpty) {
              return const Center(child: Text('Tidak ada data'));
            }

            return ListView.builder(
              itemCount: state.filteredCustomers.length,
              itemBuilder: (context, index) {
                final customer = state.filteredCustomers[index];
                return CustomerCard(
                  customer: customer,
                  isSelected: customer.id == state.selectedCustomer?.id,
                  onTap: () {
                    // Trigger event
                    context.read<CustomerBloc>().add(
                      SelectCustomer(customer.id),
                    );
                  },
                );
              },
            );
          }

          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    // Show form dialog
    // ...
    // Setelah submit:
    context.read<CustomerBloc>().add(
      CreateCustomer(CustomerRequestModel(...)),
    );
  }
}
```

---

## Struktur Folder

### Struktur Lengkap

```
lib/
├── main.dart                              # Entry point
├── injection.dart                         # Dependency injection setup
│
├── core/                                  # CORE LAYER
│   ├── components/                        # Reusable UI components
│   │   ├── buttons.dart                   # Button variants
│   │   ├── custom_text_field.dart         # Input field
│   │   ├── loading_indicator.dart         # Loading animation
│   │   ├── spaces.dart                    # Spacing utilities
│   │   └── status_badge.dart              # Status display
│   │
│   ├── constants/                         # App constants
│   │   ├── colors.dart                    # Color palette
│   │   └── variables.dart                 # API URLs, configs
│   │
│   ├── extensions/                        # Dart extensions
│   │   ├── build_context_ext.dart         # Context helpers
│   │   ├── date_time_ext.dart             # Date formatting
│   │   ├── double_ext.dart                # Number formatting
│   │   ├── int_ext.dart                   # Integer helpers
│   │   └── string_ext.dart                # String utilities
│   │
│   ├── services/                          # External services
│   │   └── printer_service.dart           # Thermal printer
│   │
│   ├── utils/                             # Utilities
│   │   └── screen_size.dart               # Responsive helpers
│   │
│   └── widgets/                           # Complex reusable widgets
│       └── responsive_widget.dart         # Responsive builder
│
├── data/                                  # DATA LAYER
│   ├── datasources/                       # Data sources
│   │   ├── api_service.dart               # HTTP client base
│   │   ├── auth_local_datasource.dart     # Token storage
│   │   ├── auth_remote_datasource.dart    # Auth API
│   │   ├── appointment_remote_datasource.dart
│   │   ├── customer_remote_datasource.dart
│   │   ├── dashboard_remote_datasource.dart
│   │   ├── loyalty_remote_datasource.dart
│   │   ├── package_remote_datasource.dart
│   │   ├── product_remote_datasource.dart
│   │   ├── referral_remote_datasource.dart
│   │   ├── report_remote_datasource.dart
│   │   ├── service_remote_datasource.dart
│   │   ├── settings_remote_datasource.dart
│   │   ├── staff_remote_datasource.dart
│   │   ├── transaction_remote_datasource.dart
│   │   └── treatment_remote_datasource.dart
│   │
│   └── models/                            # Data models
│       ├── requests/                      # Request body models
│       │   ├── appointment_request_model.dart
│       │   ├── customer_request_model.dart
│       │   └── login_request_model.dart
│       │
│       └── responses/                     # API response models
│           ├── api_response.dart
│           ├── appointment_model.dart
│           ├── auth_response_model.dart
│           ├── customer_model.dart
│           ├── dashboard_model.dart
│           ├── loyalty_point_model.dart
│           ├── loyalty_redemption_model.dart
│           ├── loyalty_reward_model.dart
│           ├── package_model.dart
│           ├── product_model.dart
│           ├── referral_model.dart
│           ├── report_model.dart
│           ├── service_category_model.dart
│           ├── service_model.dart
│           ├── settings_model.dart
│           ├── transaction_model.dart
│           ├── treatment_record_model.dart
│           └── user_model.dart
│
└── presentation/                          # PRESENTATION LAYER
    ├── appointment/
    │   ├── bloc/
    │   │   ├── appointment_bloc.dart
    │   │   ├── appointment_event.dart
    │   │   └── appointment_state.dart
    │   ├── pages/
    │   │   ├── appointment_calendar_page.dart
    │   │   └── add_appointment_page.dart
    │   └── widgets/
    │       ├── appointment_card.dart
    │       ├── appointment_detail_panel.dart
    │       └── time_slot_picker.dart
    │
    ├── auth/
    │   ├── bloc/
    │   │   ├── login/
    │   │   │   ├── login_bloc.dart
    │   │   │   ├── login_event.dart
    │   │   │   └── login_state.dart
    │   │   └── logout/
    │   │       ├── logout_bloc.dart
    │   │       ├── logout_event.dart
    │   │       └── logout_state.dart
    │   └── pages/
    │       ├── login_page.dart
    │       └── splash_page.dart
    │
    ├── checkout/
    │   ├── bloc/
    │   │   ├── checkout_bloc.dart
    │   │   ├── checkout_event.dart
    │   │   └── checkout_state.dart
    │   └── pages/
    │       └── checkout_page.dart
    │
    ├── customer/
    │   ├── bloc/
    │   │   ├── customer_bloc.dart
    │   │   ├── customer_event.dart
    │   │   └── customer_state.dart
    │   ├── pages/
    │   │   └── customer_list_page.dart
    │   └── widgets/
    │       ├── customer_card.dart
    │       ├── customer_detail_panel.dart
    │       └── customer_form_dialog.dart
    │
    ├── dashboard/
    │   ├── bloc/
    │   │   ├── dashboard_bloc.dart
    │   │   ├── dashboard_event.dart
    │   │   └── dashboard_state.dart
    │   ├── pages/
    │   │   └── dashboard_page.dart
    │   └── widgets/
    │       ├── dashboard_phone_layout.dart
    │       ├── dashboard_tablet_layout.dart
    │       ├── revenue_chart.dart
    │       ├── stats_card.dart
    │       └── today_appointments_list.dart
    │
    ├── home/
    │   ├── pages/
    │   │   └── home_page.dart
    │   └── widgets/
    │       └── drawer_widget.dart
    │
    ├── loyalty/
    │   ├── bloc/
    │   │   ├── loyalty_bloc.dart
    │   │   ├── loyalty_event.dart
    │   │   └── loyalty_state.dart
    │   ├── pages/
    │   │   └── loyalty_page.dart
    │   └── widgets/
    │       ├── loyalty_points_history.dart
    │       ├── loyalty_rewards_grid.dart
    │       ├── loyalty_summary_card.dart
    │       └── redeem_reward_dialog.dart
    │
    ├── package/
    │   ├── bloc/
    │   │   ├── package_bloc.dart
    │   │   ├── package_event.dart
    │   │   └── package_state.dart
    │   └── pages/
    │       ├── package_page.dart
    │       └── customer_package_page.dart
    │
    ├── product/
    │   ├── bloc/
    │   │   ├── product_bloc.dart
    │   │   ├── product_event.dart
    │   │   └── product_state.dart
    │   ├── pages/
    │   │   └── product_page.dart
    │   └── widgets/
    │       ├── product_card.dart
    │       ├── product_category_chips.dart
    │       └── products_grid.dart
    │
    ├── referral/
    │   ├── bloc/
    │   │   ├── referral_bloc.dart
    │   │   ├── referral_event.dart
    │   │   └── referral_state.dart
    │   ├── pages/
    │   │   └── referral_page.dart
    │   └── widgets/
    │       ├── referral_history_list.dart
    │       ├── apply_referral_form.dart
    │       └── referral_info_card.dart
    │
    ├── report/
    │   ├── bloc/
    │   │   ├── report_bloc.dart
    │   │   ├── report_event.dart
    │   │   └── report_state.dart
    │   └── pages/
    │       └── report_page.dart
    │
    ├── service/
    │   ├── bloc/
    │   │   ├── service_bloc.dart
    │   │   ├── service_event.dart
    │   │   └── service_state.dart
    │   ├── pages/
    │   │   └── service_list_page.dart
    │   └── widgets/
    │       ├── category_chip.dart
    │       └── service_card.dart
    │
    ├── settings/
    │   ├── bloc/
    │   │   └── settings_bloc.dart
    │   ├── pages/
    │   │   └── settings_page.dart
    │   └── widgets/
    │       ├── clinic_info_card.dart
    │       ├── feature_toggle_widget.dart
    │       └── operating_hours_widget.dart
    │
    ├── staff/
    │   ├── bloc/
    │   │   └── staff_bloc.dart
    │   ├── pages/
    │   │   └── staff_page.dart
    │   └── widgets/
    │       ├── beautician_picker.dart
    │       └── staff_availability.dart
    │
    ├── transaction/
    │   ├── bloc/
    │   │   ├── transaction_bloc.dart
    │   │   ├── transaction_event.dart
    │   │   └── transaction_state.dart
    │   └── pages/
    │       └── transaction_page.dart
    │
    └── treatment/
        ├── bloc/
        │   ├── treatment_bloc.dart
        │   ├── treatment_event.dart
        │   └── treatment_state.dart
        └── pages/
            ├── treatment_page.dart
            └── add_treatment_page.dart
```

### Aturan Penamaan File

| Type | Convention | Contoh |
|------|------------|--------|
| File | snake_case | `customer_bloc.dart` |
| Class | PascalCase | `CustomerBloc` |
| Variable | camelCase | `selectedCustomer` |
| Constant | camelCase | `apiBaseUrl` |
| Private | _underscore | `_allCustomers` |

---

## Data Layer

### API Service (HTTP Client)

```dart
// lib/data/datasources/api_service.dart

import 'dart:convert';
import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/variables.dart';
import 'auth_local_datasource.dart';

class ApiService {
  final AuthLocalDatasource _authLocal;

  ApiService({required AuthLocalDatasource authLocal})
      : _authLocal = authLocal;

  /// Mendapatkan headers dengan token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authLocal.getToken();
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// HTTP GET request
  Future<Either<String, Map<String, dynamic>>> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final uri = Uri.parse('${Variables.apiBaseUrl}$endpoint').replace(
        queryParameters: queryParams?.map(
          (key, value) => MapEntry(key, value.toString()),
        ),
      );

      log('GET: $uri');

      final response = await http.get(uri, headers: await _getHeaders());

      return _handleResponse(response);
    } catch (e) {
      log('GET Error: $e');
      return Left('Network error: $e');
    }
  }

  /// HTTP POST request
  Future<Either<String, Map<String, dynamic>>> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse('${Variables.apiBaseUrl}$endpoint');

      log('POST: $uri');
      log('Body: $body');

      final response = await http.post(
        uri,
        headers: await _getHeaders(),
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse(response);
    } catch (e) {
      log('POST Error: $e');
      return Left('Network error: $e');
    }
  }

  /// HTTP PUT request
  Future<Either<String, Map<String, dynamic>>> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse('${Variables.apiBaseUrl}$endpoint');

      log('PUT: $uri');

      final response = await http.put(
        uri,
        headers: await _getHeaders(),
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse(response);
    } catch (e) {
      log('PUT Error: $e');
      return Left('Network error: $e');
    }
  }

  /// HTTP DELETE request
  Future<Either<String, Map<String, dynamic>>> delete(String endpoint) async {
    try {
      final uri = Uri.parse('${Variables.apiBaseUrl}$endpoint');

      log('DELETE: $uri');

      final response = await http.delete(uri, headers: await _getHeaders());

      return _handleResponse(response);
    } catch (e) {
      log('DELETE Error: $e');
      return Left('Network error: $e');
    }
  }

  /// Handle HTTP response
  Either<String, Map<String, dynamic>> _handleResponse(http.Response response) {
    log('Response [${response.statusCode}]: ${response.body}');

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    switch (response.statusCode) {
      case 200:
      case 201:
        return Right(body);
      case 401:
        // Token expired
        return const Left('Sesi telah berakhir. Silakan login kembali.');
      case 422:
        // Validation error
        final errors = body['errors'] as Map<String, dynamic>?;
        if (errors != null) {
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            return Left(firstError.first.toString());
          }
        }
        return Left(body['message'] ?? 'Validation error');
      case 404:
        return const Left('Data tidak ditemukan');
      case 500:
        return const Left('Server error. Coba lagi nanti.');
      default:
        return Left(body['message'] ?? 'Terjadi kesalahan');
    }
  }
}
```

### Remote Datasource (Contoh)

```dart
// lib/data/datasources/customer_remote_datasource.dart

import 'package:dartz/dartz.dart';
import '../models/requests/customer_request_model.dart';
import '../models/responses/customer_model.dart';
import 'api_service.dart';
import '../../injection.dart';

class CustomerRemoteDatasource {
  final ApiService _api;

  CustomerRemoteDatasource() : _api = getIt<ApiService>();

  /// Get semua customer
  Future<Either<String, List<CustomerModel>>> getCustomers({
    int page = 1,
    int perPage = 20,
    String? search,
  }) async {
    final result = await _api.get(
      '/customers',
      queryParams: {
        'page': page,
        'per_page': perPage,
        if (search != null) 'search': search,
      },
    );

    return result.fold(
      (error) => Left(error),
      (data) {
        final list = (data['data'] as List)
            .map((json) => CustomerModel.fromJson(json))
            .toList();
        return Right(list);
      },
    );
  }

  /// Get detail customer by ID
  Future<Either<String, CustomerModel>> getCustomerById(int id) async {
    final result = await _api.get('/customers/$id');

    return result.fold(
      (error) => Left(error),
      (data) => Right(CustomerModel.fromJson(data['data'])),
    );
  }

  /// Create customer baru
  Future<Either<String, CustomerModel>> createCustomer(
    CustomerRequestModel request,
  ) async {
    final result = await _api.post('/customers', body: request.toJson());

    return result.fold(
      (error) => Left(error),
      (data) => Right(CustomerModel.fromJson(data['data'])),
    );
  }

  /// Update customer
  Future<Either<String, CustomerModel>> updateCustomer(
    int id,
    CustomerRequestModel request,
  ) async {
    final result = await _api.put('/customers/$id', body: request.toJson());

    return result.fold(
      (error) => Left(error),
      (data) => Right(CustomerModel.fromJson(data['data'])),
    );
  }

  /// Delete customer
  Future<Either<String, void>> deleteCustomer(int id) async {
    final result = await _api.delete('/customers/$id');

    return result.fold(
      (error) => Left(error),
      (_) => const Right(null),
    );
  }
}
```

### Model (Contoh)

```dart
// lib/data/models/responses/customer_model.dart

import 'package:equatable/equatable.dart';

class CustomerModel extends Equatable {
  final int id;
  final String name;
  final String? phone;
  final String? email;
  final DateTime? birthDate;
  final String? address;
  final String? notes;
  final int loyaltyPoints;
  final String? referralCode;
  final String? tier;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CustomerModel({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.birthDate,
    this.address,
    this.notes,
    this.loyaltyPoints = 0,
    this.referralCode,
    this.tier,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Factory constructor dari JSON
  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as int,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'])
          : null,
      address: json['address'] as String?,
      notes: json['notes'] as String?,
      loyaltyPoints: json['loyalty_points'] as int? ?? 0,
      referralCode: json['referral_code'] as String?,
      tier: json['tier'] as String?,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  /// Convert ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'birth_date': birthDate?.toIso8601String(),
      'address': address,
      'notes': notes,
      'loyalty_points': loyaltyPoints,
      'referral_code': referralCode,
      'tier': tier,
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    phone,
    email,
    birthDate,
    address,
    notes,
    loyaltyPoints,
    referralCode,
    tier,
  ];
}
```

```dart
// lib/data/models/requests/customer_request_model.dart

class CustomerRequestModel {
  final String name;
  final String? phone;
  final String? email;
  final DateTime? birthDate;
  final String? address;
  final String? notes;

  const CustomerRequestModel({
    required this.name,
    this.phone,
    this.email,
    this.birthDate,
    this.address,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (birthDate != null) 'birth_date': birthDate!.toIso8601String(),
      if (address != null) 'address': address,
      if (notes != null) 'notes': notes,
    };
  }
}
```

---

## Presentation Layer

### Page Structure

```dart
// lib/presentation/customer/pages/customer_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/widgets/responsive_widget.dart';
import '../bloc/customer_bloc.dart';
import '../bloc/customer_event.dart';
import '../widgets/customer_phone_layout.dart';
import '../widgets/customer_tablet_layout.dart';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  @override
  void initState() {
    super.initState();
    // Trigger fetch on init
    context.read<CustomerBloc>().add(FetchCustomers());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pelanggan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Show search
            },
          ),
        ],
      ),
      body: ResponsiveWidget(
        phone: const CustomerPhoneLayout(),
        tablet: const CustomerTabletLayout(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show add dialog
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

### Phone Layout

```dart
// lib/presentation/customer/widgets/customer_phone_layout.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/customer_bloc.dart';
import '../bloc/customer_state.dart';
import 'customer_card.dart';

class CustomerPhoneLayout extends StatelessWidget {
  const CustomerPhoneLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerBloc, CustomerState>(
      builder: (context, state) {
        if (state is CustomerLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is CustomerError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(state.message),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<CustomerBloc>().add(FetchCustomers());
                  },
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        if (state is CustomerLoaded) {
          if (state.filteredCustomers.isEmpty) {
            return const Center(
              child: Text('Tidak ada pelanggan'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<CustomerBloc>().add(FetchCustomers());
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.filteredCustomers.length,
              itemBuilder: (context, index) {
                final customer = state.filteredCustomers[index];
                return CustomerCard(
                  customer: customer,
                  onTap: () {
                    // Navigate to detail page (phone)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CustomerDetailPage(
                          customer: customer,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        }

        return const SizedBox();
      },
    );
  }
}
```

### Tablet Layout (Master-Detail)

```dart
// lib/presentation/customer/widgets/customer_tablet_layout.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/responses/customer_model.dart';
import '../bloc/customer_bloc.dart';
import '../bloc/customer_event.dart';
import '../bloc/customer_state.dart';
import 'customer_card.dart';
import 'customer_detail_panel.dart';

class CustomerTabletLayout extends StatelessWidget {
  const CustomerTabletLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerBloc, CustomerState>(
      builder: (context, state) {
        if (state is CustomerLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is CustomerLoaded) {
          return Row(
            children: [
              // Left Panel - Customer List (40%)
              Expanded(
                flex: 40,
                child: _buildListPanel(context, state),
              ),

              // Divider
              const VerticalDivider(width: 1),

              // Right Panel - Customer Detail (60%)
              Expanded(
                flex: 60,
                child: _buildDetailPanel(state),
              ),
            ],
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildListPanel(BuildContext context, CustomerLoaded state) {
    if (state.filteredCustomers.isEmpty) {
      return const Center(child: Text('Tidak ada pelanggan'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.filteredCustomers.length,
      itemBuilder: (context, index) {
        final customer = state.filteredCustomers[index];
        final isSelected = customer.id == state.selectedCustomer?.id;

        return CustomerCard(
          customer: customer,
          isSelected: isSelected,
          onTap: () {
            context.read<CustomerBloc>().add(
              SelectCustomer(customer.id),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailPanel(CustomerLoaded state) {
    if (state.selectedCustomer == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Pilih pelanggan untuk melihat detail',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return CustomerDetailPanel(
      customer: state.selectedCustomer!,
      isUpdating: state.isUpdating,
      isDeleting: state.isDeleting,
    );
  }
}
```

---

## Core Layer

### Colors

```dart
// lib/core/constants/colors.dart

import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // Prevent instantiation

  // ============ PRIMARY COLORS (Rose) ============
  static const Color primary = Color(0xFFf43f5e);        // Rose-500
  static const Color primaryLight = Color(0xFFfb7185);   // Rose-400
  static const Color primaryDark = Color(0xFFe11d48);    // Rose-600
  static const Color primarySurface = Color(0xFFffe4e6); // Rose-100

  // ============ NEUTRAL COLORS ============
  static const Color background = Color(0xFFFFF9F5);     // Cream
  static const Color surface = Color(0xFFFFFFFF);        // White
  static const Color card = Color(0xFFFFEEE8);           // Peach light

  // ============ TEXT COLORS ============
  static const Color textPrimary = Color(0xFF1f2937);    // Gray-800
  static const Color textSecondary = Color(0xFF6b7280);  // Gray-500
  static const Color textMuted = Color(0xFF9ca3af);      // Gray-400
  static const Color textOnPrimary = Colors.white;

  // ============ SEMANTIC COLORS ============
  static const Color success = Color(0xFF22c55e);        // Green-500
  static const Color successLight = Color(0xFFdcfce7);   // Green-100
  static const Color warning = Color(0xFFf59e0b);        // Amber-500
  static const Color warningLight = Color(0xFFfef3c7);   // Amber-100
  static const Color error = Color(0xFFef4444);          // Red-500
  static const Color errorLight = Color(0xFFfee2e2);     // Red-100
  static const Color info = Color(0xFF3b82f6);           // Blue-500
  static const Color infoLight = Color(0xFFdbeafe);      // Blue-100

  // ============ STATUS COLORS ============
  static const Color statusPending = Color(0xFFf59e0b);    // Amber
  static const Color statusConfirmed = Color(0xFF3b82f6);  // Blue
  static const Color statusInProgress = Color(0xFF8b5cf6); // Purple
  static const Color statusCompleted = Color(0xFF22c55e);  // Green
  static const Color statusCancelled = Color(0xFFef4444);  // Red
  static const Color statusNoShow = Color(0xFF6b7280);     // Gray

  // ============ TIER COLORS ============
  static const Color tierBronze = Color(0xFFcd7f32);
  static const Color tierSilver = Color(0xFFc0c0c0);
  static const Color tierGold = Color(0xFFffd700);
  static const Color tierPlatinum = Color(0xFFe5e4e2);

  // ============ DIVIDER & BORDER ============
  static const Color divider = Color(0xFFe5e7eb);        // Gray-200
  static const Color border = Color(0xFFd1d5db);         // Gray-300

  // ============ HELPER METHOD ============
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return statusPending;
      case 'confirmed':
        return statusConfirmed;
      case 'in_progress':
        return statusInProgress;
      case 'completed':
        return statusCompleted;
      case 'cancelled':
        return statusCancelled;
      case 'no_show':
        return statusNoShow;
      default:
        return textMuted;
    }
  }
}
```

### Variables

```dart
// lib/core/constants/variables.dart

class Variables {
  Variables._();

  // ============ API CONFIGURATION ============
  static const String baseUrl = 'http://192.168.18.131:8000';
  static const String apiBaseUrl = '$baseUrl/api/v1';

  // ============ API ENDPOINTS ============
  // Auth
  static const String loginEndpoint = '/login';
  static const String logoutEndpoint = '/logout';
  static const String profileEndpoint = '/profile';

  // Customer
  static const String customersEndpoint = '/customers';

  // Appointment
  static const String appointmentsEndpoint = '/appointments';
  static const String appointmentsTodayEndpoint = '/appointments-today';
  static const String appointmentsAvailableSlotsEndpoint = '/appointments-available-slots';

  // Service
  static const String servicesEndpoint = '/services';
  static const String serviceCategoriesEndpoint = '/service-categories';

  // Product
  static const String productsEndpoint = '/products';
  static const String productCategoriesEndpoint = '/product-categories';

  // Staff
  static const String staffEndpoint = '/staff';
  static const String beauticiansEndpoint = '/staff/beauticians';

  // Package
  static const String packagesEndpoint = '/packages';
  static const String customerPackagesEndpoint = '/customer-packages';

  // Transaction
  static const String transactionsEndpoint = '/transactions';

  // Dashboard
  static const String dashboardEndpoint = '/dashboard';
  static const String dashboardSummaryEndpoint = '/dashboard/summary';

  // Report
  static const String reportsEndpoint = '/reports';
  static const String reportsRevenueEndpoint = '/reports/revenue';
  static const String reportsServicesEndpoint = '/reports/services';

  // Loyalty
  static const String loyaltyRewardsEndpoint = '/loyalty/rewards';
  static const String loyaltyRedemptionsEndpoint = '/loyalty/redemptions';
  static const String loyaltyCheckCodeEndpoint = '/loyalty/check-code';

  // Referral
  static const String referralValidateEndpoint = '/referral/validate';
  static const String referralProgramInfoEndpoint = '/referral/program-info';

  // Settings
  static const String settingsEndpoint = '/settings';
  static const String settingsBrandingEndpoint = '/settings/branding';

  // ============ APP CONFIGURATION ============
  static const int apiTimeoutSeconds = 30;
  static const int paginationLimit = 20;
}
```

### Screen Size Utilities

```dart
// lib/core/utils/screen_size.dart

import 'package:flutter/material.dart';

enum DeviceType { phone, tablet, desktop }

class ScreenSize {
  ScreenSize._();

  // ============ BREAKPOINTS ============
  static const double phoneMaxWidth = 600;
  static const double tabletMaxWidth = 1024;

  // ============ DEVICE TYPE CHECKS ============
  static bool isPhone(BuildContext context) {
    return MediaQuery.of(context).size.width < phoneMaxWidth;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= phoneMaxWidth && width <= tabletMaxWidth;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width > tabletMaxWidth;
  }

  static bool isTabletOrLarger(BuildContext context) {
    return MediaQuery.of(context).size.width >= phoneMaxWidth;
  }

  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < phoneMaxWidth) return DeviceType.phone;
    if (width <= tabletMaxWidth) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  // ============ RESPONSIVE VALUES ============
  static T responsive<T>(
    BuildContext context, {
    required T phone,
    T? tablet,
    T? desktop,
  }) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.phone:
        return phone;
      case DeviceType.tablet:
        return tablet ?? phone;
      case DeviceType.desktop:
        return desktop ?? tablet ?? phone;
    }
  }

  // ============ GRID COLUMNS ============
  static int gridColumns(BuildContext context) {
    return responsive(context, phone: 2, tablet: 3, desktop: 4);
  }

  static int serviceGridColumns(BuildContext context) {
    return responsive(context, phone: 2, tablet: 4, desktop: 5);
  }

  static int productGridColumns(BuildContext context) {
    return responsive(context, phone: 2, tablet: 4, desktop: 4);
  }

  // ============ PADDING ============
  static double responsivePadding(BuildContext context) {
    return responsive(context, phone: 16.0, tablet: 24.0, desktop: 32.0);
  }

  static EdgeInsets responsiveEdgeInsets(BuildContext context) {
    final padding = responsivePadding(context);
    return EdgeInsets.all(padding);
  }

  // ============ FONT SIZE ============
  static double fontSize(BuildContext context, {double base = 14}) {
    return responsive(context, phone: base, tablet: base + 1, desktop: base + 2);
  }

  // ============ CARD SIZE ============
  static double cardWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final columns = gridColumns(context);
    final padding = responsivePadding(context);
    final spacing = 16.0;

    return (width - (padding * 2) - (spacing * (columns - 1))) / columns;
  }
}
```

### Responsive Widget

```dart
// lib/core/widgets/responsive_widget.dart

import 'package:flutter/material.dart';
import '../utils/screen_size.dart';

class ResponsiveWidget extends StatelessWidget {
  final Widget phone;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveWidget({
    super.key,
    required this.phone,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > ScreenSize.tabletMaxWidth) {
          return desktop ?? tablet ?? phone;
        }
        if (constraints.maxWidth >= ScreenSize.phoneMaxWidth) {
          return tablet ?? phone;
        }
        return phone;
      },
    );
  }
}

/// Widget untuk split screen (Master-Detail pattern)
class SplitLayout extends StatelessWidget {
  final Widget master;
  final Widget detail;
  final int masterFlex;
  final int detailFlex;
  final bool showDivider;

  const SplitLayout({
    super.key,
    required this.master,
    required this.detail,
    this.masterFlex = 40,
    this.detailFlex = 60,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Master Panel
        Expanded(
          flex: masterFlex,
          child: master,
        ),
        // Divider
        if (showDivider) const VerticalDivider(width: 1),
        // Detail Panel
        Expanded(
          flex: detailFlex,
          child: detail,
        ),
      ],
    );
  }
}
```

### Extensions

```dart
// lib/core/extensions/date_time_ext.dart

import 'package:intl/intl.dart';

extension DateTimeExt on DateTime {
  /// Format: "15 Feb 2024"
  String toDateString() {
    return DateFormat('d MMM yyyy', 'id_ID').format(this);
  }

  /// Format: "15 Feb 2024, 09:30"
  String toFormattedString() {
    return DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(this);
  }

  /// Format: "09:30"
  String toTimeString() {
    return DateFormat('HH:mm').format(this);
  }

  /// Format: "Senin, 15 Feb 2024"
  String toFullDateString() {
    return DateFormat('EEEE, d MMM yyyy', 'id_ID').format(this);
  }

  /// Check if same day
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  /// Check if today
  bool get isToday => isSameDay(DateTime.now());

  /// Check if yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(yesterday);
  }
}
```

```dart
// lib/core/extensions/int_ext.dart

import 'package:intl/intl.dart';

extension IntExt on int {
  /// Format: "Rp 1.250.000"
  String toCurrencyString() {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(this);
  }

  /// Format: "1.250.000"
  String toFormattedNumber() {
    final formatter = NumberFormat('#,###', 'id_ID');
    return formatter.format(this);
  }

  /// Format duration: "90 menit" -> "1 jam 30 menit"
  String toDurationString() {
    if (this < 60) return '$this menit';
    final hours = this ~/ 60;
    final minutes = this % 60;
    if (minutes == 0) return '$hours jam';
    return '$hours jam $minutes menit';
  }
}
```

---

## Dependency Injection

### Setup dengan GetIt

```dart
// lib/injection.dart

import 'package:get_it/get_it.dart';
import 'data/datasources/api_service.dart';
import 'data/datasources/auth_local_datasource.dart';
import 'data/datasources/auth_remote_datasource.dart';
import 'data/datasources/customer_remote_datasource.dart';
import 'data/datasources/dashboard_remote_datasource.dart';
import 'data/datasources/appointment_remote_datasource.dart';
import 'data/datasources/service_remote_datasource.dart';
import 'data/datasources/product_remote_datasource.dart';
import 'data/datasources/staff_remote_datasource.dart';
import 'data/datasources/package_remote_datasource.dart';
import 'data/datasources/transaction_remote_datasource.dart';
import 'data/datasources/treatment_remote_datasource.dart';
import 'data/datasources/loyalty_remote_datasource.dart';
import 'data/datasources/referral_remote_datasource.dart';
import 'data/datasources/report_remote_datasource.dart';
import 'data/datasources/settings_remote_datasource.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // ============ LOCAL DATASOURCES ============
  getIt.registerLazySingleton<AuthLocalDatasource>(
    () => AuthLocalDatasource(),
  );

  // ============ API SERVICE ============
  getIt.registerLazySingleton<ApiService>(
    () => ApiService(authLocal: getIt<AuthLocalDatasource>()),
  );

  // ============ REMOTE DATASOURCES ============
  getIt.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasource(),
  );

  getIt.registerLazySingleton<DashboardRemoteDatasource>(
    () => DashboardRemoteDatasource(api: getIt<ApiService>()),
  );

  getIt.registerLazySingleton<CustomerRemoteDatasource>(
    () => CustomerRemoteDatasource(),
  );

  getIt.registerLazySingleton<AppointmentRemoteDatasource>(
    () => AppointmentRemoteDatasource(),
  );

  getIt.registerLazySingleton<ServiceRemoteDatasource>(
    () => ServiceRemoteDatasource(),
  );

  getIt.registerLazySingleton<ProductRemoteDatasource>(
    () => ProductRemoteDatasource(),
  );

  getIt.registerLazySingleton<StaffRemoteDatasource>(
    () => StaffRemoteDatasource(),
  );

  getIt.registerLazySingleton<PackageRemoteDatasource>(
    () => PackageRemoteDatasource(),
  );

  getIt.registerLazySingleton<TransactionRemoteDatasource>(
    () => TransactionRemoteDatasource(),
  );

  getIt.registerLazySingleton<TreatmentRemoteDatasource>(
    () => TreatmentRemoteDatasource(),
  );

  getIt.registerLazySingleton<LoyaltyRemoteDatasource>(
    () => LoyaltyRemoteDatasource(),
  );

  getIt.registerLazySingleton<ReferralRemoteDatasource>(
    () => ReferralRemoteDatasource(),
  );

  getIt.registerLazySingleton<ReportRemoteDatasource>(
    () => ReportRemoteDatasource(),
  );

  getIt.registerLazySingleton<SettingsRemoteDatasource>(
    () => SettingsRemoteDatasource(),
  );
}
```

### Main Entry Point

```dart
// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'injection.dart';
import 'core/constants/colors.dart';
import 'presentation/auth/bloc/login/login_bloc.dart';
import 'presentation/auth/bloc/logout/logout_bloc.dart';
import 'presentation/customer/bloc/customer_bloc.dart';
import 'presentation/appointment/bloc/appointment_bloc.dart';
import 'presentation/dashboard/bloc/dashboard_bloc.dart';
import 'presentation/service/bloc/service_bloc.dart';
import 'presentation/product/bloc/product_bloc.dart';
import 'presentation/staff/bloc/staff_bloc.dart';
import 'presentation/checkout/bloc/checkout_bloc.dart';
import 'presentation/transaction/bloc/transaction_bloc.dart';
import 'presentation/loyalty/bloc/loyalty_bloc.dart';
import 'presentation/referral/bloc/referral_bloc.dart';
import 'presentation/report/bloc/report_bloc.dart';
import 'presentation/settings/bloc/settings_bloc.dart';
import 'presentation/auth/pages/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependencies
  setupDependencies();

  // Initialize Indonesian date formatting
  await initializeDateFormatting('id_ID', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Auth
        BlocProvider(create: (_) => LoginBloc()),
        BlocProvider(create: (_) => LogoutBloc()),

        // Features
        BlocProvider(create: (_) => DashboardBloc()),
        BlocProvider(create: (_) => CustomerBloc()),
        BlocProvider(create: (_) => AppointmentBloc()),
        BlocProvider(create: (_) => ServiceBloc()),
        BlocProvider(create: (_) => ProductBloc()),
        BlocProvider(create: (_) => StaffBloc()),
        BlocProvider(create: (_) => CheckoutBloc()),
        BlocProvider(create: (_) => TransactionBloc()),
        BlocProvider(create: (_) => LoyaltyBloc()),
        BlocProvider(create: (_) => ReferralBloc()),
        BlocProvider(create: (_) => ReportBloc()),
        BlocProvider(create: (_) => SettingsBloc()),
      ],
      child: MaterialApp(
        title: 'GlowUp Clinic',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: AppColors.background,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
          ),
        ),
        home: const SplashPage(),
      ),
    );
  }
}
```

---

## Error Handling

### Either Pattern dari dartz

```dart
import 'package:dartz/dartz.dart';

// Either<Left, Right>
// Left = Error (String message)
// Right = Success (Data)

Future<Either<String, CustomerModel>> getCustomer(int id) async {
  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Right(CustomerModel.fromJson(data));
    } else {
      return Left('Error: ${response.statusCode}');
    }
  } catch (e) {
    return Left('Network error: $e');
  }
}

// Penggunaan di BLoC
final result = await _datasource.getCustomer(id);

result.fold(
  (error) => emit(CustomerError(error)),      // Handle Left (error)
  (customer) => emit(CustomerLoaded(customer)), // Handle Right (success)
);
```

### Error States di BLoC

```dart
// Standard error state
class CustomerError extends CustomerState {
  final String message;
  const CustomerError(this.message);
}

// Di widget - tampilkan error
BlocListener<CustomerBloc, CustomerState>(
  listener: (context, state) {
    if (state is CustomerError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () {
              context.read<CustomerBloc>().add(FetchCustomers());
            },
          ),
        ),
      );
    }
  },
  child: ...
)
```

---

## Responsive Design

### Split Screen Ratios

| Page | Master | Detail |
|------|--------|--------|
| Dashboard | 60% | 40% |
| Customer List | 40% | 60% |
| Appointment Calendar | 65% | 35% |
| Checkout/POS | 60% | 40% |
| Transaction History | 40% | 60% |
| Settings | 35% | 65% |

### Implementation Pattern

```dart
class FeatureTabletLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Master (Left Panel)
        Expanded(
          flex: 40,  // 40%
          child: MasterListWidget(),
        ),
        const VerticalDivider(width: 1),
        // Detail (Right Panel)
        Expanded(
          flex: 60,  // 60%
          child: DetailPanelWidget(),
        ),
      ],
    );
  }
}
```

---

## State Management Flow

```
┌───────────────────────────────────────────────────────────────────┐
│                    COMPLETE STATE FLOW                             │
│                                                                    │
│  ┌─────────┐         ┌─────────┐         ┌─────────┐              │
│  │   UI    │         │  BLOC   │         │  DATA   │              │
│  │ Widget  │         │ Handler │         │ Source  │              │
│  └────┬────┘         └────┬────┘         └────┬────┘              │
│       │                   │                   │                    │
│  1. User clicks button    │                   │                    │
│       │                   │                   │                    │
│       ▼                   │                   │                    │
│  context.read<Bloc>()     │                   │                    │
│       .add(Event())       │                   │                    │
│       │                   │                   │                    │
│       └──────────────────►│                   │                    │
│                           │                   │                    │
│              2. Event received                │                    │
│                           │                   │                    │
│                           ▼                   │                    │
│                   emit(Loading())             │                    │
│                           │                   │                    │
│       ◄───────────────────┤                   │                    │
│  3. UI rebuilds           │                   │                    │
│     (shows loader)        │                   │                    │
│                           │                   │                    │
│                           ▼                   │                    │
│                   await datasource            │                    │
│                      .getData()               │                    │
│                           │                   │                    │
│                           └──────────────────►│                    │
│                                               │                    │
│                              4. API call      │                    │
│                                               │                    │
│                           ◄───────────────────┤                    │
│                    5. Either<Error, Data>     │                    │
│                           │                   │                    │
│                           ▼                   │                    │
│                   result.fold(                │                    │
│                     (err) => emit(Error(err)),│                    │
│                     (data) => emit(Loaded(data)),                  │
│                   )                           │                    │
│                           │                   │                    │
│       ◄───────────────────┤                   │                    │
│  6. UI rebuilds           │                   │                    │
│     (shows data/error)    │                   │                    │
│       │                   │                   │                    │
│       ▼                   │                   │                    │
│  BlocBuilder              │                   │                    │
│  returns new widget       │                   │                    │
│                                                                    │
└───────────────────────────────────────────────────────────────────┘
```

---

## Best Practices

### 1. File Organization

```
✅ DO:
- Satu fitur = satu folder di presentation/
- BLoC, pages, widgets terpisah
- Model request dan response terpisah

❌ DON'T:
- Campur logic di widget
- API call langsung dari widget
- State management tanpa BLoC
```

### 2. State Management

```dart
✅ DO:
// Gunakan copyWith untuk immutable state
emit(state.copyWith(isLoading: true));

// Pisahkan success notification state
emit(CustomerCreated(customer));
emit(CustomerLoaded(customers));

❌ DON'T:
// Mutate state langsung
state.customers.add(newCustomer); // SALAH!
emit(state); // SALAH!
```

### 3. Error Handling

```dart
✅ DO:
// Gunakan Either dari dartz
Future<Either<String, Data>> getData();

// Handle di BLoC
result.fold(
  (error) => emit(ErrorState(error)),
  (data) => emit(LoadedState(data)),
);

❌ DON'T:
// Throw exception
throw Exception('Error'); // SALAH!

// Try-catch di widget
try {
  await api.getData();
} catch (e) { } // SALAH - seharusnya di BLoC
```

### 4. Responsive Design

```dart
✅ DO:
// Gunakan ResponsiveWidget
ResponsiveWidget(
  phone: PhoneLayout(),
  tablet: TabletLayout(),
);

// Gunakan ScreenSize utilities
ScreenSize.responsive(context, phone: 16, tablet: 24);

❌ DON'T:
// Hardcode breakpoint
if (MediaQuery.of(context).size.width > 600) // SALAH

// Skip tablet layout
// Phone only // SALAH untuk halaman utama
```

### 5. Widget Building

```dart
✅ DO:
// BlocBuilder untuk UI
BlocBuilder<CustomerBloc, CustomerState>(
  builder: (context, state) { ... }
);

// BlocListener untuk side effects
BlocListener<CustomerBloc, CustomerState>(
  listener: (context, state) {
    // Show snackbar, navigate, etc.
  }
);

// BlocConsumer untuk keduanya
BlocConsumer<CustomerBloc, CustomerState>(
  listener: ...,
  builder: ...,
);

❌ DON'T:
// setState untuk state kompleks
setState(() {
  _customers = newList; // SALAH - gunakan BLoC
});
```

### 6. Naming Convention

| Type | Convention | Contoh |
|------|------------|--------|
| Files | snake_case | `customer_bloc.dart` |
| Classes | PascalCase | `CustomerBloc` |
| Variables | camelCase | `selectedCustomer` |
| Constants | camelCase | `apiBaseUrl` |
| Private | _underscore | `_allCustomers` |
| Events | VerbNoun | `FetchCustomers` |
| States | NounAdjective | `CustomerLoaded` |

---

## Kesimpulan

Arsitektur GlowUp Clinic App dibangun dengan prinsip:

1. **Clean Architecture** - Separation of concerns yang jelas
2. **BLoC Pattern** - Predictable state management
3. **Dependency Injection** - Loose coupling dengan GetIt
4. **Either Pattern** - Functional error handling
5. **Responsive Design** - Support phone & tablet
6. **Immutable State** - Predictable UI updates

---

*Dokumentasi ini dibuat untuk event AFC (Apprentice Flutter Challenge)*
