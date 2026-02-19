import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/product_remote_datasource.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRemoteDatasource _productDatasource;

  ProductBloc({required ProductRemoteDatasource productDatasource})
      : _productDatasource = productDatasource,
        super(const ProductState()) {
    on<FetchProductCategories>(_onFetchCategories);
    on<FetchProducts>(_onFetchProducts);
    on<SelectProductCategory>(_onSelectCategory);
    on<SearchProducts>(_onSearch);
    on<ClearProductSearch>(_onClearSearch);
    on<ClearProductError>(_onClearError);
  }

  Future<void> _onFetchCategories(
    FetchProductCategories event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(isLoadingCategories: true, clearError: true));

    final result = await _productDatasource.getCategories(
      withProducts: event.withProducts,
      withCount: event.withCount,
    );

    result.fold(
      (error) =>
          emit(state.copyWith(isLoadingCategories: false, error: error)),
      (categories) => emit(state.copyWith(
        isLoadingCategories: false,
        categories: categories,
      )),
    );
  }

  Future<void> _onFetchProducts(
    FetchProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(isLoadingProducts: true, clearError: true));

    final result = await _productDatasource.getProducts(
      categoryId: event.categoryId ?? state.selectedCategoryId,
      search: event.search ?? (state.searchQuery.isNotEmpty ? state.searchQuery : null),
      inStockOnly: event.inStockOnly,
      page: event.page,
    );

    result.fold(
      (error) => emit(state.copyWith(isLoadingProducts: false, error: error)),
      (response) {
        final products = event.page == 1
            ? response.data
            : [...state.products, ...response.data];
        emit(state.copyWith(
          isLoadingProducts: false,
          products: products,
          productsMeta: response.meta,
        ));
      },
    );
  }

  void _onSelectCategory(
    SelectProductCategory event,
    Emitter<ProductState> emit,
  ) {
    emit(state.copyWith(
      selectedCategoryId: event.categoryId,
      clearCategory: event.categoryId == null,
      products: [], // Clear products when changing category
    ));
    add(FetchProducts(categoryId: event.categoryId));
  }

  void _onSearch(SearchProducts event, Emitter<ProductState> emit) {
    emit(state.copyWith(
      searchQuery: event.query,
      products: [], // Clear products when searching
    ));
    add(FetchProducts(search: event.query));
  }

  void _onClearSearch(ClearProductSearch event, Emitter<ProductState> emit) {
    emit(state.copyWith(
      searchQuery: '',
      products: [],
    ));
    add(const FetchProducts());
  }

  void _onClearError(ClearProductError event, Emitter<ProductState> emit) {
    emit(state.copyWith(clearError: true));
  }
}
