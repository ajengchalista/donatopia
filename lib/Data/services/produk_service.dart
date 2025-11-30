import 'package:flutter/material.dart';

// Definisi warna Donatopia
class DonatopiaColors {
  // Warna soft pink dari background gambar (hex #F0E5E7)
  static const Color backgroundSoftPink = Color.fromARGB(255, 240, 229, 231);
  // Warna pink kemerahan untuk harga (Rp.) dari gambar (hex #CC6073)
  static const Color cardValueColor = Color(0xFFCC6073);
  // Warna pink sedang untuk FAB/Keranjang (hex #F48FB1)
  static const Color primaryPink = Color(0xFFF48FB1);
  // Warna teks gelap untuk "Dashboard"
  static const Color darkText = Color(0xFF636363);
  // Warna teks sekunder (Abu-abu) untuk hint text
  static const Color secondaryText = Color(0xFF999999);
  // Warna untuk Floating Cart Button, mirip headerPink pada gambar Anda
  static const Color floatingCartButtonColor = Color.fromARGB(255, 240, 153, 169);
  // Warna latar belakang putih untuk Bar Atas
  static const Color barBackgroundWhite = Color.fromARGB(255, 255, 255, 255);
  // Warna latar belakang search bar yang lebih terang/pucat dari soft pink
  static const Color searchBarBackground = Color.fromARGB(255, 255, 245, 246);
  // Warna pink muda baru untuk teks Donatopia (RGB 247, 178, 190)
  static const Color softPinkText = Color.fromRGBO(247, 178, 190, 1);
  
  // Memberi nilai pada headerTextColor untuk menghindari error
  static const Color headerTextColor = softPinkText;

  static var cardBackground;
}


class KasirPage extends StatelessWidget {
  const KasirPage({super.key});
  
  // DATA PRODUK
  final List<Map<String, dynamic>> donutProducts = const [
    {"name": "BLUEBERRY BLISS", "price": 23000, "image": "blueberry_bliss.png", "width": 80.0, "height": 90.0},
    {"name": "SUNNY LEMON", "price": 21000, "image": "sunny_lemon.png", "width": 80.0, "height": 50.0},
    {"name": "PINKSBITEZ", "price": 24000, "image": "pinksbitez.png", "width": 65.0, "height": 65.0},
    {"name": "BLUSH BITE", "price": 23000, "image": "blush_bite.png", "width": 55.0, "height": 55.0}, 
    {"name": "SUNNY CRISP", "price": 19000, "image": "sunny_crisp.png", "width": 48.0, "height": 48.0},
    {"name": "CHOCO DRIP", "price": 20000, "image": "choco_drop.png", "width": 62.0, "height": 62.0},
    {"name": "VANILLUSH", "price": 17000, "image": "vanillush.png", "width": 52.0, "height": 52.0}, 
    {"name": "NUT CRAVE", "price": 19000, "image": "nut_crave.png", "width": 58.0, "height": 58.0},
  ];

