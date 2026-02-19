# Implementation Checklist - GlowUp API Integration

Checklist detail untuk tracking progress implementasi API baru.

**Last Updated:** 2026-02-06

---

## Phase 1: Foundation (Data Layer)

### 1.1 Base Setup

| Task | File | Status | Notes |
|------|------|--------|-------|
| Update API base URL | `lib/core/constants/variables.dart` | [x] | Added new endpoints |
| Create ApiResponse model | `lib/data/models/responses/api_response.dart` | [x] | Generic response wrapper |
| Create PaginatedResponse model | `lib/data/models/responses/api_response.dart` | [x] | Includes PaginationMeta |
| Create/Update ApiService | `lib/data/datasources/api_service.dart` | [x] | Base HTTP client with multipart |

### 1.2 Auth Layer

| Task | File | Status | Notes |
|------|------|--------|-------|
| Update UserModel | `lib/data/models/responses/user_model.dart` | [x] | Already has helper methods |
| Create AuthResponseModel | `lib/data/models/responses/auth_response_model.dart` | [x] | Already exists |
| Update AuthRemoteDatasource | `lib/data/datasources/auth_remote_datasource.dart` | [x] | Already exists |
| Update AuthLocalDatasource | `lib/data/datasources/auth_local_datasource.dart` | [x] | Already exists |

### 1.3 Customer Models

| Task | File | Status | Notes |
|------|------|--------|-------|
| Update CustomerModel | `lib/data/models/responses/customer_model.dart` | [x] | Added loyalty & referral fields |
| Create ReferralStats class | `lib/data/models/responses/referral_model.dart` | [x] | Separate file |
| Create CustomerStats class | `lib/data/models/responses/customer_model.dart` | [x] | Added to CustomerModel file |
| Create CustomerRequestModel | `lib/data/models/requests/customer_request_model.dart` | [x] | Already exists |

### 1.4 Loyalty Models

| Task | File | Status | Notes |
|------|------|--------|-------|
| Create LoyaltyPointModel | `lib/data/models/responses/loyalty_point_model.dart` | [x] | Points history item |
| Create LoyaltyRewardModel | `lib/data/models/responses/loyalty_reward_model.dart` | [x] | Available rewards |
| Create LoyaltyRedemptionModel | `lib/data/models/responses/loyalty_redemption_model.dart` | [x] | Redemption record |
| Create LoyaltySummary | `lib/data/models/responses/loyalty_point_model.dart` | [x] | Customer loyalty overview |

### 1.5 Referral Models

| Task | File | Status | Notes |
|------|------|--------|-------|
| Create ReferralLogModel | `lib/data/models/responses/referral_model.dart` | [x] | Referral history |
| Create ReferralInfo | `lib/data/models/responses/referral_model.dart` | [x] | Customer referral info |
| Create ReferralProgramInfo | `lib/data/models/responses/referral_model.dart` | [x] | Program settings |

### 1.6 Product Models

| Task | File | Status | Notes |
|------|------|--------|-------|
| Create ProductCategoryModel | `lib/data/models/responses/product_model.dart` | [x] | Category list |
| Create ProductModel | `lib/data/models/responses/product_model.dart` | [x] | Product details |

### 1.7 Settings Models

| Task | File | Status | Notes |
|------|------|--------|-------|
| Create SettingsModel | `lib/data/models/responses/settings_model.dart` | [x] | Main settings |
| Create ClinicInfo | `lib/data/models/responses/settings_model.dart` | [x] | Clinic details |
| Create OperatingHourModel | `lib/data/models/responses/settings_model.dart` | [x] | Business hours |
| Create BrandingInfo | `lib/data/models/responses/settings_model.dart` | [x] | Logo & colors |
| Create LoyaltyConfig | `lib/data/models/responses/settings_model.dart` | [x] | Loyalty settings |

### 1.8 Dashboard Models

| Task | File | Status | Notes |
|------|------|--------|-------|
| Create/Update DashboardModel | `lib/data/models/responses/dashboard_model.dart` | [x] | Main dashboard data |
| Create DashboardStats | `lib/data/models/responses/dashboard_model.dart` | [x] | Exists (RevenueChartData) |
| Create RevenueChartData | `lib/data/models/responses/dashboard_model.dart` | [x] | Chart data |
| Create DashboardSummary | `lib/data/models/responses/dashboard_model.dart` | [x] | Summary endpoint |
| Create PopularService | `lib/data/models/responses/dashboard_model.dart` | [x] | Popular services |

### 1.9 Other Models

