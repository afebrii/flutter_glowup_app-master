import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../../../core/components/spaces.dart';
import '../../../core/widgets/responsive_widget.dart';
import '../../../data/datasources/product_remote_datasource.dart';
import '../../../data/models/responses/product_model.dart';
import '../../../injection.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import '../widgets/product_category_chips.dart';
import '../widgets/products_grid.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductBloc(
        productDatasource: getIt<ProductRemoteDatasource>(),
      )
        ..add(const FetchProductCategories(withCount: true))
        ..add(const FetchProducts()),
      child: const ResponsiveWidget(
        phone: _ProductPhoneLayout(),
        tablet: _ProductTabletLayout(),
      ),
    );
  }
}

// Phone Layout
class _ProductPhoneLayout extends StatelessWidget {
  const _ProductPhoneLayout();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Produk'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocConsumer<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: AppColors.error,
              ),
            );
            context.read<ProductBloc>().add(const ClearProductError());
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // Search Bar
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TextField(
                  onChanged: (value) {
                    if (value.isEmpty) {
                      context
                          .read<ProductBloc>()
                          .add(const ClearProductSearch());
                    } else {
                      context.read<ProductBloc>().add(SearchProducts(value));
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari produk...',
                    hintStyle: const TextStyle(
                        color: AppColors.textMuted, fontSize: 14),
                    prefixIcon: const Icon(Icons.search,
                        color: AppColors.textMuted, size: 20),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
              ),

              // Category Chips
              ProductCategoryChips(
                categories: state.categories,
                selectedCategoryId: state.selectedCategoryId,
                onCategorySelected: (categoryId) {
                  context
                      .read<ProductBloc>()
                      .add(SelectProductCategory(categoryId));
                },
              ),
              const SpaceHeight.h12(),

              // Products Grid
              Expanded(
                child: ProductsGrid(
                  products: state.products,
                  isLoading: state.isLoadingProducts,
                  hasMore: state.hasMoreProducts,
                  crossAxisCount: 2,
                  onProductTap: (product) {
                    _showProductDetail(context, product);
                  },
                  onLoadMore: () {
                    final nextPage =
                        (state.productsMeta?.currentPage ?? 0) + 1;
                    context
                        .read<ProductBloc>()
                        .add(FetchProducts(page: nextPage));
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showProductDetail(BuildContext context, ProductModel product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: _ProductDetailContent(product: product),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Tablet Layout
class _ProductTabletLayout extends StatefulWidget {
  const _ProductTabletLayout();

  @override
  State<_ProductTabletLayout> createState() => _ProductTabletLayoutState();
}

class _ProductTabletLayoutState extends State<_ProductTabletLayout> {
  ProductModel? _selectedProduct;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductBloc, ProductState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: AppColors.error,
            ),
          );
          context.read<ProductBloc>().add(const ClearProductError());
        }
      },
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Panel (35%) - Categories
              Expanded(
                flex: 35,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppColors.border.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: TextField(
                          onChanged: (value) {
                            if (value.isEmpty) {
                              context
                                  .read<ProductBloc>()
                                  .add(const ClearProductSearch());
                            } else {
                              context
                                  .read<ProductBloc>()
                                  .add(SearchProducts(value));
                            }
                          },
                          decoration: InputDecoration(
                            hintText: 'Cari produk...',
                            hintStyle: const TextStyle(
                                color: AppColors.textMuted, fontSize: 14),
                            prefixIcon: const Icon(Icons.search,
                                color: AppColors.textMuted, size: 20),
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: AppColors.primary),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),

                      // Categories
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Kategori',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SpaceHeight.h8(),
                      Expanded(
                        child: _CategoriesList(
                          categories: state.categories,
                          selectedId: state.selectedCategoryId,
                          isLoading: state.isLoadingCategories,
                          onSelect: (id) {
                            context
                                .read<ProductBloc>()
                                .add(SelectProductCategory(id));
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SpaceWidth.w20(),

              // Right Panel (65%) - Products + Detail
              Expanded(
                flex: 65,
                child: Column(
                  children: [
                    // Products Grid
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color:
                                  AppColors.border.withValues(alpha: 0.5)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  const Icon(Icons.inventory_2_outlined,
                                      color: AppColors.primary, size: 20),
                                  const SpaceWidth.w8(),
                                  Text(
                                    state.selectedCategory?.name ??
                                        'Semua Produk',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${state.products.length} produk',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: ProductsGrid(
                                products: state.products,
                                isLoading: state.isLoadingProducts,
                                hasMore: state.hasMoreProducts,
                                crossAxisCount: 4,
                                onProductTap: (product) {
                                  setState(
                                      () => _selectedProduct = product);
                                },
                                onLoadMore: () {
                                  final nextPage =
                                      (state.productsMeta?.currentPage ??
                                              0) +
                                          1;
                                  context.read<ProductBloc>().add(
                                      FetchProducts(page: nextPage));
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Detail Panel (if selected)
                    if (_selectedProduct != null) ...[
                      const SpaceHeight.h16(),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color:
                                  AppColors.border.withValues(alpha: 0.5)),
                        ),
                        child:
                            _ProductDetailContent(product: _selectedProduct!),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CategoriesList extends StatelessWidget {
  final List<ProductCategoryModel> categories;
  final int? selectedId;
  final bool isLoading;
  final Function(int?) onSelect;

  const _CategoriesList({
    required this.categories,
    this.selectedId,
    required this.isLoading,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      children: [
        _CategoryTile(
          name: 'Semua Produk',
          count: null,
          isSelected: selectedId == null,
          onTap: () => onSelect(null),
        ),
        ...categories.map((cat) => _CategoryTile(
              name: cat.name,
              count: cat.productsCount,
              isSelected: selectedId == cat.id,
              onTap: () => onSelect(cat.id),
            )),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final String name;
  final int? count;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.name,
    this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        onTap: onTap,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        tileColor: isSelected
            ? AppColors.primary.withValues(alpha: 0.1)
            : null,
        leading: Icon(
          Icons.folder_outlined,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          size: 20,
        ),
        title: Text(
          name,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color:
                isSelected ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
        trailing: count != null
            ? Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.2)
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textMuted,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

class _ProductDetailContent extends StatelessWidget {
  final ProductModel product;

  const _ProductDetailContent({required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                product.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: product.isAvailable
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                product.isAvailable ? 'Stok Tersedia' : 'Stok Habis',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: product.isAvailable
                      ? AppColors.success
                      : AppColors.error,
                ),
              ),
            ),
          ],
        ),
        const SpaceHeight.h8(),
        Text(
          product.displayPrice,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        if (product.description != null) ...[
          const SpaceHeight.h12(),
          Text(
            product.description!,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
        const SpaceHeight.h12(),
        Row(
          children: [
            if (product.sku != null) ...[
              const Icon(Icons.qr_code, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(
                'SKU: ${product.sku}',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(width: 16),
            ],
            const Icon(Icons.inventory, size: 14, color: AppColors.textMuted),
            const SizedBox(width: 4),
            Text(
              'Stok: ${product.stock}',
              style:
                  const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
      ],
    );
  }
}
