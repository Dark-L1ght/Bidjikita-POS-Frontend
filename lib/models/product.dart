import 'package:flutter/foundation.dart';
import 'bundle.dart';
import 'product_variant.dart';

@immutable
class Product {
  final String id; // local string key
  final int? apiId; // database integer ID
  final String name;
  final int price; // display price (cheapest variant price) in IDR
  final String category;
  final String description;
  final List<String> ingredients;
  final String caffeineLevel;
  final List<String> availableSizes;
  final List<String> sugarLevels;
  final bool isBundle;
  final List<String> bundleContents;
  final int originalPrice;
  final String? imageUrl;
  final String status;
  final bool lowStock;
  final List<ProductVariant> variants;

  /// For bundle products only: the original [BundleItem] data used when
  /// expanding the bundle into individual order items.
  final List<BundleItem> bundleItems;

  const Product({
    required this.id,
    this.apiId,
    required this.name,
    required this.price,
    required this.category,
    required this.description,
    required this.ingredients,
    required this.caffeineLevel,
    required this.availableSizes,
    this.sugarLevels = const [],
    this.isBundle = false,
    this.bundleContents = const [],
    this.originalPrice = 0,
    this.imageUrl,
    this.status = 'available',
    this.lowStock = false,
    this.variants = const [],
    this.bundleItems = const [],
  });

  bool get isAvailable => status == 'available';

  /// Build a [Product] from a backend API JSON object.
  /// Supports both Prisma (lowercase) and Sequelize (uppercase) field names.
  factory Product.fromApi(Map<String, dynamic> json) {
    final rawVariants =
        (json['ProductVariants'] ?? json['variants'] ?? []) as List<dynamic>;
    final variants = rawVariants
        .map((v) => ProductVariant.fromJson(v as Map<String, dynamic>))
        .toList();

    final displayPrice = variants.isNotEmpty
        ? variants.map((v) => v.price).reduce((a, b) => a < b ? a : b)
        : 0;

    final catObj =
        (json['Category'] ?? json['category']) as Map<String, dynamic>?;
    final category = catObj?['category_name'] as String? ?? 'Lainnya';

    return Product(
      id: json['id'].toString(),
      apiId: json['id'] as int,
      name: json['product_name'] as String,
      price: displayPrice,
      category: category,
      description: (json['description'] as String?) ?? '',
      ingredients: const [],
      caffeineLevel: '',
      availableSizes: variants.map((v) => v.variantName).toList(),
      sugarLevels: const [],
      imageUrl: json['image_url'] as String?,
      status: (json['status'] as String?) ?? 'available',
      lowStock: json['low_stock'] == true,
      variants: variants,
      bundleItems: const [],
    );
  }
}