| Task | File | Status | Notes |
|------|------|--------|-------|
| Update AppointmentModel | `lib/data/models/responses/appointment_model.dart` | [x] | Already has enums & helpers |
| Create TimeSlot | `lib/data/models/responses/appointment_model.dart` | [x] | Available slots |
| Create TreatmentRecordModel | `lib/data/models/responses/treatment_record_model.dart` | [x] | With photos |
| Create TransactionModel | `lib/data/models/responses/transaction_model.dart` | [x] | Full details |
| Create PackageModel | `lib/data/models/responses/package_model.dart` | [x] | Package templates |
| Create CustomerPackageModel | `lib/data/models/responses/package_model.dart` | [x] | Purchased packages |

---

## Phase 2: Datasources

### 2.1 Core Datasources

| Task | File | Status | Notes |
|------|------|--------|-------|
| Update DashboardRemoteDatasource | `lib/data/datasources/dashboard_remote_datasource.dart` | [x] | Added getSummary |
| Create SettingsRemoteDatasource | `lib/data/datasources/settings_remote_datasource.dart` | [x] | Settings API |
| Existing CustomerRemoteDatasource | `lib/data/datasources/customer_remote_datasource.dart` | [x] | Already exists |

### 2.2 New Feature Datasources

| Task | File | Status | Notes |
|------|------|--------|-------|
| Create LoyaltyRemoteDatasource | `lib/data/datasources/loyalty_remote_datasource.dart` | [x] | Full loyalty API |
| Create ReferralRemoteDatasource | `lib/data/datasources/referral_remote_datasource.dart` | [x] | Referral API |
| Create ProductRemoteDatasource | `lib/data/datasources/product_remote_datasource.dart` | [x] | Products API |
| Create StaffRemoteDatasource | `lib/data/datasources/staff_remote_datasource.dart` | [x] | Staff/beautician API |

### 2.3 Existing Datasources Update

| Task | File | Status | Notes |
|------|------|--------|-------|
| Existing AppointmentRemoteDatasource | `lib/data/datasources/appointment_remote_datasource.dart` | [x] | Already has slots, calendar |
| Existing ServiceRemoteDatasource | `lib/data/datasources/service_remote_datasource.dart` | [x] | Already exists |
| Create TreatmentRemoteDatasource | `lib/data/datasources/treatment_remote_datasource.dart` | [x] | Multipart upload |
| Create TransactionRemoteDatasource | `lib/data/datasources/transaction_remote_datasource.dart` | [x] | Receipt endpoint |
| Create PackageRemoteDatasource | `lib/data/datasources/package_remote_datasource.dart` | [x] | Customer packages |

### 2.4 Dependency Injection

| Task | File | Status | Notes |
|------|------|--------|-------|
| Setup GetIt | `lib/injection.dart` | [x] | DI container |
| Register all datasources | `lib/injection.dart` | [x] | All registered |
| Add get_it package | `pubspec.yaml` | [x] | Version 8.0.3 |
| Add equatable package | `pubspec.yaml` | [x] | Version 2.0.7 |

---

## Phase 3: BLoC State Management

### 3.1 New BLoCs

| Task | Folder | Status | Notes |
|------|--------|--------|-------|
| Create LoyaltyBloc | `lib/presentation/loyalty/bloc/` | [x] | Event, State, BLoC |
| Create ReferralBloc | `lib/presentation/referral/bloc/` | [x] | Event, State, BLoC |
| Create ProductBloc | `lib/presentation/product/bloc/` | [x] | Event, State, BLoC |
| Create SettingsBloc | `lib/presentation/settings/bloc/` | [x] | Combined file |
| Create StaffBloc | `lib/presentation/staff/bloc/` | [x] | Combined file |
| Create TreatmentBloc | `lib/presentation/treatment/bloc/` | [x] | Event, State, BLoC |

### 3.2 Update Existing BLoCs

| Task | File | Status | Notes |
|------|------|--------|-------|
| Update DashboardBloc | `lib/presentation/dashboard/bloc/` | [x] | New events/states |
| Update CustomerBloc | `lib/presentation/customer/bloc/` | [x] | Loyalty/referral support |
| Update AppointmentBloc | `lib/presentation/appointment/bloc/` | [x] | Calendar, slots |
| Update TransactionBloc | `lib/presentation/transaction/bloc/` | [x] | Receipt support |

---

## Phase 4: UI Implementation

### 4.1 Dashboard Enhancement

