import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart'; // <--- TAMBAHKAN INI UNTUK MENGGUNAKAN WIDGET IMAGE
import 'package:intl/intl.dart';
// PASTIKAN PATH INI BENAR
import 'package:donatopia/widgets/custom_drawer.dart'; 

// ----------------------------------------------------
// Definisi Warna (Tetap)
// ----------------------------------------------------
class DonatopiaColors {
  static const Color backgroundSoftPink = Color.fromARGB(255, 249, 244, 246);
  static const Color cardValueColor = Color(0xFFCC6073); // Pink Gelap
  static const Color primaryPink = Color(0xFFF48FB1); // Pink Primer
  static const Color darkText = Color(0xFF636363);
  static const Color secondaryText = Color(0xFF999999);
  static const Color barBackgroundWhite = Color(0xFFFFFFFF);
  static const Color searchBarBackground = Color.fromARGB(255, 255, 245, 246);
  static const Color softPinkText = Color.fromRGBO(247, 178, 190, 1);
  static const Color softHistoryBackground = Color.fromARGB(255, 250, 235, 237);
  static const Color softHistoryTotalBackground = Color.fromARGB(255, 247, 219, 224);
  static const Color headerTextColor = softPinkText;
  static const Color customerTitleColor = cardValueColor;
  static const Color addButtonColor = primaryPink;
}

// ----------------------------------------------------
// Model untuk Data Pesanan dalam Riwayat (Tetap)
// ----------------------------------------------------
class OrderItem {
  final String name;
  final int quantity;
  final int pricePerItem;

  OrderItem({required this.name, required this.quantity, required this.pricePerItem});

  int get subtotal => quantity * pricePerItem;
}

// ----------------------------------------------------
// Model untuk Riwayat Pelanggan (Tetap)
// ----------------------------------------------------
class CustomerHistory {
  final String id;
  final String name;
  final String transactionTime;
  final List<OrderItem> items;
  final int discount;

  CustomerHistory({
    required this.id,
    required this.name,
    required this.transactionTime,
    required this.items,
    this.discount = 4000,
  });

  int get subtotal {
    return items.fold(0, (sum, item) => sum + item.subtotal);
  }

  int get total => subtotal - discount;
}


// ----------------------------------------------------
// 1. StatefulWidget PelangganPage
// ----------------------------------------------------
class PelangganPage extends StatefulWidget {
  // 💡 PERBAIKAN: Definisikan routeName sesuai kebutuhan CustomDrawer
  static const String routeName = '/pelanggan';

  const PelangganPage({super.key});

  @override
  State<PelangganPage> createState() => _PelangganPageState();
}

class _PelangganPageState extends State<PelangganPage> {
  String _searchText = '';
  late List<CustomerHistory> _customerHistory;

  @override
  void initState() {
    super.initState();
    // Data Simulasi (Tetap)
    _customerHistory = [
      CustomerHistory(
        id: 'c1',
        name: 'Chaca',
        transactionTime: '09.15',
        items: [
          OrderItem(name: 'PINKSBITEZ', quantity: 1, pricePerItem: 24000),
          OrderItem(name: 'VANILLUSH', quantity: 1, pricePerItem: 17000),
        ],
        discount: 4000,
      ),
      CustomerHistory(
        id: 'c2',
        name: 'Ziah Clara',
        transactionTime: '08.18',
        items: [
          OrderItem(name: 'BLUEBERRY BLISS', quantity: 1, pricePerItem: 23000),
          OrderItem(name: 'SUNNY LEMON', quantity: 1, pricePerItem: 21000),
        ],
        discount: 4000,
      ),
      CustomerHistory(
        id: 'c3',
        name: 'Agustine Erlyna',
        transactionTime: '08.13',
        items: [
          OrderItem(name: 'BLUEBERRY BLISS', quantity: 3, pricePerItem: 23000),
        ],
        discount: 4000,
      ),
      CustomerHistory(
        id: 'c4',
        name: 'Ariza Salsadil',
        transactionTime: '08.13',
        items: [
          OrderItem(name: 'CHOCO DRIP', quantity: 2, pricePerItem: 20000),
          OrderItem(name: 'SUNNY CRISP', quantity: 1, pricePerItem: 19000),
        ],
        discount: 5000,
      ),
    ];
  }

