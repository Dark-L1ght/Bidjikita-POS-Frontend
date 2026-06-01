import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';

const _sugarLevels = ['Normal Sugar', 'Less Sugar', 'No Sugar'];
const _beverageSizes = ['Small (Hot)', 'Medium (Iced)', 'Large (Iced)'];

// ---------------------------------------------------------------------------
// Dummy product catalogue
// ---------------------------------------------------------------------------
final productListProvider = Provider<List<Product>>((ref) {
  return const [
    // ── KOPI ───────────────────────────────────────────────────────────────
    Product(
      id: 'p1',
      name: 'French Vanilla Fantasy',
      price: 42000,
      category: 'Kopi',
      description:
          'Perpaduan kopi Arabika premium dengan sentuhan vanilla manis yang khas. Cocok untuk kamu yang suka kopi dengan cita rasa lembut.',
      ingredients: [
        'Kopi Arabika',
        'Ekstrak vanilla alami',
        'Gula halus',
        'Susu segar',
      ],
      caffeineLevel: 'Sedang',
      availableSizes: _beverageSizes,
      sugarLevels: _sugarLevels,
    ),
    Product(
      id: 'p2',
      name: 'Almond Amore',
      price: 48000,
      category: 'Kopi',
      description:
          'Espresso double shot dipadukan dengan susu almond yang lembut dan sedikit karamel.',
      ingredients: ['Double espresso', 'Susu almond', 'Sirup karamel'],
      caffeineLevel: 'Tinggi',
      availableSizes: _beverageSizes,
      sugarLevels: _sugarLevels,
    ),
    Product(
      id: 'p3',
      name: 'Irish Cream Infusion',
      price: 52000,
      category: 'Kopi',
      description:
          'Perpaduan mewah antara espresso dan rasa Irish cream yang kaya.',
      ingredients: [
        'Espresso',
        'Sirup Irish cream',
        'Krim kental',
        'Serutan cokelat',
      ],
      caffeineLevel: 'Tinggi',
      availableSizes: _beverageSizes,
      sugarLevels: _sugarLevels,
    ),
    Product(
      id: 'p4',
      name: 'Dark Roast Dynamite',
      price: 32000,
      category: 'Kopi',
      description:
          'Dark roast yang kuat dan bertenaga untuk kamu yang menginginkan intensitas penuh.',
      ingredients: ['Kopi Arabika dark roast', 'Air panas'],
      caffeineLevel: 'Sangat Tinggi',
      availableSizes: _beverageSizes,
      sugarLevels: _sugarLevels,
    ),
    Product(
      id: 'p5',
      name: 'Americano Classic',
      price: 28000,
      category: 'Kopi',
      description:
          'Espresso bersih yang diencerkan ke proporsi sempurna untuk rasa yang halus dan bersih.',
      ingredients: ['Double espresso', 'Air panas'],
      caffeineLevel: 'Tinggi',
      availableSizes: _beverageSizes,
      sugarLevels: _sugarLevels,
    ),
    Product(
      id: 'p6',
      name: 'Cappuccino Deluxe',
      price: 35000,
      category: 'Kopi',
      description:
          'Cappuccino Italia klasik dengan microfoam susu yang sempurna dan espresso yang kaya.',
      ingredients: [
        'Double espresso',
        'Susu kukus',
        'Busa susu',
        'Bubuk kakao',
      ],
      caffeineLevel: 'Sedang',
      availableSizes: _beverageSizes,
      sugarLevels: _sugarLevels,
    ),
    // ── NON-KOPI ──────────────────────────────────────────────────────────
    Product(
      id: 'p7',
      name: 'Matcha Latte',
      price: 38000,
      category: 'Non-Kopi',
      description:
          'Matcha seremonial premium Jepang dipadukan dengan susu kukus yang creamy.',
      ingredients: ['Matcha seremonial grade', 'Susu kukus', 'Madu'],
      caffeineLevel: 'Rendah',
      availableSizes: _beverageSizes,
      sugarLevels: _sugarLevels,
    ),
    Product(
      id: 'p8',
      name: 'Chocolate Velvet',
      price: 35000,
      category: 'Non-Kopi',
      description:
          'Minuman cokelat Belgia premium yang lembut seperti beludru.',
      ingredients: ['Cokelat Belgia', 'Susu full cream', 'Krim kocok'],
      caffeineLevel: 'Tidak Ada',
      availableSizes: _beverageSizes,
      sugarLevels: _sugarLevels,
    ),
    Product(
      id: 'p9',
      name: 'Taro Dream',
      price: 36000,
      category: 'Non-Kopi',
      description:
          'Talas ungu creamy yang diblender bersama susu segar untuk minuman berwarna ungu.',
      ingredients: ['Bubuk talas', 'Susu segar', 'Gula', 'Es'],
      caffeineLevel: 'Tidak Ada',
      availableSizes: _beverageSizes,
      sugarLevels: _sugarLevels,
    ),
    Product(
      id: 'p10',
      name: 'Raspberry Ripple',
      price: 38000,
      category: 'Non-Kopi',
      description:
          'Minuman raspberry menyegarkan dengan rasa asam-manis yang meledak di mulut.',
      ingredients: ['Sirup raspberry', 'Air soda', 'Lemon segar', 'Daun mint'],
      caffeineLevel: 'Tidak Ada',
      availableSizes: _beverageSizes,
      sugarLevels: _sugarLevels,
    ),
    // ── MAKANAN ───────────────────────────────────────────────────────────
    Product(
      id: 'p11',
      name: 'Croissant Butter',
      price: 25000,
      category: 'Makanan',
      description:
          'Croissant segar yang dipanggang dengan lapisan mentega premium. Renyah di luar, lembut di dalam.',
      ingredients: ['Tepung terigu', 'Mentega premium', 'Telur', 'Susu'],
      caffeineLevel: 'Tidak Ada',
      availableSizes: ['Regular'],
    ),
    Product(
      id: 'p12',
      name: 'Avocado Toast',
      price: 35000,
      category: 'Makanan',
      description:
          'Roti sourdough panggang dengan topping alpukat segar, garam laut, dan cabai merah.',
      ingredients: [
        'Roti sourdough',
        'Alpukat segar',
        'Garam laut',
        'Lemon',
        'Cabai merah',
      ],
      caffeineLevel: 'Tidak Ada',
      availableSizes: ['Regular'],
    ),
    Product(
      id: 'p13',
      name: 'Banana Bread',
      price: 22000,
      category: 'Makanan',
      description:
          'Roti pisang lembab yang terbuat dari pisang matang dan rempah-rempah hangat.',
      ingredients: [
        'Pisang matang',
        'Tepung',
        'Telur',
        'Mentega',
        'Kayu manis',
      ],
      caffeineLevel: 'Tidak Ada',
      availableSizes: ['Regular'],
    ),
    // ── SNACK ─────────────────────────────────────────────────────────────
    Product(
      id: 'p14',
      name: 'Cinnamon Swirl',
      price: 20000,
      category: 'Snack',
      description: 'Pastri putar kayu manis yang hangat, ditaburi gula halus.',
      ingredients: ['Tepung', 'Kayu manis', 'Gula merah', 'Mentega'],
      caffeineLevel: 'Tidak Ada',
      availableSizes: ['Regular'],
    ),
    Product(
      id: 'p15',
      name: 'Chocolate Brownies',
      price: 18000,
      category: 'Snack',
      description:
          'Brownies cokelat yang padat dan fudgy dengan bagian atas yang sedikit renyah.',
      ingredients: ['Dark chocolate', 'Telur', 'Mentega', 'Gula', 'Tepung'],
      caffeineLevel: 'Tidak Ada',
      availableSizes: ['Regular'],
    ),
    Product(
      id: 'p16',
      name: 'White Choco Wonder',
      price: 22000,
      category: 'Snack',
      description:
          'Cookie putih cokelat creamy dengan kacang macadamia renyah.',
      ingredients: [
        'White chocolate',
        'Kacang macadamia',
        'Tepung',
        'Mentega',
        'Vanilla',
      ],
      caffeineLevel: 'Tidak Ada',
      availableSizes: ['Regular'],
    ),
  ];
});

// ---------------------------------------------------------------------------
// Filters
// ---------------------------------------------------------------------------
final selectedCategoryProvider = StateProvider<String>((ref) => 'Semua');

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredProductsProvider = Provider<List<Product>>((ref) {
  final category = ref.watch(selectedCategoryProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final products = ref.watch(productListProvider);

  var result = category == 'Semua'
      ? products
      : products.where((p) => p.category == category).toList();

  if (query.isNotEmpty) {
    result = result
        .where((p) => p.name.toLowerCase().contains(query))
        .toList();
  }

  return result;
});
