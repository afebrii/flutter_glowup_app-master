import 'package:dartz/dartz.dart';
import '../../core/constants/variables.dart';
import '../models/responses/report_model.dart';
import 'api_service.dart';

/// Remote datasource for Report API
class ReportRemoteDatasource {
  final ApiService _api;

  ReportRemoteDatasource({required ApiService api}) : _api = api;

  /// Get complete report data
  Future<Either<String, ReportData>> getReportData({
    required String period,
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, String>{
      'period': period,
    };
    if (startDate != null) queryParams['start_date'] = startDate;
    if (endDate != null) queryParams['end_date'] = endDate;

    final result = await _api.get(
      Variables.reports,
      queryParams: queryParams,
    );

    return result.fold(
      (error) => Left(error),
      (data) {
        try {
          final reportData = ReportData.fromJson(data['data'] ?? data);
          return Right(reportData);
        } catch (e) {
          return Left('Gagal memproses data laporan: $e');
        }
      },
    );
  }

  /// Get report summary
  Future<Either<String, ReportSummary>> getReportSummary({
    required String period,
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, String>{
      'period': period,
    };
    if (startDate != null) queryParams['start_date'] = startDate;
    if (endDate != null) queryParams['end_date'] = endDate;

    final result = await _api.get(
      '${Variables.reports}/summary',
      queryParams: queryParams,
    );

    return result.fold(
      (error) => Left(error),
      (data) {
        try {
          final summary = ReportSummary.fromJson(data['data'] ?? data);
          return Right(summary);
        } catch (e) {
          return Left('Gagal memproses ringkasan laporan: $e');
        }
      },
    );
  }

  /// Get revenue/sales report
  Future<Either<String, List<SalesReportItem>>> getSalesReport({
    required String period,
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, String>{
      'period': period,
    };
    if (startDate != null) queryParams['start_date'] = startDate;
    if (endDate != null) queryParams['end_date'] = endDate;

    final result = await _api.get(
      Variables.reportsRevenue,
      queryParams: queryParams,
    );

    return result.fold(
      (error) => Left(error),
      (data) {
        try {
          final items = (data['data'] as List? ?? [])
              .map((e) => SalesReportItem.fromJson(e))
              .toList();
          return Right(items);
        } catch (e) {
          return Left('Gagal memproses laporan penjualan: $e');
        }
      },
    );
  }

  /// Get services report
  Future<Either<String, List<ServiceReportItem>>> getServicesReport({
    required String period,
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, String>{
      'period': period,
    };
    if (startDate != null) queryParams['start_date'] = startDate;
    if (endDate != null) queryParams['end_date'] = endDate;

    final result = await _api.get(
      Variables.reportsServices,
      queryParams: queryParams,
    );

    return result.fold(
      (error) => Left(error),
      (data) {
        try {
          final items = (data['data'] as List? ?? [])
              .map((e) => ServiceReportItem.fromJson(e))
              .toList();
          return Right(items);
        } catch (e) {
          return Left('Gagal memproses laporan layanan: $e');
        }
      },
    );
  }

  /// Get customers report
  Future<Either<String, Map<String, dynamic>>> getCustomersReport({
    required String period,
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, String>{
      'period': period,
    };
    if (startDate != null) queryParams['start_date'] = startDate;
    if (endDate != null) queryParams['end_date'] = endDate;

    final result = await _api.get(
      Variables.reportsCustomers,
      queryParams: queryParams,
    );

    return result.fold(
      (error) => Left(error),
      (data) {
        try {
          final responseData = data['data'] ?? data;
          final stats = CustomerReportStats.fromJson(responseData['stats'] ?? responseData);
          final topCustomers = (responseData['top_customers'] as List? ?? [])
              .map((e) => CustomerReportItem.fromJson(e))
              .toList();
          return Right({
            'stats': stats,
            'top_customers': topCustomers,
          });
        } catch (e) {
          return Left('Gagal memproses laporan pelanggan: $e');
        }
      },
    );
  }

  /// Get staff report
  Future<Either<String, List<StaffReportItem>>> getStaffReport({
    required String period,
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, String>{
      'period': period,
    };
    if (startDate != null) queryParams['start_date'] = startDate;
    if (endDate != null) queryParams['end_date'] = endDate;

    final result = await _api.get(
      Variables.reportsStaff,
      queryParams: queryParams,
    );

    return result.fold(
      (error) => Left(error),
      (data) {
        try {
          final items = (data['data'] as List? ?? [])
              .map((e) => StaffReportItem.fromJson(e))
              .toList();
          return Right(items);
        } catch (e) {
          return Left('Gagal memproses laporan staff: $e');
        }
      },
    );
  }

  /// Get packages report
  Future<Either<String, Map<String, dynamic>>> getPackagesReport({
    required String period,
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, String>{
      'period': period,
    };
    if (startDate != null) queryParams['start_date'] = startDate;
    if (endDate != null) queryParams['end_date'] = endDate;

    final result = await _api.get(
      '${Variables.reports}/packages',
      queryParams: queryParams,
    );

    return result.fold(
      (error) => Left(error),
      (data) {
        try {
          final responseData = data['data'] ?? data;
          final stats = PackageReportStats.fromJson(responseData['stats'] ?? responseData);
          final packages = (responseData['packages'] as List? ?? [])
              .map((e) => PackageReportItem.fromJson(e))
              .toList();
          return Right({
            'stats': stats,
            'packages': packages,
          });
        } catch (e) {
          return Left('Gagal memproses laporan paket: $e');
        }
      },
    );
  }
}
