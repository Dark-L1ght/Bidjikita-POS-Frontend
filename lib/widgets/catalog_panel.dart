import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../utils/currency.dart';

class CatalogPanel extends ConsumerStatefulWidget {
  const CatalogPanel({super.key});

  @override
  ConsumerState<CatalogPanel> createState() => _CatalogPanelState();
}

class _CatalogPanelState extends ConsumerState<CatalogPanel> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // initialise search controller with provider value
    _searchController.text = ref.read(searchQueryProvider);

  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // "Add Order" dialog
  // ──────────────────────────────────────────────────────────────────────────
  void _showAddOrderDialog(BuildContext context, Product product) {
    int quantity = 1;
    String selectedSize = product.availableSizes.isNotEmpty
        ? product.availableSizes.first
        : '';
    String selectedSugarLevel = product.sugarLevels.isNotEmpty
        ? product.sugarLevels.first
        : '';
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final totalPrice = product.price * quantity;

          return Dialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 100,
              vertical: 32,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: 460,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Header ────────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: const Icon(
                              Icons.add_shopping_cart_rounded,
                              color: Colors.white,
                              size: 15,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Add Order',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => Navigator.pop(ctx),
                            child: Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    // ── Scrollable body ───────────────────────────────────
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product info card
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 72,
                                    height: 72,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.coffee,
                                      size: 36,
                                      color: Color(0xFF8B4513),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              formatRupiah(product.price),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                _stepperBtn(
                                                  icon: Icons.remove,
                                                  enabled: quantity > 1,
                                                  onTap: () => setDialogState(
                                                    () => quantity--,
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 14,
                                                      ),
                                                  child: Text(
                                                    '$quantity',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                                _stepperBtn(
                                                  icon: Icons.add,
                                                  enabled: true,
                                                  onTap: () => setDialogState(
                                                    () => quantity++,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 22),

                            // ── Cup size ──────────────────────────────────
                            if (product.availableSizes.length > 1) ...[
                              _sectionLabel('Select a Cup', required: true),
                              const SizedBox(height: 10),
                              _radioGroup(
                                items: product.availableSizes,
                                selected: selectedSize,
                                onSelect: (v) =>
                                    setDialogState(() => selectedSize = v),
                              ),
                              const SizedBox(height: 22),
                            ],

                            // ── Sugar level ───────────────────────────────
                            if (product.sugarLevels.isNotEmpty) ...[
                              _sectionLabel('Sugar Level', required: true),
                              const SizedBox(height: 10),
                              _radioGroup(
                                items: product.sugarLevels,
                                selected: selectedSugarLevel,
                                onSelect: (v) => setDialogState(
                                  () => selectedSugarLevel = v,
                                ),
                              ),
                              const SizedBox(height: 22),
                            ],

                            // ── Notes ─────────────────────────────────────
                            _sectionLabel('Catatan', required: false),
                            const SizedBox(height: 10),
                            TextField(
                              controller: noteController,
                              maxLines: 3,
                              textInputAction: TextInputAction.newline,
                              decoration: InputDecoration(
                                hintText:
                                    'Contoh: tanpa es, less sweet, extra shot...',
                                hintStyle: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 13,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF04291A),
                                  ),
                                ),
                                contentPadding: const EdgeInsets.all(12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Add to Order button ───────────────────────────────
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF04291A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            ref
                                .read(cartProvider.notifier)
                                .addItem(
                                  product,
                                  selectedSize,
                                  selectedSugarLevel,
                                  noteController.text,
                                  quantity: quantity,
                                );
                            Navigator.pop(ctx);
                            _showAddedSnackbar(context, product.name);
                          },
                          child: Text(
                            '(${formatRupiah(totalPrice)}) Tambah ke Pesanan',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddedSnackbar(BuildContext context, String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name ditambahkan ke keranjang'),
        duration: const Duration(milliseconds: 1400),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF04291A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Product detail popup
  // ──────────────────────────────────────────────────────────────────────────
  void _showProductDetail(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 480,
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Detail Produk',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.cancel_outlined,
                        color: Colors.black54,
                        size: 26,
                      ),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3A2F),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.coffee,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            formatRupiah(product.price),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF04291A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEBF5F0),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              product.category,
                              style: const TextStyle(
                                color: Color(0xFF04291A),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _detailSection('Deskripsi', product.description),
                const SizedBox(height: 20),
                const Text(
                  'Bahan-bahan',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 8),
                ...product.ingredients.map(
                  (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '• $i',
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _detailSection('Tingkat Kafein', product.caffeineLevel),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF04291A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showAddOrderDialog(context, product);
                    },
                    icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                    label: const Text(
                      'Tambah ke Pesanan',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailSection(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Build
  // ──────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    const categories = ['Semua', 'Kopi', 'Non-Kopi', 'Makanan', 'Snack'];
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final products = ref.watch(filteredProductsProvider);
    final totalCount = ref.watch(productListProvider).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),

          // ── Category chips + search + result count ─────────────────────────
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 35,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      final isSelected = selectedCategory == cat;
                      return Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSelected
                                ? const Color(0xFF04291A)
                                : const Color(0xFFEAEAEA),
                            foregroundColor: isSelected
                                ? Colors.white
                                : Colors.black87,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                          ),
                          onPressed: () =>
                              ref
                                      .read(selectedCategoryProvider.notifier)
                                      .state =
                                  cat,
                          child: Text(
                            cat,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Search box placed to the right of category chips
              SizedBox(
                width: 260,
                height: 35,
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => ref.read(searchQueryProvider.notifier).state = v,
                  textAlignVertical: TextAlignVertical.center,
                  style: const TextStyle(height: 1.0),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Cari nama menu...',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                    prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[400], size: 18),
                    prefixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    suffixIcon: Visibility(
                      visible: searchQuery.isNotEmpty,
                      maintainState: true,
                      maintainAnimation: true,
                      maintainSize: true,
                      child: GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          ref.read(searchQueryProvider.notifier).state = '';
                        },
                        child: Icon(Icons.cancel_rounded, color: Colors.grey[400], size: 18),
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF04291A), width: 1.5),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Result count badge
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  searchQuery.isNotEmpty
                      ? '${products.length} dari $totalCount menu'
                      : '${products.length} menu',
                  key: ValueKey('${products.length}_$searchQuery'),
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Product grid or empty state ───────────────────────────────
          Expanded(
            child: products.isEmpty
                ? _buildEmptySearch(searchQuery)
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.82,
                        ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final prod = products[index];
                      return _ProductCard(
                        product: prod,
                        searchQuery: searchQuery,
                        onTap: () => _showProductDetail(context, prod),
                        onAddToCart: () => _showAddOrderDialog(context, prod),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearch(String query) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 56, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            query.isNotEmpty
                ? 'Tidak ada menu untuk "$query"'
                : 'Tidak ada menu di kategori ini',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            query.isNotEmpty
                ? 'Coba kata kunci lain atau ganti kategori'
                : 'Pilih kategori lain',
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
          if (query.isNotEmpty) ...[
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                _searchController.clear();
                ref.read(searchQueryProvider.notifier).state = '';
              },
              icon: const Icon(Icons.close_rounded, size: 16),
              label: const Text('Hapus pencarian'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF04291A),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Dialog helpers
// ──────────────────────────────────────────────────────────────────────────────

Widget _sectionLabel(String title, {required bool required}) {
  return Row(
    children: [
      Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      if (required) ...[
        const SizedBox(width: 4),
        const Text(
          '*',
          style: TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    ],
  );
}

/// Radio-style bordered list (single select).
Widget _radioGroup({
  required List<String> items,
  required String selected,
  required ValueChanged<String> onSelect,
}) {
  return Container(
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey[300]!),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      children: items.asMap().entries.map((entry) {
        final i = entry.key;
        final item = entry.value;
        final isSelected = selected == item;
        return GestureDetector(
          onTap: () => onSelect(item),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: i < items.length - 1
                  ? Border(bottom: BorderSide(color: Colors.grey[200]!))
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item, style: const TextStyle(fontSize: 14)),
                _radioIndicator(isSelected),
              ],
            ),
          ),
        );
      }).toList(),
    ),
  );
}

Widget _radioIndicator(bool isSelected) {
  return Container(
    width: 20,
    height: 20,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: isSelected ? const Color(0xFF04291A) : Colors.grey[400]!,
        width: 2,
      ),
    ),
    child: isSelected
        ? Center(
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF04291A),
              ),
            ),
          )
        : null,
  );
}

