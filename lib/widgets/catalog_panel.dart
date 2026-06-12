import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../models/product_variant.dart';
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
  final _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    // initialise search controller with provider value
    _searchController.text = ref.read(searchQueryProvider);
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // "Add Order" dialog
  // ──────────────────────────────────────────────────────────────────────────

  void _showAddOrderDialog(BuildContext context, Product product) {
    final variants = product.variants;
    final noteController = TextEditingController();

    // Selection state — single variant only.
    int quantity = 1;
    ProductVariant? selectedVariant = variants.isNotEmpty
        ? variants.first
        : null;

    int computeEffectivePrice() {
      return selectedVariant?.price ?? product.price;
    }

    List<int> buildVariantIds() {
      return selectedVariant != null ? [selectedVariant!.id] : [];
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final effectivePrice = computeEffectivePrice();
          final totalPrice = effectivePrice * quantity;

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

                    // ── Scrollable body ────────────────────────────────────
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
                                  // Product image / icon
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: SizedBox(
                                      width: 72,
                                      height: 72,
                                      child: product.imageUrl != null
                                          ? Image.network(
                                              '${AppConfig.baseUrl}${product.imageUrl}',
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, _, _) =>
                                                  product.isBundle &&
                                                      product
                                                          .bundleItems
                                                          .isNotEmpty
                                                  ? _BundleCollage(
                                                      product: product,
                                                    )
                                                  : const Center(
                                                      child: Icon(
                                                        Icons.coffee,
                                                        color: Colors.white30,
                                                        size: 40,
                                                      ),
                                                    ),
                                            )
                                          : product.isBundle &&
                                                product.bundleItems.isNotEmpty
                                          ? _BundleCollage(product: product)
                                          : const Center(
                                              child: Icon(
                                                Icons.coffee,
                                                color: Colors.white30,
                                                size: 40,
                                              ),
                                            ),
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
                                              formatRupiah(effectivePrice),
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
                            // ── Stock warning ─────────────────────────────
                            if (product.lowStock)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.orange[200]!,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.inventory_2_outlined,
                                        size: 16,
                                        color: Colors.orange[700],
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Stok bahan baku untuk menu ini menipis.\nPastikan ketersediaan sebelum memproses pesanan.',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.orange[900],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),

                            // ── Variant selection ────────────────────────
                            if (variants.length > 1) ...[
                              _sectionLabel('Pilih Varian', required: true),
                              const SizedBox(height: 10),
                              ...variants.map((v) {
                                final isSelected = selectedVariant?.id == v.id;
                                return GestureDetector(
                                  onTap: () => setDialogState(() {
                                    selectedVariant = v;
                                  }),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFFEBF5F0)
                                          : Colors.white,
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFF04291A)
                                            : Colors.grey[300]!,
                                        width: isSelected ? 1.5 : 1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 18,
                                              height: 18,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: isSelected
                                                      ? const Color(0xFF04291A)
                                                      : Colors.grey[400]!,
                                                  width: 2,
                                                ),
                                              ),
                                              child: isSelected
                                                  ? Center(
                                                      child: Container(
                                                        width: 10,
                                                        height: 10,
                                                        decoration:
                                                            const BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color: Color(
                                                                0xFF04291A,
                                                              ),
                                                            ),
                                                      ),
                                                    )
                                                  : null,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              v.variantName,
                                              style: const TextStyle(
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (v.price > 0)
                                          Text(
                                            formatRupiah(v.price),
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                              const SizedBox(height: 14),
                            ],

                            // ── Notes ────────────────────────────────────────
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

                    // ── Add to Order button ────────────────────────────────
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
                            if (product.isBundle &&
                                product.bundleItems.isNotEmpty) {
                              // Expand bundle into individual items.
                              _addBundleToCart(
                                ctx,
                                product,
                                quantity,
                                noteController,
                              );
                            } else {
                              ref
                                  .read(cartProvider.notifier)
                                  .addItem(
                                    product,
                                    selectedVariant?.variantName ?? '',
                                    '',
                                    noteController.text,
                                    quantity: quantity,
                                    effectivePrice: effectivePrice,
                                    selectedVariantIds: buildVariantIds(),
                                  );
                            }
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

  /// Adds a bundle as a single cart item with its expanded sub-items.
  void _addBundleToCart(
    BuildContext dialogContext,
    Product bundleProduct,
    int bundleQuantity,
    TextEditingController noteController,
  ) {
    final allProducts =
        ref.read(productListProvider).valueOrNull ?? <Product>[];
    final subItems = <BundleSubItem>[];

    for (final bi in bundleProduct.bundleItems) {
      final realProduct = allProducts.cast<Product?>().firstWhere(
        (p) => p?.apiId == bi.productId,
        orElse: () => null,
      );
      if (realProduct == null) continue;

      // Resolve variant name — the backend may not include it when
      // the bundle item was created without an explicit variant_id.
      String? variantName = bi.variantName;
      if (variantName == null && realProduct.variants.isNotEmpty) {
        if (bi.variantId != null) {
          final match = realProduct.variants.cast<ProductVariant?>().firstWhere(
            (v) => v?.id == bi.variantId,
            orElse: () => null,
          );
          variantName = match?.variantName;
        } else {
          // Only one variant — that's the one being used.
          variantName = realProduct.variants.first.variantName;
        }
      }

      subItems.add(
        BundleSubItem(
          productId: bi.productId,
          variantIds: bi.variantId != null ? <int>[bi.variantId!] : <int>[],
          quantity: bi.quantity * bundleQuantity,
          productName: realProduct.name,
          variantName: variantName,
        ),
      );
    }

    if (subItems.isEmpty) return;

    ref
        .read(cartProvider.notifier)
        .addItem(
          bundleProduct,
          '',
          '',
          noteController.text,
          effectivePrice: bundleProduct.price,
          bundleSubItems: subItems,
        );
  }

  void _showAddedSnackbar(BuildContext context, String name) {
    // Narrow, left-aligned toast — right margin is calculated so the toast
    // is ~360px wide regardless of screen size.
    final screenWidth = MediaQuery.of(context).size.width;
    const double leftInset = 24;
    const double targetWidth = 360;
    final rightInset = (screenWidth - leftInset - targetWidth).clamp(
      24.0,
      1200.0,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$name ditambahkan ke keranjang',
          style: const TextStyle(
            color: Color(0xFF04291A),
            fontWeight: FontWeight.w600,
          ),
        ),
        duration: const Duration(milliseconds: 1400),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Color(0xFF04291A), width: 1.2),
        ),
        margin: EdgeInsets.only(left: leftInset, right: rightInset, bottom: 24),
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: SizedBox(
                        width: 120,
                        height: 120,
                        child: product.imageUrl != null
                            ? Image.network(
                                '${AppConfig.baseUrl}${product.imageUrl}',
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    product.isBundle &&
                                        product.bundleItems.isNotEmpty
                                    ? _BundleCollage(product: product)
                                    : const Center(
                                        child: Icon(
                                          Icons.coffee,
                                          color: Colors.white30,
                                          size: 40,
                                        ),
                                      ),
                              )
                            : product.isBundle && product.bundleItems.isNotEmpty
                            ? _BundleCollage(product: product)
                            : const Center(
                                child: Icon(
                                  Icons.coffee,
                                  color: Colors.white30,
                                  size: 40,
                                ),
                              ),
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
                          if (product.lowStock)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.inventory_2_outlined,
                                    size: 14,
                                    color: Colors.orange[700],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Stok bahan baku menipis',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.orange[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _detailSection('Deskripsi', product.description),
                // ── Variant list ─────────────────────────────────────
                if (product.variants.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Varian',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  ...product.variants.map(
                    (v) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '• ${v.variantName}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            formatRupiah(v.price),
                            style: const TextStyle(
                              color: Color(0xFF04291A),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
    final categoriesAsync = ref.watch(categoryListProvider);
    final categories =
        categoriesAsync.valueOrNull ??
        const ['Semua', 'Kopi', 'Non-Kopi', 'Makanan', 'Snack', 'Bundling'];
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final products = ref.watch(filteredProductsProvider);
    final totalCount = ref.watch(productListProvider).valueOrNull?.length ?? 0;

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
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: _isFocused ? 280 : 220,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: _isFocused
                        ? const Color(0xFF04291A)
                        : const Color(0xFFDDDDDD),
                    width: 1.5,
                  ),
                  boxShadow: _isFocused
                      ? [
                          BoxShadow(
                            color: const Color(
                              0xFF04291A,
                            ).withValues(alpha: 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  onChanged: (v) =>
                      ref.read(searchQueryProvider.notifier).state = v,
                  textAlignVertical: TextAlignVertical.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Cari kopi, snack, makanan...',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12.5,
                      fontWeight: FontWeight.normal,
                    ),
                    prefixIcon: AnimatedRotation(
                      turns: _isFocused ? 0.25 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.search_rounded,
                        color: _isFocused
                            ? const Color(0xFF04291A)
                            : Colors.grey[400],
                        size: 18,
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    suffixIcon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 150),
                      child: searchQuery.isNotEmpty
                          ? GestureDetector(
                              key: const ValueKey('clear_btn'),
                              onTap: () {
                                _searchController.clear();
                                ref.read(searchQueryProvider.notifier).state =
                                    '';
                              },
                              child: Icon(
                                Icons.cancel_rounded,
                                color: Colors.grey[400],
                                size: 18,
                              ),
                            )
                          : const SizedBox.shrink(
                              key: ValueKey('empty_suffix'),
                            ),
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 8,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
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
            child: ref
                .watch(productListProvider)
                .when(
                  loading: () => const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Color(0xFF04291A)),
                        SizedBox(height: 16),
                        Text(
                          'Memuat menu...',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  error: (e, _) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_off_rounded,
                          size: 56,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Gagal memuat menu',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          e.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF04291A),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () =>
                              ref.read(productListProvider.notifier).refresh(),
                          icon: const Icon(Icons.refresh_rounded, size: 16),
                          label: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                  data: (_) => products.isEmpty
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
                              onAddToCart: () =>
                                  _showAddOrderDialog(context, prod),
                            );
                          },
                        ),
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
    final savings = product.originalPrice - product.price;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: product.isBundle
                ? const Color(0xFF04291A).withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            Expanded(
              child: Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: product.isBundle
                          ? const Color(0xFF0D2B20)
                          : const Color(0xFF1E3A2F),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: product.imageUrl != null
                          ? Image.network(
                              '${AppConfig.baseUrl}${product.imageUrl}',
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (_, _, _) =>
                                  product.isBundle &&
                                      product.bundleItems.isNotEmpty
                                  ? _BundleCollage(product: product)
                                  : Center(
                                      child: Icon(
                                        Icons.coffee,
                                        color: Colors.white30,
                                        size: 40,
                                      ),
                                    ),
                            )
                          : product.isBundle && product.bundleItems.isNotEmpty
                          ? _BundleCollage(product: product)
                          : Center(
                              child: Icon(
                                Icons.coffee,
                                color: Colors.white30,
                                size: 40,
                              ),
                            ),
                    ),
                  ),
                  // Bundle badge — always shown on bundles so they're visually
                  // distinct from regular products, even with a single item or no savings.
                  if (product.isBundle)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF04291A),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Bundle',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  // Low-stock warning badge
                  if (product.lowStock)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange[700],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Stok Menipis',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  // Bundle savings badge (only when there are savings)
                  if (product.isBundle && savings > 0)
                    Positioned(
                      top: product.lowStock ? 30 : 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber[700],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Hemat ${_shortK(savings)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Info area
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, bottom: 10),
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
                        // Bundle contents
                        if (product.isBundle &&
                            product.bundleContents.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            product.bundleContents.join(' + '),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[500],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              formatRupiah(product.price),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                            if (product.isBundle &&
                                product.originalPrice > product.price) ...[
                              const SizedBox(width: 4),
                              Text(
                                formatRupiah(product.originalPrice),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[400],
                                  decoration: TextDecoration.lineThrough,
                                  decorationThickness: 1.5,
                                ),
                              ),
                            ],
                          ],
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
// Bundle collage — renders product images in a grid
// ──────────────────────────────────────────────────────────────────────────────

class _BundleCollage extends ConsumerWidget {
  final Product product;

  const _BundleCollage({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allProducts =
        ref.watch(productListProvider).valueOrNull ?? <Product>[];

    // Collect image URLs from the bundle items' products.
    final imageUrls = <String>[];
    for (final bi in product.bundleItems) {
      final p = allProducts.cast<Product?>().firstWhere(
        (p) => p?.apiId == bi.productId,
        orElse: () => null,
      );
      if (p?.imageUrl != null && p!.imageUrl!.isNotEmpty) {
        imageUrls.add(p.imageUrl!);
      }
    }

    if (imageUrls.isEmpty) {
      return Center(
        child: Icon(
          Icons.card_giftcard_rounded,
          color: Colors.white30,
          size: 40,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return _collageGrid(imageUrls, constraints);
      },
    );
  }

  Widget _collageGrid(List<String> urls, BoxConstraints constraints) {
    final count = urls.length > 4 ? 4 : urls.length;
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              _collageCell(urls, 0),
              if (count >= 2 && count != 3) _collageCell(urls, 1),
            ],
          ),
        ),
        if (count >= 3)
          Expanded(
            child: Row(
              children: [
                _collageCell(urls, count == 3 ? 1 : 2),
                if (count >= 4) _collageCell(urls, 3),
              ],
            ),
          ),
      ],
    );
  }

  Widget _collageCell(List<String> urls, int index) {
    if (index >= urls.length) {
      return const SizedBox.shrink();
    }
    const border = Border(
      right: BorderSide(color: Color(0x33FFFFFF), width: 0.5),
      bottom: BorderSide(color: Color(0x33FFFFFF), width: 0.5),
    );
    return Expanded(
      child: Container(
        decoration: BoxDecoration(border: border),
        child: Image.network(
          '${AppConfig.baseUrl}${urls[index]}',
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Center(
            child: Icon(Icons.coffee, color: Colors.white24, size: 20),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────

String _shortK(int amount) {
  if (amount >= 1000) return 'Rp ${(amount ~/ 1000)}K';
  return formatRupiah(amount);
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
