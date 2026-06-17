import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/shift_provider.dart';
import '../utils/currency.dart';

/// Dashboard tab content — shows shift summary and cash/QRIS tracking.
class ShiftDashboard extends ConsumerWidget {
  final VoidCallback? onEndShift;

  const ShiftDashboard({super.key, this.onEndShift});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shiftState = ref.watch(shiftProvider);
    final shift = shiftState.activeShift;

    if (shift == null) {
      return const Center(
        child: Text(
          'Tidak ada shift aktif.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final salesCash = shift.expectedCash - shift.startingCash;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Ringkasan Shift',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const Spacer(),
              if (onEndShift != null)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  onPressed: onEndShift,
                  icon: const Icon(Icons.stop_circle_outlined, size: 16),
                  label: const Text(
                    'Akhiri Shift',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),

          // Stats cards row
          Row(
            children: [
              _StatCard(
                label: 'Orders',
                value: '${shift.orderCount}',
                icon: Icons.receipt_long_outlined,
              ),
              const SizedBox(width: 16),
              _StatCard(
                label: 'Penjualan Tunai',
                value: formatRupiah(salesCash),
                icon: Icons.payments_outlined,
              ),
              const SizedBox(width: 16),
              _StatCard(
                label: 'Penjualan QRIS',
                value: formatRupiah(shift.expectedQris),
                icon: Icons.qr_code_2_rounded,
              ),
              const SizedBox(width: 16),
              _StatCard(
                label: 'Total',
                value: formatRupiah(salesCash + shift.expectedQris),
                icon: Icons.attach_money_rounded,
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Reconciliation section
          const Text(
            'Rekonsiliasi',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          _ReconRow(
            label: 'Uang awal',
            value: formatRupiah(shift.startingCash),
          ),
          _ReconRow(label: 'Penjualan tunai', value: formatRupiah(salesCash)),
          _ReconRow(
            label: 'Seharusnya di kasir',
            value: formatRupiah(shift.expectedCash),
            bold: true,
          ),
          const SizedBox(height: 12),
          _ReconRow(
            label: 'Penjualan QRIS',
            value: formatRupiah(shift.expectedQris),
            bold: true,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF04291A), size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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

class _ReconRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _ReconRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
