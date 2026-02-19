import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class FetchProductCategories extends ProductEvent {
  final bool withProducts;
  final bool withCount;

  const FetchProductCategories({
    this.withProducts = false,
    this.withCount = true,
  });

  @override
  List<Object?> get props => [withProducts, withCount];
}

class FetchProducts extends ProductEvent {
  final int? categoryId;
  final String? search;
  final bool inStockOnly;
  final int page;

  const FetchProducts({
    this.categoryId,
    this.search,
    this.inStockOnly = true,
    this.page = 1,
  });

  @override
  List<Object?> get props => [categoryId, search, inStockOnly, page];
}

class SelectProductCategory extends ProductEvent {
  final int? categoryId;

  const SelectProductCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class SearchProducts extends ProductEvent {
  final String query;

  const SearchProducts(this.query);

  @override
  List<Object?> get props => [query];
}

class ClearProductSearch extends ProductEvent {
  const ClearProductSearch();
}

class ClearProductError extends ProductEvent {
  const ClearProductError();
}
