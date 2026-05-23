import 'package:flutter/material.dart';
import '../widgets/catalog_panel.dart';
import '../widgets/cart_panel.dart';

class PosDashboardScreen extends StatelessWidget {
  const PosDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      // 1. TOP APP BAR (Header Utama)
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70,
        title: Row(
          children: [
            // Logo & Nama Brand
            const Icon(Icons.eco, color: Color(0xFF04291A)), // Representasi logo daun/biji
            const SizedBox(width: 8),
            const Text(
              'Bidjikita Coffee Roastery',
              style: TextStyle(color: Color(0xFF04291A), fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const Spacer(),
            
            // Tab Menu & Dashboard di tengah kanan
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F3F2),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF04291A),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text('Menu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Dashboard', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            
            // Tombol Aksi (Refresh, Notifikasi)
            IconButton(icon: const Icon(Icons.refresh, color: Colors.black54), onPressed: () {}),
            IconButton(icon: const Icon(Icons.notifications_none, color: Colors.black54), onPressed: () {}),
            const SizedBox(width: 12),
            
            // Profil Kasir
            const Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Nabil', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('Kasir Utama', style: TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Color(0xFFEAEAEA),
                  child: Icon(Icons.person, color: Colors.grey),
                )
              ],
            )
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey[200], height: 1),
        ),
      ),
      
      // 2. BODY LAYOUT (Split Screen)
      body: const Row(
        children: [
          // Sisi Kiri: Filter Kategori & Grid Menu (Porsi 3/4 Layar)
          Expanded(
            flex: 3,
            child: CatalogPanel(),
          ),
          
          // Sisi Kanan: Detail Pesanan / Keranjang (Porsi 1/4 Layar)
          Expanded(
            flex: 1,
            child: CartPanel(),
          ),
        ],
      ),
    );
  }
}