import 'package:flutter/foundation.dart';

/// A bundled product from the backend `Bundle` table.
///
/// Response shape from `GET /api/bundles`:
/// ```json
/// {
///   "id": 1,
///   "bundle_name": "Paket Hemat",
///   "description": "...",
///   "bundle_price": 45000,
///   "BundleItems": [
///     {
///       "id": 1,
///       "quantity": 1,
///       "product_id": 1,
///       "Product": { "id": 1, "product_name": "Kopi Susu" },
///       "ProductVariant": { "id": 1, "variant_name": "Regular", "price": 25000 }
///     }
///   ]
/// }
/// ```
@immutable
class Bundle {
  final int id;
  final String bundleName;
  final String description;
  final int bundlePrice;
  final int totalBundleCost;
  final int bundleProfit;
  final String? imageUrl;
  final List<BundleItem> items;

  const Bundle({
    required this.id,
    required this.bundleName,
    this.description = '',
    required this.bundlePrice,
    this.totalBundleCost = 0,
    this.bundleProfit = 0,
    this.imageUrl,
    this.items = const [],
  });

  factory Bundle.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['BundleItems'] as List<dynamic>?) ?? [];
    final items = rawItems
        .map((i) => BundleItem.fromJson(i as Map<String, dynamic>))
        .toList();

    return Bundle(
      id: json['id'] as int,
      bundleName: json['bundle_name'] as String,
      description: (json['description'] as String?) ?? '',
      bundlePrice: double.parse((json['bundle_price'] ?? 0).toString()).round(),
      totalBundleCost: double.parse(
        (json['total_bundle_cost'] ?? 0).toString(),
      ).round(),
      bundleProfit: double.parse(
        (json['bundle_profit'] ?? 0).toString(),
      ).round(),
      imageUrl: json['image_url'] as String?,
      items: items,
    );
  }
}

@immutable
class BundleItem {
  final int id;
  final int productId;
  final int quantity;
  final String productName;
  final int? variantId;
  final String? variantName;

  const BundleItem({
    required this.id,
    required this.productId,
    this.quantity = 1,
    this.productName = '',
    this.variantId,
    this.variantName,
  });

  factory BundleItem.fromJson(Map<String, dynamic> json) {
    final product = json['Product'] as Map<String, dynamic>?;
    final variant = json['ProductVariant'] as Map<String, dynamic>?;

    return BundleItem(
      id: json['id'] as int,
      productId: json['product_id'] as int,
      quantity: (json['quantity'] as int?) ?? 1,
      productName: (product?['product_name'] as String?) ?? '',
      variantId: variant?['id'] as int?,
      variantName: variant?['variant_name'] as String?,
    );
  }
}
