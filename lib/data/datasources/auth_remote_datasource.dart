import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/variables.dart';
import '../models/requests/login_request_model.dart';
import '../models/responses/auth_response_model.dart';
import '../models/responses/user_model.dart';
import 'auth_local_datasource.dart';

class AuthRemoteDatasource {
  final AuthLocalDatasource _localDatasource = AuthLocalDatasource();

  /// Get authorization headers
  Future<Map<String, String>> _getHeaders({bool withAuth = false}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (withAuth) {
      final token = await _localDatasource.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  /// Login user
  Future<Either<String, AuthResponseModel>> login(
    LoginRequestModel request,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(Variables.login),
        headers: headers,
        body: jsonEncode(request.toJson()),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final authResponse = AuthResponseModel.fromJson(body['data'] ?? body);
        return Right(authResponse);
      } else {
        final message = body['message'] ?? 'Login gagal. Silakan coba lagi.';
        return Left(message);
      }
    } catch (e) {
      return Left('Terjadi kesalahan jaringan. Silakan coba lagi.');
    }
  }

  /// Logout user
  Future<Either<String, bool>> logout() async {
    try {
      final headers = await _getHeaders(withAuth: true);
      final response = await http.post(
        Uri.parse(Variables.logout),
        headers: headers,
      );

      // Always clear local data regardless of API response
      await _localDatasource.clearAll();

      if (response.statusCode == 200) {
        return const Right(true);
      } else {
        // Still return success since we've cleared local data
        return const Right(true);
      }
    } catch (e) {
      // Still clear local data even if API fails
      await _localDatasource.clearAll();
      return const Right(true);
    }
  }

  /// Get current user profile
  Future<Either<String, UserModel>> getProfile() async {
    try {
      final headers = await _getHeaders(withAuth: true);
      final response = await http.get(
        Uri.parse(Variables.profile),
        headers: headers,
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final user = UserModel.fromJson(body['data'] ?? body);
        // Update local user data
        await _localDatasource.saveUser(user);
        return Right(user);
      } else if (response.statusCode == 401) {
        // Token expired, clear local data
        await _localDatasource.clearAll();
        return const Left('Sesi telah berakhir. Silakan login kembali.');
      } else {
        final message = body['message'] ?? 'Gagal mengambil data profil.';
        return Left(message);
      }
    } catch (e) {
      return Left('Terjadi kesalahan jaringan. Silakan coba lagi.');
    }
  }

  /// Check if token is still valid
  Future<bool> validateToken() async {
    final result = await getProfile();
    return result.isRight();
  }
}
