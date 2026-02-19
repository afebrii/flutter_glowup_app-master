# Arsitektur Kode Flutter GlowUp Clinic

Dokumentasi arsitektur dan struktur kode aplikasi Flutter GlowUp Clinic.

---

## Daftar Isi

1. [Overview Arsitektur](#overview-arsitektur)
2. [Struktur Folder](#struktur-folder)
3. [Layer Architecture](#layer-architecture)
4. [State Management (BLoC)](#state-management-bloc)
5. [Data Flow](#data-flow)
6. [Dependency Injection](#dependency-injection)
7. [Code Generation](#code-generation)
8. [Best Practices](#best-practices)

---

## Overview Arsitektur

Aplikasi ini menggunakan **Clean Architecture** yang dimodifikasi dengan pattern **BLoC (Business Logic Component)** untuk state management.

```
┌─────────────────────────────────────────────────────────────┐
│                     Presentation Layer                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │   Pages     │  │   Widgets   │  │   BLoC (State Mgmt) │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                       Data Layer                             │
│  ┌─────────────────────┐  ┌───────────────────────────────┐ │
│  │   Remote Datasource │  │       Local Datasource        │ │
│  │   (API Calls)       │  │   (SharedPrefs, SQLite)       │ │
│  └─────────────────────┘  └───────────────────────────────┘ │
│  ┌─────────────────────────────────────────────────────────┐│
│  │                      Models                              ││
│  │  (Request Models, Response Models, Entity Models)       ││
│  └─────────────────────────────────────────────────────────┘│
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                       Core Layer                             │
│  ┌───────────┐  ┌────────────┐  ┌────────────┐  ┌────────┐ │
│  │ Constants │  │ Extensions │  │ Components │  │ Utils  │ │
│  └───────────┘  └────────────┘  └────────────┘  └────────┘ │
└─────────────────────────────────────────────────────────────┘
```

---

## Struktur Folder

```
lib/
├── main.dart                    # Entry point aplikasi
├── core/                        # Core utilities & shared code
│   ├── constants/
│   │   ├── colors.dart          # Definisi warna tema
│   │   └── variables.dart       # API endpoints & constants
│   ├── extensions/
│   │   ├── build_context_ext.dart   # Navigator extensions
│   │   ├── int_ext.dart             # Currency formatting
│   │   ├── double_ext.dart          # Number formatting
│   │   ├── string_ext.dart          # String utilities
│   │   └── date_time_ext.dart       # Date formatting
│   ├── components/
│   │   ├── buttons.dart         # Reusable button widgets
│   │   ├── custom_text_field.dart
│   │   ├── custom_dropdown.dart
│   │   ├── search_input.dart
│   │   ├── spaces.dart          # SizedBox shortcuts
│   │   ├── loading_indicator.dart
│   │   ├── status_badge.dart    # Status badges
│   │   └── empty_state.dart
│   ├── services/
│   │   └── printer_service.dart # Bluetooth printer service
│   ├── utils/
│   │   └── screen_size.dart     # Screen size helper
│   └── widgets/
│       ├── responsive_widget.dart   # Phone/Tablet layout
│       └── responsive_layout.dart
│
├── data/                        # Data layer
│   ├── datasources/
│   │   ├── auth_local_datasource.dart    # Token & user storage
│   │   ├── auth_remote_datasource.dart   # Auth API
│   │   ├── service_remote_datasource.dart
│   │   ├── customer_remote_datasource.dart
│   │   ├── appointment_remote_datasource.dart
│   │   ├── treatment_remote_datasource.dart
│   │   ├── package_remote_datasource.dart
│   │   ├── transaction_remote_datasource.dart
│   │   ├── dashboard_remote_datasource.dart
│   │   └── report_remote_datasource.dart
│   └── models/
│       ├── requests/            # Request body models
│       │   ├── login_request_model.dart
│       │   ├── customer_request_model.dart
│       │   └── appointment_request_model.dart
│       └── responses/           # API response models
│           ├── auth_response_model.dart
│           ├── user_model.dart
│           ├── service_model.dart
│           ├── customer_model.dart
│           ├── appointment_model.dart
│           └── transaction_model.dart
│
└── presentation/                # UI layer
    ├── auth/
    │   ├── bloc/
    │   │   ├── login/
    │   │   │   ├── login_bloc.dart
    │   │   │   ├── login_event.dart
    │   │   │   └── login_state.dart
    │   │   └── logout/
    │   └── pages/
    │       ├── login_page.dart
    │       └── splash_page.dart
    │
    ├── home/
    │   ├── pages/
    │   │   └── home_page.dart
    │   └── widgets/
    │       ├── drawer_widget.dart
    │       ├── home_phone_layout.dart
    │       └── home_tablet_layout.dart
    │
    ├── dashboard/
    │   ├── bloc/
    │   ├── pages/
    │   │   └── dashboard_page.dart
    │   └── widgets/
    │       ├── dashboard_phone_layout.dart
    │       └── dashboard_tablet_layout.dart
    │
    ├── customer/
    │   ├── bloc/
    │   ├── pages/
    │   │   ├── customer_list_page.dart
    │   │   └── customer_detail_page.dart
    │   └── widgets/
    │       ├── customer_phone_layout.dart
    │       └── customer_tablet_layout.dart
    │
    ├── appointment/
    │   ├── bloc/
    │   ├── pages/
    │   │   ├── appointment_calendar_page.dart
    │   │   └── booking_page.dart
    │   └── widgets/
    │       ├── calendar_phone_layout.dart
    │       └── calendar_tablet_layout.dart
    │
    ├── pos/
    │   ├── bloc/
    │   ├── pages/
    │   │   ├── checkout_page.dart
    │   │   └── payment_page.dart
    │   └── widgets/
    │       ├── checkout_phone_layout.dart
    │       └── checkout_tablet_layout.dart
    │
    └── settings/
        ├── pages/
        └── widgets/
```

---

## Layer Architecture

### 1. Core Layer

Layer ini berisi kode yang digunakan di seluruh aplikasi.

#### Constants

```dart
// lib/core/constants/colors.dart
class AppColors {
  // Primary - Rose
  static const Color primary = Color(0xFFf43f5e);
  static const Color primaryLight = Color(0xFFfb7185);
  static const Color primaryDark = Color(0xFFe11d48);

  // Semantic
  static const Color success = Color(0xFF22c55e);
  static const Color warning = Color(0xFFf59e0b);
  static const Color error = Color(0xFFef4444);
  // ...
}

// lib/core/constants/variables.dart
class Variables {
  static const String baseUrl = 'https://glowup-clinic.server.com';
  static const String apiBaseUrl = '$baseUrl/api/v1';
  static const String login = '$apiBaseUrl/login';
  // ...
}
```

#### Extensions

```dart
// lib/core/extensions/int_ext.dart
extension IntExt on int {
  String get currencyFormat {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(this);
  }
}

// Usage: 50000.currencyFormat => "Rp 50.000"
```

```dart
// lib/core/extensions/build_context_ext.dart
extension BuildContextExt on BuildContext {
  void push(Widget page) {
    Navigator.push(this, MaterialPageRoute(builder: (_) => page));
  }

  void pushAndRemoveUntil(Widget page, bool Function(Route) predicate) {
    Navigator.pushAndRemoveUntil(
      this,
      MaterialPageRoute(builder: (_) => page),
      predicate,
    );
  }
}
```

#### Components (Reusable Widgets)

```dart
// lib/core/components/buttons.dart
class Button {
  static Widget filled({
    required VoidCallback onPressed,
    required String label,
    Color? color,
    double? width,
    bool isLoading = false,
  }) {
    return SizedBox(
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppColors.primary,
        ),
        child: isLoading
            ? const CircularProgressIndicator()
            : Text(label),
      ),
    );
  }
}
```

### 2. Data Layer

#### Remote Datasource

```dart
// lib/data/datasources/customer_remote_datasource.dart
class CustomerRemoteDatasource {
  Future<Either<String, List<CustomerModel>>> getCustomers({
    String? search,
    int page = 1,
  }) async {
    try {
      final token = await AuthLocalDatasource().getToken();
      final queryParams = <String, String>{
        'page': '$page',
      };
      if (search != null) queryParams['search'] = search;

      final uri = Uri.parse(Variables.customers)
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final customers = (data['data'] as List)
            .map((e) => CustomerModel.fromJson(e))
            .toList();
        return Right(customers);
      }
      return Left('Error: ${response.statusCode}');
    } catch (e) {
      return Left(e.toString());
    }
  }
}
```

#### Local Datasource

```dart
// lib/data/datasources/auth_local_datasource.dart
class AuthLocalDatasource {
  static const _tokenKey = 'token';
  static const _userKey = 'user';

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return UserModel.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
```

#### Models

```dart
// lib/data/models/responses/customer_model.dart
class CustomerModel {
  final int id;
  final String name;
  final String phone;
  final String? email;
  final String? skinType;
  final List<String>? skinConcerns;
  final int totalVisits;
  final int totalSpent;

  CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.skinType,
    this.skinConcerns,
    this.totalVisits = 0,
    this.totalSpent = 0,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      skinType: json['skin_type'],
      skinConcerns: json['skin_concerns'] != null
          ? List<String>.from(json['skin_concerns'])
          : null,
      totalVisits: json['total_visits'] ?? 0,
      totalSpent: json['total_spent'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'skin_type': skinType,
      'skin_concerns': skinConcerns,
    };
  }
}
```

### 3. Presentation Layer

#### Pages

```dart
// lib/presentation/customer/pages/customer_list_page.dart
class CustomerListPage extends StatelessWidget {
  const CustomerListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pelanggan')),
      body: ResponsiveWidget(
        phone: const CustomerPhoneLayout(),
        tablet: const CustomerTabletLayout(),
      ),
    );
  }
}
```

#### Widgets

```dart
// lib/core/widgets/responsive_widget.dart
class ResponsiveWidget extends StatelessWidget {
  final Widget phone;
  final Widget? tablet;

  const ResponsiveWidget({
    super.key,
    required this.phone,
    this.tablet,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 600) {
          return tablet ?? phone;
        }
        return phone;
      },
    );
  }
}
```

---

## State Management (BLoC)

### BLoC Pattern Structure

Setiap fitur memiliki 3 file:
1. `*_bloc.dart` - Business logic
2. `*_event.dart` - Input events
3. `*_state.dart` - Output states

### Example: Customer BLoC

#### Events
```dart
// lib/presentation/customer/bloc/customer_event.dart
abstract class CustomerEvent {}

class FetchCustomers extends CustomerEvent {
  final String? search;
  final int page;

  FetchCustomers({this.search, this.page = 1});
}

class CreateCustomer extends CustomerEvent {
  final CustomerRequestModel request;

  CreateCustomer(this.request);
}

class UpdateCustomer extends CustomerEvent {
  final int id;
  final CustomerRequestModel request;

  UpdateCustomer(this.id, this.request);
}

class DeleteCustomer extends CustomerEvent {
  final int id;

  DeleteCustomer(this.id);
}
```

#### States
```dart
// lib/presentation/customer/bloc/customer_state.dart
abstract class CustomerState {}

class CustomerInitial extends CustomerState {}

class CustomerLoading extends CustomerState {}

class CustomerLoaded extends CustomerState {
  final List<CustomerModel> customers;
  final bool hasMore;

  CustomerLoaded(this.customers, {this.hasMore = true});
}

class CustomerError extends CustomerState {
  final String message;
  CustomerError(this.message);
}

class CustomerActionSuccess extends CustomerState {
  final String message;
  CustomerActionSuccess(this.message);
}
```

#### BLoC
```dart
// lib/presentation/customer/bloc/customer_bloc.dart
class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final CustomerRemoteDatasource _datasource;

  CustomerBloc(this._datasource) : super(CustomerInitial()) {
    on<FetchCustomers>(_onFetchCustomers);
    on<CreateCustomer>(_onCreateCustomer);
    on<UpdateCustomer>(_onUpdateCustomer);
    on<DeleteCustomer>(_onDeleteCustomer);
  }

  Future<void> _onFetchCustomers(
    FetchCustomers event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerLoading());

    final result = await _datasource.getCustomers(
      search: event.search,
      page: event.page,
    );

    result.fold(
      (error) => emit(CustomerError(error)),
      (customers) => emit(CustomerLoaded(customers)),
    );
  }

  Future<void> _onCreateCustomer(
    CreateCustomer event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerLoading());

    final result = await _datasource.createCustomer(event.request);

    result.fold(
      (error) => emit(CustomerError(error)),
      (customer) => emit(CustomerActionSuccess('Pelanggan berhasil ditambahkan')),
    );
  }

  // ... other handlers
}
```

### Menggunakan BLoC di UI

```dart
// Di main.dart - Provider setup
MultiBlocProvider(
  providers: [
    BlocProvider(
      create: (context) => LoginBloc(AuthRemoteDatasource()),
    ),
    BlocProvider(
      create: (context) => CustomerBloc(CustomerRemoteDatasource()),
    ),
    // ... other providers
  ],
  child: MaterialApp(...),
)

// Di halaman - Trigger event
ElevatedButton(
  onPressed: () {
    context.read<CustomerBloc>().add(
      FetchCustomers(search: searchQuery),
    );
  },
  child: Text('Cari'),
)

// Di halaman - Listen to state
BlocListener<CustomerBloc, CustomerState>(
  listener: (context, state) {
    if (state is CustomerActionSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    } else if (state is CustomerError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message), backgroundColor: Colors.red),
      );
    }
  },
  child: BlocBuilder<CustomerBloc, CustomerState>(
    builder: (context, state) {
      if (state is CustomerLoading) {
        return const CircularProgressIndicator();
      }
      if (state is CustomerLoaded) {
        return CustomerList(customers: state.customers);
      }
      return const EmptyState();
    },
  ),
)
```

---

## Data Flow

```
User Action → Event → BLoC → Datasource → API/Local → Model → State → UI Update

┌────────┐    ┌───────┐    ┌──────┐    ┌────────────┐    ┌─────┐
│  User  │───▶│ Event │───▶│ BLoC │───▶│ Datasource │───▶│ API │
│ Action │    │       │    │      │    │            │    │     │
└────────┘    └───────┘    └──────┘    └────────────┘    └──┬──┘
                              │                             │
                              │    ┌───────────────────────┘
                              │    │
                              ▼    ▼
                           ┌──────────┐    ┌───────┐    ┌────┐
                           │  State   │───▶│  UI   │───▶│User│
                           │          │    │Update │    │    │
                           └──────────┘    └───────┘    └────┘
```

### Flow Example: Get Customers

1. **User** membuka halaman Customer List
2. **Event** `FetchCustomers` di-dispatch
3. **BLoC** menerima event dan memanggil datasource
4. **Datasource** melakukan HTTP request ke API
5. **API** mengembalikan response JSON
6. **Model** di-parse dari JSON
7. **State** `CustomerLoaded(customers)` di-emit
8. **UI** rebuild dengan data pelanggan

---

## Dependency Injection

Aplikasi ini menggunakan dependency injection sederhana melalui constructor:

```dart
// BLoC menerima datasource melalui constructor
class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final CustomerRemoteDatasource _datasource;

  CustomerBloc(this._datasource) : super(CustomerInitial()) {
    // ...
  }
}

// Di main.dart
BlocProvider(
  create: (context) => CustomerBloc(CustomerRemoteDatasource()),
)
```

---

## Code Generation

### Packages Used
- `freezed` - Immutable classes & union types
- `json_serializable` - JSON serialization
- `build_runner` - Code generation runner

### Generate Code

```bash
# One-time generation
dart run build_runner build --delete-conflicting-outputs

# Watch mode (auto-generate on file changes)
dart run build_runner watch --delete-conflicting-outputs
```

### Example: Freezed Model

```dart
// appointment_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'appointment_model.freezed.dart';
part 'appointment_model.g.dart';

@freezed
class AppointmentModel with _$AppointmentModel {
  const factory AppointmentModel({
    required int id,
    @JsonKey(name: 'customer_id') required int customerId,
    @JsonKey(name: 'service_id') required int serviceId,
    @JsonKey(name: 'appointment_date') required DateTime appointmentDate,
    @JsonKey(name: 'start_time') required String startTime,
    required String status,
  }) = _AppointmentModel;

  factory AppointmentModel.fromJson(Map<String, dynamic> json) =>
      _$AppointmentModelFromJson(json);
}
```

---

## Best Practices

### 1. Separation of Concerns
- UI logic di widgets/pages
- Business logic di BLoC
- Data logic di datasources
- Shared utilities di core

### 2. Immutable State
- State classes bersifat immutable
- Gunakan `copyWith` untuk update state

### 3. Error Handling
- Gunakan `Either<String, T>` dari dartz untuk error handling
- `Left` untuk error, `Right` untuk success

```dart
Future<Either<String, CustomerModel>> getCustomer(int id) async {
  try {
    // ...
    return Right(customer);
  } catch (e) {
    return Left(e.toString());
  }
}
```

### 4. Consistent Naming
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables/functions: `camelCase`
- Constants: `SCREAMING_SNAKE_CASE` atau `camelCase`

### 5. Responsive Design
- Selalu gunakan `ResponsiveWidget` untuk halaman utama
- Test di berbagai ukuran layar

---

## Testing

### Unit Test Structure

```
test/
├── data/
│   ├── datasources/
│   │   └── auth_remote_datasource_test.dart
│   └── models/
│       └── customer_model_test.dart
├── presentation/
│   └── bloc/
│       └── customer_bloc_test.dart
└── widget_test.dart
```

### Example Test

```dart
// test/presentation/bloc/customer_bloc_test.dart
void main() {
  late CustomerBloc customerBloc;
  late MockCustomerRemoteDatasource mockDatasource;

  setUp(() {
    mockDatasource = MockCustomerRemoteDatasource();
    customerBloc = CustomerBloc(mockDatasource);
  });

  tearDown(() {
    customerBloc.close();
  });

  test('initial state is CustomerInitial', () {
    expect(customerBloc.state, isA<CustomerInitial>());
  });

  blocTest<CustomerBloc, CustomerState>(
    'emits [CustomerLoading, CustomerLoaded] when fetch succeeds',
    build: () {
      when(() => mockDatasource.getCustomers())
          .thenAnswer((_) async => Right(mockCustomers));
      return customerBloc;
    },
    act: (bloc) => bloc.add(FetchCustomers()),
    expect: () => [
      isA<CustomerLoading>(),
      isA<CustomerLoaded>(),
    ],
  );
}
```

---

*Dokumentasi ini terakhir diperbarui: Januari 2025*
