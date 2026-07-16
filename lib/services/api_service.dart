import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/bundle.dart';
import '../models/product.dart';
import '../models/shift.dart';

/// Thrown when the server returns a non-2xx status or a network error occurs.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiService {
  ApiService._();

  static Map<String, String> _headers({String? token}) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── Auth ────────────────────────────────────────────────────────────────────

  /// Returns `{ "token": "...", "user": { ... } }` on success.
  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    final res = await http
        .post(
          Uri.parse('${AppConfig.baseUrl}/api/auth/login'),
          headers: _headers(),
          body: jsonEncode({'username': username, 'password': password}),
        )
        .timeout(const Duration(seconds: 30));

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 200) {
      throw ApiException(
        data['message'] as String? ?? 'Login gagal',
        statusCode: res.statusCode,
      );
    }
    return data;
  }

  // ── Products ─────────────────────────────────────────────────────────────────

  static Future<List<Product>> getProducts({String? token}) async {
    final res = await http
        .get(
          Uri.parse('${AppConfig.baseUrl}/api/products'),
          headers: _headers(token: token),
        )
        .timeout(const Duration(seconds: 15));

    if (res.statusCode != 200) {
      throw const ApiException('Gagal memuat produk');
    }
    final list = jsonDecode(res.body) as List<dynamic>;
    return list.map((e) => Product.fromApi(e as Map<String, dynamic>)).toList();
  }

  // ── Categories ───────────────────────────────────────────────────────────────

  static Future<List<String>> getCategories({String? token}) async {
    final res = await http
        .get(
          Uri.parse('${AppConfig.baseUrl}/api/categories'),
          headers: _headers(token: token),
        )
        .timeout(const Duration(seconds: 10));

    if (res.statusCode != 200) {
      throw const ApiException('Gagal memuat kategori');
    }
    final list = jsonDecode(res.body) as List<dynamic>;
    return list
        .map((c) => (c as Map<String, dynamic>)['category_name'] as String)
        .toList();
  }

  // ── Bundles ───────────────────────────────────────────────────────────────────

  static Future<List<Bundle>> getBundles({String? token}) async {
    final res = await http
        .get(
          Uri.parse('${AppConfig.baseUrl}/api/bundles'),
          headers: _headers(token: token),
        )
        .timeout(const Duration(seconds: 15));

    if (res.statusCode != 200) {
      throw const ApiException('Gagal memuat bundel');
    }
    final list = jsonDecode(res.body) as List<dynamic>;
    return list.map((b) => Bundle.fromJson(b as Map<String, dynamic>)).toList();
  }

  // ── Shifts ───────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> getActiveShift({
    required String token,
  }) async {
    final res = await http
        .get(
          Uri.parse('${AppConfig.baseUrl}/api/shifts/active'),
          headers: _headers(token: token),
        )
        .timeout(const Duration(seconds: 10));

    if (res.statusCode == 404 || res.statusCode == 204) return null;
    if (res.statusCode != 200) {
      throw const ApiException('Gagal memuat shift aktif');
    }
    return jsonDecode(res.body) as Map<String, dynamic>?;
  }

  static Future<Shift> clockIn({
    required String token,
    required int startingCash,
  }) async {
    final res = await http
        .post(
          Uri.parse('${AppConfig.baseUrl}/api/shifts/clock-in'),
          headers: _headers(token: token),
          body: jsonEncode({'starting_cash': startingCash}),
        )
        .timeout(const Duration(seconds: 10));

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 201 && res.statusCode != 200) {
      throw ApiException(
        data['message'] as String? ?? 'Gagal memulai shift',
        statusCode: res.statusCode,
      );
    }
    return Shift.fromJson(data);
  }

  static Future<Map<String, dynamic>> clockOut({
    required String token,
    int? actualCash,
    int? actualQris,
  }) async {
    final body = <String, dynamic>{};
    if (actualCash != null) body['actual_cash'] = actualCash;
    if (actualQris != null) body['actual_qris'] = actualQris;

    final res = await http
        .put(
          Uri.parse('${AppConfig.baseUrl}/api/shifts/clock-out'),
          headers: _headers(token: token),
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 10));

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 200) {
      throw ApiException(
        data['message'] as String? ?? 'Gagal mengakhiri shift',
        statusCode: res.statusCode,
      );
    }
    return data;
  }

  // ── Orders ───────────────────────────────────────────────────────────────────

  /// [items] = `[{ "product_id": int, "quantity": int, "variant_ids": [int], "notes": "..." }]`
  static Future<Map<String, dynamic>> createOrder({
    required String token,
    required List<Map<String, dynamic>> items,
    required String orderNumber,
  }) async {
    final res = await http
        .post(
          Uri.parse('${AppConfig.baseUrl}/api/orders'),
          headers: _headers(token: token),
          body: jsonEncode({'order_number': orderNumber, 'items': items}),
        )
        .timeout(const Duration(seconds: 15));

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 201) {
      throw ApiException(
        data['message'] as String? ?? 'Gagal membuat pesanan',
        statusCode: res.statusCode,
      );
    }
    return data;
  }

  // ── Transactions ─────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> createTransaction({
    required String token,
    required int orderId,
    required String paymentMethod,
    String notes = '',
  }) async {
    final res = await http
        .post(
          Uri.parse('${AppConfig.baseUrl}/api/transactions'),
          headers: _headers(token: token),
          body: jsonEncode({
            'order_id': orderId,
            'payment_method': paymentMethod,
            if (notes.isNotEmpty) 'notes': notes,
          }),
        )
        .timeout(const Duration(seconds: 15));

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 201) {
      throw ApiException(
        data['message'] as String? ?? 'Gagal membuat transaksi',
        statusCode: res.statusCode,
      );
    }
    return data;
  }
}
