import 'package:flutter/foundation.dart';
import 'cart_item.dart';

@immutable
class ReceiptData {
  final String orderId;
  final DateTime dateTime;
  final String orderType; // 'Dine In' | 'Takeaway'
  final List<CartItem> items;
  final int subtotal;
  final int total;
  final String paymentMethod; // 'QRIS' | 'Tunai'
  final int cashReceived; // 0 when QRIS
  final int change; // 0 when QRIS
  final String cashierName;
  final String customerName;

  const ReceiptData({
    required this.orderId,
    required this.dateTime,
    required this.orderType,
    required this.items,
    required this.subtotal,
    required this.total,
    required this.paymentMethod,
    this.cashReceived = 0,
    this.change = 0,
    this.cashierName = 'Kasir',
    this.customerName = '',
  });
}
