import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'auth_local_datasource.dart';

/// Base API Service class for making HTTP requests
class ApiService {
  final AuthLocalDatasource _authLocal;
  final http.Client? _client;

  ApiService({
    required AuthLocalDatasource authLocal,
    http.Client? client,
  })  : _authLocal = authLocal,
        _client = client;

  http.Client get client => _client ?? http.Client();

  /// Get authorization headers
  Future<Map<String, String>> getHeaders({bool withAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (withAuth) {
      final token = await _authLocal.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  /// Generic GET request
  Future<Either<String, Map<String, dynamic>>> get(
    String url, {
    Map<String, String>? queryParams,
    bool withAuth = true,
  }) async {
    try {
      var uri = Uri.parse(url);
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: {
          ...uri.queryParameters,
          ...queryParams,
        });
      }

      dev.log('📡 GET $uri', name: 'API');

      final response = await client.get(
        uri,
        headers: await getHeaders(withAuth: withAuth),
      );

      dev.log('📥 GET $url → ${response.statusCode} (${response.body.length} bytes)', name: 'API');

      return _handleResponse(response);
    } catch (e) {
      dev.log('❌ GET $url → ERROR: $e', name: 'API');
      return Left(_handleError(e));
    }
  }

  /// Generic POST request
  Future<Either<String, Map<String, dynamic>>> post(
    String url, {
    Map<String, dynamic>? body,
    bool withAuth = true,
  }) async {
    try {
      dev.log('📡 POST $url', name: 'API');
      if (body != null) dev.log('📦 Body: ${jsonEncode(body)}', name: 'API');

      final response = await client.post(
        Uri.parse(url),
        headers: await getHeaders(withAuth: withAuth),
        body: body != null ? jsonEncode(body) : null,
      );

      dev.log('📥 POST $url → ${response.statusCode}', name: 'API');
      dev.log('📄 Response: ${response.body.length > 500 ? '${response.body.substring(0, 500)}...' : response.body}', name: 'API');

      return _handleResponse(response);
    } catch (e) {
      dev.log('❌ POST $url → ERROR: $e', name: 'API');
      return Left(_handleError(e));
    }
  }

  /// Generic PUT request
  Future<Either<String, Map<String, dynamic>>> put(
    String url, {
    Map<String, dynamic>? body,
    bool withAuth = true,
  }) async {
    try {
      dev.log('📡 PUT $url', name: 'API');
      if (body != null) dev.log('📦 Body: ${jsonEncode(body)}', name: 'API');

      final response = await client.put(
        Uri.parse(url),
        headers: await getHeaders(withAuth: withAuth),
        body: body != null ? jsonEncode(body) : null,
      );

      dev.log('📥 PUT $url → ${response.statusCode}', name: 'API');
      dev.log('📄 Response: ${response.body.length > 500 ? '${response.body.substring(0, 500)}...' : response.body}', name: 'API');

      return _handleResponse(response);
    } catch (e) {
      dev.log('❌ PUT $url → ERROR: $e', name: 'API');
      return Left(_handleError(e));
    }
  }

  /// Generic PATCH request
  Future<Either<String, Map<String, dynamic>>> patch(
    String url, {
    Map<String, dynamic>? body,
    bool withAuth = true,
  }) async {
    try {
      final response = await client.patch(
        Uri.parse(url),
        headers: await getHeaders(withAuth: withAuth),
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse(response);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  /// Generic DELETE request
  Future<Either<String, Map<String, dynamic>>> delete(
    String url, {
    bool withAuth = true,
  }) async {
    try {
      final response = await client.delete(
        Uri.parse(url),
        headers: await getHeaders(withAuth: withAuth),
      );

      return _handleResponse(response);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  /// Multipart POST request for file uploads
  Future<Either<String, Map<String, dynamic>>> postMultipart(
    String url, {
    Map<String, String>? fields,
    Map<String, File>? files,
    Map<String, List<File>>? fileArrays,
    bool withAuth = true,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));

      // Add auth header
      if (withAuth) {
        final token = await _authLocal.getToken();
        if (token != null && token.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer $token';
        }
      }
      request.headers['Accept'] = 'application/json';

      // Add fields
      if (fields != null) {
        request.fields.addAll(fields);
      }

      // Add single files
      if (files != null) {
        for (final entry in files.entries) {
          request.files.add(await http.MultipartFile.fromPath(
            entry.key,
            entry.value.path,
          ));
        }
      }

      // Add file arrays
      if (fileArrays != null) {
        for (final entry in fileArrays.entries) {
          for (var i = 0; i < entry.value.length; i++) {
            request.files.add(await http.MultipartFile.fromPath(
              '${entry.key}[$i]',
              entry.value[i].path,
            ));
          }
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  /// Handle API response
  Either<String, Map<String, dynamic>> _handleResponse(http.Response response) {
    final body = response.body.isNotEmpty ? jsonDecode(response.body) : {};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      dev.log('✅ Response OK (${response.statusCode})', name: 'API');
      return Right(body);
    }

    dev.log('⚠️ Response ERROR (${response.statusCode}): ${response.body}', name: 'API');

    // Handle specific error codes
    switch (response.statusCode) {
      case 401:
        // Token expired or invalid
        _authLocal.clearAll();
        return const Left('Sesi telah berakhir. Silakan login kembali.');
      case 403:
        return const Left('Anda tidak memiliki akses untuk melakukan ini.');
      case 404:
        return const Left('Data tidak ditemukan.');
      case 422:
        // Validation error
        if (body['errors'] != null) {
          final errors = body['errors'] as Map<String, dynamic>;
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            return Left(firstError.first.toString());
          }
        }
        return Left(body['message'] ?? 'Validasi gagal.');
      case 500:
        return const Left('Terjadi kesalahan server. Silakan coba lagi.');
      default:
        return Left(body['message'] ?? 'Terjadi kesalahan. Silakan coba lagi.');
    }
  }

  /// Handle errors
  String _handleError(dynamic error) {
    if (error is SocketException) {
      return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
    } else if (error is HttpException) {
      return 'Terjadi kesalahan HTTP.';
    } else if (error is FormatException) {
      return 'Format response tidak valid.';
    }
    return 'Terjadi kesalahan jaringan. Silakan coba lagi.';
  }
}
