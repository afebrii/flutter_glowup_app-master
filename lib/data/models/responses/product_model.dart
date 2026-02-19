/// Product category model
class ProductCategoryModel {
  final int id;
  final String name;
  final String? description;
  final int sortOrder;
  final bool isActive;
  final int? productsCount;
  final List<ProductModel>? products;

  ProductCategoryModel({
    required this.id,
    required this.name,
    this.description,
    required this.sortOrder,
    required this.isActive,
    this.productsCount,
    this.products,
  });

  factory ProductCategoryModel.fromJson(Map<String, dynamic> json) {
    return ProductCategoryModel(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      sortOrder: json['sort_order'] ?? 0,
      isActive: json['is_active'] ?? true,
      productsCount: json['products_count'],
      products: json['products'] != null
          ? (json['products'] as List)
              .map((e) => ProductModel.fromJson(e))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'sort_order': sortOrder,
        'is_active': isActive,
        'products_count': productsCount,
      };
}

/// Product model
class ProductModel {
  final int id;
  final int categoryId;
  final String name;
  final String? sku;
  final String? description;
  final double price;
  final String? formattedPrice;
  final double? costPrice;
  final String? formattedCostPrice;
  final int stock;
  final int minStock;
  final String? unit;
  final String? image;
  final String? imageUrl;
  final bool isActive;
  final bool trackStock;
  final bool isLowStock;
  final bool isOutOfStock;
  final ProductCategoryModel? category;

  ProductModel({
    required this.id,
    required this.categoryId,
    required this.name,
    this.sku,
    this.description,
    required this.price,
    this.formattedPrice,
    this.costPrice,
    this.formattedCostPrice,
    required this.stock,
    required this.minStock,
    this.unit,
    this.image,
    this.imageUrl,
    required this.isActive,
    required this.trackStock,
    required this.isLowStock,
    required this.isOutOfStock,
    this.category,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      categoryId: json['category_id'] ?? 0,
      name: json['name'] ?? '',
      sku: json['sku'],
      description: json['description'],
      price: (json['price'] ?? 0).toDouble(),
      formattedPrice: json['formatted_price'],
      costPrice: json['cost_price']?.toDouble(),
      formattedCostPrice: json['formatted_cost_price'],
      stock: json['stock'] ?? 0,
      minStock: json['min_stock'] ?? 0,
      unit: json['unit'],
      image: json['image'],
      imageUrl: json['image_url'],
      isActive: json['is_active'] ?? true,
      trackStock: json['track_stock'] ?? false,
      isLowStock: json['is_low_stock'] ?? false,
      isOutOfStock: json['is_out_of_stock'] ?? false,
      category: json['category'] != null
          ? ProductCategoryModel.fromJson(json['category'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category_id': categoryId,
        'name': name,
        'sku': sku,
        'description': description,
        'price': price,
        'formatted_price': formattedPrice,
        'cost_price': costPrice,
        'stock': stock,
        'min_stock': minStock,
        'unit': unit,
        'image': image,
        'image_url': imageUrl,
        'is_active': isActive,
        'track_stock': trackStock,
      };

  /// Check if product is available for sale
  bool get isAvailable => isActive && !isOutOfStock;

  /// Get stock status text
  String get stockStatus {
    if (isOutOfStock) return 'Habis';
    if (isLowStock) return 'Stok Rendah';
    return 'Tersedia';
  }

  /// Get display price
  String get displayPrice => formattedPrice ?? 'Rp ${price.toStringAsFixed(0)}';
}
