import 'package:dartz/dartz.dart';
import '../../core/constants/variables.dart';
import '../models/responses/settings_model.dart';
import 'api_service.dart';

class SettingsRemoteDatasource {
  final ApiService _api;

  SettingsRemoteDatasource({required ApiService api}) : _api = api;

  /// Get all settings
  Future<Either<String, SettingsModel>> getSettings() async {
    final result = await _api.get(Variables.settings);

    return result.fold(
      (error) => Left(error),
      (data) {
        try {
          return Right(SettingsModel.fromJson(data['data'] ?? data));
        } catch (e) {
          return Left('Gagal memproses data settings: $e');
        }
      },
    );
  }

  /// Get branding info (logo, colors)
  Future<Either<String, BrandingInfo>> getBranding() async {
    final result = await _api.get(Variables.settingsBranding);

    return result.fold(
      (error) => Left(error),
      (data) {
        try {
          return Right(BrandingInfo.fromJson(data['data'] ?? data));
        } catch (e) {
          return Left('Gagal memproses data branding: $e');
        }
      },
    );
  }

  /// Get operating hours
  Future<Either<String, List<OperatingHourModel>>> getOperatingHours() async {
    final result = await _api.get('${Variables.settings}/hours');

    return result.fold(
      (error) => Left(error),
      (data) {
        try {
          final list = (data['data'] as List)
              .map((e) => OperatingHourModel.fromJson(e))
              .toList();
          return Right(list);
        } catch (e) {
          return Left('Gagal memproses data jam operasional: $e');
        }
      },
    );
  }

  /// Get loyalty config
  Future<Either<String, LoyaltyConfig>> getLoyaltyConfig() async {
    final result = await _api.get('${Variables.settings}/loyalty');

    return result.fold(
      (error) => Left(error),
      (data) {
        try {
          return Right(LoyaltyConfig.fromJson(data['data'] ?? data));
        } catch (e) {
          return Left('Gagal memproses data loyalty: $e');
        }
      },
    );
  }

  /// Update clinic info
  Future<Either<String, SettingsModel>> updateClinicInfo(
    Map<String, dynamic> clinicData,
  ) async {
    final result = await _api.put(
      '${Variables.settings}/clinic',
      body: clinicData,
    );

    return result.fold(
      (error) => Left(error),
      (data) {
        try {
          return Right(SettingsModel.fromJson(data['data'] ?? data));
        } catch (e) {
          return Left('Gagal memproses data settings: $e');
        }
      },
    );
  }

  /// Update operating hours
  Future<Either<String, List<OperatingHourModel>>> updateOperatingHours(
    List<Map<String, dynamic>> hoursData,
  ) async {
    final result = await _api.put(
      '${Variables.settings}/hours',
      body: {'operating_hours': hoursData},
    );

    return result.fold(
      (error) => Left(error),
      (data) {
        try {
          final list = (data['data'] as List)
              .map((e) => OperatingHourModel.fromJson(e))
              .toList();
          return Right(list);
        } catch (e) {
          return Left('Gagal memproses data jam operasional: $e');
        }
      },
    );
  }
}
