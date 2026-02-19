# Flutter API Services - GlowUp Integration

Implementasi API services/datasources untuk Flutter.

## Base API Service

```dart
// lib/data/datasources/api_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:dartz/dartz.dart';
import '../models/responses/api_response.dart';
import 'auth_local_datasource.dart';

class ApiService {
  static const String baseUrl = 'https://glowup.jagoflutter.com/api/v1';

  final http.Client _client;
  final AuthLocalDatasource _authLocal;

  ApiService({
    http.Client? client,
    required AuthLocalDatasource authLocal,
  }) : _client = client ?? http.Client(),
       _authLocal = authLocal;

  Future<Map<String, String>> _getHeaders({bool requiresAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await _authLocal.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Future<Either<String, T>> get<T>(
    String endpoint, {
    T Function(dynamic)? fromJson,
    Map<String, dynamic>? queryParams,
    bool requiresAuth = true,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl$endpoint');
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams.map(
          (k, v) => MapEntry(k, v?.toString() ?? ''),
        ));
      }

      final response = await _client.get(
        uri,
        headers: await _getHeaders(requiresAuth: requiresAuth),
      );

      return _handleResponse(response, fromJson);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  Future<Either<String, T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJson,
    bool requiresAuth = true,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(requiresAuth: requiresAuth),
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse(response, fromJson);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  Future<Either<String, T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJson,
    bool requiresAuth = true,
  }) async {
    try {
      final response = await _client.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(requiresAuth: requiresAuth),
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse(response, fromJson);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  Future<Either<String, T>> patch<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJson,
    bool requiresAuth = true,
  }) async {
    try {
      final response = await _client.patch(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(requiresAuth: requiresAuth),
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse(response, fromJson);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  Future<Either<String, T>> delete<T>(
    String endpoint, {
    T Function(dynamic)? fromJson,
    bool requiresAuth = true,
  }) async {
    try {
      final response = await _client.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(requiresAuth: requiresAuth),
      );

      return _handleResponse(response, fromJson);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  Future<Either<String, T>> postMultipart<T>(
    String endpoint, {
    required Map<String, String> fields,
    required List<http.MultipartFile> files,
    T Function(dynamic)? fromJson,
    bool requiresAuth = true,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl$endpoint'));

      final headers = await _getHeaders(requiresAuth: requiresAuth);
      request.headers.addAll(headers);
      request.fields.addAll(fields);
      request.files.addAll(files);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response, fromJson);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  Either<String, T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJson,
  ) {
    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (fromJson != null) {
        return Right(fromJson(body['data'] ?? body));
      }
      return Right(body as T);
    }

    // Handle errors
    if (response.statusCode == 401) {
      return const Left('Session expired. Please login again.');
    }

    if (response.statusCode == 422) {
      // Validation errors
      final errors = body['errors'] as Map<String, dynamic>?;
      if (errors != null) {
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          return Left(firstError.first.toString());
        }
      }
      return Left(body['message'] ?? 'Validation error');
    }

    return Left(body['message'] ?? 'An error occurred');
  }

  String _handleError(dynamic error) {
    if (error is SocketException) {
      return 'No internet connection';
    }
    if (error is HttpException) {
      return 'Server error';
    }
    return 'An unexpected error occurred';
  }
}
```

---

## Auth Service

