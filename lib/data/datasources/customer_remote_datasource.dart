import 'dart:convert';
import 'dart:developer' as dev;
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/variables.dart';
import '../models/requests/customer_request_model.dart';
import '../models/responses/customer_model.dart';
import 'auth_local_datasource.dart';

class CustomerRemoteDatasource {
  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthLocalDatasource().getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Either<String, List<CustomerModel>>> getCustomers({
    String? search,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      var url = '${Variables.customers}?page=$page&per_page=$perPage';
      if (search != null && search.isNotEmpty) {
        url += '&search=$search';
      }

      dev.log('📡 GET $url', name: 'Customer');
      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );
      dev.log('📥 Status ${response.statusCode}', name: 'Customer');
      dev.log('📥 Body: ${response.body}', name: 'Customer');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = (data['data'] as List)
            .map((e) => CustomerModel.fromJson(e))
            .toList();
        return Right(list);
      } else {
        final error = jsonDecode(response.body);
        return Left(error['message'] ?? 'Gagal memuat pelanggan');
      }
    } catch (e) {
      return Left('Network error: $e');
    }
  }

  Future<Either<String, CustomerModel>> getCustomerById(int id) async {
    try {
      dev.log('📡 GET ${Variables.customers}/$id', name: 'Customer');
      final response = await http.get(
        Uri.parse('${Variables.customers}/$id'),
        headers: await _getHeaders(),
      );
      dev.log('📥 Status ${response.statusCode}', name: 'Customer');
      dev.log('📥 Body: ${response.body}', name: 'Customer');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Right(CustomerModel.fromJson(data['data']));
      } else {
        final error = jsonDecode(response.body);
        return Left(error['message'] ?? 'Gagal memuat detail pelanggan');
      }
    } catch (e) {
      return Left('Network error: $e');
    }
  }

  Future<Either<String, CustomerModel>> createCustomer(CustomerRequestModel request) async {
    try {
      dev.log('📡 POST ${Variables.customers}', name: 'Customer');
      final response = await http.post(
        Uri.parse(Variables.customers),
        headers: await _getHeaders(),
        body: jsonEncode(request.toJson()),
      );
      dev.log('📥 Status ${response.statusCode}', name: 'Customer');
      dev.log('📥 Body: ${response.body}', name: 'Customer');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Right(CustomerModel.fromJson(data['data']));
      } else {
        final error = jsonDecode(response.body);
        return Left(error['message'] ?? 'Gagal membuat pelanggan');
      }
    } catch (e) {
      return Left('Network error: $e');
    }
  }

  Future<Either<String, CustomerModel>> updateCustomer(int id, CustomerRequestModel request) async {
    try {
      dev.log('📡 PUT ${Variables.customers}/$id', name: 'Customer');
      final response = await http.put(
        Uri.parse('${Variables.customers}/$id'),
        headers: await _getHeaders(),
        body: jsonEncode(request.toJson()),
      );
      dev.log('📥 Status ${response.statusCode}', name: 'Customer');
      dev.log('📥 Body: ${response.body}', name: 'Customer');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Right(CustomerModel.fromJson(data['data']));
      } else {
        final error = jsonDecode(response.body);
        return Left(error['message'] ?? 'Gagal mengupdate pelanggan');
      }
    } catch (e) {
      return Left('Network error: $e');
    }
  }

  Future<Either<String, bool>> deleteCustomer(int id) async {
    try {
      dev.log('📡 DELETE ${Variables.customers}/$id', name: 'Customer');
      final response = await http.delete(
        Uri.parse('${Variables.customers}/$id'),
        headers: await _getHeaders(),
      );
      dev.log('📥 Status ${response.statusCode}', name: 'Customer');
      dev.log('📥 Body: ${response.body}', name: 'Customer');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return const Right(true);
      } else {
        final error = jsonDecode(response.body);
        return Left(error['message'] ?? 'Gagal menghapus pelanggan');
      }
    } catch (e) {
      return Left('Network error: $e');
    }
  }

  // Mock data for testing
  Future<Either<String, List<CustomerModel>>> getCustomersMock({String? search}) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final customers = [
      CustomerModel(
        id: 1,
        name: 'Rina Susanti',
        phone: '081234567890',
        email: 'rina@email.com',
        birthdate: DateTime(1990, 5, 15),
        gender: 'female',
        skinType: 'combination',
        skinConcerns: ['acne', 'dark_spots'],
        totalVisits: 12,
        totalSpent: 4500000,
        lastVisit: DateTime.now().subtract(const Duration(days: 7)),
        createdAt: DateTime(2024, 1, 15),
      ),
      CustomerModel(
        id: 2,
        name: 'Maya Putri',
        phone: '081234567891',
        email: 'maya@email.com',
        birthdate: DateTime(1995, 8, 20),
        gender: 'female',
        skinType: 'oily',
        skinConcerns: ['acne', 'large_pores'],
        totalVisits: 8,
        totalSpent: 2800000,
        lastVisit: DateTime.now().subtract(const Duration(days: 14)),
        createdAt: DateTime(2024, 2, 10),
      ),
      CustomerModel(
        id: 3,
        name: 'Dewi Anggraini',
        phone: '081234567892',
        email: 'dewi@email.com',
        birthdate: DateTime(1988, 3, 10),
        gender: 'female',
        skinType: 'dry',
        skinConcerns: ['wrinkles', 'dullness'],
        totalVisits: 15,
        totalSpent: 7500000,
        lastVisit: DateTime.now().subtract(const Duration(days: 3)),
        createdAt: DateTime(2023, 11, 5),
      ),
      CustomerModel(
        id: 4,
        name: 'Siti Nurhaliza',
        phone: '081234567893',
        email: 'siti@email.com',
        birthdate: DateTime(1992, 11, 25),
        gender: 'female',
        skinType: 'sensitive',
        skinConcerns: ['redness', 'dryness'],
        allergies: 'Fragrance, Retinol',
        totalVisits: 5,
        totalSpent: 1500000,
        lastVisit: DateTime.now().subtract(const Duration(days: 21)),
        createdAt: DateTime(2024, 3, 1),
      ),
      CustomerModel(
        id: 5,
        name: 'Amanda Wijaya',
        phone: '081234567894',
        email: 'amanda@email.com',
        birthdate: DateTime(1998, 7, 8),
        gender: 'female',
        skinType: 'normal',
        totalVisits: 3,
        totalSpent: 900000,
        lastVisit: DateTime.now().subtract(const Duration(days: 30)),
        createdAt: DateTime(2024, 4, 20),
      ),
      CustomerModel(
        id: 6,
        name: 'Ratna Sari',
        phone: '081234567895',
        email: 'ratna@email.com',
        birthdate: DateTime(1985, 12, 3),
        gender: 'female',
        skinType: 'combination',
        skinConcerns: ['aging', 'dark_spots'],
        totalVisits: 20,
        totalSpent: 12000000,
        lastVisit: DateTime.now().subtract(const Duration(days: 1)),
        createdAt: DateTime(2023, 6, 15),
      ),
      CustomerModel(
        id: 7,
        name: 'Budi Santoso',
        phone: '081234567896',
        email: 'budi@email.com',
        birthdate: DateTime(1982, 4, 18),
        gender: 'male',
        skinType: 'oily',
        skinConcerns: ['acne'],
        totalVisits: 4,
        totalSpent: 1200000,
        lastVisit: DateTime.now().subtract(const Duration(days: 45)),
        createdAt: DateTime(2024, 2, 28),
      ),
      CustomerModel(
        id: 8,
        name: 'Fitri Handayani',
        phone: '081234567897',
        email: 'fitri@email.com',
        birthdate: DateTime(1993, 9, 12),
        gender: 'female',
        skinType: 'dry',
        skinConcerns: ['dullness', 'fine_lines'],
        totalVisits: 10,
        totalSpent: 3500000,
        lastVisit: DateTime.now().subtract(const Duration(days: 10)),
        createdAt: DateTime(2023, 12, 1),
      ),
      CustomerModel(
        id: 9,
        name: 'Lisa Permata',
        phone: '081234567898',
        email: 'lisa@email.com',
        birthdate: DateTime(2000, 1, 30),
        gender: 'female',
        skinType: 'oily',
        skinConcerns: ['acne', 'blackheads'],
        totalVisits: 6,
        totalSpent: 1800000,
        lastVisit: DateTime.now().subtract(const Duration(days: 5)),
        createdAt: DateTime(2024, 1, 10),
      ),
      CustomerModel(
        id: 10,
        name: 'Kartini Wulandari',
        phone: '081234567899',
        email: 'kartini@email.com',
        birthdate: DateTime(1978, 6, 21),
        gender: 'female',
        skinType: 'combination',
        skinConcerns: ['wrinkles', 'sagging'],
        totalVisits: 25,
        totalSpent: 18000000,
        lastVisit: DateTime.now(),
        createdAt: DateTime(2022, 8, 15),
      ),
    ];

    if (search != null && search.isNotEmpty) {
      final query = search.toLowerCase();
      return Right(customers.where((c) {
        return c.name.toLowerCase().contains(query) ||
            c.phone.contains(query) ||
            (c.email?.toLowerCase().contains(query) ?? false);
      }).toList());
    }

    return Right(customers);
  }

  Future<Either<String, CustomerModel>> getCustomerByIdMock(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final result = await getCustomersMock();
    return result.fold(
      (error) => Left(error),
      (customers) {
        final customer = customers.where((c) => c.id == id).firstOrNull;
        if (customer != null) {
          return Right(customer);
        }
        return const Left('Pelanggan tidak ditemukan');
      },
    );
  }
}
