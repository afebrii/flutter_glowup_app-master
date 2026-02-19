import 'package:dartz/dartz.dart';
import '../../core/constants/variables.dart';
import '../models/responses/api_response.dart';
import '../models/responses/product_model.dart';
import 'api_service.dart';

class ProductRemoteDatasource {
  final ApiService _api;

  ProductRemoteDatasource({required ApiService api}) : _api = api;

  /// Get product categories
  Future<Either<String, List<ProductCategoryModel>>> getCategories({
    bool withProducts = false,
    bool withCount = true,
  }) async {
    final result = await _api.get(
      Variables.productCategories,
      queryParams: {
        if (withProducts) 'with_products': '1',
        if (withCount) 'with_count': '1',
      },
    );

    return result.fold(
      (error) => Left(error),
      (data) {
        try {
          final list = (data['data'] as List)
              .map((e) => ProductCategoryModel.fromJson(e))
              .toList();
          return Right(list);
        } catch (e) {
          return Left('Gagal memproses kategori produk: $e');
        }
      },
    );
  }

  /// Get products
  Future<Either<String, PaginatedResponse<ProductModel>>> getProducts({
    int? categoryId,
    String? search,
    bool inStockOnly = true,
    int page = 1,
    int perPage = 20,
  }) async {
    final result = await _api.get(
      Variables.products,
      queryParams: {
        'page': page.toString(),
        'per_page': perPage.toString(),
        if (categoryId != null) 'category_id': categoryId.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
        if (inStockOnly) 'in_stock_only': '1',
      },
    );

    return result.fold(
      (error) => Left(error),
      (data) {
        try {
          return Right(PaginatedResponse.fromJson(
            data,
            (json) => ProductModel.fromJson(json),
          ));
        } catch (e) {
          return Left('Gagal memproses data produk: $e');
        }
      },
    );
  }

  /// Get single product by ID
  Future<Either<String, ProductModel>> getProductById(int id) async {
    final result = await _api.get('${Variables.products}/$id');

    return result.fold(
      (error) => Left(error),
      (data) {
        try {
          return Right(ProductModel.fromJson(data['data']));
        } catch (e) {
          return Left('Gagal memproses data produk: $e');
        }
      },
    );
  }

  /// Search products (uses the list endpoint with search param)
  Future<Either<String, List<ProductModel>>> searchProducts(
    String query, {
    int limit = 10,
  }) async {
    final result = await _api.get(
      Variables.products,
      queryParams: {
        'search': query,
        'per_page': limit.toString(),
      },
    );

    return result.fold(
      (error) => Left(error),
      (data) {
        try {
          final list = (data['data'] as List)
              .map((e) => ProductModel.fromJson(e))
              .toList();
          return Right(list);
        } catch (e) {
          return Left('Gagal mencari produk: $e');
        }
      },
    );
  }
}