```dart
// lib/data/datasources/auth_remote_datasource.dart

import 'package:dartz/dartz.dart';
import '../models/responses/user_model.dart';
import '../models/responses/auth_response_model.dart';
import '../models/requests/login_request_model.dart';
import 'api_service.dart';
import 'auth_local_datasource.dart';

class AuthRemoteDatasource {
  final ApiService _api;
  final AuthLocalDatasource _authLocal;

  AuthRemoteDatasource({
    required ApiService api,
    required AuthLocalDatasource authLocal,
  }) : _api = api, _authLocal = authLocal;

  Future<Either<String, AuthResponseModel>> login(LoginRequestModel request) async {
    final result = await _api.post<AuthResponseModel>(
      '/login',
      body: request.toJson(),
      fromJson: (json) => AuthResponseModel.fromJson(json),
      requiresAuth: false,
    );

    return result.fold(
      (error) => Left(error),
      (auth) async {
        await _authLocal.saveAuthData(auth.token, auth.user);
        return Right(auth);
      },
    );
  }

  Future<Either<String, void>> logout() async {
    final result = await _api.post('/logout');
    await _authLocal.clearAll();
    return result.fold(
      (error) => Left(error),
      (_) => const Right(null),
    );
  }

  Future<Either<String, UserModel>> getProfile() async {
    return _api.get<UserModel>(
      '/profile',
      fromJson: (json) => UserModel.fromJson(json),
    );
  }

  Future<Either<String, UserModel>> updateProfile(Map<String, dynamic> data) async {
    return _api.put<UserModel>(
      '/profile',
      body: data,
      fromJson: (json) => UserModel.fromJson(json),
    );
  }

  Future<bool> validateToken() async {
    final result = await getProfile();
    return result.isRight();
  }
}
```

---

## Dashboard Service

```dart
// lib/data/datasources/dashboard_remote_datasource.dart

import 'package:dartz/dartz.dart';
import '../models/responses/dashboard_model.dart';
import 'api_service.dart';

class DashboardRemoteDatasource {
  final ApiService _api;

  DashboardRemoteDatasource({required ApiService api}) : _api = api;

  Future<Either<String, DashboardModel>> getDashboard() async {
    return _api.get<DashboardModel>(
      '/dashboard',
      fromJson: (json) => DashboardModel.fromJson(json),
    );
  }

  Future<Either<String, DashboardSummary>> getSummary() async {
    return _api.get<DashboardSummary>(
      '/dashboard/summary',
      fromJson: (json) => DashboardSummary.fromJson(json),
    );
  }
}
```

---

## Settings Service

```dart
// lib/data/datasources/settings_remote_datasource.dart

import 'package:dartz/dartz.dart';
import '../models/responses/settings_model.dart';
import 'api_service.dart';

class SettingsRemoteDatasource {
  final ApiService _api;

  SettingsRemoteDatasource({required ApiService api}) : _api = api;

  Future<Either<String, SettingsModel>> getSettings() async {
    return _api.get<SettingsModel>(
      '/settings',
      fromJson: (json) => SettingsModel.fromJson(json),
      requiresAuth: false,
    );
  }

  Future<Either<String, ClinicInfo>> getClinicInfo() async {
    return _api.get<ClinicInfo>(
      '/settings/clinic',
      fromJson: (json) => ClinicInfo.fromJson(json),
      requiresAuth: false,
    );
  }

  Future<Either<String, List<OperatingHourModel>>> getOperatingHours() async {
    return _api.get<List<OperatingHourModel>>(
      '/settings/hours',
      fromJson: (json) => (json as List)
          .map((e) => OperatingHourModel.fromJson(e))
          .toList(),
      requiresAuth: false,
    );
  }

  Future<Either<String, BrandingInfo>> getBranding() async {
    return _api.get<BrandingInfo>(
      '/settings/branding',
      fromJson: (json) => BrandingInfo.fromJson(json),
      requiresAuth: false,
    );
  }

  Future<Either<String, LoyaltyConfig>> getLoyaltyConfig() async {
    return _api.get<LoyaltyConfig>(
      '/settings/loyalty',
      fromJson: (json) => LoyaltyConfig.fromJson(json),
      requiresAuth: false,
    );
  }
}
```

---

## Customer Service

