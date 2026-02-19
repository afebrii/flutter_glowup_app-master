import 'package:get_it/get_it.dart';

import 'data/datasources/api_service.dart';
import 'data/datasources/auth_local_datasource.dart';
import 'data/datasources/auth_remote_datasource.dart';
import 'data/datasources/customer_remote_datasource.dart';
import 'data/datasources/dashboard_remote_datasource.dart';
import 'data/datasources/appointment_remote_datasource.dart';
import 'data/datasources/service_remote_datasource.dart';
import 'data/datasources/settings_remote_datasource.dart';
import 'data/datasources/loyalty_remote_datasource.dart';
import 'data/datasources/referral_remote_datasource.dart';
import 'data/datasources/product_remote_datasource.dart';
import 'data/datasources/staff_remote_datasource.dart';
import 'data/datasources/package_remote_datasource.dart';
import 'data/datasources/transaction_remote_datasource.dart';
import 'data/datasources/treatment_remote_datasource.dart';
import 'data/datasources/report_remote_datasource.dart';

final getIt = GetIt.instance;

/// Setup all dependencies
void setupDependencies() {
  // ==================== Local Datasources ====================
  getIt.registerLazySingleton<AuthLocalDatasource>(
    () => AuthLocalDatasource(),
  );

  // ==================== API Service ====================
  getIt.registerLazySingleton<ApiService>(
    () => ApiService(authLocal: getIt<AuthLocalDatasource>()),
  );

  // ==================== Remote Datasources ====================

  // Auth
  getIt.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasource(),
  );

  // Dashboard
  getIt.registerLazySingleton<DashboardRemoteDatasource>(
    () => DashboardRemoteDatasource(api: getIt<ApiService>()),
  );

  // Settings
  getIt.registerLazySingleton<SettingsRemoteDatasource>(
    () => SettingsRemoteDatasource(api: getIt<ApiService>()),
  );

  // Customer
  getIt.registerLazySingleton<CustomerRemoteDatasource>(
    () => CustomerRemoteDatasource(),
  );

  // Loyalty
  getIt.registerLazySingleton<LoyaltyRemoteDatasource>(
    () => LoyaltyRemoteDatasource(api: getIt<ApiService>()),
  );

  // Referral
  getIt.registerLazySingleton<ReferralRemoteDatasource>(
    () => ReferralRemoteDatasource(api: getIt<ApiService>()),
  );

  // Product
  getIt.registerLazySingleton<ProductRemoteDatasource>(
    () => ProductRemoteDatasource(api: getIt<ApiService>()),
  );

  // Staff
  getIt.registerLazySingleton<StaffRemoteDatasource>(
    () => StaffRemoteDatasource(api: getIt<ApiService>()),
  );

  // Service
  getIt.registerLazySingleton<ServiceRemoteDatasource>(
    () => ServiceRemoteDatasource(),
  );

  // Appointment
  getIt.registerLazySingleton<AppointmentRemoteDatasource>(
    () => AppointmentRemoteDatasource(),
  );

  // Treatment
  getIt.registerLazySingleton<TreatmentRemoteDatasource>(
    () => TreatmentRemoteDatasource(api: getIt<ApiService>()),
  );

  // Package
  getIt.registerLazySingleton<PackageRemoteDatasource>(
    () => PackageRemoteDatasource(api: getIt<ApiService>()),
  );

  // Transaction
  getIt.registerLazySingleton<TransactionRemoteDatasource>(
    () => TransactionRemoteDatasource(api: getIt<ApiService>()),
  );

  // Report
  getIt.registerLazySingleton<ReportRemoteDatasource>(
    () => ReportRemoteDatasource(api: getIt<ApiService>()),
  );
}

/// Reset all dependencies (useful for testing)
Future<void> resetDependencies() async {
  await getIt.reset();
  setupDependencies();
}
