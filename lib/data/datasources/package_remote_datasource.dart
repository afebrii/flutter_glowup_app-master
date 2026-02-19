import 'package:dartz/dartz.dart';
import '../../core/constants/variables.dart';
import '../models/responses/api_response.dart';
import '../models/responses/package_model.dart';
import 'api_service.dart';

class PackageRemoteDatasource {
  final ApiService _api;

  PackageRemoteDatasource({required ApiService api}) : _api = api;

  /// Get all packages
  Future<Either<String, List<PackageModel>>> getPackages({
    int? serviceId,
    bool activeOnly = true,
  }) async {
    final result = await _api.get(
      Variables.packages,
      queryParams: {
        if (serviceId != null) 'service_id': serviceId.toString(),
        if (activeOnly) 'active': '1',
      },
    );

    return result.fold(
      (error) => Left(error),
      (data) {
        try {
          final list = (data['data'] as List)
              .map((e) => PackageModel.fromJson(e))
              .toList();
          return Right(list);
        } catch (e) {
          return Left('Gagal memproses data paket: $e');
        }
      },
    );
  }

  /// Get package by ID
  Future<Either<String, PackageModel>> getPackageById(int id) async {
    final result = await _api.get('${Variables.packages}/$id');

    return result.fold(
      (error) => Left(error),
      (data) {
        try {
          return Right(PackageModel.fromJson(data['data']));
        } catch (e) {
          return Left('Gagal memproses data paket: $e');
        }
      },
    );
  }

  /// Get customer packages
  Future<Either<String, PaginatedResponse<CustomerPackageModel>>>
      getCustomerPackages({
    int? customerId,
    String? status,
    bool usableOnly = false,
    int page = 1,
    int perPage = 20,
  }) async {
    final result = await _api.get(
      Variables.customerPackages,
      queryParams: {
        if (customerId != null) 'customer_id': customerId.toString(),
        'page': page.toString(),
        'per_page': perPage.toString(),
        if (status != null) 'status': status,
        if (usableOnly) 'active_only': '1',
      },
    );

    return result.fold(
      (error) => Left(error),
      (data) {
        try {
          return Right(PaginatedResponse.fromJson(
            data,
            (json) => CustomerPackageModel.fromJson(json),
          ));
        } catch (e) {
          return Left('Gagal memproses data paket pelanggan: $e');
        }
      },
    );
  }

  /// Get customer package by ID
  Future<Either<String, CustomerPackageModel>> getCustomerPackageById(
    int id,
  ) async {
    final result = await _api.get('${Variables.customerPackages}/$id');

    return result.fold(
      (error) => Left(error),
      (data) {
        try {
          return Right(CustomerPackageModel.fromJson(data['data']));
        } catch (e) {
          return Left('Gagal memproses data paket: $e');
        }
      },
    );
  }

  /// Sell package to customer
  Future<Either<String, CustomerPackageModel>> sellPackage({
    required int customerId,
    required int packageId,
    double? pricePaid,
    String? notes,
  }) async {
    final result = await _api.post(
      Variables.customerPackages,
      body: {
        'customer_id': customerId,
        'package_id': packageId,
        if (pricePaid != null) 'price_paid': pricePaid,
        if (notes != null) 'notes': notes,
      },
    );

    return result.fold(
      (error) => Left(error),
      (data) {
        try {
          return Right(CustomerPackageModel.fromJson(data['data']));
        } catch (e) {
          return Left('Gagal menjual paket: $e');
        }
      },
    );
  }

  /// Use session from customer package
  Future<Either<String, CustomerPackageModel>> useSession(
    int customerPackageId, {
    int? appointmentId,
    String? notes,
  }) async {
    final result = await _api.post(
      '${Variables.customerPackages}/$customerPackageId/use',
      body: {
        if (appointmentId != null) 'appointment_id': appointmentId,
        if (notes != null) 'notes': notes,
      },
    );

    return result.fold(
      (error) => Left(error),
      (data) {
        try {
          return Right(CustomerPackageModel.fromJson(data['data']));
        } catch (e) {
          return Left('Gagal menggunakan sesi: $e');
        }
      },
    );
  }

  /// Get usable packages for booking
  Future<Either<String, List<CustomerPackageModel>>> getUsablePackagesForService(
    int customerId,
    int serviceId,
  ) async {
    final result = await _api.get(
      '${Variables.customerPackages}/usable',
      queryParams: {
        'customer_id': customerId.toString(),
        'service_id': serviceId.toString(),
      },
    );

    return result.fold(
      (error) => Left(error),
      (data) {
        try {
          final list = (data['data'] as List)
              .map((e) => CustomerPackageModel.fromJson(e))
              .toList();
          return Right(list);
        } catch (e) {
          return Left('Gagal memproses data paket: $e');
        }
      },
    );
  }
}
