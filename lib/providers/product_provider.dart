import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bundle.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

// ---------------------------------------------------------------------------
// Product list — fetched from products API, merged with bundles
// ---------------------------------------------------------------------------

class ProductNotifier extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() async {
    final token = ref.watch(authProvider).token;
    final products = await ApiService.getProducts(token: token);

    // Fetch bundles and convert to Product-like objects.
    List<Bundle> bundles;
    try {
      bundles = await ApiService.getBundles(token: token);
    } catch (_) {
      bundles = [];
    }

    final bundleProducts = bundles
        .where((b) => b.items.isNotEmpty)
        .map((b) => _bundleToProduct(b))
        .toList();

    return [...products, ...bundleProducts];
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final token = ref.read(authProvider).token;
      final products = await ApiService.getProducts(token: token);

      List<Bundle> bundles;
      try {
        bundles = await ApiService.getBundles(token: token);
      } catch (_) {
        bundles = [];
      }

      final bundleProducts = bundles
          .where((b) => b.items.isNotEmpty)
          .map((b) => _bundleToProduct(b))
          .toList();

      return [...products, ...bundleProducts];
    });
  }
}

/// Converts a backend [Bundle] into a [Product] for display in the catalog.
///
/// The product is marked `isBundle = true`, has no variants (fixed price), and
/// its `bundleContents` list shows the names of the constituent items.
Product _bundleToProduct(Bundle b) {
  final contents = b.items.map((i) {
    final name = i.productName.isNotEmpty ? i.productName : 'Item';
    return i.quantity > 1 ? '$name \u00d7${i.quantity}' : name;
  }).toList();

  return Product(
    id: 'bundle_${b.id}',
    apiId: b.id, // note: not a real Product ID — bundle IDs are separate
    name: b.bundleName,
    price: b.bundlePrice,
    category: 'Bundling',
    description: b.description,
    ingredients: contents,
    caffeineLevel: '',
    availableSizes: const [],
    sugarLevels: const [],
    isBundle: true,
    bundleContents: contents,
    originalPrice: b.bundlePrice + b.bundleProfit,
    imageUrl: b.imageUrl,
    status: 'available',
    variants: const [],
    bundleItems: b.items,
  );
}

final productListProvider =
    AsyncNotifierProvider<ProductNotifier, List<Product>>(ProductNotifier.new);

// ---------------------------------------------------------------------------
// Category list — fetched from the API, with 'Semua' and 'Bundling' prepended
// ---------------------------------------------------------------------------

final categoryListProvider = FutureProvider<List<String>>((ref) async {
  final token = ref.watch(authProvider).token;
  try {
    final cats = await ApiService.getCategories(token: token);
    return ['Semua', ...cats, 'Bundling'];
  } catch (_) {
    return const ['Semua', 'Kopi', 'Non-Kopi', 'Makanan', 'Snack', 'Bundling'];
  }
});

// ---------------------------------------------------------------------------
// Filters
// ---------------------------------------------------------------------------

final selectedCategoryProvider = StateProvider<String>((ref) => 'Semua');

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredProductsProvider = Provider<List<Product>>((ref) {
  final category = ref.watch(selectedCategoryProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final products = ref.watch(productListProvider).valueOrNull ?? [];

  var result = category == 'Semua'
      ? products
      : products.where((p) => p.category == category).toList();

  if (query.isNotEmpty) {
    result = result.where((p) => p.name.toLowerCase().contains(query)).toList();
  }

  return result;
});
