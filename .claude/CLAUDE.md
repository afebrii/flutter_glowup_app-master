# Claude Code Rules - Flutter GlowUp Clinic App

## Project Overview
Aplikasi mobile untuk klinik kecantikan GlowUp menggunakan Flutter dengan BLoC pattern untuk state management.

---

## Architecture Rules

### 1. Clean Architecture dengan BLoC

```
Presentation Layer (UI) → BLoC (Business Logic) → Data Layer (Datasource + Models) → Core Layer
```

### 2. Struktur Folder Wajib

```
lib/
├── core/                        # Shared utilities
│   ├── constants/               # colors.dart, variables.dart
│   ├── extensions/              # int_ext.dart, date_time_ext.dart
│   ├── components/              # Reusable widgets
│   ├── utils/                   # screen_size.dart
│   └── widgets/                 # responsive_widget.dart
│
├── data/                        # Data layer
│   ├── datasources/             # Remote & Local datasource
│   └── models/
│       ├── requests/            # Request body models
│       └── responses/           # API response models
│
└── presentation/                # UI layer
    └── [feature]/
        ├── bloc/                # BLoC files
        ├── pages/               # Screen pages
        └── widgets/             # Feature-specific widgets
            ├── *_phone_layout.dart
            └── *_tablet_layout.dart
```

### 3. BLoC Pattern (Wajib)

Setiap fitur HARUS memiliki 3 file:
- `*_bloc.dart` - Business logic
- `*_event.dart` - Input events
- `*_state.dart` - Output states

```dart
// Event
abstract class CustomerEvent {}
class FetchCustomers extends CustomerEvent {}

// State
abstract class CustomerState {}
class CustomerInitial extends CustomerState {}
class CustomerLoading extends CustomerState {}
class CustomerLoaded extends CustomerState {
  final List<CustomerModel> customers;
  CustomerLoaded(this.customers);
}
class CustomerError extends CustomerState {
  final String message;
  CustomerError(this.message);
}

// BLoC
class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final CustomerRemoteDatasource _datasource;
  CustomerBloc(this._datasource) : super(CustomerInitial()) {
    on<FetchCustomers>(_onFetchCustomers);
  }
}
```

### 4. Error Handling dengan Either

Gunakan `Either<String, T>` dari package `dartz`:
- `Left` untuk error message
- `Right` untuk success data

```dart
Future<Either<String, CustomerModel>> getCustomer(int id) async {
  try {
    // ... API call
    return Right(customer);
  } catch (e) {
    return Left(e.toString());
  }
}
```

### 5. Naming Convention

| Type | Convention | Example |
|------|------------|---------|
| Files | snake_case | `customer_bloc.dart` |
| Classes | PascalCase | `CustomerBloc` |
| Variables | camelCase | `selectedCustomer` |
| Constants | camelCase | `apiBaseUrl` |

---

## Tablet View Implementation Rules

### 1. Responsive Widget (WAJIB)

Semua halaman utama HARUS menggunakan `ResponsiveWidget`:

```dart
class CustomerListPage extends StatelessWidget {
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

### 2. Screen Size Breakpoints

```dart
static const double phoneMaxWidth = 600;
static const double tabletMaxWidth = 1024;
```

- Phone: < 600px
- Tablet: 600px - 1024px
- Desktop: > 1024px

### 3. Split Screen Ratios (WAJIB)

| Page | Left Panel | Right Panel |
|------|------------|-------------|
| Dashboard | 60% | 40% |
| Customer List | 40% | 60% |
| Appointment Calendar | 65% | 35% |
| Checkout/POS | 60% | 40% |
| Transaction History | 40% | 60% |
| Settings | 35% | 65% |

### 4. Master-Detail Pattern untuk Tablet

```dart
class CustomerTabletLayout extends StatefulWidget {
  @override
  State<CustomerTabletLayout> createState() => _CustomerTabletLayoutState();
}

class _CustomerTabletLayoutState extends State<CustomerTabletLayout> {
  CustomerModel? _selectedCustomer;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left Panel - List (40%)
        Expanded(
          flex: 40,
          child: CustomerList(
            onSelect: (customer) {
              setState(() => _selectedCustomer = customer);
            },
          ),
        ),
        const VerticalDivider(width: 1),
        // Right Panel - Detail (60%)
        Expanded(
          flex: 60,
          child: _selectedCustomer != null
              ? CustomerDetailPanel(customer: _selectedCustomer!)
              : const Center(child: Text('Pilih pelanggan')),
        ),
      ],
    );
  }
}
```

### 5. Grid Columns

| Device | Services | Cards |
|--------|----------|-------|
| Phone | 2 | 2 |
| Tablet | 4 | 4 |

### 6. Padding Scale

| Device | Padding |
|--------|---------|
| Phone | 16px |
| Tablet | 24px |

---

## Color Theme (Rose)

```dart
class AppColors {
  // Primary - Rose
  static const Color primary = Color(0xFFf43f5e);        // rose-500
  static const Color primaryLight = Color(0xFFfb7185);   // rose-400
  static const Color primaryDark = Color(0xFFe11d48);    // rose-600

  // Background
  static const Color background = Color(0xFFFFF9F5);     // Cream
  static const Color surface = Color(0xFFFFEEE8);        // Peach

  // Status
  static const Color statusPending = Color(0xFFf59e0b);    // Amber
  static const Color statusConfirmed = Color(0xFF3b82f6);  // Blue
  static const Color statusInProgress = Color(0xFF8b5cf6); // Purple
  static const Color statusCompleted = Color(0xFF22c55e);  // Green
  static const Color statusCancelled = Color(0xFFef4444);  // Red
}
```

---

## API Integration

### Base URL
```dart
static const String baseUrl = 'https://glowup-clinic.server.com';
static const String apiBaseUrl = '$baseUrl/api/v1';
```

### Authentication
- Laravel Sanctum (Token-based)
- Token disimpan di SharedPreferences

### Request Headers
```dart
headers: {
  'Authorization': 'Bearer $token',
  'Accept': 'application/json',
  'Content-Type': 'application/json',
}
```

---

## Testing Checklist

Sebelum commit, pastikan test di:
- [ ] Phone portrait (< 600px)
- [ ] Phone landscape
- [ ] Tablet portrait (600px - 900px)
- [ ] Tablet landscape (900px - 1024px)

---

## Do's and Don'ts

### DO:
- Gunakan `ResponsiveWidget` untuk semua halaman utama
- Pisahkan phone dan tablet layout ke file terpisah
- Gunakan BLoC untuk state management
- Gunakan `Either` untuk error handling
- Test di berbagai ukuran layar

### DON'T:
- Jangan hardcode ukuran layar
- Jangan mix business logic di widget
- Jangan buat API call langsung dari widget
- Jangan gunakan `setState` untuk state yang kompleks
- Jangan skip tablet layout untuk halaman utama
