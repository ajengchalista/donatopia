import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:donatopia/widgets/custom_drawer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

final supabase = Supabase.instance.client;

class DonatopiaColors {
  static const Color primaryPink = Color(0xFFF48FB1);
  static const Color backgroundSoftPink = Color.fromARGB(255, 249, 244, 246);
  static const Color cardValueColor = Color(0xFFCC6073);
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

// ==================== MODEL ====================

class OrderItem {
  final String name;
  final int quantity;
  final int pricePerItem;

  OrderItem({
    required this.name,
    required this.quantity,
    required this.pricePerItem,
  });

  int get subtotal => quantity * pricePerItem;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      name: json['product_name'] as String? ?? 'Unknown Item',
      quantity: (json['quantity'] as int?) ?? 0,
      pricePerItem: (json['price_per_item'] as int?) ?? 0,
    );
  }
}

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
    this.discount = 0,
  });

  int get subtotal => items.fold(0, (sum, item) => sum + item.subtotal);
  int get total => subtotal - discount;

  factory CustomerHistory.fromJson(Map<String, dynamic> json) {
    final List<dynamic> itemsJson = json['transaksi_detail'] ?? [];
    final List<OrderItem> items = itemsJson
        .map((item) => OrderItem(
              name: item['produk']?['nama'] ?? 'Unknown Item',
              quantity: item['jumlah'] ?? 0,
              pricePerItem: (item['harga'] ?? 0).toInt(),
            ))
        .toList();

    String formattedTime = 'N/A';
    if (json['created_at'] != null) {
      final dateTime = DateTime.parse(json['created_at'].toString()).toLocal();
      formattedTime = DateFormat('HH:mm').format(dateTime);
    }

    return CustomerHistory(
      id: json['id'].toString(),
      name: json['pelanggan']?['nama_pelanggan'] ?? 'Tanpa Nama',
      transactionTime: formattedTime,
      items: items,
      discount: (json['diskon'] as int?) ?? 0,
    );
  }
}

class Pelanggan {
  final int id;
  final String nama;
  final String? noTelepon;
  final String? alamat;
  final String? email;

  Pelanggan({
    required this.id,
    required this.nama,
    this.noTelepon,
    this.alamat,
    this.email,
  });

  factory Pelanggan.fromJson(Map<String, dynamic> json) {
    return Pelanggan(
      id: json['id'] as int,
      nama: json['nama_pelanggan'] as String? ?? 'Tanpa Nama',
      noTelepon: json['no_telepon'] as String?,
      alamat: json['alamat'] as String?,
      email: json['email'] as String?,
    );
  }
}

// ==================== MAIN PAGE ====================

class PelangganPage extends StatefulWidget {
  static const String routeName = '/pelanggan';
  const PelangganPage({super.key});

  @override
  State<PelangganPage> createState() => _PelangganPageState();
}

class _PelangganPageState extends State<PelangganPage> {
  String _searchText = '';
  List<CustomerHistory>? _customerHistory;
  List<Pelanggan> _daftarPelanggan = [];
  bool _isLoading = true;
  bool _isLoadingPelanggan = true;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final StreamSubscription<List<Map<String, dynamic>>> _transactionsSubscription;

  @override
  void initState() {
    super.initState();
    _fetchCustomerHistory();
    _fetchDaftarPelanggan();
    _setupRealtimeListener();
  }

