import 'package:dartz/dartz.dart';
import '../../core/constants/variables.dart';
import '../models/responses/user_model.dart';
import 'api_service.dart';

class StaffRemoteDatasource {
  final ApiService _api;

  StaffRemoteDatasource({required ApiService api}) : _api = api;

  /// Get all staff
  Future<Either<String, List<UserModel>>> getStaff({
    String? role,
    bool activeOnly = true,
  }) async {
    final result = await _api.get(
      Variables.staff,
      queryParams: {
        if (role != null) 'role': role,
        if (activeOnly) 'active_only': '1',
      },
    );

    return result.fold(
      (error) => Left(error),
      (data) {
        try {
          final list = (data['data'] as List)
              .map((e) => UserModel.fromJson(e))
              .toList();
          return Right(list);
        } catch (e) {
          return Left('Gagal memproses data staff: $e');
        }
      },
    );
  }

  /// Get beauticians only
  Future<Either<String, List<UserModel>>> getBeauticians({
    bool activeOnly = true,
  }) async {
    final result = await _api.get(
      Variables.beauticians,
      queryParams: {
        if (activeOnly) 'active_only': '1',
      },
    );

    return result.fold(
      (error) => Left(error),
      (data) {
        try {
          final list = (data['data'] as List)
              .map((e) => UserModel.fromJson(e))
              .toList();
          return Right(list);
        } catch (e) {
          return Left('Gagal memproses data beautician: $e');
        }
      },
    );
  }

  /// Get staff by ID
  Future<Either<String, UserModel>> getStaffById(int id) async {
    final result = await _api.get('${Variables.staff}/$id');

    return result.fold(
      (error) => Left(error),
      (data) {
        try {
          return Right(UserModel.fromJson(data['data']));
        } catch (e) {
          return Left('Gagal memproses data staff: $e');
        }
      },
    );
  }

  /// Get staff availability for a specific date
  Future<Either<String, List<Map<String, dynamic>>>> getStaffAvailability(
    int staffId,
    DateTime date,
  ) async {
    final result = await _api.get(
      '${Variables.staff}/$staffId/availability',
      queryParams: {
        'date': date.toIso8601String().split('T').first,
      },
    );

    return result.fold(
      (error) => Left(error),
      (data) {
        try {
          final list = (data['data'] as List)
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
          return Right(list);
        } catch (e) {
          return Left('Gagal memproses ketersediaan staff: $e');
        }
      },
    );
  }
}