```dart
// lib/data/datasources/customer_remote_datasource.dart

import 'package:dartz/dartz.dart';
import '../models/responses/customer_model.dart';
import '../models/responses/api_response.dart';
import '../models/requests/customer_request_model.dart';
import 'api_service.dart';

class CustomerRemoteDatasource {
  final ApiService _api;

  CustomerRemoteDatasource({required ApiService api}) : _api = api;

  Future<Either<String, PaginatedResponse<CustomerModel>>> getCustomers({
    String? search,
    int page = 1,
    int perPage = 15,
  }) async {
    return _api.get<PaginatedResponse<CustomerModel>>(
      '/customers',
      queryParams: {
        if (search != null && search.isNotEmpty) 'search': search,
        'page': page.toString(),
        'per_page': perPage.toString(),
      },
      fromJson: (json) => PaginatedResponse.fromJson(
        json,
        (e) => CustomerModel.fromJson(e),
      ),
    );
  }

  Future<Either<String, CustomerModel>> getCustomerById(int id) async {
    return _api.get<CustomerModel>(
      '/customers/$id',
      fromJson: (json) => CustomerModel.fromJson(json),
    );
  }

  Future<Either<String, CustomerModel>> createCustomer(
    CustomerRequestModel request,
  ) async {
    return _api.post<CustomerModel>(
      '/customers',
      body: request.toJson(),
      fromJson: (json) => CustomerModel.fromJson(json),
    );
  }

  Future<Either<String, CustomerModel>> updateCustomer(
    int id,
    CustomerRequestModel request,
  ) async {
    return _api.put<CustomerModel>(
      '/customers/$id',
      body: request.toJson(),
      fromJson: (json) => CustomerModel.fromJson(json),
    );
  }

  Future<Either<String, void>> deleteCustomer(int id) async {
    return _api.delete('/customers/$id');
  }

  Future<Either<String, CustomerStats>> getCustomerStats(int id) async {
    return _api.get<CustomerStats>(
      '/customers/$id/stats',
      fromJson: (json) => CustomerStats.fromJson(json),
    );
  }
}
```

---

## Loyalty Service

```dart
// lib/data/datasources/loyalty_remote_datasource.dart

import 'package:dartz/dartz.dart';
import '../models/responses/loyalty_point_model.dart';
import '../models/responses/loyalty_reward_model.dart';
import '../models/responses/loyalty_redemption_model.dart';
import '../models/responses/api_response.dart';
import 'api_service.dart';

class LoyaltyRemoteDatasource {
  final ApiService _api;

  LoyaltyRemoteDatasource({required ApiService api}) : _api = api;

  // Customer Loyalty
  Future<Either<String, LoyaltySummary>> getCustomerLoyaltySummary(
    int customerId,
  ) async {
    return _api.get<LoyaltySummary>(
      '/customers/$customerId/loyalty',
      fromJson: (json) => LoyaltySummary.fromJson(json),
    );
  }

  Future<Either<String, PaginatedResponse<LoyaltyPointModel>>> getCustomerPoints(
    int customerId, {
    int page = 1,
  }) async {
    return _api.get<PaginatedResponse<LoyaltyPointModel>>(
      '/customers/$customerId/loyalty/points',
      queryParams: {'page': page.toString()},
      fromJson: (json) => PaginatedResponse.fromJson(
        json,
        (e) => LoyaltyPointModel.fromJson(e),
      ),
    );
  }

  Future<Either<String, PaginatedResponse<LoyaltyRedemptionModel>>>
      getCustomerRedemptions(
    int customerId, {
    String? status,
    int page = 1,
  }) async {
    return _api.get<PaginatedResponse<LoyaltyRedemptionModel>>(
      '/customers/$customerId/loyalty/redemptions',
      queryParams: {
        if (status != null) 'status': status,
        'page': page.toString(),
      },
      fromJson: (json) => PaginatedResponse.fromJson(
        json,
        (e) => LoyaltyRedemptionModel.fromJson(e),
      ),
    );
  }

  // Rewards
  Future<Either<String, List<LoyaltyRewardModel>>> getRewards() async {
    return _api.get<List<LoyaltyRewardModel>>(
      '/loyalty/rewards',
      fromJson: (json) => (json as List)
          .map((e) => LoyaltyRewardModel.fromJson(e))
          .toList(),
    );
  }

  Future<Either<String, LoyaltyRewardModel>> getRewardById(int id) async {
    return _api.get<LoyaltyRewardModel>(
      '/loyalty/rewards/$id',
      fromJson: (json) => LoyaltyRewardModel.fromJson(json),
    );
  }

  // Redeem
  Future<Either<String, LoyaltyRedemptionModel>> redeemReward(
    int customerId,
    int rewardId,
  ) async {
    return _api.post<LoyaltyRedemptionModel>(
      '/customers/$customerId/loyalty/redeem',
      body: {'reward_id': rewardId},
      fromJson: (json) => LoyaltyRedemptionModel.fromJson(json),
    );
  }

  // Check & Use Code
  Future<Either<String, Map<String, dynamic>>> checkCode(String code) async {
    return _api.post<Map<String, dynamic>>(
      '/loyalty/check-code',
      body: {'code': code},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<Either<String, LoyaltyRedemptionModel>> useCode(
    String code, {
    int? transactionId,
  }) async {
    return _api.post<LoyaltyRedemptionModel>(
      '/loyalty/use-code',
      body: {
        'code': code,
        if (transactionId != null) 'transaction_id': transactionId,
      },
      fromJson: (json) => LoyaltyRedemptionModel.fromJson(json),
    );
  }

  Future<Either<String, LoyaltyRedemptionModel>> cancelRedemption(
    int redemptionId,
  ) async {
    return _api.post<LoyaltyRedemptionModel>(
      '/loyalty/redemptions/$redemptionId/cancel',
      fromJson: (json) => LoyaltyRedemptionModel.fromJson(json),
    );
  }

  // Adjust Points (Admin)
  Future<Either<String, Map<String, dynamic>>> adjustPoints(
    int customerId, {
    required int points,
    required String description,
  }) async {
    return _api.post<Map<String, dynamic>>(
      '/customers/$customerId/loyalty/adjust',
      body: {
        'points': points,
        'description': description,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }
}
```

