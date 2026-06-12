import 'package:flutter/foundation.dart';
import 'product.dart';

/// Describes a single item within a bundle for order expansion.
@immutable
class BundleSubItem {
  final int productId;
  final List<int> variantIds;
  final int quantity;
  final String productName;
  final String? variantName;

  const BundleSubItem({
    required this.productId,
    this.variantIds = const [],
    this.quantity = 1,
    this.productName = '',
    this.variantName,
  });
}

@immutable
class CartItem {
  final String id;
  final Product product;
  final int quantity;
  final String size;
  final String sugarLevel;
  final String note;

  /// Actual per-item price after applying variant price.
  /// Falls back to product.price if not set.
  final int effectivePrice;

  /// Backend variant IDs selected by the customer.
  /// Sent to the API as `variant_ids` when creating an order.
  final List<int> selectedVariantIds;

  /// For bundle products only: the expanded items sent to the order API
  /// instead of this cart item's own product_id.
  final List<BundleSubItem> bundleSubItems;

  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.size,
    this.sugarLevel = '',
    this.note = '',
    int? effectivePrice,
    this.selectedVariantIds = const [],
    this.bundleSubItems = const [],
  }) : effectivePrice = effectivePrice ?? product.price;

  int get subtotal => effectivePrice * quantity;

  /// Builds a deterministic ID — identical configurations are merged in cart.
  static String buildId(
    String productId,
    String size,
    String sugarLevel,
    String note,
  ) {
    return '${productId}_${size}_${sugarLevel}_${note.trim()}';
  }

  CartItem copyWith({int? quantity, String? note}) {
    return CartItem(
      id: id,
      product: product,
      quantity: quantity ?? this.quantity,
      size: size,
      sugarLevel: sugarLevel,
      note: note ?? this.note,
      effectivePrice: effectivePrice,
      selectedVariantIds: selectedVariantIds,
      bundleSubItems: bundleSubItems,
    );
  }
}
