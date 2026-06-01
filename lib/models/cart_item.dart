import 'package:flutter/foundation.dart';
import 'product.dart';

@immutable
class CartItem {
  final String id;
  final Product product;
  final int quantity;
  final String size;
  final String sugarLevel;
  final String note;

  const CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.size,
    this.sugarLevel = '',
    this.note = '',
  });

  int get subtotal => product.price * quantity;

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
    );
  }
}