---

## Referral Service

```dart
// lib/data/datasources/referral_remote_datasource.dart

import 'package:dartz/dartz.dart';
import '../models/responses/customer_model.dart';
import '../models/responses/referral_log_model.dart';
import '../models/responses/api_response.dart';
import 'api_service.dart';

class ReferralRemoteDatasource {
  final ApiService _api;

  ReferralRemoteDatasource({required ApiService api}) : _api = api;

  // Public endpoints
  Future<Either<String, ReferralProgramInfo>> getProgramInfo() async {
    return _api.get<ReferralProgramInfo>(
      '/referral/program-info',
      fromJson: (json) => ReferralProgramInfo.fromJson(json),
      requiresAuth: false,
    );
  }

  Future<Either<String, Map<String, dynamic>>> validateCode(String code) async {
    return _api.post<Map<String, dynamic>>(
      '/referral/validate',
      body: {'code': code},
      fromJson: (json) => json as Map<String, dynamic>,
      requiresAuth: false,
    );
  }

  // Protected endpoints
  Future<Either<String, ReferralInfo>> getCustomerReferral(
    int customerId,
  ) async {
    return _api.get<ReferralInfo>(
      '/customers/$customerId/referral',
      fromJson: (json) => ReferralInfo.fromJson(json),
    );
  }

  Future<Either<String, PaginatedResponse<ReferralLogModel>>> getReferralHistory(
    int customerId, {
    int page = 1,
  }) async {
    return _api.get<PaginatedResponse<ReferralLogModel>>(
      '/customers/$customerId/referral/history',
      queryParams: {'page': page.toString()},
      fromJson: (json) => PaginatedResponse.fromJson(
        json,
        (e) => ReferralLogModel.fromJson(e),
      ),
    );
  }

  Future<Either<String, PaginatedResponse<CustomerModel>>> getReferredCustomers(
    int customerId, {
    int page = 1,
  }) async {
    return _api.get<PaginatedResponse<CustomerModel>>(
      '/customers/$customerId/referral/referrals',
      queryParams: {'page': page.toString()},
      fromJson: (json) => PaginatedResponse.fromJson(
        json,
        (e) => CustomerModel.fromJson(e),
      ),
    );
  }

  Future<Either<String, Map<String, dynamic>>> applyReferralCode(
    int customerId,
    String code,
  ) async {
    return _api.post<Map<String, dynamic>>(
      '/customers/$customerId/referral/apply',
      body: {'code': code},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }
}
```