  // Helper untuk format harga (Rp. XXX.XXX)
  String _formatPrice(int price) {
    String priceStr = price.toString();
    String formatted = priceStr.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp. $formatted';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DonatopiaColors.backgroundSoftPink, 
      
      body: Stack(
        children: [
          Column(
            children: [
              // 1. WHITE HEADER CONTAINER
              Container(
                // Mengurangi padding bawah agar lebih ringkas seperti contoh
                padding: const EdgeInsets.fromLTRB(16.0, 45.0, 16.0, 5.0), 
                decoration: BoxDecoration(
                  color: DonatopiaColors.barBackgroundWhite, 
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: _buildHeader(), // Header/Logo/Menu
              ),
              
              // 2. SEARCH BAR
              Padding(
                // Menambahkan sedikit jarak dari header
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0), 
                child: _buildSearchBar(),
              ),

              // 3. PRODUCT GRID
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0, left: 16.0, right: 16.0),
                  child: GridView.builder(
                    padding: EdgeInsets.zero, 
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // 3 kolom
                      childAspectRatio: 0.80, 
                      crossAxisSpacing: 10, 
                      mainAxisSpacing: 10, 
                    ),
                    itemCount: donutProducts.length,
                    itemBuilder: (context, index) {
                      final product = donutProducts[index];
                      return _buildProductCard(
                        product['name'] as String,
                        product['price'] as int,
                        product['image'] as String,
                        product['width'] as double,
                        product['height'] as double,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          
          // Floating Action Button (Keranjang)
          _buildFloatingCartButton(),
        ],
      ),
    );
  }

  // --- Widget Pembantu ---

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center, // Pusatkan secara vertikal
          children: [
            // Logo Donatopia 
            Container(
              width: 45, 
              height: 45, 
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22.5), 
                color: DonatopiaColors.headerTextColor.withOpacity(0.1), // Pink sangat pucat
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'assets/images/donatopia.png', 
                    width: 90, // Diperbesar sedikit agar lebih jelas
                    height: 40,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10), 
            // Mengubah menjadi Stack untuk menumpuk teks dan memposisikannya lebih dekat
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // Mengatur jarak (spacing) vertikal lebih ketat
              mainAxisAlignment: MainAxisAlignment.center, 
              children: [
                const Text(
                  'Donatopia',
                  style: TextStyle(
                    // Warna pink muda
                    color: DonatopiaColors.softPinkText, 
                    fontSize: 18, // Ukuran teks Donatopia diperbesar
                    fontWeight: FontWeight.w800, 
                    height: 1.0, // Mengurangi jarak antar baris
                  ),
                ),
                const Text(
                  // PERUBAHAN: Mengubah teks 'Kasir' menjadi 'Dashboard'
                  'Dashboard', 
                  style: TextStyle(
                    fontSize: 12, 
                    color: DonatopiaColors.darkText, // Warna abu-abu gelap
                    height: 1.0, // Mengurangi jarak antar baris
                  ),
                ),
              ],
            ),
          ],
        ),
        // Icon Menu Toggle (Hamburger Icon)
        const Icon(Icons.menu, color: DonatopiaColors.darkText, size: 28), 
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3), 
      decoration: BoxDecoration(
        color: DonatopiaColors.searchBarBackground, 
        borderRadius: BorderRadius.circular(15), 
        border: Border.all(
          color: DonatopiaColors.secondaryText.withOpacity(0.4), 
          width: 1.0
        ), 
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Cari produk...',
          border: InputBorder.none,
          hintStyle: TextStyle(
            color: DonatopiaColors.secondaryText, 
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(Icons.search, color: DonatopiaColors.secondaryText, size: 20),
          prefixIconConstraints: BoxConstraints(minWidth: 35), 
        ),
      ),
    );
  }

  Widget _buildProductCard(String name, int price, String imageAsset, double width, double height) {
    String formattedPrice = _formatPrice(price); 
    
    final String fullImagePath = 'assets/images/donatopia.png';
    
    return GestureDetector(
      onTap: () {
        // Logika saat produk diklik
      },
      child: Container(
        padding: const EdgeInsets.all(3), 
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 253, 188, 188).withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            Container(
              width: width, 
              height: height, 
              margin: const EdgeInsets.only(bottom: 2), 
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10), 
                image: DecorationImage(
                  image: AssetImage(fullImagePath), 
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 8, 
                fontWeight: FontWeight.w700,
                color: DonatopiaColors.darkText,
                height: 1.1, 
              ),
            ),
            
            Text(
              formattedPrice,
              style: const TextStyle(
                fontSize: 7, 
                fontWeight: FontWeight.w500,
                color: DonatopiaColors.primaryPink, 
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFloatingCartButton() {
    return Positioned(
      bottom: 30, 
      right: 20, 
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: DonatopiaColors.primaryPink, 
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: DonatopiaColors.primaryPink.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent, 
          child: InkWell(
            onTap: () {
              // Logika saat tombol keranjang ditekan
            },
            child: const Center(
              child: Icon(
                Icons.shopping_cart, 
                color: Colors.white, 
                size: 28,
              ),
            ),
          ),
        ),
      ),
    );
  }
}