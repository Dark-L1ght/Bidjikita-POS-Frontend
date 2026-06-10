import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/receipt.dart';
import '../providers/cart_provider.dart';
import '../services/receipt_printer.dart';
import '../utils/currency.dart';

class CartPanel extends ConsumerWidget {
  const CartPanel({super.key});

  // ──────────────────────────────────────────────────────────────────────────
  // Payment method selection
  // ──────────────────────────────────────────────────────────────────────────
  void _showPaymentMethodDialog(
    BuildContext context,
    WidgetRef ref,
    CartState cart,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 380,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pilih Metode Pembayaran',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: const Icon(
                      Icons.close,
                      size: 20,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Total amount
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF5F0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Pembayaran',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    Text(
                      formatRupiah(cart.total),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF04291A),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Payment method cards
              Row(
                children: [
                  Expanded(
                    child: _PaymentMethodCard(
                      icon: Icons.qr_code_2_rounded,
                      label: 'QRIS',
                      sublabel: 'Scan kode QR',
                      onTap: () {
                        Navigator.pop(ctx);
                        _showQrisDialog(context, ref, cart);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PaymentMethodCard(
                      icon: Icons.payments_outlined,
                      label: 'Tunai',
                      sublabel: 'Uang kas',
                      onTap: () {
                        Navigator.pop(ctx);
                        _showCashDialog(context, ref, cart);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // QRIS dialog
  // ──────────────────────────────────────────────────────────────────────────
  void _showQrisDialog(BuildContext context, WidgetRef ref, CartState cart) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 380,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      _showPaymentMethodDialog(context, ref, cart);
                    },
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      size: 20,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Pembayaran QRIS',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: const Icon(
                      Icons.close,
                      size: 20,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Total
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF5F0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      'Total Pembayaran',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatRupiah(cart.total),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF04291A),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // QRIS code
              // ── TO ADD YOUR QRIS IMAGE ────────────────────────────────
              // 1. Place your file at:  assets/images/qris_code.png
              // 2. Register it in pubspec.yaml under flutter → assets
              // 3. Replace the Container below with:
              //    Image.asset('assets/images/qris_code.png', width: 200, height: 200)
              // ─────────────────────────────────────────────────────────
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.qr_code_2_rounded,
                      size: 80,
                      color: Color(0xFF04291A),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bidjikita Coffee Roastery',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tambahkan qris_code.png\nke assets/images/',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[400], fontSize: 9),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Scan kode QR di atas dengan aplikasi pembayaran',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
              const SizedBox(height: 20),
              // Confirm button
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
                    final receipt = _buildReceiptData(cart, 'QRIS');
                    ref.read(cartProvider.notifier).clearCart();
                    Navigator.pop(ctx);
                    _showReceiptDialog(context, receipt);
                  },
                  icon: const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 18,
                  ),
                  label: const Text(
                    'Konfirmasi Pembayaran',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Cash dialog with custom numpad
  // ──────────────────────────────────────────────────────────────────────────
  void _showCashDialog(BuildContext context, WidgetRef ref, CartState cart) {
    String cashStr = '0';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final cashAmount = int.tryParse(cashStr) ?? 0;
          final change = cashAmount - cart.total;
          final canConfirm = cashAmount >= cart.total;

          // ── Quick denomination suggestions ────────────────────────────
          final List<int> quickAmounts = [cart.total];
          for (final d in [50000, 100000, 150000, 200000, 500000]) {
            if (d > cart.total) quickAmounts.add(d);
            if (quickAmounts.length >= 4) break;
          }

          // ── Numpad input handlers ─────────────────────────────────────
          void pressDigit(String d) => setDialogState(() {
            cashStr = cashStr == '0' ? d : cashStr + d;
          });

          void press000() => setDialogState(() {
            if (cashStr != '0') cashStr += '000';
          });

          void pressBackspace() => setDialogState(() {
            cashStr = cashStr.length > 1
                ? cashStr.substring(0, cashStr.length - 1)
                : '0';
          });

          return Dialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 160,
              vertical: 20,
            ),
            child: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Header ───────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(ctx);
                            _showPaymentMethodDialog(context, ref, cart);
                          },
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            size: 20,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.payments_outlined,
                          size: 18,
                          color: Color(0xFF04291A),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Pembayaran Tunai',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: const Icon(
                            Icons.close,
                            size: 20,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Order total ─────────────────────────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Pesanan',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                formatRupiah(cart.total),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF04291A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // ── Cash amount display ──────────────────────
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: cashAmount > 0
                                    ? const Color(0xFF04291A)
                                    : Colors.grey[300]!,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Uang Diterima',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[500],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  cashAmount == 0
                                      ? 'Rp 0'
                                      : formatRupiah(cashAmount),
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // ── Quick amount buttons ─────────────────────
                          Row(
                            children: quickAmounts.map((amount) {
                              final isExact = amount == cart.total;
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: GestureDetector(
                                    onTap: () => setDialogState(
                                      () => cashStr = amount.toString(),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isExact
                                            ? const Color(0xFFEBF5F0)
                                            : const Color(0xFFF5F5F5),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: isExact
                                              ? const Color(0xFF04291A)
                                              : Colors.grey[300]!,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          if (isExact)
                                            Text(
                                              'Pas',
                                              style: TextStyle(
                                                fontSize: 9,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          Text(
                                            _shortRupiah(amount),
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: isExact
                                                  ? const Color(0xFF04291A)
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),

                          // ── Numpad ────────────────────────────────────
                          _buildNumpad(
                            pressDigit: pressDigit,
                            press000: press000,
                            pressBackspace: pressBackspace,
                          ),
                          const SizedBox(height: 16),

                          // ── Change ────────────────────────────────────
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: canConfirm
                                  ? const Color(0xFFEBF5F0)
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Kembalian',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  canConfirm
                                      ? formatRupiah(change)
                                      : 'Kurang ${formatRupiah(-change)}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: canConfirm
                                        ? const Color(0xFF04291A)
                                        : Colors.red[400],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // ── Confirm button ────────────────────────────
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: canConfirm
                                    ? const Color(0xFF04291A)
                                    : Colors.grey[300],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              onPressed: canConfirm
                                  ? () {
                                      final receipt = _buildReceiptData(
                                        cart,
                                        'Tunai',
                                        cashReceived: cashAmount,
                                        change: change,
                                      );
                                      ref
                                          .read(cartProvider.notifier)
                                          .clearCart();
                                      Navigator.pop(ctx);
                                      _showReceiptDialog(context, receipt);
                                    }
                                  : null,
                              icon: Icon(
                                Icons.check_circle_outline_rounded,
                                size: 18,
                                color: canConfirm
                                    ? Colors.white
                                    : Colors.grey[500],
                              ),
                              label: Text(
                                'Konfirmasi Pembayaran',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: canConfirm
                                      ? Colors.white
                                      : Colors.grey[500],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNumpad({
    required void Function(String) pressDigit,
    required VoidCallback press000,
    required VoidCallback pressBackspace,
  }) {
    final rows = [
      ['7', '8', '9'],
      ['4', '5', '6'],
      ['1', '2', '3'],
      ['000', '0', '⌫'],
    ];

    return Column(
      children: rows.map((row) {
        return Row(
          children: row.map((key) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: _NumpadKey(
                  label: key,
                  onTap: () {
                    if (key == '⌫') {
                      pressBackspace();
                    } else if (key == '000') {
                      press000();
                    } else {
                      pressDigit(key);
                    }
                  },
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Receipt dialog + preview
  // ──────────────────────────────────────────────────────────────────────────
  ReceiptData _buildReceiptData(
    CartState cart,
    String paymentMethod, {
    int cashReceived = 0,
    int change = 0,
  }) {
    return ReceiptData(
      orderId: _generateOrderId(),
      dateTime: DateTime.now(),
      orderType: cart.orderType == OrderType.dineIn ? 'Dine In' : 'Takeaway',
      items: List.from(cart.items),
      subtotal: cart.subtotal,
      tax: cart.tax,
      total: cart.total,
      paymentMethod: paymentMethod,
      cashReceived: cashReceived,
      change: change,
    );
  }

  void _showReceiptDialog(BuildContext context, ReceiptData receipt) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Success header ──────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 24,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFF04291A),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pembayaran Berhasil!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${receipt.paymentMethod}  ·  ${formatRupiah(receipt.total)}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Receipt preview ─────────────────────────────────────
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _buildReceiptPreview(receipt),
                ),
              ),

              // ── Action buttons ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text(
                          'Selesai',
                          style: TextStyle(color: Colors.black87),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF04291A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                        onPressed: () {
                          ReceiptPrinter.print(receipt);
                          Navigator.pop(ctx);
                        },
                        icon: const Icon(Icons.print_rounded, size: 18),
                        label: const Text(
                          'Cetak Struk',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptPreview(ReceiptData receipt) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAF7),
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'BIDJIKITA COFFEE ROASTERY',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Jl. Coffee Street No. 1, Jakarta',
            style: TextStyle(color: Colors.grey[600], fontSize: 10),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Colors.black26),
          const SizedBox(height: 4),
          _previewRow('No. Pesanan', receipt.orderId),
          _previewRow('Tanggal', _receiptFmtDate(receipt.dateTime)),
          _previewRow('Kasir', receipt.cashierName),
          _previewRow('Tipe', receipt.orderType),
          const SizedBox(height: 4),
          const Divider(height: 1, color: Colors.black26),
          const SizedBox(height: 4),
          // Items
          ...receipt.items.expand<Widget>((item) {
            return [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${item.quantity}×  ${item.product.name}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    formatRupiah(item.subtotal),
                    style: const TextStyle(fontSize: 11),
                  ),
                ],
              ),
              if (item.size != 'Regular')
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 14),
                    child: Text(
                      [
                        item.size,
                        if (item.sugarLevel.isNotEmpty) item.sugarLevel,
                      ].join(' · '),
                      style: TextStyle(fontSize: 9, color: Colors.grey[500]),
                    ),
                  ),
                ),
              if (item.note.isNotEmpty)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 14),
                    child: Text(
                      '"${item.note}"',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
            ];
          }),
          const SizedBox(height: 4),
          const Divider(height: 1, color: Colors.black26),
          const SizedBox(height: 4),
          _previewRow('Subtotal', formatRupiah(receipt.subtotal)),
          _previewRow('Pajak 11%', formatRupiah(receipt.tax)),
          const SizedBox(height: 4),
          Container(height: 1.5, color: Colors.black87),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TOTAL',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              Text(
                formatRupiah(receipt.total),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Color(0xFF04291A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(height: 1.5, color: Colors.black87),
          const SizedBox(height: 6),
          _previewRow('Pembayaran', receipt.paymentMethod),
          if (receipt.paymentMethod == 'Tunai') ...[
            _previewRow('Diterima', formatRupiah(receipt.cashReceived)),
            _previewRow('Kembalian', formatRupiah(receipt.change)),
          ],
          const SizedBox(height: 8),
          const Divider(height: 1, color: Colors.black26),
          const SizedBox(height: 6),
          Text(
            'Terima kasih atas kunjungan Anda!',
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
          Text(
            'Selamat menikmati minuman Anda :)',
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
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
          // ── Header ──────────────────────────────────────────────────
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

          // ── Dine In / Takeaway ────────────────────────────────────────
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

          // ── Item list / empty state ──────────────────────────────────
          Expanded(
            child: cart.items.isEmpty
                ? _buildEmptyState()
                : _buildItemList(ref, cart),
          ),

          // ── Payment summary ──────────────────────────────────────────
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
                  '"${item.note}"',
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
          const SizedBox(height: 14),
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
                  : () => _showPaymentMethodDialog(context, ref, cart),
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
// Payment method card
// ──────────────────────────────────────────────────────────────────────────────
class _PaymentMethodCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final VoidCallback onTap;

  const _PaymentMethodCard({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEBF5F0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 28, color: const Color(0xFF04291A)),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sublabel,
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Custom numpad key
// ──────────────────────────────────────────────────────────────────────────────
class _NumpadKey extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _NumpadKey({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isBackspace = label == '⌫';
    return Material(
      color: isBackspace ? const Color(0xFFFFEBEB) : const Color(0xFFF5F5F5),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: SizedBox(
          height: 52,
          child: Center(
            child: isBackspace
                ? Icon(
                    Icons.backspace_outlined,
                    size: 20,
                    color: Colors.red[400],
                  )
                : Text(
                    label,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
          ),
        ),
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
// Helpers
// ──────────────────────────────────────────────────────────────────────────────

// ──────────────────────────────────────────────────────────────────────────────
// Receipt preview helpers
// ──────────────────────────────────────────────────────────────────────────────

Widget _previewRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 1.5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.black54),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 10, color: Colors.black87),
        ),
      ],
    ),
  );
}

String _generateOrderId() {
  final now = DateTime.now();
  final ms = (now.millisecondsSinceEpoch % 10000).toString().padLeft(4, '0');
  return '#${now.year.toString().substring(2)}'
      '${now.month.toString().padLeft(2, '0')}'
      '${now.day.toString().padLeft(2, '0')}-$ms';
}

String _receiptFmtDate(DateTime dt) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '${dt.day} ${months[dt.month - 1]} ${dt.year}  $h:$m';
}

/// Compact Rupiah label for the quick-amount buttons, e.g. "Rp 100K".
String _shortRupiah(int amount) {
  if (amount >= 1000000) return 'Rp ${(amount / 1000000).toStringAsFixed(0)}Jt';
  if (amount >= 1000) return 'Rp ${(amount / 1000).toStringAsFixed(0)}K';
  return formatRupiah(amount);
}

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
