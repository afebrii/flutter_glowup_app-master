# Enhancement Todo List - GlowUp API Integration

Daftar enhancement dan pekerjaan yang perlu dilakukan untuk integrasi API baru ke Flutter app.

---

## Analisis Status Saat Ini

Berdasarkan dokumentasi di folder `newintegration`, API telah diperbarui dengan fitur-fitur baru:
- Loyalty System (Points, Rewards, Redemption)
- Referral System (Referral codes, Tracking)
- Products (Product inventory browsing)
- Dashboard (Statistics & Analytics)
- Settings (Clinic info, Operating hours, Feature flags)
- Staff (Staff/beautician management)

---

## Priority Levels

| Level | Keterangan |
|-------|------------|
| P0 | Critical - harus diimplementasikan segera |
| P1 | High - penting untuk fitur utama |
| P2 | Medium - enhancement yang bagus untuk dimiliki |
| P3 | Low - bisa dikerjakan belakangan |

---

## 1. Data Layer - Models (P0)

### 1.1 Base Response Models
- [x] Buat `lib/data/models/responses/api_response.dart`
  - `ApiResponse<T>` - generic wrapper untuk API response
  - `PaginatedResponse<T>` - wrapper untuk paginated data
  - `PaginationMeta` - metadata pagination

### 1.2 Auth Models
- [x] Update `lib/data/models/responses/user_model.dart`
  - Tambah helper methods: `isOwner`, `isAdmin`, `isBeautician`, `hasAdminAccess`
  - Tambah `roleDisplayName` dan `initials`

### 1.3 Customer Models (Update)
- [x] Update `lib/data/models/responses/customer_model.dart`
  - Tambah fields: `loyaltyPoints`, `lifetimePoints`, `loyaltyTier`, `loyaltyTierLabel`
  - Tambah fields: `referralCode`, `referredById`, `referrer`, `referralStats`
  - Tambah class `ReferralStats`
  - Tambah class `CustomerStats`

### 1.4 Loyalty Models (Baru)
- [x] Buat `lib/data/models/responses/loyalty_point_model.dart`
- [x] Buat `lib/data/models/responses/loyalty_reward_model.dart`
- [x] Buat `lib/data/models/responses/loyalty_redemption_model.dart`
- [x] Buat `lib/data/models/responses/loyalty_summary_model.dart` (di loyalty_point_model.dart)

### 1.5 Referral Models (Baru)
- [x] Buat `lib/data/models/responses/referral_log_model.dart` (di referral_model.dart)
- [x] Buat `lib/data/models/responses/referral_info_model.dart` (di referral_model.dart)
- [x] Buat `lib/data/models/responses/referral_program_info_model.dart` (di referral_model.dart)

### 1.6 Product Models (Baru)
- [x] Buat `lib/data/models/responses/product_category_model.dart` (di product_model.dart)
- [x] Buat `lib/data/models/responses/product_model.dart`

### 1.7 Settings Models (Baru)
- [x] Buat `lib/data/models/responses/settings_model.dart`
  - `SettingsModel`
  - `ClinicInfo`
  - `OperatingHourModel`
  - `BrandingInfo`
  - `LoyaltyConfig`

### 1.8 Dashboard Models (Update)
- [x] Update `lib/data/models/responses/dashboard_model.dart`
  - Sesuaikan dengan struktur response API baru
  - Tambah `DashboardStats`, `RevenueChartData`, `DashboardSummary`, `PopularService`

### 1.9 Staff Models (Baru)
- [x] Gunakan `UserModel` yang sudah ada dengan filter role

### 1.10 Request Models (Update)
- [x] Update/Buat request models sesuai kebutuhan:
  - `LoginRequestModel`
  - `CustomerRequestModel`
  - `AppointmentRequestModel`
  - `UpdateAppointmentStatusRequest`
  - `RedeemRewardRequest`
  - `AdjustPointsRequest`

---

## 2. Data Layer - Datasources (P0)

### 2.1 Base API Service
- [x] Buat/Update `lib/data/datasources/api_service.dart`
  - Implementasi generic methods: `get`, `post`, `put`, `patch`, `delete`
  - Tambah `postMultipart` untuk upload files
  - Implementasi proper error handling
  - Implementasi token management

### 2.2 Existing Datasources (Update)
- [x] Update `lib/data/datasources/auth_remote_datasource.dart`
- [x] Update `lib/data/datasources/customer_remote_datasource.dart`
  - Tambah `getCustomerStats`
- [x] Update `lib/data/datasources/appointment_remote_datasource.dart`
  - Tambah `getTodayAppointments`, `getCalendarAppointments`, `getAvailableSlots`
  - Tambah `updateStatus`
- [x] Update `lib/data/datasources/service_remote_datasource.dart`
- [x] Update `lib/data/datasources/package_remote_datasource.dart`
- [x] Update `lib/data/datasources/transaction_remote_datasource.dart`
  - Tambah `getReceipt`

### 2.3 New Datasources
- [x] Buat `lib/data/datasources/dashboard_remote_datasource.dart`
- [x] Buat `lib/data/datasources/settings_remote_datasource.dart`
- [x] Buat `lib/data/datasources/loyalty_remote_datasource.dart`
- [x] Buat `lib/data/datasources/referral_remote_datasource.dart`
- [x] Buat `lib/data/datasources/product_remote_datasource.dart`
- [x] Buat `lib/data/datasources/staff_remote_datasource.dart`
- [x] Buat `lib/data/datasources/treatment_remote_datasource.dart`