| Task | File | Status | Notes |
|------|------|--------|-------|
| Update Dashboard Phone Layout | `lib/presentation/dashboard/widgets/dashboard_phone_layout.dart` | [x] | Stats cards |
| Create/Update Dashboard Tablet Layout | `lib/presentation/dashboard/widgets/dashboard_tablet_layout.dart` | [x] | Split view 60:40 |
| Add Revenue Chart | Dashboard widgets | [x] | fl_chart package |
| Add Today Appointments | Dashboard widgets | [x] | List view |

### 4.2 Customer Detail Enhancement

| Task | File | Status | Notes |
|------|------|--------|-------|
| Add Loyalty Points Card | Customer detail | [x] | Points & tier badge |
| Add Referral Code Card | Customer detail | [x] | Code & copy button |
| Add Customer Stats Card | Customer detail | [x] | Visits, spent, packages |
| Add Points History Tab | Customer detail | [x] | Via loyalty page |

### 4.3 Loyalty UI

| Task | Folder | Status | Notes |
|------|--------|--------|-------|
| Create Loyalty Summary Widget | `lib/presentation/loyalty/pages/` | [x] | Points overview |
| Create Points History List | `lib/presentation/loyalty/pages/` | [x] | Paginated list |
| Create Rewards Grid | `lib/presentation/loyalty/pages/` | [x] | Available rewards |
| Create Redeem Dialog | `lib/presentation/loyalty/pages/` | [x] | Confirm redeem |
| Create Code Check Form | `lib/presentation/loyalty/pages/` | [x] | Gunakan Kode tab + checkout section |
| Create Adjust Points Dialog | `lib/presentation/customer/widgets/` | [x] | In customer detail panel |

### 4.4 Referral UI

| Task | Folder | Status | Notes |
|------|--------|--------|-------|
| Create Referral Info Card | `lib/presentation/referral/pages/` | [x] | Code + share |
| Create Referral QR Widget | `lib/presentation/referral/pages/` | [x] | QR code display |
| Create Referral History List | `lib/presentation/referral/pages/` | [x] | History items |
| Create Referred Customers List | `lib/presentation/referral/pages/` | [x] | In referral page tabs |
| Create Apply Code Form | `lib/presentation/referral/pages/` | [x] | For new customer |

### 4.5 Product UI

| Task | Folder | Status | Notes |
|------|--------|--------|-------|
| Create Product Categories | `lib/presentation/product/pages/` | [x] | Horizontal scroll |
| Create Products Grid | `lib/presentation/product/pages/` | [x] | 2 cols phone, 4 tablet |
| Create Product Card | `lib/presentation/product/pages/` | [x] | Image, name, price |
| Create Product Detail Page | `lib/presentation/product/pages/` | [x] | Inline in product_page |
| Create Product Search | `lib/presentation/product/pages/` | [x] | Search bar |

### 4.6 Settings UI

| Task | File | Status | Notes |
|------|------|--------|-------|
| Update Settings Page | `lib/presentation/settings/pages/settings_page.dart` | [x] | Clinic info from API |
| Add Operating Hours Display | Settings page | [x] | Weekly schedule from API |
| Add Feature Flags Section | Settings page | [x] | Feature chips display |

### 4.7 Staff/Beautician UI

| Task | Folder | Status | Notes |
|------|--------|--------|-------|
| Create Beautician Picker | `lib/presentation/staff/pages/` | [x] | For appointment |
| Create Staff List | `lib/presentation/staff/pages/` | [x] | Phone + tablet layout |

---

## Phase 5: Integration & Testing

### 5.1 Integration

| Task | Status | Notes |
|------|--------|-------|
| Wire up Dashboard with API | [x] | DashboardBloc connected |
| Wire up Customer with loyalty/referral | [x] | Detail panel shows loyalty & referral |
| Wire up Appointment with slots | [x] | Already in AppointmentBloc |
| Wire up Checkout with loyalty codes | [x] | Loyalty code section in checkout |
| Wire up Settings on app start | [x] | SettingsBloc in settings_page |

### 5.2 Testing

| Task | Status | Notes |
|------|--------|-------|
| Test login flow | [ ] | Token storage |
| Test dashboard data | [ ] | Stats accuracy |
| Test customer CRUD | [ ] | With pagination |
| Test loyalty redeem flow | [ ] | Points deduction |
| Test referral apply flow | [ ] | Points award |
| Test appointment booking | [ ] | Time slot validation |
| Test responsive layouts | [ ] | Phone & tablet |

---

## Phase 6: Polish & Deploy