---

## Product Service

```dart
// lib/data/datasources/product_remote_datasource.dart

import 'package:dartz/dartz.dart';
import '../models/responses/product_model.dart';
import '../models/responses/api_response.dart';
import 'api_service.dart';

class ProductRemoteDatasource {
  final ApiService _api;

  ProductRemoteDatasource({required ApiService api}) : _api = api;

  Future<Either<String, List<ProductCategoryModel>>> getCategories({
    bool withProducts = false,
    bool withCount = false,
  }) async {
    return _api.get<List<ProductCategoryModel>>(
      '/product-categories',
      queryParams: {
        if (withProducts) 'with_products': '1',
        if (withCount) 'with_count': '1',
      },
      fromJson: (json) => (json as List)
          .map((e) => ProductCategoryModel.fromJson(e))
          .toList(),
    );
  }

  Future<Either<String, ProductCategoryModel>> getCategoryById(int id) async {
    return _api.get<ProductCategoryModel>(
      '/product-categories/$id',
      fromJson: (json) => ProductCategoryModel.fromJson(json),
    );
  }

  Future<Either<String, PaginatedResponse<ProductModel>>> getProducts({
    int? categoryId,
    String? search,
    bool inStockOnly = true,
    int page = 1,
    int perPage = 20,
  }) async {
    return _api.get<PaginatedResponse<ProductModel>>(
      '/products',
      queryParams: {
        if (categoryId != null) 'category_id': categoryId.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
        'in_stock_only': inStockOnly ? '1' : '0',
        'page': page.toString(),
        'per_page': perPage.toString(),
      },
      fromJson: (json) => PaginatedResponse.fromJson(
        json,
        (e) => ProductModel.fromJson(e),
      ),
    );
  }

  Future<Either<String, ProductModel>> getProductById(int id) async {
    return _api.get<ProductModel>(
      '/products/$id',
      fromJson: (json) => ProductModel.fromJson(json),
    );
  }
}
```

---

## Staff Service

```dart
// lib/data/datasources/staff_remote_datasource.dart

import 'package:dartz/dartz.dart';
import '../models/responses/user_model.dart';
import '../models/responses/api_response.dart';
import 'api_service.dart';

class StaffRemoteDatasource {
  final ApiService _api;

  StaffRemoteDatasource({required ApiService api}) : _api = api;

  Future<Either<String, PaginatedResponse<UserModel>>> getStaff({
    String? role,
    String? search,
    bool activeOnly = true,
    int page = 1,
    int perPage = 20,
  }) async {
    return _api.get<PaginatedResponse<UserModel>>(
      '/staff',
      queryParams: {
        if (role != null) 'role': role,
        if (search != null && search.isNotEmpty) 'search': search,
        'active_only': activeOnly ? '1' : '0',
        'page': page.toString(),
        'per_page': perPage.toString(),
      },
      fromJson: (json) => PaginatedResponse.fromJson(
        json,
        (e) => UserModel.fromJson(e),
      ),
    );
  }

  Future<Either<String, List<UserModel>>> getBeauticians() async {
    return _api.get<List<UserModel>>(
      '/staff/beauticians',
      fromJson: (json) => (json as List)
          .map((e) => UserModel.fromJson(e))
          .toList(),
    );
  }

  Future<Either<String, UserModel>> getStaffById(int id) async {
    return _api.get<UserModel>(
      '/staff/$id',
      fromJson: (json) => UserModel.fromJson(json),
    );
  }
}
```

---

## Appointment Service