  // Helper untuk format harga (Tetap)
  String _formatPrice(int price) {
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0);
    return format.format(price).replaceAll('.', ',');
  }

  // LOGIKA PEMFILTERAN (Tetap)
  List<CustomerHistory> get _filteredCustomerHistory {
    if (_searchText.isEmpty) {
      return _customerHistory;
    }

    final searchLower = _searchText.toLowerCase();
    return _customerHistory.where((history) {
      return history.name.toLowerCase().contains(searchLower);
    }).toList();
  }
  
  // ----------------------------------------------------
  // 2. Metode build()
  // ----------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final filteredHistory = _filteredCustomerHistory;
    final totalCustomers = _customerHistory.length;

    return Scaffold(
      backgroundColor: DonatopiaColors.backgroundSoftPink,
      
      // 💡 PERBAIKAN: Ganti _buildSidebar() dengan CustomDrawer
      endDrawer: const CustomDrawer(currentRoute: PelangganPage.routeName), 
      
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. WHITE HEADER CONTAINER
          Container(
            padding: const EdgeInsets.fromLTRB(16.0, 45.0, 16.0, 10.0),
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
            // Header menggunakan Builder agar IconButton dapat mengakses Scaffold.of(context)
            child: Builder( 
              builder: (scaffoldContext) => _buildHeader(scaffoldContext),
            ),
          ),
          
          // 2. CUSTOMER TITLE & ADD BUTTON
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 15.0, 16.0, 10.0),
            child: _buildCustomerTitle(totalCustomers),
          ),
          
          // 3. SEARCH BAR PELANGGAN
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 15.0),
            child: _buildSearchBar(), 
          ),

          // 4. JUDUL RIWAYAT PELANGGAN
          const Padding(
            padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 10.0),
            child: Text(
              'Riwayat Pelanggan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: DonatopiaColors.darkText,
              ),
            ),
          ),

          // 5. RIWAYAT PELANGGAN (Expanded ListView)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: filteredHistory.length,
              itemBuilder: (context, index) {
                return _buildCustomerHistoryCard(filteredHistory[index]);
              },
            ),
          ),
        ],
      ),
      // 8. FUNGSI PLACEHOLDER MODAL TAMBAH PELANGGAN (diletakkan di luar build)
    );
  }

  // ----------------------------------------------------
  // 3. WIDGET HEADER (Modifikasi Icon Cart)
  // ----------------------------------------------------
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // Ikon Cart (Keranjang Belanja) - DIGANTI DENGAN IMAGE.ASSET
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: DonatopiaColors.primaryPink.withOpacity(0.1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0), // Padding untuk memastikan logo terlihat bagus di dalam Container
                child: Image.asset(
                  'assets/images/donatopia.png', // <--- PATH GAMBAR DONATOPIA
                  fit: BoxFit.contain,
                ),
              ),
              // Kode asli yang diganti:
              // child: const Icon(Icons.shopping_cart_outlined, color: DonatopiaColors.cardValueColor, size: 24),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Donatopia',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: DonatopiaColors.cardValueColor,
                  ),
                ),
                Text(
                  'Pelanggan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: DonatopiaColors.secondaryText,
                  ),
                ),
              ],
            ),
          ],
        ),
        
        // Ikon Menu/Sidebar
        // Catatan: Context di sini adalah context dari Builder di atas, 
        // sehingga Scaffold.of(context) dapat bekerja.
        IconButton(
          icon: const Icon(Icons.menu, color: DonatopiaColors.darkText, size: 28),
          onPressed: () {
            Scaffold.of(context).openEndDrawer(); // Membuka EndDrawer (Sidebar)
          },
        ),
      ],
    );
  }

  // ----------------------------------------------------
  // 4. WIDGET TITLE & ADD BUTTON (Tetap)
  // ----------------------------------------------------
  Widget _buildCustomerTitle(int totalCustomers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pelanggan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: DonatopiaColors.customerTitleColor,
              ),
            ),
            Text(
              '$totalCustomers Pelanggan',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: DonatopiaColors.secondaryText,
              ),
            ),
          ],
        ),
        
        // Tombol Add (+)
        Container(
          width: 40, 
          height: 40,
          decoration: BoxDecoration(
            color: DonatopiaColors.addButtonColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            icon: const Icon(Icons.add, color: Colors.white, size: 24),
            onPressed: () {
              _showAddCustomerModal(context);
            },
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------
  // 5. WIDGET SEARCH BAR (Tetap)
  // ----------------------------------------------------
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: DonatopiaColors.searchBarBackground,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: DonatopiaColors.secondaryText.withOpacity(0.4), width: 1.0),
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchText = value;
          });
        },
        decoration: const InputDecoration(
          hintText: 'Cari pelanggan...',
          border: InputBorder.none,
          hintStyle: TextStyle(color: DonatopiaColors.secondaryText, fontSize: 14, fontWeight: FontWeight.w400),
          prefixIcon: Icon(Icons.search, color: DonatopiaColors.secondaryText, size: 20),
          prefixIconConstraints: BoxConstraints(minWidth: 35),
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // 6. WIDGET HISTORY CARD (Tetap)
  // ----------------------------------------------------
  Widget _buildCustomerHistoryCard(CustomerHistory history) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: DonatopiaColors.softHistoryBackground,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: DonatopiaColors.primaryPink.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nama Pelanggan & Edit/Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                history.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: DonatopiaColors.darkText,
                ),
              ),
              Row(
                children: [
                  // Ikon Edit (simulasi)
                  const Icon(Icons.edit, color: DonatopiaColors.secondaryText, size: 16),
                  const SizedBox(width: 5),
                  // Waktu Transaksi
                  Text(
                    history.transactionTime,
                    style: const TextStyle(
                      fontSize: 14,
                      color: DonatopiaColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Detail Pesanan
          const Text(
            'Pesanan :',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: DonatopiaColors.darkText,
            ),
          ),
          const SizedBox(height: 5),

          // Daftar Item Pesanan
          ...history.items.map((item) => Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama Item & Kuantitas
                Flexible(
                  child: Text(
                    '• ${item.name} ${item.quantity}x',
                    style: const TextStyle(fontSize: 14, color: DonatopiaColors.darkText, height: 1.5),
                  ),
                ),
                // Harga Satuan/Per Item
                Text(
                  _formatPrice(item.pricePerItem),
                  style: const TextStyle(fontSize: 14, color: DonatopiaColors.darkText),
                ),
              ],
            ),
          )).toList(),

          const SizedBox(height: 10),

          // Box Subtotal, Diskon, Total
          Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: DonatopiaColors.softHistoryTotalBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                // Subtotal
                _buildTotalRow('Subtotal', history.subtotal, DonatopiaColors.darkText),
                // Diskon
                _buildTotalRow('Disc', history.discount, DonatopiaColors.cardValueColor),
                // Total
                _buildTotalRow('Total', history.total, DonatopiaColors.darkText),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Widget Pembantu untuk Baris Total (Tetap)
  Widget _buildTotalRow(String label, int value, Color color) {
    final isTotal = label == 'Total';
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label :',
            style: TextStyle(
              fontSize: 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
          Text(
            _formatPrice(value),
            style: TextStyle(
              fontSize: 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // 7. WIDGET SIDEBAR (FUNGSI INI DIHAPUS, DIGANTIKAN CUSTOMDRAWER)
  // ----------------------------------------------------
  // FUNGSI _buildSidebar() YANG LAMA SUDAH DIHAPUS DARI SINI
  // ----------------------------------------------------
  
  // ----------------------------------------------------
  // 8. FUNGSI PLACEHOLDER MODAL TAMBAH PELANGGAN (Tetap)
  // ----------------------------------------------------
  void _showAddCustomerModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('Tambah Pelanggan Baru'),
          content: const Text('Fungsi ini akan membuka formulir untuk menambahkan data pelanggan baru.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(), 
              child: const Text('Tutup', style: TextStyle(color: DonatopiaColors.primaryPink)),
            ),
          ],
        );
      },
    );
  }
}