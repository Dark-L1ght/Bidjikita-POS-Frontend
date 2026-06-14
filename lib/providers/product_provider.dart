import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bundle.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../utils/logger.dart';
import 'auth_provider.dart';

// ---------------------------------------------------------------------------
// Product list
// ---------------------------------------------------------------------------

class ProductNotifier extends Notifier<AsyncValue<List<Product>>> {
  @override
  AsyncValue<List<Product>> build() {
    _load();
    return const AsyncLoading();
  }

  Future<void> _load() async {
    try {
      final token = ref.read(authProvider).token;
      final products = await ApiService.getProducts(token: token);

      List<Bundle> bundles;
      try {
        bundles = await ApiService.getBundles(token: token);
      } catch (e) {
        logError('Failed to fetch bundles', e);
        bundles = [];
      }

      final bundleProducts = bundles
          .where((b) => b.items.isNotEmpty)
          .map((b) => _bundleToProduct(b))
          .toList();

      state = AsyncData([...products, ...bundleProducts]);
    } catch (e, st) {
      logError('Failed to load products', e, st);
      state = AsyncError(e, st);
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final token = ref.read(authProvider).token;
      final products = await ApiService.getProducts(token: token);

      List<Bundle> bundles;
      try {
        bundles = await ApiService.getBundles(token: token);
      } catch (e) {
        logError('Failed to fetch bundles', e);
        bundles = [];
      }

      final bundleProducts = bundles
          .where((b) => b.items.isNotEmpty)
          .map((b) => _bundleToProduct(b))
          .toList();

      state = AsyncData([...products, ...bundleProducts]);
    } catch (e, st) {
      logError('Failed to load products', e, st);
      state = AsyncError(e, st);
    }
  }

  void reset() => state = const AsyncLoading();
}

/// Converts a backend [Bundle] into a [Product] for display in the catalog.
Product _bundleToProduct(Bundle b) {
  final contents = b.items.map((i) {
    final name = i.productName.isNotEmpty ? i.productName : 'Item';
    return i.quantity > 1 ? '$name \u00d7${i.quantity}' : name;
  }).toList();

  return Product(
    id: 'bundle_${b.id}',
    apiId: b.id,
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
    NotifierProvider<ProductNotifier, AsyncValue<List<Product>>>(
      ProductNotifier.new,
    );

// ---------------------------------------------------------------------------
// Category list
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

class _CategoryFilter extends Notifier<String> {
  @override
  String build() => 'Semua';
  void set(String cat) => state = cat;
}

class _SearchFilter extends Notifier<String> {
  @override
  String build() => '';
  void set(String q) => state = q;
}

final selectedCategoryProvider = NotifierProvider<_CategoryFilter, String>(_CategoryFilter.new);

final searchQueryProvider = NotifierProvider<_SearchFilter, String>(_SearchFilter.new);

final filteredProductsProvider = Provider<List<Product>>((ref) {
  final category = ref.watch(selectedCategoryProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final products = ref.watch(productListProvider).asData?.value ?? [];

  var result = category == 'Semua'
      ? products
      : products.where((p) => p.category == category).toList();

  if (query.isNotEmpty) {
    result = result.where((p) => p.name.toLowerCase().contains(query)).toList();
  }

  return result;
});