```dart
// lib/data/datasources/appointment_remote_datasource.dart

import 'package:dartz/dartz.dart';
import '../models/responses/appointment_model.dart';
import '../models/responses/api_response.dart';
import '../models/requests/appointment_request_model.dart';
import 'api_service.dart';

class AppointmentRemoteDatasource {
  final ApiService _api;

  AppointmentRemoteDatasource({required ApiService api}) : _api = api;

  Future<Either<String, PaginatedResponse<AppointmentModel>>> getAppointments({
    String? status,
    String? startDate,
    String? endDate,
    int? staffId,
    int? customerId,
    int page = 1,
    int perPage = 15,
  }) async {
    return _api.get<PaginatedResponse<AppointmentModel>>(
      '/appointments',
      queryParams: {
        if (status != null) 'status': status,
        if (startDate != null) 'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
        if (staffId != null) 'staff_id': staffId.toString(),
        if (customerId != null) 'customer_id': customerId.toString(),
        'page': page.toString(),
        'per_page': perPage.toString(),
      },
      fromJson: (json) => PaginatedResponse.fromJson(
        json,
        (e) => AppointmentModel.fromJson(e),
      ),
    );
  }

  Future<Either<String, AppointmentModel>> getAppointmentById(int id) async {
    return _api.get<AppointmentModel>(
      '/appointments/$id',
      fromJson: (json) => AppointmentModel.fromJson(json),
    );
  }

  Future<Either<String, AppointmentModel>> createAppointment(
    AppointmentRequestModel request,
  ) async {
    return _api.post<AppointmentModel>(
      '/appointments',
      body: request.toJson(),
      fromJson: (json) => AppointmentModel.fromJson(json),
    );
  }

  Future<Either<String, AppointmentModel>> updateAppointment(
    int id,
    AppointmentRequestModel request,
  ) async {
    return _api.put<AppointmentModel>(
      '/appointments/$id',
      body: request.toJson(),
      fromJson: (json) => AppointmentModel.fromJson(json),
    );
  }

  Future<Either<String, void>> deleteAppointment(int id) async {
    return _api.delete('/appointments/$id');
  }

  Future<Either<String, AppointmentModel>> updateStatus(
    int id,
    UpdateAppointmentStatusRequest request,
  ) async {
    return _api.patch<AppointmentModel>(
      '/appointments/$id/status',
      body: request.toJson(),
      fromJson: (json) => AppointmentModel.fromJson(json),
    );
  }

  Future<Either<String, List<AppointmentModel>>> getTodayAppointments() async {
    return _api.get<List<AppointmentModel>>(
      '/appointments-today',
      fromJson: (json) => (json as List)
          .map((e) => AppointmentModel.fromJson(e))
          .toList(),
    );
  }

  Future<Either<String, List<AppointmentModel>>> getCalendarAppointments({
    required String start,
    required String end,
  }) async {
    return _api.get<List<AppointmentModel>>(
      '/appointments-calendar',
      queryParams: {
        'start': start,
        'end': end,
      },
      fromJson: (json) => (json as List)
          .map((e) => AppointmentModel.fromJson(e))
          .toList(),
    );
  }

  Future<Either<String, List<TimeSlot>>> getAvailableSlots({
    required String date,
    required int serviceId,
    int? staffId,
  }) async {
    return _api.get<List<TimeSlot>>(
      '/appointments-available-slots',
      queryParams: {
        'date': date,
        'service_id': serviceId.toString(),
        if (staffId != null) 'staff_id': staffId.toString(),
      },
      fromJson: (json) => (json as List)
          .map((e) => TimeSlot.fromJson(e))
          .toList(),
    );
  }
}
```

---

## Treatment Service

