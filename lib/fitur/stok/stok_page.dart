import 'package:flutter/material.dart';
import 'package:donatopia/widgets/custom_drawer.dart';

class DonatopiaColors {
  static const Color backgroundSoftTan = Color.fromARGB(255, 240, 229, 231); 
  static const Color primaryPink = Color(0xFFCC6073); // Pink Gelap/Warna Utama Card
  static const Color primaryText = Color(0xFF636363); // Teks gelap utama
  static const Color barBackgroundWhite = Color(0xFFFFFFFF);
  static const Color secondaryText = Color(0xFF999999); // Teks abu-abu sekunder
  static const Color softCardPink = Color.fromARGB(255, 255, 255, 255); 
  static const Color softTextPink = Color.fromARGB(255, 179, 93, 110); 
  static const Color statusAman = Color.fromARGB(255, 76, 175, 80); // Hijau
  static const Color statusRendah = Color.fromARGB(255, 255, 87, 34); 
  static const Color historyBackground = Color.fromARGB(255, 255, 206, 206); 
  static const Color historyTitle = primaryText;
  static const Color historySubText = Color(0xFF999999); 
  static const Color historyPinkLabel = Color.fromARGB(255, 234, 234, 234);
}

class StokProduk {
  final String namaProduk;
  final String kategori;
  final int stokSaatIni;
  final int stokMinimal;
  final String status;
  final Color statusColor;
  final Color categoryColor;
  final Color categoryTextColor;

  StokProduk({
    required this.namaProduk,
    required this.kategori,
    required this.stokSaatIni,
    required this.stokMinimal,
    required this.status,
    required this.statusColor,
    required this.categoryColor,
    required this.categoryTextColor,
  });
}

// Model untuk Riwayat Perubahan Stok
class RiwayatStok {
  final String produk;
  final String detail;
  final String waktu;
  final String label;

  RiwayatStok({required this.produk, required this.detail, required this.waktu, required this.label});
}

class StokBarangPage extends StatefulWidget {
  static const String routeName = '/stok';
  const StokBarangPage({super.key});

  @override
  State<StokBarangPage> createState() => _StokBarangPageState();
}

class _StokBarangPageState extends State<StokBarangPage> {
  
  // Data Stok Produk Real-Time
  final List<StokProduk> _stokProduk = [
    StokProduk(
      namaProduk: 'BLUEBERRY SLICE', kategori: 'DONAT TOPPING', stokSaatIni: 15, stokMinimal: 10, status: 'Aman', statusColor: DonatopiaColors.statusAman,
      categoryColor: DonatopiaColors.primaryPink.withOpacity(0.1), categoryTextColor: DonatopiaColors.primaryPink,
    ),
    StokProduk(
      namaProduk: 'SUNNY LEMON', kategori: 'DONAT TOPPING', stokSaatIni: 10, stokMinimal: 6, status: 'Aman', statusColor: DonatopiaColors.statusAman,
      categoryColor: DonatopiaColors.primaryPink.withOpacity(0.1), categoryTextColor: DonatopiaColors.primaryPink,
    ),
    StokProduk(
      namaProduk: 'PINK BITES', kategori: 'DONAT TOPPING', stokSaatIni: 5, stokMinimal: 6, status: 'Rendah', statusColor: DonatopiaColors.statusRendah,
      categoryColor: DonatopiaColors.primaryPink.withOpacity(0.1), categoryTextColor: DonatopiaColors.primaryPink,
    ),
    StokProduk(
      namaProduk: 'BLUE BITC', kategori: 'DONAT TOPPING', stokSaatIni: 9, stokMinimal: 8, status: 'Rendah', statusColor: DonatopiaColors.statusRendah,
      categoryColor: DonatopiaColors.primaryPink.withOpacity(0.1), categoryTextColor: DonatopiaColors.primaryPink,
    ),
    StokProduk(
      namaProduk: 'SUNNY CRISP', kategori: 'MINUMAN', stokSaatIni: 12, stokMinimal: 6, status: 'Aman', statusColor: DonatopiaColors.statusAman,
      categoryColor: Colors.blue.withOpacity(0.1), categoryTextColor: Colors.blue.shade800,
    ),
    StokProduk(
      namaProduk: 'CHOCO CRISP', kategori: 'MINUMAN', stokSaatIni: 16, stokMinimal: 15, status: 'Aman', statusColor: DonatopiaColors.statusAman,
      categoryColor: Colors.blue.withOpacity(0.1), categoryTextColor: Colors.blue.shade800,
    ),
    StokProduk(
      namaProduk: 'VANILLUSH', kategori: 'MINUMAN', stokSaatIni: 20, stokMinimal: 13, status: 'Aman', statusColor: DonatopiaColors.statusAman,
      categoryColor: Colors.blue.withOpacity(0.1), categoryTextColor: Colors.blue.shade800,
    ),
    StokProduk(
      namaProduk: 'NUT CRAVE', kategori: 'DONAT TOPPING', stokSaatIni: 25, stokMinimal: 15, status: 'Aman', statusColor: DonatopiaColors.statusAman,
      categoryColor: DonatopiaColors.primaryPink.withOpacity(0.1), categoryTextColor: DonatopiaColors.primaryPink,
    ),
  ];
  