| Task | Status | Notes |
|------|--------|-------|
| Error handling UI | [x] | BLoC error states with SnackBar |
| Loading states | [x] | CircularProgressIndicator in all pages |
| Empty states | [x] | Empty state widgets in lists |
| Pull to refresh | [x] | RefreshIndicator on list pages |
| Offline handling | [ ] | Graceful degradation |
| Performance optimization | [ ] | Lazy loading |
| Final QA testing | [ ] | All devices |
| Deploy to TestFlight/Play Store | [ ] | Beta release |

---

## Files Created/Modified Summary

### New Files Created (Phase 1 & 2)

**Models:**
- `lib/data/models/responses/api_response.dart`
- `lib/data/models/responses/loyalty_point_model.dart`
- `lib/data/models/responses/loyalty_reward_model.dart`
- `lib/data/models/responses/loyalty_redemption_model.dart`
- `lib/data/models/responses/referral_model.dart`
- `lib/data/models/responses/product_model.dart`
- `lib/data/models/responses/settings_model.dart`
- `lib/data/models/responses/package_model.dart`
- `lib/data/models/responses/transaction_model.dart`
- `lib/data/models/responses/treatment_record_model.dart`

**Datasources:**
- `lib/data/datasources/api_service.dart`
- `lib/data/datasources/settings_remote_datasource.dart`
- `lib/data/datasources/loyalty_remote_datasource.dart`
- `lib/data/datasources/referral_remote_datasource.dart`
- `lib/data/datasources/product_remote_datasource.dart`
- `lib/data/datasources/staff_remote_datasource.dart`
- `lib/data/datasources/transaction_remote_datasource.dart`
- `lib/data/datasources/package_remote_datasource.dart`
- `lib/data/datasources/treatment_remote_datasource.dart`

**Core:**
- `lib/injection.dart`

### Modified Files

- `lib/core/constants/variables.dart` - Added new endpoints
- `lib/data/models/responses/customer_model.dart` - Added loyalty & referral fields
- `lib/data/models/responses/dashboard_model.dart` - Added DashboardSummary, PopularService
- `lib/data/datasources/dashboard_remote_datasource.dart` - Added getSummary method
- `pubspec.yaml` - Added get_it & equatable packages

---

## Progress Summary

| Phase | Total Tasks | Completed | Progress |
|-------|-------------|-----------|----------|
| Phase 1: Models | 30+ | 30+ | 100% |
| Phase 2: Datasources | 15 | 15 | 100% |
| Phase 3: BLoCs | 10 | 10 | 100% |
| Phase 4: UI | 30 | 30 | 100% |
| Phase 5: Integration | 12 | 5 | ~42% |
| Phase 6: Deploy | 8 | 4 | 50% |
| **Total** | **105+** | **94+** | **~90%** |

---

### New Files Created (Phase 3 & 4)

**BLoCs:**
- `lib/presentation/loyalty/bloc/loyalty_bloc.dart` + event + state
- `lib/presentation/referral/bloc/referral_bloc.dart` + event + state
- `lib/presentation/product/bloc/product_bloc.dart` + event + state
- `lib/presentation/settings/bloc/settings_bloc.dart` (combined)
- `lib/presentation/staff/bloc/staff_bloc.dart` (combined)
- `lib/presentation/treatment/bloc/treatment_bloc.dart` + event + state
- `lib/presentation/checkout/bloc/checkout_bloc.dart` + event + state
- `lib/presentation/transaction/bloc/transaction_bloc.dart` + event + state
- `lib/presentation/package/bloc/package_bloc.dart` + event + state

**Pages:**
- `lib/presentation/loyalty/pages/loyalty_page.dart`
- `lib/presentation/referral/pages/referral_page.dart`
- `lib/presentation/product/pages/product_page.dart`
- `lib/presentation/staff/pages/staff_page.dart`
- `lib/presentation/treatment/pages/treatment_page.dart`
- `lib/presentation/checkout/pages/checkout_page.dart`
- `lib/presentation/transaction/pages/transaction_page.dart`
- `lib/presentation/package/pages/package_page.dart`
- `lib/presentation/dashboard/widgets/dashboard_phone_layout.dart`
- `lib/presentation/dashboard/widgets/dashboard_tablet_layout.dart`

### Modified Files (Phase 3-5)

- `lib/main.dart` - Added all BlocProviders
- `lib/presentation/home/pages/home_page.dart` - Navigation for all features
- `lib/presentation/settings/pages/settings_page.dart` - SettingsBloc integration
- `lib/presentation/customer/widgets/customer_detail_panel.dart` - Loyalty & referral display

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-02-06 | Initial checklist created |
| 1.1 | 2026-02-06 | Phase 1 & 2 completed |
| 1.2 | 2026-02-06 | Phase 3, 4 & 5 partially completed (~84% total) |
