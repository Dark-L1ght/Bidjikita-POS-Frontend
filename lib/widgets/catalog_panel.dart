import 'package:flutter/material.dart';

class CatalogPanel extends StatelessWidget {
  const CatalogPanel({super.key});

  // ==========================================
  // FUNCTION POPUP: MURNI DETAIL INFORMASI PRODUK
  // ==========================================
  void _showProductDetail(BuildContext context, Map<String, String> produk) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 480, // Lebar popup proporsional untuk tablet
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER: Judul & Tombol Close
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Detail Product', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.black, size: 30),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // INFO UTAMA: Gambar, Nama, Harga
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
                        child: const Icon(Icons.coffee, color: Colors.white, size: 50),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(produk['nama']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(produk['harga']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // DESKRIPSI
                  const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  const Text(
                    'French Vanilla Fantasy is a smooth blend of coffee with a distinctive sweet vanilla touch. Combining rich coffee flavors...',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 20),

                  // BAHAN-BAHAN
                  const Text('Ingredients', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  const Text('• High-quality Arabica coffee\n• Natural vanilla extract\n• Fine granulated sugar', 
                    style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5)),
                  const SizedBox(height: 20),

                  // TINGKAT KAFEIN
                  const Text('Caffeine Level', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  const Text('Moderate', style: TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 20),

                  // REVISI: PACKAGE SIZE SEBAGAI INFORMASI TEKS BUKAN BUTTON
                  const Text('Package Size', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  const Text('Small (Hot), Medium (Ice), Large (Ice)', style: TextStyle(color: Colors.grey, fontSize: 14)),
                  
                  // NOTE: Tombol "Add to Cart" sudah dihapus sepenuhnya dari sini
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final kategori = ['Semua', 'Kopi', 'Non-kopi', 'Makanan', 'Snack'];
    
    final List<Map<String, String>> produkList = [
      {'nama': 'French Vanilla Fantasy', 'harga': 'Rp 42.000'},
      {'nama': 'Almond Amore', 'harga': 'Rp 48.000'},
      {'nama': 'Raspberry Ripple', 'harga': 'Rp 38.000'},
      {'nama': 'Cinnamon Swirl', 'harga': 'Rp 35.000'},
      {'nama': 'White Chocolate Wonder', 'harga': 'Rp 45.000'},
      {'nama': 'Dark Roast Dynamite', 'harga': 'Rp 32.000'},
      {'nama': 'Irish Cream Infusion', 'harga': 'Rp 52.000'},
      {'nama': 'Decaf Delight', 'harga': 'Rp 30.000'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kategori Selector
          SizedBox(
            height: 35,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: kategori.length,
              itemBuilder: (context, index) {
                bool isSelected = index == 0;
                return Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected ? const Color(0xFF04291A) : const Color(0xFFEAEAEA),
                      foregroundColor: isSelected ? Colors.white : Colors.black87,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    onPressed: () {},
                    child: Text(kategori[index], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          
          // Grid Produk
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.82,
              ),
              itemCount: produkList.length,
              itemBuilder: (context, index) {
                final prod = produkList[index];
                
                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _showProductDetail(context, prod),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Gambar Produk
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
                        // Detail Informasi Teks
                        Padding(
                          padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      prod['nama']!,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      prod['harga']!,
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.black87),
                                    ),
                                  ],
                                ),
                              ),
                              // Tombol Tambah (+)
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF04291A),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.add, color: Colors.white, size: 18),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}