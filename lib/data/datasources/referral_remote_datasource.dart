import 'package:dartz/dartz.dart';
import '../../core/constants/variables.dart';
import '../models/responses/api_response.dart';
import '../models/responses/referral_model.dart';
import 'api_service.dart';

class ReferralRemoteDatasource {
  final ApiService _api;

  ReferralRemoteDatasource({required ApiService api}) : _api = api;

  /// Get customer referral info
  Future<Either<String, ReferralInfo>> getCustomerReferral(
    int customerId,
  ) async {
    final result = await _api.get(
      '${Variables.customers}/$customerId/referral',
    );

    return result.fold(
      (error) => Left(error),
      (data) {
        try {
          return Right(ReferralInfo.fromJson(data['data'] ?? data));
        } catch (e) {
          return Left('Gagal memproses data referral: $e');
        }
      },
    );
  }

  /// Get customer referral history
  Future<Either<String, PaginatedResponse<ReferralLogModel>>> getReferralHistory(
    int customerId, {
    int page = 1,
    int perPage = 15,
  }) async {
    final result = await _api.get(
      '${Variables.customers}/$customerId/referral/history',
      queryParams: {
        'page': page.toString(),
        'per_page': perPage.toString(),
      },
    );

    return result.fold(
      (error) => Left(error),
      (data) {
        try {
          return Right(PaginatedResponse.fromJson(
            data,
            (json) => ReferralLogModel.fromJson(json),
          ));
        } catch (e) {
          return Left('Gagal memproses riwayat referral: $e');
        }
      },
    );
  }

  /// Get customers referred by this customer
  /// API returns paginated ReferralLogResource (same as referral history)
  Future<Either<String, PaginatedResponse<ReferralLogModel>>> getReferredCustomers(
    int customerId, {
    int page = 1,
    int perPage = 15,
  }) async {
    final result = await _api.get(
      '${Variables.customers}/$customerId/referral/referrals',
      queryParams: {
        'page': page.toString(),
        'per_page': perPage.toString(),
      },
    );

    return result.fold(
      (error) => Left(error),
      (data) {
        try {
          return Right(PaginatedResponse.fromJson(
            data,
            (json) => ReferralLogModel.fromJson(json),
          ));
        } catch (e) {
          return Left('Gagal memproses data referral: $e');
        }
      },
    );
  }

  /// Validate referral code
  Future<Either<String, Map<String, dynamic>>> validateCode(String code) async {
    final result = await _api.post(
      Variables.referralValidate,
      body: {'code': code},
    );

    return result.fold(
      (error) => Left(error),
      (data) => Right(data),
    );
  }

  /// Apply referral code to customer
  Future<Either<String, Map<String, dynamic>>> applyReferralCode(
    int customerId,
    String code,
  ) async {
    final result = await _api.post(
      '${Variables.customers}/$customerId/referral/apply',
      body: {'code': code},
    );

    return result.fold(
      (error) => Left(error),
      (data) => Right(data),
    );
  }

  /// Get referral program info
  Future<Either<String, ReferralProgramInfo>> getProgramInfo() async {
    final result = await _api.get(Variables.referralProgram);

    return result.fold(
      (error) => Left(error),
      (data) {
        try {
          return Right(ReferralProgramInfo.fromJson(data['data'] ?? data));
        } catch (e) {
          return Left('Gagal memproses info program: $e');
        }
      },
    );
  }
}