  @override
  void dispose() {
    _transactionsSubscription.cancel();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // ==================== FETCH DATA ====================

  Future<void> _fetchDaftarPelanggan() async {
    setState(() => _isLoadingPelanggan = true);
    try {
      final response = await supabase
          .from('pelanggan')
          .select('id, nama_pelanggan, no_telepon, alamat, email')
          .order('nama_pelanggan', ascending: true);

      final list = (response as List<dynamic>)
          .map((e) => Pelanggan.fromJson(e as Map<String, dynamic>))
          .toList();

      setState(() {
        _daftarPelanggan = list;
        _isLoadingPelanggan = false;
      });
    } catch (e) {
      debugPrint('Error fetch pelanggan: $e');
      setState(() => _isLoadingPelanggan = false);
    }
  }

  Future<void> _fetchCustomerHistory() async {
    setState(() => _isLoading = true);
    try {
      final response = await supabase
          .from('transaksi')
          .select('''
          id, created_at, diskon,
          pelanggan ( nama_pelanggan ),
          transaksi_detail ( jumlah, harga, produk ( nama ) )
        ''')
          .order('created_at', ascending: false);

      final List<CustomerHistory> data = (response as List<dynamic>)
          .map((json) => CustomerHistory.fromJson(json))
          .toList();

      setState(() {
        _customerHistory = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetch history: $e');
      setState(() {
        _isLoading = false;
        _customerHistory = [];
      });
    }
  }

  void _setupRealtimeListener() {
    _transactionsSubscription = supabase
        .from('transaksi')
        .stream(primaryKey: ['id'])
        .listen((_) => _fetchCustomerHistory());
  }

  // ==================== CRUD PELANGGAN ====================

  Future<void> _addPelangganBaru() async {
    final nama = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final alamat = _addressController.text.trim();
    final email = _emailController.text.trim();

    if (nama.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama wajib diisi')),
      );
      return;
    }

    setState(() => _isLoadingPelanggan = true);
    try {
      await supabase.from('pelanggan').insert({
        'nama_pelanggan': nama,
        if (phone.isNotEmpty) 'no_telepon': phone,
        if (alamat.isNotEmpty) 'alamat': alamat,
        if (email.isNotEmpty) 'email': email,
      });
      await _fetchDaftarPelanggan();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pelanggan "$nama" berhasil ditambahkan')),
        );
      }
    } catch (e) {
      debugPrint('Error tambah pelanggan: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menambah pelanggan')),
        );
      }
    } finally {
      setState(() => _isLoadingPelanggan = false);
    }
  }

  Future<void> _updateNamaPelanggan(int id, String newName) async {
    if (newName.trim().isEmpty) return;
    try {
      await supabase
          .from('pelanggan')
          .update({'nama_pelanggan': newName.trim()})
          .eq('id', id);

      await _fetchDaftarPelanggan();
      await _fetchCustomerHistory();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nama pelanggan diperbarui')),
        );
      }
    } catch (e) {
      debugPrint('Error update nama pelanggan: $e');
    }
  }

  Future<void> _hapusPelanggan(int pelangganId, String nama) async {
    setState(() => _isLoadingPelanggan = true);
    try {
      await supabase.from('pelanggan').delete().eq('id', pelangganId);
      await _fetchDaftarPelanggan();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pelanggan "$nama" dihapus'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error hapus pelanggan: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menghapus pelanggan')),
        );
      }
    } finally {
      setState(() => _isLoadingPelanggan = false);
    }
  }

  // ==================== UTILS ====================

  String _formatPrice(int price) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp. ',
      decimalDigits: 0,
    );
    return format.format(price).replaceAll(',', '.');
  }

  List<CustomerHistory> get _filteredCustomerHistory {
    if (_customerHistory == null || _searchText.isEmpty)
      return _customerHistory ?? [];
    final lower = _searchText.toLowerCase();
    return _customerHistory!
        .where((h) => h.name.toLowerCase().contains(lower))
        .toList();
  }

  // ==================== MODAL (Dengan Telepon, Alamat, Email) ====================

  void _showAddCustomerModal(BuildContext context) {
    _nameController.clear();
    _phoneController.clear();
    _addressController.clear();
    _emailController.clear();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'Tambah Pelanggan Baru',
          style: TextStyle(color: DonatopiaColors.cardValueColor),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Nama pelanggan *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: 'No. Telepon (opsional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Email (opsional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _addressController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'Alamat (opsional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: DonatopiaColors.primaryPink,
            ),
            onPressed: () {
              _addPelangganBaru();
              Navigator.pop(ctx);
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditCustomerModal(BuildContext context, CustomerHistory history) {
    _nameController.text = history.name;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'Ubah Nama Pelanggan',
          style: TextStyle(color: DonatopiaColors.cardValueColor),
        ),
        content: TextField(
          controller: _nameController,
          decoration: const InputDecoration(hintText: 'Nama baru'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: DonatopiaColors.primaryPink,
            ),
            onPressed: () {
              final newName = _nameController.text.trim();
              if (newName.isNotEmpty && newName != history.name) {
                // Hanya update nama (karena edit dari history)
                supabase
                    .from('pelanggan')
                    .update({'nama_pelanggan': newName})
                    .eq('nama_pelanggan', history.name);
                _fetchCustomerHistory();
                _fetchDaftarPelanggan();
              }
              Navigator.pop(ctx);
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ==================== BUILD (UI TETAP SAMA) ====================

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _customerHistory == null) {
      return const Scaffold(
        backgroundColor: DonatopiaColors.backgroundSoftPink,
        body: Center(
          child: CircularProgressIndicator(color: DonatopiaColors.primaryPink),
        ),
      );
    }

    final filteredHistory = _filteredCustomerHistory;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: DonatopiaColors.backgroundSoftPink,
      endDrawer: const CustomDrawer(currentRoute: PelangganPage.routeName),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // HEADER
              Container(
                padding: const EdgeInsets.fromLTRB(16, 45, 16, 10),
                decoration: const BoxDecoration(
                  color: DonatopiaColors.barBackgroundWhite,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: _buildHeader(context),
              ),

              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildCustomerTitle(),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildSearchBar(),
              ),
              const SizedBox(height: 20),

              // DAFTAR PELANGGAN (Hanya nama tetap ditampilkan)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Daftar Nama Pelanggan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: DonatopiaColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _isLoadingPelanggan
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: DonatopiaColors.primaryPink,
                            ),
                          )
                        : _daftarPelanggan.isEmpty
                            ? const Text(
                                'Belum ada pelanggan.',
                                style: TextStyle(color: DonatopiaColors.secondaryText),
                              )
                            : Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: _daftarPelanggan.map((pel) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: DonatopiaColors.searchBarBackground,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(pel.nama),
                                        const SizedBox(width: 6),
                                        GestureDetector(
                                          onTap: () {
                                            final ctrl = TextEditingController(text: pel.nama);
                                            showDialog(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                title: const Text('Edit Nama Pelanggan'),
                                                content: TextField(controller: ctrl),
                                                actions: [
                                                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
                                                  ElevatedButton(
                                                    style: ElevatedButton.styleFrom(backgroundColor: DonatopiaColors.primaryPink),
                                                    onPressed: () {
                                                      if (ctrl.text.trim().isNotEmpty) {
                                                        _updateNamaPelanggan(pel.id, ctrl.text.trim());
                                                      }
                                                      Navigator.pop(ctx);
                                                    },
                                                    child: const Text('Simpan', style: TextStyle(color: Colors.white)),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                          child: const Icon(Icons.edit, size: 18),
                                        ),
                                        const SizedBox(width: 6),
                                        GestureDetector(
                                          onTap: () => _hapusPelanggan(pel.id, pel.nama),
                                          child: const Icon(Icons.delete, color: Colors.redAccent, size: 18),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // RIWAYAT TRANSAKSI (TETAP SAMA)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Riwayat Transaksi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: DonatopiaColors.darkText,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: filteredHistory.isEmpty && !_isLoading
                    ? const Center(child: Text('Tidak ada riwayat transaksi.'))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredHistory.length,
                        itemBuilder: (_, i) => _buildCustomerHistoryCard(filteredHistory[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== WIDGETS (TIDAK BERUBAH) ====================

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: DonatopiaColors.primaryPink.withOpacity(0.1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Image.asset('assets/images/donatopia.png', fit: BoxFit.contain),
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Donatopia', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: DonatopiaColors.cardValueColor)),
                Text('Pelanggan', style: TextStyle(fontSize: 14, color: DonatopiaColors.secondaryText)),
              ],
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.menu, color: DonatopiaColors.darkText, size: 28),
          onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
        ),
      ],
    );
  }

  Widget _buildCustomerTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pelanggan', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: DonatopiaColors.customerTitleColor)),
            Text('${_daftarPelanggan.length} Pelanggan', style: const TextStyle(color: DonatopiaColors.secondaryText)),
          ],
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: DonatopiaColors.addButtonColor, borderRadius: BorderRadius.circular(10)),
          child: IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showAddCustomerModal(context),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: DonatopiaColors.searchBarBackground,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: DonatopiaColors.secondaryText.withOpacity(0.4)),
      ),
      child: TextField(
        onChanged: (v) => setState(() => _searchText = v),
        decoration: const InputDecoration(
          hintText: 'Cari pelanggan...',
          border: InputBorder.none,
          hintStyle: TextStyle(color: DonatopiaColors.secondaryText),
          prefixIcon: Icon(Icons.search, color: DonatopiaColors.secondaryText),
        ),
      ),
    );
  }

  Widget _buildCustomerHistoryCard(CustomerHistory history) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: DonatopiaColors.softHistoryBackground,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: DonatopiaColors.primaryPink.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(history.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: DonatopiaColors.darkText)),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18, color: DonatopiaColors.secondaryText),
                    onPressed: () => _showEditCustomerModal(context, history),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                    onPressed: () => _showDeleteTransactionConfirmation(context, history),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  Text(history.transactionTime, style: const TextStyle(color: DonatopiaColors.secondaryText)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text('Pesanan :', style: TextStyle(fontWeight: FontWeight.w600, color: DonatopiaColors.darkText)),
          const SizedBox(height: 5),
          ...history.items.map((item) => Padding(
                padding: const EdgeInsets.only(left: 10, bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(child: Text('• ${item.name} ${item.quantity}x', style: const TextStyle(color: DonatopiaColors.darkText))),
                    Text(_formatPrice(item.pricePerItem), style: const TextStyle(color: DonatopiaColors.darkText)),
                  ],
                ),
              )),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: DonatopiaColors.softHistoryTotalBackground, borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: [
                _buildTotalRow('Subtotal', history.subtotal, DonatopiaColors.darkText),
                _buildTotalRow('Disc', history.discount, DonatopiaColors.cardValueColor),
                _buildTotalRow('Total', history.total, DonatopiaColors.darkText, isBold: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, int value, Color color, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$label :', style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color)),
          Text(_formatPrice(value), style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color)),
        ],
      ),
    );
  }

  void _showDeleteTransactionConfirmation(BuildContext context, CustomerHistory history) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Hapus Transaksi?'),
        content: Text('Yakin ingin menghapus transaksi atas nama "${history.name}" pukul ${history.transactionTime}?\n\nData akan hilang selamanya.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              supabase.from('transaksi').delete().eq('id', history.id);
              _fetchCustomerHistory();
              Navigator.pop(ctx);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}