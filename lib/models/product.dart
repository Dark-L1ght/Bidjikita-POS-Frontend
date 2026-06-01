import 'package:flutter/foundation.dart';

@immutable
class Product {
  final String id;
  final String name;
  final int price; // base price in IDR
  final String category; // 'Kopi', 'Non-Kopi', 'Makanan', 'Snack'
  final String description;
  final List<String> ingredients;
  final String caffeineLevel;
  final List<String> availableSizes;
  final List<String> sugarLevels;

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
  });
}
