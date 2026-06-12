import 'package:flutter/foundation.dart';

/// A single variant row from the backend's `ProductVariant` table.
///
/// Each variant represents an option with its own selling price, e.g.
/// "Regular" (Rp 25.000), "Large" (Rp 30.000), or "Extra Shot" (+Rp 5.000).
@immutable
class ProductVariant {
  final int id;
  final String variantName;
  final int price;
  final int overheadCost;
  final int productId;

  const ProductVariant({
    required this.id,
    required this.variantName,
    required this.price,
    this.overheadCost = 0,
    this.productId = 0,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'] as int,
      variantName: json['variant_name'] as String,
      price: double.parse((json['price'] ?? 0).toString()).round(),
      overheadCost: double.parse(
        (json['overhead_cost'] ?? 0).toString(),
      ).round(),
      productId: (json['product_id'] as int?) ?? 0,
    );
  }
}
