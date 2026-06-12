import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/bundle.dart';
import '../models/product.dart';

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

  static Future<T> _withRetry<T>(
    Future<T> Function() call, {
    int attempts = 2,
  }) async {
    for (var i = 0; i < attempts; i++) {
      try {
        return await call();
      } catch (_) {
        if (i == attempts - 1) rethrow;
        await Future.delayed(const Duration(seconds: 1));
      }
    }
    throw const ApiException('Retry exhausted');
  }

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
        .timeout(const Duration(seconds: 10));

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
    return _withRetry(() async {
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
      return list
          .map((e) => Product.fromApi(e as Map<String, dynamic>))
          .toList();
    });
  }

  // ── Categories ───────────────────────────────────────────────────────────────

  static Future<List<String>> getCategories({String? token}) async {
    return _withRetry(() async {
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
    });
  }

  // ── Bundles ───────────────────────────────────────────────────────────────────

  static Future<List<Bundle>> getBundles({String? token}) async {
    return _withRetry(() async {
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
      return list
          .map((b) => Bundle.fromJson(b as Map<String, dynamic>))
          .toList();
    });
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