```dart
// lib/data/datasources/treatment_remote_datasource.dart

import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import '../models/responses/treatment_record_model.dart';
import '../models/responses/api_response.dart';
import 'api_service.dart';

class TreatmentRemoteDatasource {
  final ApiService _api;

  TreatmentRemoteDatasource({required ApiService api}) : _api = api;

  Future<Either<String, PaginatedResponse<TreatmentRecordModel>>> getTreatments({
    int? customerId,
    bool withPhotos = false,
    int page = 1,
    int perPage = 15,
  }) async {
    return _api.get<PaginatedResponse<TreatmentRecordModel>>(
      '/treatments',
      queryParams: {
        if (customerId != null) 'customer_id': customerId.toString(),
        if (withPhotos) 'with_photos': '1',
        'page': page.toString(),
        'per_page': perPage.toString(),
      },
      fromJson: (json) => PaginatedResponse.fromJson(
        json,
        (e) => TreatmentRecordModel.fromJson(e),
      ),
    );
  }

  Future<Either<String, TreatmentRecordModel>> getTreatmentById(int id) async {
    return _api.get<TreatmentRecordModel>(
      '/treatments/$id',
      fromJson: (json) => TreatmentRecordModel.fromJson(json),
    );
  }

  Future<Either<String, TreatmentRecordModel>> createTreatment({
    required int appointmentId,
    required int customerId,
    required int staffId,
    String? notes,
    String? recommendations,
    String? followUpDate,
    List<File>? beforePhotos,
    List<File>? afterPhotos,
  }) async {
    final fields = {
      'appointment_id': appointmentId.toString(),
      'customer_id': customerId.toString(),
      'staff_id': staffId.toString(),
      if (notes != null) 'notes': notes,
      if (recommendations != null) 'recommendations': recommendations,
      if (followUpDate != null) 'follow_up_date': followUpDate,
    };

    final files = <http.MultipartFile>[];

    if (beforePhotos != null) {
      for (var i = 0; i < beforePhotos.length; i++) {
        files.add(await http.MultipartFile.fromPath(
          'before_photos[$i]',
          beforePhotos[i].path,
        ));
      }
    }

    if (afterPhotos != null) {
      for (var i = 0; i < afterPhotos.length; i++) {
        files.add(await http.MultipartFile.fromPath(
          'after_photos[$i]',
          afterPhotos[i].path,
        ));
      }
    }

    return _api.postMultipart<TreatmentRecordModel>(
      '/treatments',
      fields: fields,
      files: files,
      fromJson: (json) => TreatmentRecordModel.fromJson(json),
    );
  }

  Future<Either<String, TreatmentRecordModel>> updateTreatment(
    int id, {
    String? notes,
    String? recommendations,
    String? followUpDate,
  }) async {
    return _api.put<TreatmentRecordModel>(
      '/treatments/$id',
      body: {
        if (notes != null) 'notes': notes,
        if (recommendations != null) 'recommendations': recommendations,
        if (followUpDate != null) 'follow_up_date': followUpDate,
      },
      fromJson: (json) => TreatmentRecordModel.fromJson(json),
    );
  }

  Future<Either<String, void>> deleteTreatment(int id) async {
    return _api.delete('/treatments/$id');
  }
}
```

---

## Transaction Service

```dart
// lib/data/datasources/transaction_remote_datasource.dart

import 'package:dartz/dartz.dart';
import '../models/responses/transaction_model.dart';
import '../models/responses/api_response.dart';
import 'api_service.dart';

class TransactionRemoteDatasource {
  final ApiService _api;

  TransactionRemoteDatasource({required ApiService api}) : _api = api;

  Future<Either<String, PaginatedResponse<TransactionModel>>> getTransactions({
    int? customerId,
    String? status,
    String? startDate,
    String? endDate,
    int page = 1,
    int perPage = 15,
  }) async {
    return _api.get<PaginatedResponse<TransactionModel>>(
      '/transactions',
      queryParams: {
        if (customerId != null) 'customer_id': customerId.toString(),
        if (status != null) 'status': status,
        if (startDate != null) 'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
        'page': page.toString(),
        'per_page': perPage.toString(),
      },
      fromJson: (json) => PaginatedResponse.fromJson(
        json,
        (e) => TransactionModel.fromJson(e),
      ),
    );
  }

  Future<Either<String, TransactionModel>> getTransactionById(int id) async {
    return _api.get<TransactionModel>(
      '/transactions/$id',
      fromJson: (json) => TransactionModel.fromJson(json),
    );
  }

  Future<Either<String, Map<String, dynamic>>> getReceipt(int id) async {
    return _api.get<Map<String, dynamic>>(
      '/transactions/$id/receipt',
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }
}
```