Widget _stepperBtn({
  required IconData icon,
  required bool enabled,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: enabled ? onTap : null,
    child: Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey[300]!),
        color: enabled ? Colors.white : Colors.grey[100],
      ),
      child: Icon(
        icon,
        size: 16,
        color: enabled ? Colors.black87 : Colors.grey[400],
      ),
    ),
  );
}

// ──────────────────────────────────────────────────────────────────────────────
// Product card — highlights matching text in the product name
// ──────────────────────────────────────────────────────────────────────────────
class _ProductCard extends StatelessWidget {
  final Product product;
  final String searchQuery;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const _ProductCard({
    required this.product,
    required this.searchQuery,
    required this.onTap,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A2F),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(Icons.coffee, color: Colors.white30, size: 40),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _HighlightText(
                          text: product.name,
                          query: searchQuery,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatRupiah(product.price),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: onAddToCart,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFF04291A),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Highlights the query substring inside text with a green tint
// ──────────────────────────────────────────────────────────────────────────────
class _HighlightText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle style;
  final int maxLines;

  const _HighlightText({
    required this.text,
    required this.query,
    required this.style,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      );
    }

    final lower = text.toLowerCase();
    final q = query.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;

    while (true) {
      final idx = lower.indexOf(q, start);
      if (idx == -1) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }
      if (idx > start) {
        spans.add(TextSpan(text: text.substring(start, idx)));
      }
      spans.add(
        TextSpan(
          text: text.substring(idx, idx + q.length),
          style: const TextStyle(
            backgroundColor: Color(0xFFB2DFDB),
            color: Color(0xFF004D40),
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      start = idx + q.length;
    }

    return Text.rich(
      TextSpan(children: spans),
      style: style,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}
