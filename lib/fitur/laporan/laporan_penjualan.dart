import 'package:flutter/material.dart';
import 'package:donatopia/widgets/custom_drawer.dart'; 

class DonatopiaColors {
  static const Color backgroundSoftPink = Color.fromARGB(255, 240, 229, 231); 
  static const Color primaryPink = Color(0xFFCC6073); 
  static const Color primaryText = Color(0xFF636363); 
  static const Color barBackgroundWhite = Color(0xFFFFFFFF); 
  static const Color secondaryText = Color(0xFF999999); 
  static const Color softCardPink = Color.fromARGB(255, 255, 235, 237);
  static const Color softTextPink = Color.fromARGB(255, 179, 93, 110);

  static const Color rankCardBackground = Color.fromARGB(255, 255, 248, 248);
  static const Color rankCardShadow = Color.fromARGB(255, 245, 235, 237);
  static const Color rankPink = Color(0xFFCC6073);
  static const Color rankSubText = Color(0xFF999999);

  static const Color transactionDetailBackground = Color.fromARGB(255, 250, 222, 227);
}

class ProductSales {
  final int rank;
  final String name;
  final int sold;
  final String revenue;

  const ProductSales({required this.rank, required this.name, required this.sold, required this.revenue});
}

class LaporanPenjualanPage extends StatefulWidget {
  static const String routeName = '/laporan';
  const LaporanPenjualanPage({super.key});

  @override
  State<LaporanPenjualanPage> createState() => _LaporanPenjualanPageState();
}

class _LaporanPenjualanPageState extends State<LaporanPenjualanPage> {
  String _selectedPeriode = 'Harian (hari ini)';
  String _selectedProduk = 'Semua Produk';
  String _selectedPelanggan = 'Semua Pelanggan';

