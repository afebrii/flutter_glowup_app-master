# GlowUp Clinic Mobile App - Development Plan

Dokumentasi lengkap untuk pengembangan aplikasi Flutter GlowUp Clinic Mobile.

---

## Overview

Aplikasi mobile untuk klinik kecantikan GlowUp yang terintegrasi dengan backend Laravel. Aplikasi ini ditujukan untuk staff klinik (Owner, Admin, Beautician) untuk mengelola operasional klinik sehari-hari.

### Tech Stack
| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.x |
| State Management | BLoC (flutter_bloc) |
| Architecture | Clean Architecture |
| API Client | http / dio |
| Local Storage | SharedPreferences |
| Code Generation | freezed, json_serializable |
| Image Handling | image_picker, cached_network_image |

### Backend API
- Base URL: `https://glowup-clinic.server.com/api/v1`
- Auth: Laravel Sanctum (Token-based)

---

## Daftar Isi

1. [Arsitektur & Struktur Folder](#arsitektur--struktur-folder)
2. [Phase 1: Foundation & Core](#phase-1-foundation--core)
3. [Phase 2: Authentication](#phase-2-authentication)
4. [Phase 3: Dashboard](#phase-3-dashboard)
5. [Phase 4: Master Data](#phase-4-master-data)
6. [Phase 5: Customer Management](#phase-5-customer-management)
7. [Phase 6: Appointment System](#phase-6-appointment-system)
8. [Phase 7: Treatment Records](#phase-7-treatment-records)
9. [Phase 8: Package Management](#phase-8-package-management)
10. [Phase 9: POS & Checkout](#phase-9-pos--checkout)
11. [Phase 10: Reports](#phase-10-reports)
12. [Phase 11: Settings](#phase-11-settings)

---

## Arsitektur & Struktur Folder

### Clean Architecture dengan BLoC

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

### Struktur Folder Target

```
lib/
├── main.dart                    # Entry point aplikasi
├── core/                        # Core utilities & shared code
│   ├── constants/
│   │   ├── colors.dart          # Definisi warna tema (Rose theme)
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
│   │   ├── status_badge.dart    # Status badges (pending, confirmed, etc)
│   │   └── empty_state.dart     # Empty state widget
│   ├── services/
│   │   └── printer_service.dart # Bluetooth printer service
│   ├── utils/
│   │   └── screen_size.dart     # Screen size helper
│   └── widgets/
│       ├── responsive_widget.dart   # Phone/Tablet layout switcher
│       └── responsive_layout.dart   # Layout builder
│
├── data/                        # Data layer
│   ├── datasources/
│   │   ├── auth_local_datasource.dart    # Token & user storage
│   │   ├── auth_remote_datasource.dart   # Auth API
│   │   ├── service_remote_datasource.dart
│   │   ├── category_remote_datasource.dart
│   │   ├── customer_remote_datasource.dart
│   │   ├── appointment_remote_datasource.dart
│   │   ├── treatment_remote_datasource.dart
│   │   ├── package_remote_datasource.dart
│   │   ├── transaction_remote_datasource.dart
│   │   ├── dashboard_remote_datasource.dart
│   │   ├── report_remote_datasource.dart
│   │   ├── staff_remote_datasource.dart
│   │   └── settings_remote_datasource.dart
│   └── models/
│       ├── requests/            # Request body models
│       │   ├── login_request_model.dart
│       │   ├── customer_request_model.dart
│       │   ├── appointment_request_model.dart
│       │   ├── treatment_request_model.dart
│       │   ├── transaction_request_model.dart
│       │   └── package_request_model.dart
│       └── responses/           # API response models
│           ├── auth_response_model.dart
│           ├── user_model.dart
│           ├── service_model.dart
│           ├── service_category_model.dart
│           ├── customer_model.dart
│           ├── appointment_model.dart
│           ├── treatment_record_model.dart
│           ├── package_model.dart
│           ├── customer_package_model.dart
│           ├── transaction_model.dart
│           ├── dashboard_model.dart
│           ├── report_model.dart
│           └── settings_model.dart
│
└── presentation/                # UI layer
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
    │   │   ├── dashboard_bloc.dart
    │   │   ├── dashboard_event.dart
    │   │   └── dashboard_state.dart
    │   ├── pages/
    │   │   └── dashboard_page.dart
    │   └── widgets/
    │       ├── dashboard_phone_layout.dart
    │       ├── dashboard_tablet_layout.dart
    │       ├── stats_card.dart
    │       ├── revenue_chart.dart
    │       └── today_appointments_list.dart
    │
    ├── service/
    │   ├── bloc/
    │   │   ├── service_bloc.dart
    │   │   ├── service_event.dart
    │   │   └── service_state.dart
    │   └── pages/
    │       └── service_list_page.dart
    │
    ├── customer/
    │   ├── bloc/
    │   │   ├── customer_bloc.dart
    │   │   ├── customer_event.dart
    │   │   └── customer_state.dart
    │   ├── pages/
    │   │   ├── customer_list_page.dart
    │   │   └── customer_detail_page.dart
    │   └── widgets/
    │       ├── customer_phone_layout.dart
    │       ├── customer_tablet_layout.dart
    │       ├── customer_form_dialog.dart
    │       ├── skin_profile_section.dart
    │       └── customer_stats_card.dart
    │
    ├── appointment/
    │   ├── bloc/
    │   │   ├── appointment_bloc.dart
    │   │   ├── appointment_event.dart
    │   │   ├── appointment_state.dart
    │   │   ├── booking/
    │   │   │   ├── booking_bloc.dart
    │   │   │   ├── booking_event.dart
    │   │   │   └── booking_state.dart
    │   │   └── calendar/
    │   │       ├── calendar_bloc.dart
    │   │       ├── calendar_event.dart
    │   │       └── calendar_state.dart
    │   ├── pages/
    │   │   ├── appointment_calendar_page.dart
    │   │   ├── booking_page.dart
    │   │   └── appointment_detail_page.dart
    │   └── widgets/
    │       ├── calendar_phone_layout.dart
    │       ├── calendar_tablet_layout.dart
    │       ├── appointment_card.dart
    │       ├── time_slot_picker.dart
    │       └── booking_step_widget.dart
    │
    ├── treatment/
    │   ├── bloc/
    │   │   ├── treatment_bloc.dart
    │   │   ├── treatment_event.dart
    │   │   └── treatment_state.dart
    │   ├── pages/
    │   │   ├── treatment_form_page.dart
    │   │   └── treatment_history_page.dart
    │   └── widgets/
    │       ├── photo_upload_widget.dart
    │       ├── before_after_gallery.dart
    │       └── treatment_timeline.dart
    │
    ├── package/
    │   ├── bloc/
    │   │   ├── package_bloc.dart
    │   │   ├── package_event.dart
    │   │   └── package_state.dart
    │   └── pages/
    │       ├── package_list_page.dart
    │       └── customer_package_page.dart
    │
    ├── pos/
    │   ├── bloc/
    │   │   ├── checkout/
    │   │   │   ├── checkout_bloc.dart
    │   │   │   ├── checkout_event.dart
    │   │   │   ├── checkout_state.dart
    │   │   │   └── cart_item_model.dart
    │   │   └── transaction/
    │   │       ├── transaction_bloc.dart
    │   │       ├── transaction_event.dart
    │   │       └── transaction_state.dart
    │   ├── pages/
    │   │   ├── checkout_page.dart
    │   │   ├── payment_page.dart
    │   │   └── invoice_page.dart
    │   └── widgets/
    │       ├── checkout_phone_layout.dart
    │       ├── checkout_tablet_layout.dart
    │       ├── cart_item_widget.dart
    │       ├── payment_method_selector.dart
    │       └── receipt_widget.dart
    │
    ├── transaction/
    │   ├── bloc/
    │   │   ├── transaction_history_bloc.dart
    │   │   ├── transaction_history_event.dart
    │   │   └── transaction_history_state.dart
    │   ├── pages/
    │   │   ├── transaction_history_page.dart
    │   │   └── transaction_detail_page.dart
    │   └── widgets/
    │       ├── history_phone_layout.dart
    │       ├── history_tablet_layout.dart
    │       └── transaction_list_item.dart
    │
    ├── report/
    │   ├── bloc/
    │   │   ├── report_bloc.dart
    │   │   ├── report_event.dart
    │   │   └── report_state.dart
    │   ├── pages/
    │   │   └── report_page.dart
    │   └── widgets/
    │       ├── report_phone_layout.dart
    │       ├── report_tablet_layout.dart
    │       ├── revenue_report_card.dart
    │       └── service_popularity_chart.dart
    │
    └── settings/
        ├── pages/
        │   ├── settings_page.dart
        │   ├── profile_page.dart
        │   ├── clinic_settings_page.dart
        │   └── printer_settings_page.dart
        └── widgets/
            ├── settings_phone_layout.dart
            └── settings_tablet_layout.dart
```

---

## Phase 1: Foundation & Core

### 1.1 Setup Project Dependencies

**File: `pubspec.yaml`**

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_bloc: ^8.1.3

  # Dependency Injection
  get_it: ^7.6.4

  # Networking
  http: ^1.1.0

  # Local Storage
  shared_preferences: ^2.2.2

  # Functional Programming
  dartz: ^0.10.1

  # Code Generation
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1

  # UI Components
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0
  flutter_svg: ^2.0.9

  # Image Handling
  image_picker: ^1.0.4
  image_cropper: ^5.0.1

  # Charts
  fl_chart: ^0.65.0

  # Date & Time
  intl: ^0.18.1
  table_calendar: ^3.0.9

  # Utils
  url_launcher: ^6.2.1
  permission_handler: ^11.1.0

  # Printing
  bluetooth_print: ^4.3.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1

  # Code Generation
  build_runner: ^2.4.7
  freezed: ^2.4.5
  json_serializable: ^6.7.1
```

### 1.2 Core - Constants

**File: `lib/core/constants/colors.dart`**

```dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary - Rose (dari Design System)
  static const Color primary = Color(0xFFf43f5e);        // rose-500
  static const Color primaryLight = Color(0xFFfb7185);   // rose-400
  static const Color primaryDark = Color(0xFFe11d48);    // rose-600

  // Secondary - Coral
  static const Color secondary = Color(0xFFcc4637);

  // Neutral - Cream & Peach
  static const Color background = Color(0xFFFFF9F5);
  static const Color surface = Color(0xFFFFEEE8);

  // Semantic Colors
  static const Color success = Color(0xFF22c55e);
  static const Color warning = Color(0xFFf59e0b);
  static const Color error = Color(0xFFef4444);
  static const Color info = Color(0xFF3b82f6);

  // Text Colors
  static const Color textPrimary = Color(0xFF1f2937);
  static const Color textSecondary = Color(0xFF6b7280);
  static const Color textMuted = Color(0xFF9ca3af);

  // Status Colors
  static const Color statusPending = Color(0xFFf59e0b);
  static const Color statusConfirmed = Color(0xFF3b82f6);
  static const Color statusInProgress = Color(0xFF8b5cf6);
  static const Color statusCompleted = Color(0xFF22c55e);
  static const Color statusCancelled = Color(0xFFef4444);
}
```

**File: `lib/core/constants/variables.dart`**

```dart
class Variables {
  static const String baseUrl = 'https://glowup-clinic.server.com';
  static const String apiBaseUrl = '$baseUrl/api/v1';

  // Auth
  static const String login = '$apiBaseUrl/login';
  static const String logout = '$apiBaseUrl/logout';
  static const String profile = '$apiBaseUrl/profile';

  // Service Categories & Services
  static const String serviceCategories = '$apiBaseUrl/service-categories';
  static const String services = '$apiBaseUrl/services';

  // Customers
  static const String customers = '$apiBaseUrl/customers';

  // Appointments
  static const String appointments = '$apiBaseUrl/appointments';
  static const String availableSlots = '$apiBaseUrl/appointments/available-slots';
  static const String calendar = '$apiBaseUrl/appointments/calendar';

  // Treatment Records
  static const String treatments = '$apiBaseUrl/treatment-records';

  // Packages
  static const String packages = '$apiBaseUrl/packages';
  static const String customerPackages = '$apiBaseUrl/customer-packages';

  // Transactions
  static const String transactions = '$apiBaseUrl/transactions';

  // Dashboard
  static const String dashboard = '$apiBaseUrl/dashboard';

  // Reports
  static const String reports = '$apiBaseUrl/reports';

  // Staff
  static const String staff = '$apiBaseUrl/staff';

  // Settings
  static const String settings = '$apiBaseUrl/settings';
}
```

### 1.3 Core - Extensions

**File: `lib/core/extensions/int_ext.dart`**

```dart
import 'package:intl/intl.dart';

extension IntExt on int {
  String get currencyFormat {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(this);
  }

  String get compactCurrency {
    if (this >= 1000000) {
      return 'Rp ${(this / 1000000).toStringAsFixed(1)}jt';
    } else if (this >= 1000) {
      return 'Rp ${(this / 1000).toStringAsFixed(0)}rb';
    }
    return currencyFormat;
  }
}
```

**File: `lib/core/extensions/date_time_ext.dart`**

```dart
import 'package:intl/intl.dart';

extension DateTimeExt on DateTime {
  String get toFormattedDate {
    return DateFormat('dd MMM yyyy', 'id_ID').format(this);
  }

  String get toFormattedTime {
    return DateFormat('HH:mm').format(this);
  }

  String get toFormattedDateTime {
    return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(this);
  }

  String get toApiFormat {
    return DateFormat('yyyy-MM-dd').format(this);
  }

  String get dayName {
    return DateFormat('EEEE', 'id_ID').format(this);
  }

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
}
```

### 1.4 Core - Responsive Utilities

**File: `lib/core/utils/screen_size.dart`**

```dart
import 'package:flutter/material.dart';

enum DeviceType { phone, tablet, desktop }

class ScreenSize {
  static const double phoneMaxWidth = 600;
  static const double tabletMaxWidth = 1024;

  static bool isPhone(BuildContext context) {
    return MediaQuery.of(context).size.width < phoneMaxWidth;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= phoneMaxWidth && width < tabletMaxWidth;
  }

  static bool isTabletOrLarger(BuildContext context) {
    return MediaQuery.of(context).size.width >= phoneMaxWidth;
  }

  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < phoneMaxWidth) return DeviceType.phone;
    if (width < tabletMaxWidth) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  static T responsive<T>(
    BuildContext context, {
    required T phone,
    T? tablet,
    T? desktop,
  }) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.desktop:
        return desktop ?? tablet ?? phone;
      case DeviceType.tablet:
        return tablet ?? phone;
      case DeviceType.phone:
        return phone;
    }
  }

  static int gridColumns(BuildContext context) {
    return responsive(context, phone: 2, tablet: 3, desktop: 4);
  }

  static double responsivePadding(BuildContext context) {
    return responsive(context, phone: 16.0, tablet: 24.0, desktop: 32.0);
  }
}
```

**File: `lib/core/widgets/responsive_widget.dart`**

```dart
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
        if (ScreenSize.isDesktop(context)) {
          return desktop ?? tablet ?? phone;
        }
        if (ScreenSize.isTablet(context)) {
          return tablet ?? phone;
        }
        return phone;
      },
    );
  }
}
```

### 1.5 Core - Reusable Components

**File: `lib/core/components/buttons.dart`**

```dart
import 'package:flutter/material.dart';
import '../constants/colors.dart';

class Button {
  static Widget filled({
    required VoidCallback onPressed,
    required String label,
    Color? color,
    double? width,
    bool isLoading = false,
    IconData? icon,
  }) {
    return SizedBox(
      width: width ?? double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
      ),
    );
  }

  static Widget outlined({
    required VoidCallback onPressed,
    required String label,
    Color? color,
    double? width,
    IconData? icon,
  }) {
    return SizedBox(
      width: width ?? double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color ?? AppColors.primary,
          side: BorderSide(color: color ?? AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
```

**File: `lib/core/components/status_badge.dart`**

```dart
import 'package:flutter/material.dart';
import '../constants/colors.dart';

enum AppointmentStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled,
  noShow,
}

class StatusBadge extends StatelessWidget {
  final AppointmentStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        _getLabel(),
        style: TextStyle(
          color: _getTextColor(),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (status) {
      case AppointmentStatus.pending:
        return AppColors.statusPending.withOpacity(0.1);
      case AppointmentStatus.confirmed:
        return AppColors.statusConfirmed.withOpacity(0.1);
      case AppointmentStatus.inProgress:
        return AppColors.statusInProgress.withOpacity(0.1);
      case AppointmentStatus.completed:
        return AppColors.statusCompleted.withOpacity(0.1);
      case AppointmentStatus.cancelled:
      case AppointmentStatus.noShow:
        return AppColors.statusCancelled.withOpacity(0.1);
    }
  }

  Color _getTextColor() {
    switch (status) {
      case AppointmentStatus.pending:
        return AppColors.statusPending;
      case AppointmentStatus.confirmed:
        return AppColors.statusConfirmed;
      case AppointmentStatus.inProgress:
        return AppColors.statusInProgress;
      case AppointmentStatus.completed:
        return AppColors.statusCompleted;
      case AppointmentStatus.cancelled:
      case AppointmentStatus.noShow:
        return AppColors.statusCancelled;
    }
  }

  String _getLabel() {
    switch (status) {
      case AppointmentStatus.pending:
        return 'Menunggu';
      case AppointmentStatus.confirmed:
        return 'Dikonfirmasi';
      case AppointmentStatus.inProgress:
        return 'Sedang Berjalan';
      case AppointmentStatus.completed:
        return 'Selesai';
      case AppointmentStatus.cancelled:
        return 'Dibatalkan';
      case AppointmentStatus.noShow:
        return 'Tidak Hadir';
    }
  }
}
```

---

## Phase 2: Authentication

### 2.1 Models

**File: `lib/data/models/requests/login_request_model.dart`**

```dart
class LoginRequestModel {
  final String email;
  final String password;

  LoginRequestModel({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
  };
}
```

**File: `lib/data/models/responses/auth_response_model.dart`**

```dart
import 'user_model.dart';

class AuthResponseModel {
  final String token;
  final UserModel user;

  AuthResponseModel({required this.token, required this.user});

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'],
      user: UserModel.fromJson(json['user']),
    );
  }
}
```

**File: `lib/data/models/responses/user_model.dart`**

```dart
class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final String role; // owner, admin, beautician

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      avatar: json['avatar'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'avatar': avatar,
    'role': role,
  };
}
```

### 2.2 Datasources

**File: `lib/data/datasources/auth_local_datasource.dart`**

```dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/responses/user_model.dart';

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

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
```

**File: `lib/data/datasources/auth_remote_datasource.dart`**

```dart
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/variables.dart';
import '../models/requests/login_request_model.dart';
import '../models/responses/auth_response_model.dart';
import 'auth_local_datasource.dart';

class AuthRemoteDatasource {
  Future<Either<String, AuthResponseModel>> login(LoginRequestModel request) async {
    try {
      final response = await http.post(
        Uri.parse(Variables.login),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Right(AuthResponseModel.fromJson(data['data']));
      } else {
        final error = jsonDecode(response.body);
        return Left(error['message'] ?? 'Login gagal');
      }
    } catch (e) {
      return Left('Network error: $e');
    }
  }

  Future<Either<String, bool>> logout() async {
    try {
      final token = await AuthLocalDatasource().getToken();
      final response = await http.post(
        Uri.parse(Variables.logout),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        await AuthLocalDatasource().clearAll();
        return const Right(true);
      } else {
        return const Left('Logout gagal');
      }
    } catch (e) {
      return Left('Network error: $e');
    }
  }
}
```

### 2.3 BLoC

**File: `lib/presentation/auth/bloc/login/login_bloc.dart`**

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/datasources/auth_local_datasource.dart';
import '../../../../data/datasources/auth_remote_datasource.dart';
import '../../../../data/models/requests/login_request_model.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRemoteDatasource _datasource;

  LoginBloc(this._datasource) : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());

    final request = LoginRequestModel(
      email: event.email,
      password: event.password,
    );

    final result = await _datasource.login(request);

    result.fold(
      (error) => emit(LoginError(error)),
      (data) async {
        await AuthLocalDatasource().saveToken(data.token);
        await AuthLocalDatasource().saveUser(data.user);
        emit(LoginSuccess(data));
      },
    );
  }
}
```

### 2.4 Pages

**File: `lib/presentation/auth/pages/login_page.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../../../core/components/buttons.dart';
import '../../../data/datasources/auth_remote_datasource.dart';
import '../../home/pages/home_page.dart';
import '../bloc/login/login_bloc.dart';
import '../bloc/login/login_event.dart';
import '../bloc/login/login_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(AuthRemoteDatasource()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocConsumer<LoginBloc, LoginState>(
          listener: (context, state) {
            if (state is LoginSuccess) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
                (route) => false,
              );
            } else if (state is LoginError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 60),
                    // Logo & Title
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.spa,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'GlowUp Clinic',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Selamat datang kembali',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                    // Email Field
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Password Field
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Login Button
                    Button.filled(
                      onPressed: () {
                        context.read<LoginBloc>().add(
                          LoginSubmitted(
                            email: _emailController.text,
                            password: _passwordController.text,
                          ),
                        );
                      },
                      label: 'Masuk',
                      isLoading: state is LoginLoading,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
```

---

## Phase 3: Dashboard

### 3.1 Models

**File: `lib/data/models/responses/dashboard_model.dart`**

```dart
class DashboardModel {
  final int totalRevenue;
  final int todayRevenue;
  final int totalAppointments;
  final int todayAppointments;
  final int newCustomers;
  final int completedTreatments;
  final List<RevenueChartData> revenueChart;
  final List<TodayAppointment> todayAppointmentsList;

  DashboardModel({
    required this.totalRevenue,
    required this.todayRevenue,
    required this.totalAppointments,
    required this.todayAppointments,
    required this.newCustomers,
    required this.completedTreatments,
    required this.revenueChart,
    required this.todayAppointmentsList,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      totalRevenue: json['total_revenue'] ?? 0,
      todayRevenue: json['today_revenue'] ?? 0,
      totalAppointments: json['total_appointments'] ?? 0,
      todayAppointments: json['today_appointments'] ?? 0,
      newCustomers: json['new_customers'] ?? 0,
      completedTreatments: json['completed_treatments'] ?? 0,
      revenueChart: (json['revenue_chart'] as List?)
          ?.map((e) => RevenueChartData.fromJson(e))
          .toList() ?? [],
      todayAppointmentsList: (json['today_appointments_list'] as List?)
          ?.map((e) => TodayAppointment.fromJson(e))
          .toList() ?? [],
    );
  }
}

class RevenueChartData {
  final String date;
  final int amount;

  RevenueChartData({required this.date, required this.amount});

  factory RevenueChartData.fromJson(Map<String, dynamic> json) {
    return RevenueChartData(
      date: json['date'],
      amount: json['amount'] ?? 0,
    );
  }
}

class TodayAppointment {
  final int id;
  final String customerName;
  final String serviceName;
  final String startTime;
  final String status;

  TodayAppointment({
    required this.id,
    required this.customerName,
    required this.serviceName,
    required this.startTime,
    required this.status,
  });

  factory TodayAppointment.fromJson(Map<String, dynamic> json) {
    return TodayAppointment(
      id: json['id'],
      customerName: json['customer_name'],
      serviceName: json['service_name'],
      startTime: json['start_time'],
      status: json['status'],
    );
  }
}
```

### 3.2 Dashboard Layouts

**Phone Layout:** Single column, scrollable
- Stats cards (2x2 grid)
- Revenue chart
- Today's appointments list

**Tablet Layout:** Split screen (60% | 40%)
- Left: Stats cards + Revenue chart
- Right: Today's appointments + Quick actions

---

## Phase 4: Master Data

### 4.1 Service Categories Model

```dart
class ServiceCategoryModel {
  final int id;
  final String name;
  final String? description;
  final String? icon;
  final int sortOrder;
  final bool isActive;

  ServiceCategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    required this.sortOrder,
    required this.isActive,
  });

  factory ServiceCategoryModel.fromJson(Map<String, dynamic> json) {
    return ServiceCategoryModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      sortOrder: json['sort_order'] ?? 0,
      isActive: json['is_active'] ?? true,
    );
  }
}
```

### 4.2 Service Model

```dart
class ServiceModel {
  final int id;
  final int categoryId;
  final String name;
  final String? description;
  final int durationMinutes;
  final int price;
  final String? image;
  final bool isActive;
  final ServiceCategoryModel? category;

  ServiceModel({
    required this.id,
    required this.categoryId,
    required this.name,
    this.description,
    required this.durationMinutes,
    required this.price,
    this.image,
    required this.isActive,
    this.category,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      categoryId: json['category_id'],
      name: json['name'],
      description: json['description'],
      durationMinutes: json['duration_minutes'] ?? 60,
      price: json['price'] ?? 0,
      image: json['image'],
      isActive: json['is_active'] ?? true,
      category: json['category'] != null
          ? ServiceCategoryModel.fromJson(json['category'])
          : null,
    );
  }
}
```

---

## Phase 5: Customer Management

### 5.1 Customer Model

```dart
class CustomerModel {
  final int id;
  final String name;
  final String phone;
  final String? email;
  final DateTime? birthdate;
  final String? gender;
  final String? address;
  final String? skinType; // normal, oily, dry, combination, sensitive
  final List<String>? skinConcerns;
  final String? allergies;
  final String? notes;
  final int totalVisits;
  final int totalSpent;
  final DateTime? lastVisit;
  final DateTime createdAt;

  CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.birthdate,
    this.gender,
    this.address,
    this.skinType,
    this.skinConcerns,
    this.allergies,
    this.notes,
    this.totalVisits = 0,
    this.totalSpent = 0,
    this.lastVisit,
    required this.createdAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      birthdate: json['birthdate'] != null
          ? DateTime.parse(json['birthdate'])
          : null,
      gender: json['gender'],
      address: json['address'],
      skinType: json['skin_type'],
      skinConcerns: json['skin_concerns'] != null
          ? List<String>.from(json['skin_concerns'])
          : null,
      allergies: json['allergies'],
      notes: json['notes'],
      totalVisits: json['total_visits'] ?? 0,
      totalSpent: json['total_spent'] ?? 0,
      lastVisit: json['last_visit'] != null
          ? DateTime.parse(json['last_visit'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
```

### 5.2 Customer Detail Page Tabs

1. **Overview**: Basic info, skin profile, stats
2. **Treatment History**: Timeline of treatments
3. **Packages**: Active packages with remaining sessions
4. **Photos**: Before/after gallery

---

## Phase 6: Appointment System

### 6.1 Appointment Model

```dart
class AppointmentModel {
  final int id;
  final int customerId;
  final int serviceId;
  final int? staffId;
  final int? customerPackageId;
  final DateTime appointmentDate;
  final String startTime;
  final String endTime;
  final String status; // pending, confirmed, in_progress, completed, cancelled, no_show
  final String source; // walk_in, phone, whatsapp, online
  final String? notes;
  final DateTime? cancelledAt;
  final String? cancelledReason;
  final CustomerModel? customer;
  final ServiceModel? service;
  final UserModel? staff;

  AppointmentModel({
    required this.id,
    required this.customerId,
    required this.serviceId,
    this.staffId,
    this.customerPackageId,
    required this.appointmentDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.source,
    this.notes,
    this.cancelledAt,
    this.cancelledReason,
    this.customer,
    this.service,
    this.staff,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'],
      customerId: json['customer_id'],
      serviceId: json['service_id'],
      staffId: json['staff_id'],
      customerPackageId: json['customer_package_id'],
      appointmentDate: DateTime.parse(json['appointment_date']),
      startTime: json['start_time'],
      endTime: json['end_time'],
      status: json['status'],
      source: json['source'] ?? 'walk_in',
      notes: json['notes'],
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'])
          : null,
      cancelledReason: json['cancelled_reason'],
      customer: json['customer'] != null
          ? CustomerModel.fromJson(json['customer'])
          : null,
      service: json['service'] != null
          ? ServiceModel.fromJson(json['service'])
          : null,
      staff: json['staff'] != null
          ? UserModel.fromJson(json['staff'])
          : null,
    );
  }
}
```

### 6.2 Booking Flow (4 Steps)

1. **Select Customer**: Search/select existing or create new
2. **Select Service**: Choose from categorized list
3. **Select Date & Time**: Calendar + available time slots
4. **Confirmation**: Review and confirm booking

### 6.3 Calendar View

- **Daily View**: Time slots per staff column
- **Weekly View**: 7-day overview with appointments

---

## Phase 7: Treatment Records

### 7.1 Treatment Record Model

```dart
class TreatmentRecordModel {
  final int id;
  final int appointmentId;
  final int customerId;
  final int? staffId;
  final String? notes;
  final String? productsUsed;
  final String? beforePhoto;
  final String? afterPhoto;
  final String? recommendations;
  final DateTime? followUpDate;
  final DateTime createdAt;
  final CustomerModel? customer;
  final AppointmentModel? appointment;

  TreatmentRecordModel({
    required this.id,
    required this.appointmentId,
    required this.customerId,
    this.staffId,
    this.notes,
    this.productsUsed,
    this.beforePhoto,
    this.afterPhoto,
    this.recommendations,
    this.followUpDate,
    required this.createdAt,
    this.customer,
    this.appointment,
  });

  factory TreatmentRecordModel.fromJson(Map<String, dynamic> json) {
    return TreatmentRecordModel(
      id: json['id'],
      appointmentId: json['appointment_id'],
      customerId: json['customer_id'],
      staffId: json['staff_id'],
      notes: json['notes'],
      productsUsed: json['products_used'],
      beforePhoto: json['before_photo'],
      afterPhoto: json['after_photo'],
      recommendations: json['recommendations'],
      followUpDate: json['follow_up_date'] != null
          ? DateTime.parse(json['follow_up_date'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      customer: json['customer'] != null
          ? CustomerModel.fromJson(json['customer'])
          : null,
      appointment: json['appointment'] != null
          ? AppointmentModel.fromJson(json['appointment'])
          : null,
    );
  }
}
```

### 7.2 Photo Upload Features

- Before/after photo capture
- Auto compression
- Gallery view per customer

---

## Phase 8: Package Management

### 8.1 Package Model

```dart
class PackageModel {
  final int id;
  final String name;
  final String? description;
  final int serviceId;
  final int totalSessions;
  final int originalPrice;
  final int packagePrice;
  final int validityDays;
  final bool isActive;
  final ServiceModel? service;

  PackageModel({
    required this.id,
    required this.name,
    this.description,
    required this.serviceId,
    required this.totalSessions,
    required this.originalPrice,
    required this.packagePrice,
    required this.validityDays,
    required this.isActive,
    this.service,
  });

  int get discountPercentage {
    if (originalPrice <= 0) return 0;
    return ((originalPrice - packagePrice) / originalPrice * 100).round();
  }

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      serviceId: json['service_id'],
      totalSessions: json['total_sessions'],
      originalPrice: json['original_price'],
      packagePrice: json['package_price'],
      validityDays: json['validity_days'],
      isActive: json['is_active'] ?? true,
      service: json['service'] != null
          ? ServiceModel.fromJson(json['service'])
          : null,
    );
  }
}
```

### 8.2 Customer Package Model

```dart
class CustomerPackageModel {
  final int id;
  final int customerId;
  final int packageId;
  final int pricePaid;
  final int sessionsTotal;
  final int sessionsUsed;
  final DateTime purchasedAt;
  final DateTime expiresAt;
  final PackageModel? package;
  final CustomerModel? customer;

  CustomerPackageModel({
    required this.id,
    required this.customerId,
    required this.packageId,
    required this.pricePaid,
    required this.sessionsTotal,
    required this.sessionsUsed,
    required this.purchasedAt,
    required this.expiresAt,
    this.package,
    this.customer,
  });

  int get sessionsRemaining => sessionsTotal - sessionsUsed;

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  bool get isExhausted => sessionsRemaining <= 0;

  factory CustomerPackageModel.fromJson(Map<String, dynamic> json) {
    return CustomerPackageModel(
      id: json['id'],
      customerId: json['customer_id'],
      packageId: json['package_id'],
      pricePaid: json['price_paid'],
      sessionsTotal: json['sessions_total'],
      sessionsUsed: json['sessions_used'],
      purchasedAt: DateTime.parse(json['purchased_at']),
      expiresAt: DateTime.parse(json['expires_at']),
      package: json['package'] != null
          ? PackageModel.fromJson(json['package'])
          : null,
      customer: json['customer'] != null
          ? CustomerModel.fromJson(json['customer'])
          : null,
    );
  }
}
```

---

## Phase 9: POS & Checkout

### 9.1 Transaction Model

```dart
class TransactionModel {
  final int id;
  final String invoiceNumber;
  final int customerId;
  final int? appointmentId;
  final int? cashierId;
  final int subtotal;
  final int discountAmount;
  final String? discountType; // percentage, fixed
  final int taxAmount;
  final int totalAmount;
  final int paidAmount;
  final String status; // pending, paid, cancelled
  final String paymentMethod; // cash, qris, transfer, card
  final DateTime createdAt;
  final CustomerModel? customer;
  final List<TransactionItemModel>? items;

  TransactionModel({
    required this.id,
    required this.invoiceNumber,
    required this.customerId,
    this.appointmentId,
    this.cashierId,
    required this.subtotal,
    this.discountAmount = 0,
    this.discountType,
    this.taxAmount = 0,
    required this.totalAmount,
    required this.paidAmount,
    required this.status,
    required this.paymentMethod,
    required this.createdAt,
    this.customer,
    this.items,
  });

  int get changeAmount => paidAmount - totalAmount;

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      invoiceNumber: json['invoice_number'],
      customerId: json['customer_id'],
      appointmentId: json['appointment_id'],
      cashierId: json['cashier_id'],
      subtotal: json['subtotal'],
      discountAmount: json['discount_amount'] ?? 0,
      discountType: json['discount_type'],
      taxAmount: json['tax_amount'] ?? 0,
      totalAmount: json['total_amount'],
      paidAmount: json['paid_amount'],
      status: json['status'],
      paymentMethod: json['payment_method'],
      createdAt: DateTime.parse(json['created_at']),
      customer: json['customer'] != null
          ? CustomerModel.fromJson(json['customer'])
          : null,
      items: (json['items'] as List?)
          ?.map((e) => TransactionItemModel.fromJson(e))
          .toList(),
    );
  }
}

class TransactionItemModel {
  final int id;
  final int transactionId;
  final String itemType; // service, package
  final int itemId;
  final String itemName;
  final int quantity;
  final int unitPrice;
  final int totalPrice;

  TransactionItemModel({
    required this.id,
    required this.transactionId,
    required this.itemType,
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory TransactionItemModel.fromJson(Map<String, dynamic> json) {
    return TransactionItemModel(
      id: json['id'],
      transactionId: json['transaction_id'],
      itemType: json['item_type'],
      itemId: json['item_id'],
      itemName: json['item_name'],
      quantity: json['quantity'],
      unitPrice: json['unit_price'],
      totalPrice: json['total_price'],
    );
  }
}
```

### 9.2 Payment Methods

- Cash
- QRIS
- Transfer Bank
- Kartu (Debit/Credit)
- Split Payment

---

## Phase 10: Reports

### 10.1 Report Types

1. **Revenue Report**: Daily, Weekly, Monthly trends
2. **Service Popularity**: Most booked services
3. **Customer Report**: New, returning, top spenders
4. **Staff Performance**: Treatments per staff

### 10.2 Export Options

- PDF Export
- Excel Export

---

## Phase 11: Settings

### 11.1 Settings Sections

1. **Profile**: User profile management
2. **Clinic Settings**: Name, address, operating hours
3. **Printer Settings**: Bluetooth thermal printer setup
4. **About**: App version, support info

---

## Tablet View Implementation Guide

### Split Screen Ratios

| Page | Left Panel | Right Panel |
|------|------------|-------------|
| Dashboard | 60% (Stats, Chart) | 40% (Appointments) |
| Customer List | 40% (List) | 60% (Detail) |
| Appointment Calendar | 65% (Calendar) | 35% (Details) |
| Checkout | 60% (Items) | 40% (Cart Summary) |
| Transaction History | 40% (List) | 60% (Detail) |
| Settings | 35% (Menu) | 65% (Content) |

### Grid Columns

| Device | Products | Cards |
|--------|----------|-------|
| Phone | 2 | 2 |
| Tablet | 4 | 4 |

### Padding Scale

| Device | Base Padding |
|--------|-------------|
| Phone | 16px |
| Tablet | 24px |

---

## Development Checklist

### Phase 1: Foundation & Core
- [ ] Setup project dependencies (pubspec.yaml)
- [ ] Create color constants
- [ ] Create API variables
- [ ] Create extensions (int, datetime, string)
- [ ] Create responsive utilities
- [ ] Create reusable button components
- [ ] Create status badge component
- [ ] Run `flutter pub get`

### Phase 2: Authentication
- [ ] Create login request model
- [ ] Create auth response model
- [ ] Create user model
- [ ] Create auth local datasource
- [ ] Create auth remote datasource
- [ ] Create login BLoC (bloc, event, state)
- [ ] Create logout BLoC
- [ ] Create splash page
- [ ] Create login page
- [ ] Test login flow

### Phase 3: Dashboard
- [ ] Create dashboard model
- [ ] Create dashboard remote datasource
- [ ] Create dashboard BLoC
- [ ] Create stats card widget
- [ ] Create revenue chart widget
- [ ] Create today appointments widget
- [ ] Create dashboard phone layout
- [ ] Create dashboard tablet layout
- [ ] Create home page with navigation

### Phase 4: Master Data
- [ ] Create service category model
- [ ] Create service model
- [ ] Create service remote datasource
- [ ] Create service BLoC
- [ ] Create service list page
- [ ] Create service category tabs

### Phase 5: Customer Management
- [ ] Create customer model
- [ ] Create customer request model
- [ ] Create customer remote datasource
- [ ] Create customer BLoC
- [ ] Create customer list page (phone & tablet)
- [ ] Create customer detail page
- [ ] Create customer form dialog
- [ ] Create skin profile section
- [ ] Test CRUD operations

### Phase 6: Appointment System
- [ ] Create appointment model
- [ ] Create appointment request model
- [ ] Create appointment remote datasource
- [ ] Create appointment BLoC
- [ ] Create calendar BLoC
- [ ] Create booking BLoC
- [ ] Create calendar page (phone & tablet)
- [ ] Create booking page (4 steps)
- [ ] Create appointment detail page
- [ ] Create time slot picker
- [ ] Test booking flow

### Phase 7: Treatment Records
- [ ] Create treatment record model
- [ ] Create treatment remote datasource
- [ ] Create treatment BLoC
- [ ] Create treatment form page
- [ ] Create photo upload widget
- [ ] Create before/after gallery
- [ ] Create treatment history timeline
- [ ] Test photo upload

### Phase 8: Package Management
- [ ] Create package model
- [ ] Create customer package model
- [ ] Create package remote datasource
- [ ] Create package BLoC
- [ ] Create package list page
- [ ] Create customer package page
- [ ] Create session redemption flow

### Phase 9: POS & Checkout
- [ ] Create transaction model
- [ ] Create transaction item model
- [ ] Create transaction request model
- [ ] Create transaction remote datasource
- [ ] Create checkout BLoC
- [ ] Create transaction BLoC
- [ ] Create checkout page (phone & tablet)
- [ ] Create payment page
- [ ] Create invoice page
- [ ] Create payment method selector
- [ ] Create receipt widget
- [ ] Test payment flow

### Phase 10: Reports
- [ ] Create report model
- [ ] Create report remote datasource
- [ ] Create report BLoC
- [ ] Create report page (phone & tablet)
- [ ] Create revenue chart
- [ ] Create service popularity chart
- [ ] Create export functionality

### Phase 11: Settings
- [ ] Create settings page
- [ ] Create profile page
- [ ] Create clinic settings page
- [ ] Create printer settings page
- [ ] Test printer connection

### Final Testing
- [ ] Test on phone (portrait)
- [ ] Test on phone (landscape)
- [ ] Test on tablet (portrait)
- [ ] Test on tablet (landscape)
- [ ] Test offline handling
- [ ] Test error states
- [ ] Performance optimization
- [ ] Build release APK/IPA

---

## API Endpoints Reference

### Authentication
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /login | Login user |
| POST | /logout | Logout user |
| GET | /profile | Get current user profile |

### Service Categories
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /service-categories | List all categories |

### Services
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /services | List all services |
| GET | /services?category_id={id} | Filter by category |

### Customers
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /customers | List customers (paginated) |
| GET | /customers/{id} | Get customer detail |
| POST | /customers | Create customer |
| PUT | /customers/{id} | Update customer |
| DELETE | /customers/{id} | Delete customer |
| GET | /customers/{id}/treatments | Get treatment history |
| GET | /customers/{id}/packages | Get active packages |
| GET | /customers/{id}/appointments | Get appointments |

### Appointments
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /appointments | List appointments |
| GET | /appointments/calendar?date={date} | Calendar view |
| GET | /appointments/available-slots | Get available time slots |
| GET | /appointments/{id} | Get detail |
| POST | /appointments | Create appointment |
| PUT | /appointments/{id} | Update appointment |
| PUT | /appointments/{id}/status | Update status |
| DELETE | /appointments/{id} | Cancel appointment |

### Treatment Records
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /treatment-records | List records |
| GET | /treatment-records/{id} | Get detail |
| POST | /treatment-records | Create record |
| PUT | /treatment-records/{id} | Update record |
| POST | /treatment-records/{id}/photos | Upload photos |

### Packages
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /packages | List packages |
| GET | /customer-packages | List customer packages |
| POST | /customer-packages | Purchase package |
| POST | /customer-packages/{id}/redeem | Redeem session |

### Transactions
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /transactions | List transactions |
| GET | /transactions/{id} | Get detail |
| POST | /transactions | Create transaction |

### Dashboard
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /dashboard | Get dashboard data |

### Reports
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /reports/revenue | Revenue report |
| GET | /reports/services | Service popularity |
| GET | /reports/customers | Customer report |
| GET | /reports/staff | Staff performance |

---

*Dokumentasi ini terakhir diperbarui: Januari 2025*
