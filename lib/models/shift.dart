import 'package:flutter/foundation.dart';

/// Represents a cashier shift from the backend.
///
/// Response shape from `GET /api/shifts/active` and `POST /api/shifts/clock-in`:
/// ```json
/// {
///   "id": 1,
///   "start_time": "2026-06-15T07:30:00.000Z",
///   "starting_cash": 500000,
///   "order_count": 23,
///   "expected_cash": 1700000,
///   "expected_qris": 800000,
///   "status": "active"
/// }
/// ```
@immutable
class Shift {
  final int id;
  final DateTime startTime;
  final int startingCash;
  final int orderCount;
  final int expectedCash;
  final int expectedQris;
  final String status;

  const Shift({
    required this.id,
    required this.startTime,
    required this.startingCash,
    this.orderCount = 0,
    this.expectedCash = 0,
    this.expectedQris = 0,
    this.status = 'active',
  });

  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      id: json['id'] as int,
      startTime: DateTime.parse(json['start_time'] as String).toLocal(),
      startingCash: double.parse(
        (json['starting_cash'] ?? 0).toString(),
      ).round(),
      orderCount: (json['order_count'] as int?) ?? 0,
      expectedCash: double.parse(
        (json['expected_cash'] ?? 0).toString(),
      ).round(),
      expectedQris: double.parse(
        (json['expected_qris'] ?? 0).toString(),
      ).round(),
      status: (json['status'] as String?) ?? 'active',
    );
  }
}