  final List<ProductSales> _topProducts = const [
    ProductSales(rank: 1, name: 'VANILLUSH', sold: 5, revenue: 'Rp. 153.000'),
    ProductSales(rank: 2, name: 'SUNNY LEMON', sold: 4, revenue: 'Rp. 126.000'),
    ProductSales(rank: 3, name: 'PINK BITES', sold: 2, revenue: 'Rp. 96.000'),
    ProductSales(rank: 3, name: 'NUT CRAVE', sold: 2, revenue: 'Rp. 38.000'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DonatopiaColors.backgroundSoftPink,
      // 🚀 PERUBAHAN 1: Hapus komentar pada endDrawer
      endDrawer: const CustomDrawer(currentRoute: LaporanPenjualanPage.routeName), 
      
      body: Column(
        children: [
          // 1. HEADER
          Container(
            padding: const EdgeInsets.fromLTRB(16.0, 45.0, 16.0, 10.0),
            decoration: _buildHeaderDecoration(),
            child: _buildHeader(context),
          ),
          
          // 2. KONTEN UTAMA
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul Halaman
                  _buildPageTitle(),
                  
                  const SizedBox(height: 20),
                  
                  // Filter Section (DIBUNGKUS CARD PUTIH)
                  _buildFilterSection(),
                  
                  const SizedBox(height: 20),
                  
                  // Kartu Ringkasan (DIBUNGKUS CARD PUTIH)
                  _buildSummaryCards(),
                  
                  const SizedBox(height: 30),
                  
                  // Produk Terlaris
                  _buildTopProductsSection(),

                  const SizedBox(height: 30),
                  
                  // Detail Transaksi
                  _buildTransactionDetail(),
                  
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER ---
  
  BoxDecoration _buildHeaderDecoration() {
    return BoxDecoration(
      color: DonatopiaColors.barBackgroundWhite,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          spreadRadius: 1,
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  // Header (Logo, Nama, Menu, Tombol Download)
  Widget _buildHeader(BuildContext context) {
    return Builder(
      builder: (innerContext) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                // Logo (sudah diubah ke Image.asset)
                Container(
                  width: 48,
                  height: 48,
                  margin: const EdgeInsets.only(left: 4.0),
                  child: Image.asset(
                    'assets/images/donatopia.png', // Path Gambar
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback jika gambar tidak ditemukan
                      return const Icon(Icons.shopping_cart, color: DonatopiaColors.primaryPink, size: 28);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Donatopia', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: DonatopiaColors.primaryPink)),
                    Text('Laporan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: DonatopiaColors.secondaryText)),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                // Tombol Download
                IconButton(
                  icon: const Icon(Icons.download, color: DonatopiaColors.primaryPink, size: 28),
                  onPressed: () {},
                ),
                // Tombol Menu
                // 🚀 PERUBAHAN 2: Tombol ini memanggil openEndDrawer() untuk membuka CustomDrawer.
                IconButton(
                  icon: const Icon(Icons.menu, color: DonatopiaColors.primaryText, size: 28),
                  onPressed: () {
                    Scaffold.of(innerContext).openEndDrawer(); 
                  },
                ),
              ],
            ),
          ],
        );
      }
    );
  }

  // Judul Halaman
  Widget _buildPageTitle() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Laporan Penjualan',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: DonatopiaColors.primaryPink,
          ),
        ),
        Text(
          'Analisis Hari Ini',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: DonatopiaColors.secondaryText,
          ),
        ),
      ],
    );
  }

  // 3. Filter Section (Dibungkus Card Putih)
  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: DonatopiaColors.barBackgroundWhite, 
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Laporan Penjualan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: DonatopiaColors.primaryText)),
          const SizedBox(height: 10),
          _buildDropdownFilter('Periode', _selectedPeriode, ['Harian (hari ini)', 'Mingguan', 'Bulanan'], (newValue) {
            setState(() => _selectedPeriode = newValue!);
          }),
          _buildDropdownFilter('Produk', _selectedProduk, ['Semua Produk', 'BLUEBERRY BLISS', 'SUNNY LEMON', 'PINKSBITEZ', 'BLUSH BITE', 'SUNNY CRISP', 'CHOCO DRIP', 'VANILLUSH', 'NUT CRAVE', ''], (newValue) {
            setState(() => _selectedProduk = newValue!);
          }),
          _buildDropdownFilter('Pelanggan', _selectedPelanggan, ['Semua Pelanggan', 'Cimi', 'Caca'], (newValue) {
            setState(() => _selectedPelanggan = newValue!);
          }),
        ],
      ),
    );
  }

  // Helper untuk Dropdown Filter
  Widget _buildDropdownFilter(String label, String currentValue, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        Text(label, style: const TextStyle(fontSize: 14, color: DonatopiaColors.secondaryText)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          decoration: BoxDecoration(
            color: DonatopiaColors.softCardPink, 
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: DonatopiaColors.softCardPink),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: currentValue,
              icon: const Icon(Icons.arrow_drop_down, color: DonatopiaColors.primaryText),
              isExpanded: true,
              style: const TextStyle(fontSize: 16, color: DonatopiaColors.primaryText),
              dropdownColor: DonatopiaColors.barBackgroundWhite,
              items: items.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  // 4. Kartu Ringkasan (Dibungkus Card Putih)
  Widget _buildSummaryCards() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: DonatopiaColors.barBackgroundWhite, 
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSummaryCard(
            label: 'Total Penjualan',
            value: 'Rp. 413.000',
          ),
          const SizedBox(height: 10),
          _buildSummaryCard(
            label: 'Total Item',
            value: '22',
          ),
          const SizedBox(height: 10),
          _buildSummaryCard(
            label: 'Transaksi',
            value: '22',
          ),
        ],
      ),
    );
  }

  // Helper untuk Kartu Ringkasan
  Widget _buildSummaryCard({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: DonatopiaColors.softCardPink,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: DonatopiaColors.softTextPink,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: DonatopiaColors.softTextPink,
            ),
          ),
        ],
      ),
    );
  }

  // 5. Produk Terlaris
  Widget _buildTopProductsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Produk Terlaris', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: DonatopiaColors.primaryText)),
        const SizedBox(height: 10),
        ..._topProducts.map((product) {
          return _buildTopProductItem(product);
        }).toList(),
      ],
    );
  }

  // Helper untuk Item Produk Terlaris
  Widget _buildTopProductItem(ProductSales product) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: DonatopiaColors.rankCardBackground,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: DonatopiaColors.rankCardShadow,
              spreadRadius: 0,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Ranking Circle
            Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                color: DonatopiaColors.rankPink,
                borderRadius: BorderRadius.circular(15),
              ),
              alignment: Alignment.center,
              child: Text(
                '${product.rank}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            const SizedBox(width: 15),
            // Nama Produk & Terjual
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: DonatopiaColors.primaryText),
                  ),
                  Text(
                    '${product.sold} terjual',
                    style: const TextStyle(fontSize: 12, color: DonatopiaColors.rankSubText),
                  ),
                ],
              ),
            ),
            // Pendapatan
            Text(
              product.revenue,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: DonatopiaColors.rankPink),
            ),
          ],
        ),
      ),
    );
  }

  // 6. Detail Transaksi
  Widget _buildTransactionDetail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Detail Transaksi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: DonatopiaColors.primaryText)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: DonatopiaColors.transactionDetailBackground,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TRX2025101600855B',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: DonatopiaColors.primaryText),
                  ),
                  _TransactionChip(label: 'Debit', color: DonatopiaColors.rankPink),
                ],
              ),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tunai', style: TextStyle(fontSize: 14, color: DonatopiaColors.secondaryText)),
                  Text('09:15', style: TextStyle(fontSize: 14, color: DonatopiaColors.secondaryText)),
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}

// Widget kecil untuk chip transaksi
class _TransactionChip extends StatelessWidget {
  final String label;
  final Color color;

  const _TransactionChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}