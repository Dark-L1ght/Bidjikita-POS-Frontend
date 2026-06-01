import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

// ---------------------------------------------------------------------------
// Order type
// ---------------------------------------------------------------------------
enum OrderType { dineIn, takeaway }

// ---------------------------------------------------------------------------
// Cart state (immutable)
// ---------------------------------------------------------------------------
@immutable
class CartState {
  final List<CartItem> items;
  final OrderType orderType;
  final int discountAmount;

  const CartState({
    this.items = const [],
    this.orderType = OrderType.dineIn,
    this.discountAmount = 0,
  });

  int get subtotal => items.fold(0, (sum, item) => sum + item.subtotal);
  int get tax => (subtotal * 0.11).round();
  int get total =>
      (subtotal - discountAmount + tax).clamp(0, double.maxFinite).toInt();
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  CartState copyWith({
    List<CartItem>? items,
    OrderType? orderType,
    int? discountAmount,
  }) {
    return CartState(
      items: items ?? this.items,
      orderType: orderType ?? this.orderType,
      discountAmount: discountAmount ?? this.discountAmount,
    );
  }
}

// ---------------------------------------------------------------------------
// Cart notifier
// ---------------------------------------------------------------------------
class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  /// Adds [quantity] units with the given configuration.
  /// Identical configurations (product + size + sugar + note) are merged.
  void addItem(
    Product product,
    String size,
    String sugarLevel,
    String note, {
    int quantity = 1,
  }) {
    final id = CartItem.buildId(product.id, size, sugarLevel, note);
    final existingIndex = state.items.indexWhere((item) => item.id == id);

    if (existingIndex >= 0) {
      final updated = [...state.items];
      updated[existingIndex] = updated[existingIndex].copyWith(
        quantity: updated[existingIndex].quantity + quantity,
      );
      state = state.copyWith(items: updated);
    } else {
      state = state.copyWith(
        items: [
          ...state.items,
          CartItem(
            id: id,
            product: product,
            quantity: quantity,
            size: size,
            sugarLevel: sugarLevel,
            note: note.trim(),
          ),
        ],
      );
    }
  }

  void removeItem(String itemId) {
    state = state.copyWith(
      items: state.items.where((item) => item.id != itemId).toList(),
    );
  }

  void incrementQuantity(String itemId) {
    state = state.copyWith(
      items: state.items.map((item) {
        if (item.id == itemId) {
          return item.copyWith(quantity: item.quantity + 1);
        }
        return item;
      }).toList(),
    );
  }

  /// Decrements quantity and auto-removes the row when it hits 0.
  void decrementQuantity(String itemId) {
    state = state.copyWith(
      items: state.items
          .map((item) {
            if (item.id == itemId) {
              return item.copyWith(quantity: item.quantity - 1);
            }
            return item;
          })
          .where((item) => item.quantity > 0)
          .toList(),
    );
  }

  void clearCart() => state = const CartState();

  void setOrderType(OrderType type) => state = state.copyWith(orderType: type);

  void setDiscount(int amount) =>
      state = state.copyWith(discountAmount: amount);
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------
final cartProvider = StateNotifierProvider<CartNotifier, CartState>(
  (ref) => CartNotifier(),
);
