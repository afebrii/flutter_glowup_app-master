import 'package:equatable/equatable.dart';
import '../../../data/models/responses/api_response.dart';
import '../../../data/models/responses/product_model.dart';

class ProductState extends Equatable {
  final List<ProductCategoryModel> categories;
  final List<ProductModel> products;
  final int? selectedCategoryId;
  final String searchQuery;
  final PaginationMeta? productsMeta;
  final bool isLoadingCategories;
  final bool isLoadingProducts;
  final String? error;

  const ProductState({
    this.categories = const [],
    this.products = const [],
    this.selectedCategoryId,
    this.searchQuery = '',
    this.productsMeta,
    this.isLoadingCategories = false,
    this.isLoadingProducts = false,
    this.error,
  });

  ProductState copyWith({
    List<ProductCategoryModel>? categories,
    List<ProductModel>? products,
    int? selectedCategoryId,
    String? searchQuery,
    PaginationMeta? productsMeta,
    bool? isLoadingCategories,
    bool? isLoadingProducts,
    String? error,
    bool clearCategory = false,
    bool clearError = false,
  }) {
    return ProductState(
      categories: categories ?? this.categories,
      products: products ?? this.products,
      selectedCategoryId:
          clearCategory ? null : (selectedCategoryId ?? this.selectedCategoryId),
      searchQuery: searchQuery ?? this.searchQuery,
      productsMeta: productsMeta ?? this.productsMeta,
      isLoadingCategories: isLoadingCategories ?? this.isLoadingCategories,
      isLoadingProducts: isLoadingProducts ?? this.isLoadingProducts,
      error: clearError ? null : (error ?? this.error),
    );
  }

  bool get isLoading => isLoadingCategories || isLoadingProducts;
  bool get hasMoreProducts => productsMeta?.hasMore ?? false;
  bool get hasSearch => searchQuery.isNotEmpty;

  ProductCategoryModel? get selectedCategory {
    if (selectedCategoryId == null) return null;
    return categories.where((c) => c.id == selectedCategoryId).firstOrNull;
  }

  @override
  List<Object?> get props => [
        categories,
        products,
        selectedCategoryId,
        searchQuery,
        productsMeta,
        isLoadingCategories,
        isLoadingProducts,
        error,
      ];
}
