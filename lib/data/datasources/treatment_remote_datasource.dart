import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../core/constants/variables.dart';
import '../models/responses/api_response.dart';
import '../models/responses/treatment_record_model.dart';
import 'api_service.dart';

class TreatmentRemoteDatasource {
  final ApiService _api;

  TreatmentRemoteDatasource({required ApiService api}) : _api = api;

  /// Get treatment records
  Future<Either<String, PaginatedResponse<TreatmentRecordModel>>>
      getTreatmentRecords({
    int? customerId,
    int? appointmentId,
    int page = 1,
    int perPage = 20,
  }) async {
    final result = await _api.get(
      Variables.treatments,
      queryParams: {
        'page': page.toString(),
        'per_page': perPage.toString(),
        if (customerId != null) 'customer_id': customerId.toString(),
        if (appointmentId != null) 'appointment_id': appointmentId.toString(),
      },
    );

    return result.fold(
      (error) => Left(error),
      (data) {
        try {
          return Right(PaginatedResponse.fromJson(
            data,
            (json) => TreatmentRecordModel.fromJson(json),
          ));
        } catch (e) {
          return Left('Gagal memproses data treatment: $e');
        }
      },
    );
  }

  /// Get treatment record by ID
  Future<Either<String, TreatmentRecordModel>> getTreatmentById(int id) async {
    final result = await _api.get('${Variables.treatments}/$id');

    return result.fold(
      (error) => Left(error),
      (data) {
        try {
          return Right(TreatmentRecordModel.fromJson(data['data']));
        } catch (e) {
          return Left('Gagal memproses data treatment: $e');
        }
      },
    );
  }

  /// Get treatment record for appointment
  Future<Either<String, TreatmentRecordModel?>> getTreatmentByAppointment(
    int appointmentId,
  ) async {
    final result = await _api.get(
      Variables.treatments,
      queryParams: {
        'appointment_id': appointmentId.toString(),
      },
    );

    return result.fold(
      (error) => Left(error),
      (data) {
        try {
          final list = data['data'] as List?;
          if (list == null || list.isEmpty) {
            return const Right(null);
          }
          return Right(TreatmentRecordModel.fromJson(list.first));
        } catch (e) {
          return Left('Gagal memproses data treatment: $e');
        }
      },
    );
  }

  /// Create treatment record
  Future<Either<String, TreatmentRecordModel>> createTreatment({
    required int appointmentId,
    required int customerId,
    String? notes,
    String? recommendations,
    DateTime? followUpDate,
    List<File>? beforePhotos,
    List<File>? afterPhotos,
    List<String>? productsUsed,
  }) async {
    final fields = <String, String>{
      'appointment_id': appointmentId.toString(),
      'customer_id': customerId.toString(),
      if (notes != null) 'notes': notes,
      if (recommendations != null) 'recommendations': recommendations,
      if (followUpDate != null)
        'follow_up_date': followUpDate.toIso8601String().split('T').first,
    };

    if (productsUsed != null) {
      for (var i = 0; i < productsUsed.length; i++) {
        fields['products_used[$i]'] = productsUsed[i];
      }
    }

    final fileArrays = <String, List<File>>{};
    if (beforePhotos != null && beforePhotos.isNotEmpty) {
      fileArrays['before_photos'] = beforePhotos;
    }
    if (afterPhotos != null && afterPhotos.isNotEmpty) {
      fileArrays['after_photos'] = afterPhotos;
    }

    final result = await _api.postMultipart(
      Variables.treatments,
      fields: fields,
      fileArrays: fileArrays.isNotEmpty ? fileArrays : null,
    );

    return result.fold(
      (error) => Left(error),
      (data) {
        try {
          return Right(TreatmentRecordModel.fromJson(data['data']));
        } catch (e) {
          return Left('Gagal membuat treatment record: $e');
        }
      },
    );
  }

  /// Update treatment record
  Future<Either<String, TreatmentRecordModel>> updateTreatment(
    int id, {
    String? notes,
    String? recommendations,
    DateTime? followUpDate,
    List<File>? newBeforePhotos,
    List<File>? newAfterPhotos,
    List<String>? removePhotos,
  }) async {
    final fields = <String, String>{
      '_method': 'PUT', // For Laravel's method spoofing
      if (notes != null) 'notes': notes,
      if (recommendations != null) 'recommendations': recommendations,
      if (followUpDate != null)
        'follow_up_date': followUpDate.toIso8601String().split('T').first,
    };

    if (removePhotos != null) {
      for (var i = 0; i < removePhotos.length; i++) {
        fields['remove_photos[$i]'] = removePhotos[i];
      }
    }

    final fileArrays = <String, List<File>>{};
    if (newBeforePhotos != null && newBeforePhotos.isNotEmpty) {
      fileArrays['before_photos'] = newBeforePhotos;
    }
    if (newAfterPhotos != null && newAfterPhotos.isNotEmpty) {
      fileArrays['after_photos'] = newAfterPhotos;
    }

    final result = await _api.postMultipart(
      '${Variables.treatments}/$id',
      fields: fields,
      fileArrays: fileArrays.isNotEmpty ? fileArrays : null,
    );

    return result.fold(
      (error) => Left(error),
      (data) {
        try {
          return Right(TreatmentRecordModel.fromJson(data['data']));
        } catch (e) {
          return Left('Gagal mengupdate treatment record: $e');
        }
      },
    );
  }

  /// Get customer treatment history
  Future<Either<String, List<TreatmentRecordModel>>> getCustomerTreatments(
    int customerId, {
    int perPage = 15,
  }) async {
    final result = await _api.get(
      '${Variables.customers}/$customerId/treatments',
      queryParams: {
        'per_page': perPage.toString(),
      },
    );

    return result.fold(
      (error) => Left(error),
      (data) {
        try {
          final list = (data['data'] as List)
              .map((e) => TreatmentRecordModel.fromJson(e))
              .toList();
          return Right(list);
        } catch (e) {
          return Left('Gagal memproses riwayat treatment: $e');
        }
      },
    );
  }
}
