import 'package:dartz/dartz.dart';
import '../../core/constants/variables.dart';
import '../models/responses/api_response.dart';
import '../models/responses/transaction_model.dart';
import 'api_service.dart';

class TransactionRemoteDatasource {
  final ApiService _api;

  TransactionRemoteDatasource({required ApiService api}) : _api = api;

  /// Get transactions
  Future<Either<String, PaginatedResponse<TransactionModel>>> getTransactions({
    int? customerId,
    String? status,
    DateTime? dateFrom,
    DateTime? dateTo,
    int page = 1,
    int perPage = 20,
  }) async {
    final result = await _api.get(
      Variables.transactions,
      queryParams: {
        'page': page.toString(),
        'per_page': perPage.toString(),
        if (customerId != null) 'customer_id': customerId.toString(),
        if (status != null) 'status': status,
        if (dateFrom != null)
          'start_date': dateFrom.toIso8601String().split('T').first,
        if (dateTo != null)
          'end_date': dateTo.toIso8601String().split('T').first,
      },
    );

    return result.fold(
      (error) => Left(error),
      (data) {
        try {
          return Right(PaginatedResponse.fromJson(
            data,
            (json) => TransactionModel.fromJson(json),
          ));
        } catch (e) {
          return Left('Gagal memproses data transaksi: $e');
        }
      },
    );
  }

  /// Get transaction by ID
  Future<Either<String, TransactionModel>> getTransactionById(int id) async {
    final result = await _api.get('${Variables.transactions}/$id');

    return result.fold(
      (error) => Left(error),
      (data) {
        try {
          return Right(TransactionModel.fromJson(data['data']));
        } catch (e) {
          return Left('Gagal memproses data transaksi: $e');
        }
      },
    );
  }

  /// Get transaction by appointment ID
  /// [status] - optional, filter by status (pending, paid, partial)
  Future<Either<String, TransactionModel?>> getTransactionByAppointment(
    int appointmentId, {
    String? status,
  }) async {
    final result = await _api.get(
      Variables.transactions,
      queryParams: {
        'appointment_id': appointmentId.toString(),
        if (status != null) 'status': status,
      },
    );

    return result.fold(
      (error) => Left(error),
      (data) {
        try {
          final items = data['data'] as List? ?? [];
          if (items.isEmpty) {
            return const Right(null);
          }
          return Right(TransactionModel.fromJson(items.first));
        } catch (e) {
          return Left('Gagal memproses data transaksi: $e');
        }
      },
    );
  }

  /// Create transaction
  Future<Either<String, TransactionModel>> createTransaction({
    required int customerId,
    int? appointmentId,
    required List<Map<String, dynamic>> items,
    String? discountType,
    double? discountAmount,
    int? pointsUsed,
    String? notes,
  }) async {
    final result = await _api.post(
      Variables.transactions,
      body: {
        'customer_id': customerId,
        if (appointmentId != null) 'appointment_id': appointmentId,
        'items': items,
        if (discountType != null) 'discount_type': discountType,
        if (discountAmount != null) 'discount_amount': discountAmount,
        if (pointsUsed != null) 'points_used': pointsUsed,
        if (notes != null) 'notes': notes,
      },
    );

    return result.fold(
      (error) => Left(error),
      (data) {
        try {
          return Right(TransactionModel.fromJson(data['data']));
        } catch (e) {
          return Left('Gagal membuat transaksi: $e');
        }
      },
    );
  }

  /// Add payment to transaction
  Future<Either<String, TransactionModel>> addPayment(
    int transactionId, {
    required double amount,
    required String paymentMethod,
    String? referenceNumber,
    String? notes,
  }) async {
    final result = await _api.post(
      '${Variables.transactions}/$transactionId/pay',
      body: {
        'amount': amount,
        'payment_method': paymentMethod,
        if (referenceNumber != null) 'reference_number': referenceNumber,
        if (notes != null) 'notes': notes,
      },
    );

    return result.fold(
      (error) => Left(error),
      (data) {
        try {
          return Right(TransactionModel.fromJson(data['data']));
        } catch (e) {
          return Left('Gagal menambah pembayaran: $e');
        }
      },
    );
  }

  /// Cancel transaction
  Future<Either<String, TransactionModel>> cancelTransaction(
    int transactionId, {
    String? reason,
  }) async {
    final result = await _api.post(
      '${Variables.transactions}/$transactionId/cancel',
      body: {
        if (reason != null) 'reason': reason,
      },
    );

    return result.fold(
      (error) => Left(error),
      (data) {
        try {
          return Right(TransactionModel.fromJson(data['data']));
        } catch (e) {
          return Left('Gagal membatalkan transaksi: $e');
        }
      },
    );
  }

  /// Get receipt data for transaction
  Future<Either<String, Map<String, dynamic>>> getReceipt(
    int transactionId,
  ) async {
    final result = await _api.get(
      '${Variables.transactions}/$transactionId/receipt',
    );

    return result.fold(
      (error) => Left(error),
      (data) => Right(data['data'] ?? data),
    );
  }

  /// Get today's transactions summary
  Future<Either<String, Map<String, dynamic>>> getTodaySummary() async {
    final result = await _api.get('${Variables.transactions}/today-summary');

    return result.fold(
      (error) => Left(error),
      (data) => Right(data['data'] ?? data),
    );
  }
}
