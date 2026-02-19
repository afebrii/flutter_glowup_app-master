import 'dart:convert';
import 'dart:developer' as dev;
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/variables.dart';
import '../models/responses/service_category_model.dart';
import '../models/responses/service_model.dart';
import 'auth_local_datasource.dart';

class ServiceRemoteDatasource {
  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthLocalDatasource().getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Either<String, List<ServiceCategoryModel>>> getCategories() async {
    try {
      dev.log('📡 GET ${Variables.serviceCategories}', name: 'Service');
      final response = await http.get(
        Uri.parse(Variables.serviceCategories),
        headers: await _getHeaders(),
      );
      dev.log('📥 Status ${response.statusCode}', name: 'Service');
      dev.log('📥 Body: ${response.body}', name: 'Service');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = (data['data'] as List)
            .map((e) => ServiceCategoryModel.fromJson(e))
            .toList();
        return Right(list);
      } else {
        final error = jsonDecode(response.body);
        return Left(error['message'] ?? 'Gagal memuat kategori');
      }
    } catch (e) {
      return Left('Network error: $e');
    }
  }

  Future<Either<String, List<ServiceModel>>> getServices({int? categoryId}) async {
    try {
      var url = Variables.services;
      if (categoryId != null) {
        url += '?category_id=$categoryId';
      }

      dev.log('📡 GET $url', name: 'Service');
      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );
      dev.log('📥 Status ${response.statusCode}', name: 'Service');
      dev.log('📥 Body: ${response.body}', name: 'Service');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = (data['data'] as List)
            .map((e) => ServiceModel.fromJson(e))
            .toList();
        return Right(list);
      } else {
        final error = jsonDecode(response.body);
        return Left(error['message'] ?? 'Gagal memuat layanan');
      }
    } catch (e) {
      return Left('Network error: $e');
    }
  }

  Future<Either<String, ServiceModel>> getServiceById(int id) async {
    try {
      dev.log('📡 GET ${Variables.services}/$id', name: 'Service');
      final response = await http.get(
        Uri.parse('${Variables.services}/$id'),
        headers: await _getHeaders(),
      );
      dev.log('📥 Status ${response.statusCode}', name: 'Service');
      dev.log('📥 Body: ${response.body}', name: 'Service');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Right(ServiceModel.fromJson(data['data']));
      } else {
        final error = jsonDecode(response.body);
        return Left(error['message'] ?? 'Gagal memuat detail layanan');
      }
    } catch (e) {
      return Left('Network error: $e');
    }
  }

  // Mock data for testing without backend
  Future<Either<String, List<ServiceCategoryModel>>> getCategoriesMock() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final categories = [
      ServiceCategoryModel(id: 1, name: 'Facial', description: 'Perawatan wajah', icon: 'spa', sortOrder: 1),
      ServiceCategoryModel(id: 2, name: 'Body Treatment', description: 'Perawatan tubuh', icon: 'self_improvement', sortOrder: 2),
      ServiceCategoryModel(id: 3, name: 'Hair Care', description: 'Perawatan rambut', icon: 'face_retouching_natural', sortOrder: 3),
      ServiceCategoryModel(id: 4, name: 'Nail Art', description: 'Perawatan kuku', icon: 'brush', sortOrder: 4),
      ServiceCategoryModel(id: 5, name: 'Injection', description: 'Suntik kecantikan', icon: 'vaccines', sortOrder: 5),
    ];

    return Right(categories);
  }

  Future<Either<String, List<ServiceModel>>> getServicesMock({int? categoryId}) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final allServices = [
      // Facial
      ServiceModel(
        id: 1,
        categoryId: 1,
        name: 'Basic Facial',
        description: 'Perawatan wajah dasar dengan pembersihan dan masker',
        durationMinutes: 60,
        price: 150000,
      ),
      ServiceModel(
        id: 2,
        categoryId: 1,
        name: 'Acne Facial',
        description: 'Perawatan khusus untuk kulit berjerawat',
        durationMinutes: 90,
        price: 250000,
      ),
      ServiceModel(
        id: 3,
        categoryId: 1,
        name: 'Whitening Facial',
        description: 'Perawatan untuk mencerahkan kulit wajah',
        durationMinutes: 90,
        price: 300000,
      ),
      ServiceModel(
        id: 4,
        categoryId: 1,
        name: 'Anti Aging Facial',
        description: 'Perawatan untuk mengurangi tanda penuaan',
        durationMinutes: 120,
        price: 450000,
      ),
      ServiceModel(
        id: 5,
        categoryId: 1,
        name: 'Gold Facial',
        description: 'Perawatan premium dengan masker emas 24K',
        durationMinutes: 120,
        price: 750000,
      ),
      // Body Treatment
      ServiceModel(
        id: 6,
        categoryId: 2,
        name: 'Body Scrub',
        description: 'Eksfoliasi seluruh tubuh untuk kulit lebih halus',
        durationMinutes: 60,
        price: 200000,
      ),
      ServiceModel(
        id: 7,
        categoryId: 2,
        name: 'Body Massage',
        description: 'Pijat relaksasi seluruh tubuh',
        durationMinutes: 90,
        price: 300000,
      ),
      ServiceModel(
        id: 8,
        categoryId: 2,
        name: 'Slimming Treatment',
        description: 'Perawatan untuk mengecilkan tubuh',
        durationMinutes: 120,
        price: 500000,
      ),
      // Hair Care
      ServiceModel(
        id: 9,
        categoryId: 3,
        name: 'Hair Spa',
        description: 'Perawatan rambut dengan vitamin dan masker',
        durationMinutes: 60,
        price: 150000,
      ),
      ServiceModel(
        id: 10,
        categoryId: 3,
        name: 'Hair Coloring',
        description: 'Pewarnaan rambut profesional',
        durationMinutes: 120,
        price: 350000,
      ),
      ServiceModel(
        id: 11,
        categoryId: 3,
        name: 'Keratin Treatment',
        description: 'Perawatan keratin untuk rambut lebih lurus dan sehat',
        durationMinutes: 180,
        price: 800000,
      ),
      // Nail Art
      ServiceModel(
        id: 12,
        categoryId: 4,
        name: 'Manicure',
        description: 'Perawatan kuku tangan',
        durationMinutes: 45,
        price: 100000,
      ),
      ServiceModel(
        id: 13,
        categoryId: 4,
        name: 'Pedicure',
        description: 'Perawatan kuku kaki',
        durationMinutes: 60,
        price: 120000,
      ),
      ServiceModel(
        id: 14,
        categoryId: 4,
        name: 'Nail Art Design',
        description: 'Desain nail art custom',
        durationMinutes: 90,
        price: 200000,
      ),
      // Injection
      ServiceModel(
        id: 15,
        categoryId: 5,
        name: 'Botox',
        description: 'Suntik botox untuk mengurangi kerutan',
        durationMinutes: 30,
        price: 2500000,
      ),
      ServiceModel(
        id: 16,
        categoryId: 5,
        name: 'Filler',
        description: 'Suntik filler untuk mengisi volume wajah',
        durationMinutes: 45,
        price: 3000000,
      ),
      ServiceModel(
        id: 17,
        categoryId: 5,
        name: 'Vitamin Injection',
        description: 'Suntik vitamin untuk kulit lebih cerah',
        durationMinutes: 15,
        price: 500000,
      ),
    ];

    if (categoryId != null) {
      return Right(allServices.where((s) => s.categoryId == categoryId).toList());
    }
    return Right(allServices);
  }
}
