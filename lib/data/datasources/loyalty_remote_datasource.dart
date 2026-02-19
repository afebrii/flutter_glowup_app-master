import 'package:dartz/dartz.dart';
import '../../core/constants/variables.dart';
import '../models/responses/api_response.dart';
import '../models/responses/loyalty_point_model.dart';
import '../models/responses/loyalty_redemption_model.dart';
import '../models/responses/loyalty_reward_model.dart';
import 'api_service.dart';

class LoyaltyRemoteDatasource {
  final ApiService _api;

  LoyaltyRemoteDatasource({required ApiService api}) : _api = api;

  /// Get customer loyalty summary
  Future<Either<String, LoyaltySummary>> getCustomerLoyaltySummary(
    int customerId,
  ) async {
    final result = await _api.get(
      '${Variables.customers}/$customerId/loyalty',
    );

    return result.fold(
      (error) => Left(error),
      (data) {
        try {
          return Right(LoyaltySummary.fromJson(data['data'] ?? data));
        } catch (e) {
          return Left('Gagal memproses data loyalty: $e');
        }
      },
    );
  }

  /// Get customer points history
  Future<Either<String, PaginatedResponse<LoyaltyPointModel>>> getCustomerPoints(
    int customerId, {
    int page = 1,
    int perPage = 15,
  }) async {
    final result = await _api.get(
      '${Variables.customers}/$customerId/loyalty/points',
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
            (json) => LoyaltyPointModel.fromJson(json),
          ));
        } catch (e) {
          return Left('Gagal memproses riwayat poin: $e');
        }
      },
    );
  }

  /// Get available rewards
  Future<Either<String, List<LoyaltyRewardModel>>> getRewards({
    bool activeOnly = true,
  }) async {
    final result = await _api.get(
      Variables.loyaltyRewards,
      queryParams: {
        if (activeOnly) 'active': '1',
      },
    );

    return result.fold(
      (error) => Left(error),
      (data) {
        try {
          final list = (data['data'] as List)
              .map((e) => LoyaltyRewardModel.fromJson(e))
              .toList();
          return Right(list);
        } catch (e) {
          return Left('Gagal memproses data rewards: $e');
        }
      },
    );
  }

  /// Redeem a reward for customer
  Future<Either<String, LoyaltyRedemptionModel>> redeemReward(
    int customerId,
    int rewardId,
  ) async {
    final result = await _api.post(
      '${Variables.customers}/$customerId/loyalty/redeem',
      body: {
        'reward_id': rewardId,
      },
    );

    return result.fold(
      (error) => Left(error),
      (data) {
        try {
          // API returns {data: {redemption: {...}, remaining_points: 250}}
          final responseData = data['data'] ?? data;
          final redemptionJson = responseData['redemption'] ?? responseData;
          return Right(LoyaltyRedemptionModel.fromJson(redemptionJson));
        } catch (e) {
          return Left('Gagal memproses redemption: $e');
        }
      },
    );
  }

  /// Get customer redemptions
  Future<Either<String, PaginatedResponse<LoyaltyRedemptionModel>>>
      getCustomerRedemptions(
    int customerId, {
    String? status,
    int page = 1,
    int perPage = 15,
  }) async {
    final result = await _api.get(
      '${Variables.customers}/$customerId/loyalty/redemptions',
      queryParams: {
        'page': page.toString(),
        'per_page': perPage.toString(),
        if (status != null) 'status': status,
      },
    );

    return result.fold(
      (error) => Left(error),
      (data) {
        try {
          return Right(PaginatedResponse.fromJson(
            data,
            (json) => LoyaltyRedemptionModel.fromJson(json),
          ));
        } catch (e) {
          return Left('Gagal memproses data redemption: $e');
        }
      },
    );
  }

  /// Check redemption code
  Future<Either<String, Map<String, dynamic>>> checkCode(String code) async {
    final result = await _api.post(
      Variables.loyaltyCheckCode,
      body: {'code': code},
    );

    return result.fold(
      (error) => Left(error),
      (data) => Right(data),
    );
  }

  /// Use redemption code
  Future<Either<String, LoyaltyRedemptionModel>> useCode(
    String code, {
    int? transactionId,
  }) async {
    final result = await _api.post(
      Variables.loyaltyUseCode,
      body: {
        'code': code,
        if (transactionId != null) 'transaction_id': transactionId,
      },
    );

    return result.fold(
      (error) => Left(error),
      (data) {
        try {
          // API returns {data: {message: "...", redemption: {...}}}
          final responseData = data['data'] ?? data;
          final redemptionJson = responseData['redemption'] ?? responseData;
          return Right(LoyaltyRedemptionModel.fromJson(redemptionJson));
        } catch (e) {
          return Left('Gagal memproses kode: $e');
        }
      },
    );
  }

  /// Cancel a pending redemption
  /// API returns {data: {message: "...", points_refunded: 100}}
  Future<Either<String, Map<String, dynamic>>> cancelRedemption(
    int redemptionId,
  ) async {
    final result = await _api.post(
      '${Variables.loyaltyRedemptions}/$redemptionId/cancel',
    );

    return result.fold(
      (error) => Left(error),
      (data) => Right(data['data'] ?? data),
    );
  }

  /// Adjust customer points (admin only)
  Future<Either<String, Map<String, dynamic>>> adjustPoints(
    int customerId, {
    required int points,
    required String description,
  }) async {
    final result = await _api.post(
      '${Variables.customers}/$customerId/loyalty/adjust',
      body: {
        'points': points,
        'description': description,
      },
    );

    return result.fold(
      (error) => Left(error),
      (data) => Right(data),
    );
  }
}