---

## 3. Presentation Layer - BLoC (P1)

### 3.1 Existing BLoCs (Update)
- [x] Update Dashboard BLoC dengan events/states baru
- [x] Update Customer BLoC untuk support loyalty & referral data

### 3.2 New BLoCs
- [x] Buat Loyalty BLoC (`lib/presentation/loyalty/bloc/`)
  - `loyalty_event.dart`
  - `loyalty_state.dart`
  - `loyalty_bloc.dart`

- [x] Buat Referral BLoC (`lib/presentation/referral/bloc/`)
  - `referral_event.dart`
  - `referral_state.dart`
  - `referral_bloc.dart`

- [x] Buat Product BLoC (`lib/presentation/product/bloc/`)
  - `product_event.dart`
  - `product_state.dart`
  - `product_bloc.dart`

- [x] Buat Settings BLoC (`lib/presentation/settings/bloc/`)
  - Combined event/state/bloc

- [x] Buat Staff BLoC (`lib/presentation/staff/bloc/`)

- [x] Buat Treatment BLoC (`lib/presentation/treatment/bloc/`)

---

## 4. Presentation Layer - UI (P1)

### 4.1 Dashboard Page Enhancement
- [x] Update dashboard dengan data dari API baru
- [x] Tambah revenue chart
- [x] Tambah today's appointments list
- [x] Responsive layout (phone & tablet)

### 4.2 Customer Detail Enhancement
- [x] Tambah loyalty points display
- [x] Tambah loyalty tier badge
- [x] Tambah referral code section
- [x] Tambah customer stats section

### 4.3 Loyalty Feature (Baru)
- [x] Loyalty summary widget/card
- [x] Points history list
- [x] Available rewards list
- [x] Redeem reward dialog
- [x] Redemption history (with cancel button)
- [x] Check code form (Gunakan Kode tab)
- [x] Points adjustment (admin) - in customer detail

### 4.4 Referral Feature (Baru)
- [x] Referral info card dengan QR code
- [x] Referral history list
- [x] Referred customers list
- [x] Apply referral code form

### 4.5 Product Feature (Baru)
- [x] Product categories list
- [x] Products grid/list
- [x] Product detail page (inline in product_page)
- [x] Product search

### 4.6 Settings Enhancement
- [x] Display clinic info
- [x] Display operating hours
- [x] Feature flags management

### 4.7 Staff Feature (Baru/Enhancement)
- [x] Staff list page
- [x] Beautician picker for appointment

### 4.8 Treatment Feature (Baru)
- [x] Treatment records list page
- [x] Treatment detail panel
- [x] Responsive layout (phone & tablet)

### 4.9 Transaction/Checkout Features
- [x] Checkout page with BLoC
- [x] Transaction history page with BLoC
- [x] Package management page with BLoC

---

## 5. Core/Utils (P1)

### 5.1 Dependency Injection
- [x] Setup `lib/injection.dart` dengan GetIt
- [x] Register semua datasources
- [x] Register semua BLoCs (di main.dart MultiBlocProvider)

### 5.2 Constants Update
- [x] Update `lib/core/constants/variables.dart` dengan API base URL baru
- [x] Tambah API endpoints constants

### 5.3 Theme/Colors
- [x] Pastikan warna loyalty tier sesuai (bronze, silver, gold, platinum)
- [x] Tambah status colors untuk berbagai status

---

## 6. Testing (P2)

### 6.1 Unit Tests
- [ ] Test models fromJson/toJson
- [ ] Test BLoC events dan states
- [ ] Test datasources (mock API)

### 6.2 Widget Tests
- [ ] Test loyalty widgets
- [ ] Test referral widgets
- [ ] Test product widgets

### 6.3 Integration Tests
- [ ] Test flow loyalty redemption
- [ ] Test flow referral code

---

## 7. Enhancement Ideas (P3)

### 7.1 Offline Support
- [ ] Cache settings data
- [ ] Cache customer data
- [ ] Cache service/product catalog

### 7.2 Push Notifications
- [ ] Appointment reminders
- [ ] Loyalty points earned notification
- [ ] Reward expiry reminders

### 7.3 QR Code Features
- [ ] Generate QR for referral code
- [ ] Scan QR for redemption code

### 7.4 Receipt/Invoice
- [ ] Generate PDF receipt
- [ ] Share receipt via WhatsApp

---

## Estimated Effort

| Section | Effort (Hours) | Status |
|---------|----------------|--------|
| Models | 8-12 | DONE |
| Datasources | 12-16 | DONE |
| BLoCs | 16-20 | DONE |
| UI/Widgets | 24-32 | DONE |
| Testing | 12-16 | TODO |
| **Total** | **72-96** | **~90%** |

---

## Notes

1. Prioritaskan fitur yang sudah ada di backend dan dibutuhkan user
2. Implementasi bertahap, mulai dari data layer ke presentation layer
3. Test di emulator sebelum deploy ke device fisik
4. Pastikan responsive untuk tablet sesuai CLAUDE.md rules
