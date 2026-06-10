import 'package:flutter/foundation.dart';

@immutable
class Product {
  final String id;
  final String name;
  final int price; // base price in IDR
  final String category; // 'Kopi', 'Non-Kopi', 'Makanan', 'Snack', 'Bundling'
  final String description;
  final List<String> ingredients;
  final String caffeineLevel;
  final List<String> availableSizes;
  final List<String> sugarLevels;

  // ── Bundle-specific fields ────────────────────────────────────────────────
  /// True when this product is a pre-defined bundle of two or more items.
  final bool isBundle;

  /// Human-readable list of what's included, e.g. ["1× Americano", "1× Croissant"].
  final List<String> bundleContents;

  /// Sum of individual item prices — used to show savings.  0 for non-bundles.
  final int originalPrice;

  const Product({
    required this.id,
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
  });
}