---

## Service (Layanan) Service

```dart
// lib/data/datasources/service_remote_datasource.dart

import 'package:dartz/dartz.dart';
import '../models/responses/service_model.dart';
import '../models/responses/api_response.dart';
import 'api_service.dart';

class ServiceRemoteDatasource {
  final ApiService _api;

  ServiceRemoteDatasource({required ApiService api}) : _api = api;

  Future<Either<String, List<ServiceCategoryModel>>> getCategories({
    bool withServices = false,
    bool withCount = false,
  }) async {
    return _api.get<List<ServiceCategoryModel>>(
      '/service-categories',
      queryParams: {
        if (withServices) 'with_services': '1',
        if (withCount) 'with_count': '1',
      },
      fromJson: (json) => (json as List)
          .map((e) => ServiceCategoryModel.fromJson(e))
          .toList(),
    );
  }

  Future<Either<String, ServiceCategoryModel>> getCategoryById(int id) async {
    return _api.get<ServiceCategoryModel>(
      '/service-categories/$id',
      fromJson: (json) => ServiceCategoryModel.fromJson(json),
    );
  }

  Future<Either<String, PaginatedResponse<ServiceModel>>> getServices({
    int? categoryId,
    String? search,
    int page = 1,
    int perPage = 20,
  }) async {
    return _api.get<PaginatedResponse<ServiceModel>>(
      '/services',
      queryParams: {
        if (categoryId != null) 'category_id': categoryId.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
        'page': page.toString(),
        'per_page': perPage.toString(),
      },
      fromJson: (json) => PaginatedResponse.fromJson(
        json,
        (e) => ServiceModel.fromJson(e),
      ),
    );
  }

  Future<Either<String, ServiceModel>> getServiceById(int id) async {
    return _api.get<ServiceModel>(
      '/services/$id',
      fromJson: (json) => ServiceModel.fromJson(json),
    );
  }
}
```

---

## Package Service

```dart
// lib/data/datasources/package_remote_datasource.dart

import 'package:dartz/dartz.dart';
import '../models/responses/package_model.dart';
import '../models/responses/api_response.dart';
import 'api_service.dart';

class PackageRemoteDatasource {
  final ApiService _api;

  PackageRemoteDatasource({required ApiService api}) : _api = api;

  Future<Either<String, List<PackageModel>>> getPackages({
    int? serviceId,
  }) async {
    return _api.get<List<PackageModel>>(
      '/packages',
      queryParams: {
        if (serviceId != null) 'service_id': serviceId.toString(),
      },
      fromJson: (json) => (json as List)
          .map((e) => PackageModel.fromJson(e))
          .toList(),
    );
  }

  Future<Either<String, PackageModel>> getPackageById(int id) async {
    return _api.get<PackageModel>(
      '/packages/$id',
      fromJson: (json) => PackageModel.fromJson(json),
    );
  }

  Future<Either<String, PaginatedResponse<CustomerPackageModel>>>
      getCustomerPackages({
    int? customerId,
    bool activeOnly = false,
    String? status,
    int page = 1,
    int perPage = 15,
  }) async {
    return _api.get<PaginatedResponse<CustomerPackageModel>>(
      '/customer-packages',
      queryParams: {
        if (customerId != null) 'customer_id': customerId.toString(),
        if (activeOnly) 'active_only': '1',
        if (status != null) 'status': status,
        'page': page.toString(),
        'per_page': perPage.toString(),
      },
      fromJson: (json) => PaginatedResponse.fromJson(
        json,
        (e) => CustomerPackageModel.fromJson(e),
      ),
    );
  }

  Future<Either<String, CustomerPackageModel>> getCustomerPackageById(
    int id,
  ) async {
    return _api.get<CustomerPackageModel>(
      '/customer-packages/$id',
      fromJson: (json) => CustomerPackageModel.fromJson(json),
    );
  }
}
```
