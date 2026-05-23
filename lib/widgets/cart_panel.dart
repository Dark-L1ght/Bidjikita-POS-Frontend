import 'package:flutter/material.dart';

class CartPanel extends StatelessWidget {
  const CartPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // -> FIXED: Memindahkan warna dan border ke dalam BoxDecoration
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Judul Pesanan
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.shopping_bag_outlined, color: Colors.black87, size: 20),
                    SizedBox(width: 8),
                    Text('Detail Pesanan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.layers_clear_outlined, size: 14, color: Colors.red),
                  label: const Text('Reset', style: TextStyle(color: Colors.red, fontSize: 12)),
                )
              ],
            ),
          ),

          // Tombol Dine-In / Takeaway
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF04291A)),
                      backgroundColor: const Color(0xFFF1F3F2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.restaurant, size: 14, color: Color(0xFF04291A)),
                    label: const Text('Dine In', style: TextStyle(color: Color(0xFF04291A), fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.local_mall_outlined, size: 14, color: Colors.grey),
                    label: const Text('Takeaway', style: TextStyle(color: Colors.grey, fontSize: 11)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),

          // Daftar Item di Keranjang Belanja
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
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
                          const Text('Almond Amore', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Icon(Icons.delete_outline, color: Colors.red[300], size: 16),
                        ],
                      ),
                      const Text('Ukuran: Kecil | Gula: Normal', style: TextStyle(color: Colors.grey, fontSize: 11)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Rp 96.000', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          // Counter Plus Minus
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              children: [
                                const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.remove, size: 14, color: Colors.black54)),
                                Text('2', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey[800])),
                                const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.add, size: 14, color: Colors.black54)),
                              ],
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),

          // Panel Rincian Pembayaran
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Column(
              children: [
                _buildRowRingkasan('Sub Total', 'Rp 96.000', isBold: false),
                _buildRowRingkasan('Diskon', '0', isBold: false, valueColor: Colors.red),
                _buildRowRingkasan('Pajak 11%', 'Rp 10.560', isBold: false),
                const Divider(),
                _buildRowRingkasan('Total Pembayaran', 'Rp 106.560', isBold: true, fontSize: 14),
                const SizedBox(height: 12),
                
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tambah Diskon', style: TextStyle(fontSize: 12, color: Colors.black54)),
                      Icon(Icons.chevron_right, size: 16, color: Colors.black54),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Tombol Aksi Utama
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 45,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF04291A),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            elevation: 0,
                          ),
                          onPressed: () {},
                          child: const Text('Bayar Sekarang', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 45,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey[300]!),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          onPressed: () {},
                          child: const Text(
                            'Tagihan Terbuka', 
                            style: TextStyle(color: Colors.black87, fontSize: 10, fontWeight: FontWeight.w600), 
                            textAlign: TextAlign.center, // -> FIXED: TextAlign.center
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRowRingkasan(String label, String value, {required bool isBold, double fontSize = 12, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: fontSize, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: Colors.black54)),
          Text(value, style: TextStyle(fontSize: fontSize, fontWeight: isBold ? FontWeight.bold : FontWeight.w600, color: valueColor ?? (isBold ? const Color(0xFF04291A) : Colors.black87))),
        ],
      ),
    );
  }
}