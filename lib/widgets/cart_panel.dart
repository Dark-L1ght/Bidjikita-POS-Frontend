import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cart_provider.dart';
import '../utils/currency.dart';

class CartPanel extends ConsumerWidget {
  const CartPanel({super.key});

  // ──────────────────────────────────────────────────────────────────────────
  // Discount dialog
  // ──────────────────────────────────────────────────────────────────────────
  void _showDiscountDialog(
    BuildContext context,
    WidgetRef ref,
    CartState cart,
  ) {
    final controller = TextEditingController(
      text: cart.discountAmount > 0 ? cart.discountAmount.toString() : '',
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Tambah Diskon',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Jumlah Diskon (Rp)',
            prefixText: 'Rp ',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF04291A)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF04291A),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            onPressed: () {
              final amount =
                  int.tryParse(controller.text.replaceAll('.', '')) ?? 0;
              ref.read(cartProvider.notifier).setDiscount(amount);
              Navigator.pop(ctx);
            },
            child: const Text('Terapkan'),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Payment confirmation dialog
  // ──────────────────────────────────────────────────────────────────────────
  void _showPaymentDialog(BuildContext context, WidgetRef ref, CartState cart) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Konfirmasi Pembayaran',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _summaryRow('Sub Total', formatRupiah(cart.subtotal)),
            if (cart.discountAmount > 0)
              _summaryRow(
                'Diskon',
                '- ${formatRupiah(cart.discountAmount)}',
                valueColor: Colors.red,
              ),
            _summaryRow('Pajak 11%', formatRupiah(cart.tax)),
            const Divider(height: 24),
            _summaryRow(
              'Total Pembayaran',
              formatRupiah(cart.total),
              isBold: true,
              fontSize: 15,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF04291A),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            onPressed: () {
              ref.read(cartProvider.notifier).clearCart();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'Pembayaran berhasil! Pesanan sedang diproses.',
                  ),
                  backgroundColor: const Color(0xFF04291A),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  margin: const EdgeInsets.all(16),
                ),
              );
            },
            child: const Text('Konfirmasi Bayar'),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Build
  // ──────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.black87,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Detail Pesanan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (cart.itemCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF04291A),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${cart.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                TextButton.icon(
                  onPressed: cart.items.isEmpty
                      ? null
                      : () => ref.read(cartProvider.notifier).clearCart(),
                  icon: const Icon(
                    Icons.layers_clear_outlined,
                    size: 14,
                    color: Colors.red,
                  ),
                  label: const Text(
                    'Reset',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          // ── Dine In / Takeaway ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _OrderTypeButton(
                    label: 'Dine In',
                    icon: Icons.restaurant,
                    isSelected: cart.orderType == OrderType.dineIn,
                    onTap: () => ref
                        .read(cartProvider.notifier)
                        .setOrderType(OrderType.dineIn),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _OrderTypeButton(
                    label: 'Takeaway',
                    icon: Icons.local_mall_outlined,
                    isSelected: cart.orderType == OrderType.takeaway,
                    onTap: () => ref
                        .read(cartProvider.notifier)
                        .setOrderType(OrderType.takeaway),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),

          // ── Item list / empty state ─────────────────────────────────────
          Expanded(
            child: cart.items.isEmpty
                ? _buildEmptyState()
                : _buildItemList(ref, cart),
          ),

          // ── Payment summary ─────────────────────────────────────────────
          _buildPaymentPanel(context, ref, cart),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 52, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            'Keranjang kosong',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Pilih produk untuk\nmemulai pesanan',
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildItemList(WidgetRef ref, CartState cart) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: cart.items.length,
      itemBuilder: (context, index) {
        final item = cart.items[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        ref.read(cartProvider.notifier).removeItem(item.id),
                    child: Icon(
                      Icons.delete_outline,
                      color: Colors.red[300],
                      size: 17,
                    ),
                  ),
                ],
              ),
              Text(
                [
                  item.size,
                  if (item.sugarLevel.isNotEmpty) item.sugarLevel,
                ].join(' · '),
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
              if (item.note.isNotEmpty)
                Text(
                  '“${item.note}”',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formatRupiah(item.subtotal),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  // Quantity stepper
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () => ref
                              .read(cartProvider.notifier)
                              .decrementQuantity(item.id),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            child: Icon(
                              Icons.remove,
                              size: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        Text(
                          '${item.quantity}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.grey[800],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => ref
                              .read(cartProvider.notifier)
                              .incrementQuantity(item.id),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            child: Icon(
                              Icons.add,
                              size: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentPanel(
    BuildContext context,
    WidgetRef ref,
    CartState cart,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        children: [
          _summaryRow(
            'Sub Total',
            cart.items.isEmpty ? '-' : formatRupiah(cart.subtotal),
          ),
          _summaryRow(
            'Diskon',
            cart.discountAmount > 0
                ? '- ${formatRupiah(cart.discountAmount)}'
                : '-',
            valueColor: cart.discountAmount > 0 ? Colors.red : null,
          ),
          _summaryRow(
            'Pajak 11%',
            cart.items.isEmpty ? '-' : formatRupiah(cart.tax),
          ),
          const Divider(height: 16),
          _summaryRow(
            'Total Pembayaran',
            cart.items.isEmpty ? 'Rp 0' : formatRupiah(cart.total),
            isBold: true,
            fontSize: 14,
          ),
          const SizedBox(height: 12),
          // Discount button
          GestureDetector(
            onTap: cart.items.isEmpty
                ? null
                : () => _showDiscountDialog(context, ref, cart),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    cart.discountAmount > 0
                        ? 'Diskon: ${formatRupiah(cart.discountAmount)}'
                        : 'Tambah Diskon',
                    style: TextStyle(
                      fontSize: 12,
                      color: cart.discountAmount > 0
                          ? const Color(0xFF04291A)
                          : Colors.black54,
                      fontWeight: cart.discountAmount > 0
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Pay button
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: cart.items.isEmpty
                    ? Colors.grey[300]
                    : const Color(0xFF04291A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                elevation: 0,
              ),
              onPressed: cart.items.isEmpty
                  ? null
                  : () => _showPaymentDialog(context, ref, cart),
              child: Text(
                'Bayar Sekarang',
                style: TextStyle(
                  color: cart.items.isEmpty ? Colors.grey[500] : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Dine-in / Takeaway toggle button
// ──────────────────────────────────────────────────────────────────────────────
class _OrderTypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _OrderTypeButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF1F3F2) : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? const Color(0xFF04291A) : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? const Color(0xFF04291A) : Colors.grey,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF04291A) : Colors.grey,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Reusable summary row (used in panel + payment dialog)
// ──────────────────────────────────────────────────────────────────────────────
Widget _summaryRow(
  String label,
  String value, {
  bool isBold = false,
  double fontSize = 12,
  Color? valueColor,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: Colors.black54,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color:
                valueColor ??
                (isBold ? const Color(0xFF04291A) : Colors.black87),
          ),
        ),
      ],
    ),
  );
}