  // Data Riwayat Perubahan Stok
  final List<RiwayatStok> _riwayatStok = [
    RiwayatStok(produk: 'NUT CRAVE', detail: 'Update: Dari 20 ke 25', waktu: 'Senin, 16 Mei 2025, 10:17', label: 'IN'),
    RiwayatStok(produk: 'CHOCO CRISP', detail: 'Penjualan: 1 pcs ke Pelanggan Umum', waktu: 'Senin, 16 Mei 2025, 10:15', label: 'OUT'),
    RiwayatStok(produk: 'SUNNY CRISP', detail: 'Penjualan: 1 pcs ke Member A001', waktu: 'Senin, 16 Mei 2025, 09:31', label: 'OUT'),
    RiwayatStok(produk: 'BLUEBERRY SLICE', detail: 'Update: Dari 10 ke 15', waktu: 'Senin, 16 Mei 2025, 09:30', label: 'IN'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DonatopiaColors.backgroundSoftTan,
    
      endDrawer: const CustomDrawer(currentRoute: StokBarangPage.routeName), 
      appBar: _buildAppBar(context),
      
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageTitleContainer(),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  _buildSummaryCards(),
                  const SizedBox(height: 30),
                  _buildRealTimeStockSection(),
                  
                  const SizedBox(height: 30),
                  _buildHistorySection(),
                  
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
PreferredSizeWidget _buildAppBar(BuildContext context) {
  return AppBar(
    backgroundColor: DonatopiaColors.barBackgroundWhite,
    automaticallyImplyLeading: false, 
    toolbarHeight: 70.0, 
    title: Row(
      children: [
        Image.asset(
          'assets/images/donatopia.png', 
          width: 48, 
          height: 48, 
        ),
        const SizedBox(width: 10),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Donatopia', 
              style: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.bold, 
                color: DonatopiaColors.primaryText
              )
            ),
            Text(
              'Stok', 
              style: TextStyle(
                fontSize: 14, 
                fontWeight: FontWeight.w400, 
                color: DonatopiaColors.secondaryText
              )
            ),
          ],
        ),
      ],
    ),
    actions: [
      // Icon Menu
      Builder(
        builder: (context) {
          return IconButton(
            icon: const Icon(Icons.menu, color: DonatopiaColors.secondaryText, size: 28),
            onPressed: () {
              Scaffold.of(context).openEndDrawer(); 
            },
          );
        }
      ),
      const SizedBox(width: 8),
    ],
    elevation: 0, 
  );
}
  Widget _buildPageTitleContainer() {
    return Container(
      width: double.infinity,
      color: DonatopiaColors.backgroundSoftTan, // Menggunakan warna background halaman
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 15.0, top: 5.0), // Padding disesuaikan
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stok Barang',
            style: TextStyle(
              fontSize: 24, 
              fontWeight: FontWeight.bold, 
              // Warna Teks Diubah Agar Kontras dengan backgroundSoftTan
              color: DonatopiaColors.primaryPink, 
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Pantau dan kelola stok',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400, 
              color: DonatopiaColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  // 3. Kartu Ringkasan Stok
  Widget _buildSummaryCards() {
    return Column(
      children: [
        _buildSummaryCard(
          title: 'Total Stok', 
          value: '406', 
          subtitle: '9 produk', 
          color: DonatopiaColors.softCardPink
        ),
        const SizedBox(height: 15),
        _buildSummaryCard(
          title: 'Stok Rendah', 
          value: '2', // Diperbarui dari data (_stokProduk)
          subtitle: '2 perlu restock', 
          color: DonatopiaColors.softCardPink
        ),
        const SizedBox(height: 15),
        _buildSummaryCard(
          title: 'Stok Aman', 
          value: '6', // Diperbarui dari data (_stokProduk)
          subtitle: '6 produk tersedia', 
          color: DonatopiaColors.softCardPink
        ),
      ],
    );
  }

  // Helper untuk Kartu Ringkasan
  Widget _buildSummaryCard({
    required String title, 
    required String value, 
    required String subtitle, 
    required Color color
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 40, 39, 39),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color.fromARGB(255, 46, 44, 44),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: DonatopiaColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealTimeStockSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Stok Produk Real-Time', 
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: DonatopiaColors.primaryText)
        ),
        const SizedBox(height: 10),
      
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: DonatopiaColors.barBackgroundWhite,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header Tabel
              _buildStockTableHeader(),
              const Divider(height: 0, color: DonatopiaColors.backgroundSoftTan),
              
              // Baris Data
              ..._stokProduk.map((produk) => _buildStockTableRow(produk)).toList(),
            ],
          ),
        ),
      ],
    );
  }
  Widget _buildStockTableHeader() {
    const TextStyle headerStyle = TextStyle(
      fontSize: 12, 
      fontWeight: FontWeight.bold, 
      color: DonatopiaColors.secondaryText,
    );
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text('Produk', style: headerStyle)),
          Expanded(flex: 2, child: Text('Kategori', style: headerStyle)),
          Expanded(flex: 1, child: Text('Stok Saat Ini', style: headerStyle, textAlign: TextAlign.center)),
          Expanded(flex: 1, child: Text('Stok Minimal', style: headerStyle, textAlign: TextAlign.center)),
          Expanded(flex: 1, child: Text('Kondisi', style: headerStyle, textAlign: TextAlign.center)),
          SizedBox(width: 30), // Untuk Icon Edit
        ],
      ),
    );
  }

  Widget _buildStockTableRow(StokProduk produk) {
    const TextStyle dataStyle = TextStyle(fontSize: 12, color: DonatopiaColors.primaryText);
    const TextStyle productStyle = TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: DonatopiaColors.primaryText);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(produk.namaProduk, style: productStyle)),
          Expanded(
            flex: 2, 
            child: Align(
              alignment: Alignment.centerLeft,
              child: _buildCategoryLabel(produk.kategori, produk.categoryColor, produk.categoryTextColor)
            )
          ),
          Expanded(flex: 1, child: Text('${produk.stokSaatIni}', style: dataStyle, textAlign: TextAlign.center)),
          Expanded(flex: 1, child: Text('${produk.stokMinimal}', style: dataStyle, textAlign: TextAlign.center)),
          Expanded(
            flex: 1, 
            child: Center(child: _buildStatusChip(produk.status, produk.statusColor))
          ),
          SizedBox(
            width: 30,
            child: IconButton(
              icon: const Icon(Icons.edit, size: 16, color: DonatopiaColors.primaryPink),
              onPressed: () {
                // Logika Edit
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildCategoryLabel(String label, Color background, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.bold,
          color: text,
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        status,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: DonatopiaColors.barBackgroundWhite,
        ),
      ),
    );
  }

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Riwayat Perubahan Stok', 
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: DonatopiaColors.primaryText)
        ),
        const SizedBox(height: 10),
        
        ..._riwayatStok.map((riwayat) => _buildHistoryItem(riwayat)).toList(),
      ],
    );
  }

  Widget _buildHistoryItem(RiwayatStok riwayat) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: DonatopiaColors.historyBackground,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  riwayat.produk,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: DonatopiaColors.historyTitle,
                  ),
                ),
                _buildHistoryLabel(riwayat.label),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              riwayat.detail,
              style: const TextStyle(
                fontSize: 14,
                color: DonatopiaColors.historySubText,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              riwayat.waktu,
              style: const TextStyle(
                fontSize: 12,
                color: DonatopiaColors.historySubText,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildHistoryLabel(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: DonatopiaColors.historyPinkLabel,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: DonatopiaColors.barBackgroundWhite,
        ),
      ),
    );
  }
}