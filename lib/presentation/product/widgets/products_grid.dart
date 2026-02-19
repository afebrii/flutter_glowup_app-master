import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/responses/product_model.dart';
import 'product_card.dart';

class ProductsGrid extends StatelessWidget {
  final List<ProductModel> products;
  final bool isLoading;
  final Function(ProductModel)? onProductTap;
  final Function(ProductModel)? onAddToCart;
  final VoidCallback? onLoadMore;
  final bool hasMore;
  final int crossAxisCount;
  final double childAspectRatio;

  const ProductsGrid({
    super.key,
    required this.products,
    this.isLoading = false,
    this.onProductTap,
    this.onAddToCart,
    this.onLoadMore,
    this.hasMore = false,
    this.crossAxisCount = 2,
    this.childAspectRatio = 0.7,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: AppColors.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tidak ada produk',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.extentAfter < 200 &&
            hasMore &&
            !isLoading) {
          onLoadMore?.call();
        }
        return false;
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: childAspectRatio,
        ),
        itemCount: products.length + (isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == products.length) {
            return const Center(child: CircularProgressIndicator());
          }

          final product = products[index];
          return ProductCard(
            product: product,
            onTap: () => onProductTap?.call(product),
            onAddToCart: () => onAddToCart?.call(product),
          );
        },
      ),
    );
  }
}

/// Sliver version for use with CustomScrollView
class ProductsSliverGrid extends StatelessWidget {
  final List<ProductModel> products;
  final bool isLoading;
  final Function(ProductModel)? onProductTap;
  final Function(ProductModel)? onAddToCart;
  final int crossAxisCount;
  final double childAspectRatio;

  const ProductsSliverGrid({
    super.key,
    required this.products,
    this.isLoading = false,
    this.onProductTap,
    this.onAddToCart,
    this.crossAxisCount = 2,
    this.childAspectRatio = 0.7,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty && !isLoading) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: AppColors.textMuted.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tidak ada produk',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: childAspectRatio,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == products.length) {
              return const Center(child: CircularProgressIndicator());
            }

            final product = products[index];
            return ProductCard(
              product: product,
              onTap: () => onProductTap?.call(product),
              onAddToCart: () => onAddToCart?.call(product),
            );
          },
          childCount: products.length + (isLoading ? 1 : 0),
        ),
      ),
    );
  }
}

/// Horizontal scroll list for featured products
class ProductsHorizontalList extends StatelessWidget {
  final List<ProductModel> products;
  final Function(ProductModel)? onProductTap;
  final Function(ProductModel)? onAddToCart;
  final String? title;
  final VoidCallback? onViewAll;

  const ProductsHorizontalList({
    super.key,
    required this.products,
    this.onProductTap,
    this.onAddToCart,
    this.title,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (onViewAll != null)
                  TextButton(
                    onPressed: onViewAll,
                    child: const Text('Lihat Semua'),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index < products.length - 1 ? 12 : 0,
                ),
                child: SizedBox(
                  width: 140,
                  child: ProductCard(
                    product: product,
                    onTap: () => onProductTap?.call(product),
                    onAddToCart: () => onAddToCart?.call(product),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
