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
  static const Color softHistoryBackground = Color.fromARGB(255, 250, 235, 237);
  static const Color softHistoryTotalBackground = Color.fromARGB(255, 247, 219, 224);
  static const Color addButtonColor = primaryPink;
}

// ==================== MODEL ====================
class OrderItem {
  final String name;
  final int quantity;
  final int pricePerItem;
  OrderItem({required this.name, required this.quantity, required this.pricePerItem});
  int get subtotal => quantity * pricePerItem;
}

class CustomerHistory {
  final String id;
  final int pelangganId;
  final String name;
  final String transactionTime;
  final List<OrderItem> items;
  final int discount;

  CustomerHistory({
    required this.id,
    required this.pelangganId,
    required this.name,
    required this.transactionTime,
    required this.items,
    this.discount = 0,
  });

  int get subtotal => items.fold(0, (sum, item) => sum + item.subtotal);
  int get total => subtotal - discount;
}

class Pelanggan {
  final int id;
  final String nama;
  final int? noTelepon;
  final String? alamat;
  final String? email;

  Pelanggan({required this.id, required this.nama, this.noTelepon, this.alamat, this.email});

  factory Pelanggan.fromJson(Map<String, dynamic> json) {
    return Pelanggan(
      id: json['id'] as int,
      nama: json['nama_pelanggan'] as String? ?? 'Tanpa Nama',
      noTelepon: json["nomor telepon"] as int?,
      alamat: json['alamat'] as String?,
      email: json['email'] as String?,
    );
  }
}

// ==================== MAIN PAGE ====================
class PelangganPage extends StatefulWidget {
  static const String routeName = '/pelanggan';
  const PelangganPage({super.key});
  @override State<PelangganPage> createState() => _PelangganPageState();
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
  late final StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _fetchCustomerHistory();
    _fetchDaftarPelanggan();
    _setupRealtime();
  }

  @override
  void dispose() {
    _subscription.cancel();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _fetchDaftarPelanggan() async {
    setState(() => _isLoadingPelanggan = true);
    try {
      final response = await supabase
          .from('pelanggan')
          .select('id, nama_pelanggan, "nomor telepon", alamat, email')
          .order('nama_pelanggan', ascending: true);

      final list = (response as List).map((e) => Pelanggan.fromJson(e)).toList();
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
            id, created_at, diskon, pelanggan_id,
            pelanggan ( id, nama_pelanggan ),
            transaksi_detail ( jumlah, harga, produk ( nama ) )
          ''')
          .order('created_at', ascending: false);

      final List<CustomerHistory> data = (response as List).map((json) {
        final itemsJson = json['transaksi_detail'] as List? ?? [];
        final items = itemsJson.map((i) => OrderItem(
              name: i['produk']?['nama'] ?? 'Unknown',
              quantity: i['jumlah'] ?? 0,
              pricePerItem: (i['harga'] ?? 0).toInt(),
            )).toList();

        final time = json['created_at'] != null
            ? DateFormat('HH:mm').format(DateTime.parse(json['created_at']).toLocal())
            : 'N/A';

        return CustomerHistory(
          id: json['id'].toString(),
          pelangganId: (json['pelanggan_id'] as num?)?.toInt() ?? 0,
          name: json['pelanggan']?['nama_pelanggan'] ?? 'Tanpa Nama',
          transactionTime: time,
          items: items,
          discount: (json['diskon'] as int?) ?? 0,
        );
      }).toList();

      setState(() {
        _customerHistory = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error history: $e');
      setState(() {
        _isLoading = false;
        _customerHistory = [];
      });
    }
  }

  void _setupRealtime() {
    _subscription = supabase
        .from('transaksi')
        .stream(primaryKey: ['id'])
        .listen((_) => _fetchCustomerHistory());
  }

  // ==================== TAMBAH PELANGGAN ====================
  Future<void> _addPelangganBaru() async {
    final nama = _nameController.text.trim();
    final phoneStr = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final alamat = _addressController.text.trim();

    try {
      await supabase.from('pelanggan').insert({
        'nama_pelanggan': nama,
        "nomor telepon": int.tryParse(phoneStr),
        'email': email.isEmpty ? null : email,
        if (alamat.isNotEmpty) 'alamat': alamat,
      });

      _nameController.clear();
      _phoneController.clear();
      _emailController.clear();
      _addressController.clear();

      _fetchDaftarPelanggan();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.green, content: Text('Pelanggan "$nama" berhasil ditambahkan!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: Colors.red, content: Text('Gagal menyimpan pelanggan')),
      );
    }
  }

  // ==================== MODAL TAMBAH PELANGGAN (DESAIN BARU) ====================
  void _showAddCustomerModal() {
    _nameController.clear();
    _phoneController.clear();
    _emailController.clear();
    _addressController.clear();

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: DonatopiaColors.backgroundSoftPink,
        title: const Text(
          'Tambah Pelanggan Baru',
          style: TextStyle(color: DonatopiaColors.cardValueColor, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  const Text('Nama', style: TextStyle(fontWeight: FontWeight.w600, color: DonatopiaColors.darkText)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Masukkan nama pelanggan',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    validator: (v) => v!.trim().isEmpty ? 'Nama wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),

                  const Text('No. Telepon', style: TextStyle(fontWeight: FontWeight.w600, color: DonatopiaColors.darkText)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'Contoh: 085712345678',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    validator: (v) {
                      if (v!.trim().isEmpty) return 'No. Telepon wajib diisi';
                      if (!RegExp(r'^[0-9]+$').hasMatch(v!)) return 'Hanya boleh angka';
                      if (v.length < 8) return 'Minimal 8 digit';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  const Text('Email', style: TextStyle(fontWeight: FontWeight.w600, color: DonatopiaColors.darkText)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'contoh@gmail.com',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    validator: (v) {
                      if (v!.trim().isEmpty) return 'Email wajib diisi';
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v!)) return 'Format email tidak valid';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  const Text('Alamat', style: TextStyle(fontWeight: FontWeight.w600, color: DonatopiaColors.darkText)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _addressController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Opsional',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal', style: TextStyle(color: DonatopiaColors.darkText))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: DonatopiaColors.primaryPink,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                _addPelangganBaru();
              }
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ==================== MODAL EDIT PELANGGAN (DESAIN SESUAI GAMBAR) ====================
  void _showEditPelangganModal(Pelanggan pel) {
    _nameController.text = pel.nama;
    _phoneController.text = pel.noTelepon?.toString() ?? '';
    _emailController.text = pel.email ?? '';
    _addressController.text = pel.alamat ?? '';

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: DonatopiaColors.backgroundSoftPink,
        title: const Text(
          'Edit Data Pelanggan',
          style: TextStyle(color: DonatopiaColors.cardValueColor, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  const Text('Nama', style: TextStyle(fontWeight: FontWeight.w600, color: DonatopiaColors.darkText)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Masukkan nama pelanggan',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    validator: (v) => v!.trim().isEmpty ? 'Nama wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),

                  const Text('No. Telepon', style: TextStyle(fontWeight: FontWeight.w600, color: DonatopiaColors.darkText)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'Contoh: 085712345678',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    validator: (v) {
                      if (v!.trim().isEmpty) return 'No. Telepon wajib diisi';
                      if (!RegExp(r'^[0-9]+$').hasMatch(v)) return 'Hanya boleh angka';
                      if (v.length < 8) return 'Minimal 8 digit';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  const Text('Email', style: TextStyle(fontWeight: FontWeight.w600, color: DonatopiaColors.darkText)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'contoh@gmail.com',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    validator: (v) {
                      if (v!.trim().isEmpty) return 'Email wajib diisi';
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v!)) return 'Format email tidak valid';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  const Text('Alamat', style: TextStyle(fontWeight: FontWeight.w600, color: DonatopiaColors.darkText)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _addressController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Opsional',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal', style: TextStyle(color: DonatopiaColors.darkText))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: DonatopiaColors.primaryPink,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            ),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                await supabase.from('pelanggan').update({
                  'nama_pelanggan': _nameController.text.trim(),
                  "nomor telepon": _phoneController.text.trim().isEmpty ? null : int.parse(_phoneController.text.trim()),
                  'email': _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
                  if (_addressController.text.trim().isNotEmpty) 'alamat': _addressController.text.trim(),
                }).eq('id', pel.id);

                _fetchDaftarPelanggan();
                _fetchCustomerHistory();
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data pelanggan diperbarui!'), backgroundColor: Colors.green),
                );
              }
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ==================== HAPUS PELANGGAN ====================
  Future<void> _hapusPelanggan(int id, String nama) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Pelanggan?'),
        content: Text('Yakin hapus pelanggan "$nama"?\nTransaksi tetap tersimpan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );

    if (confirm == true) {
      await supabase.from('pelanggan').delete().eq('id', id);
      _fetchDaftarPelanggan();
      _fetchCustomerHistory();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pelanggan "$nama" dihapus')));
    }
  }

  String _formatPrice(int price) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0).format(price).replaceAll(',', '.');
  }

  List<CustomerHistory> get _filteredHistory {
    if (_customerHistory == null || _searchText.isEmpty) return _customerHistory ?? [];
    return _customerHistory!.where((h) => h.name.toLowerCase().contains(_searchText.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _customerHistory == null) {
      return const Scaffold(backgroundColor: DonatopiaColors.backgroundSoftPink, body: Center(child: CircularProgressIndicator(color: DonatopiaColors.primaryPink)));
    }

    final filteredHistory = _filteredHistory;

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
                decoration: const BoxDecoration(color: DonatopiaColors.barBackgroundWhite, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))]),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Container(width: 40, height: 40, decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: DonatopiaColors.primaryPink.withOpacity(0.1)), child: Padding(padding: const EdgeInsets.all(8), child: Image.asset('assets/images/donatopia.png', fit: BoxFit.contain))),
                      const SizedBox(width: 10),
                      const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Donatopia', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: DonatopiaColors.cardValueColor)),
                        Text('Pelanggan', style: TextStyle(fontSize: 14, color: DonatopiaColors.secondaryText)),
                      ]),
                    ]),
                    IconButton(icon: const Icon(Icons.menu, color: DonatopiaColors.darkText, size: 28), onPressed: () => _scaffoldKey.currentState?.openEndDrawer()),
                  ],
                ),
              ),

              const SizedBox(height: 15),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Pelanggan', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: DonatopiaColors.darkText)),
                    Text('${_daftarPelanggan.length} Pelanggan', style: const TextStyle(color: DonatopiaColors.secondaryText)),
                  ]),
                  Container(width: 40, height: 40, decoration: BoxDecoration(color: DonatopiaColors.addButtonColor, borderRadius: BorderRadius.circular(10)), child: IconButton(icon: const Icon(Icons.add, color: Colors.white), onPressed: _showAddCustomerModal)),
                ],
              )),

              const SizedBox(height: 10),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(color: DonatopiaColors.searchBarBackground, borderRadius: BorderRadius.circular(15), border: Border.all(color: DonatopiaColors.secondaryText.withOpacity(0.4))),
                child: TextField(
                  onChanged: (v) => setState(() => _searchText = v),
                  decoration: const InputDecoration(hintText: 'Cari pelanggan...', border: InputBorder.none, hintStyle: TextStyle(color: DonatopiaColors.secondaryText), prefixIcon: Icon(Icons.search, color: DonatopiaColors.secondaryText)),
                ),
              )),

              const SizedBox(height: 20),

              // DAFTAR PELANGGAN
              Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Daftar Nama Pelanggan',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: DonatopiaColors.darkText),
      ),
      const SizedBox(height: 8),

      // PERBAIKAN DI SINI
      if (_isLoadingPelanggan)
        const Center(child: CircularProgressIndicator(color: DonatopiaColors.primaryPink))
      else if (_daftarPelanggan.isEmpty)
        const Text('Belum ada pelanggan.', style: TextStyle(color: DonatopiaColors.secondaryText))
      else
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _daftarPelanggan.map((pel) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: DonatopiaColors.searchBarBackground,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(pel.nama, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showEditPelangganModal(pel),
                    child: const Icon(Icons.edit, size: 18, color: DonatopiaColors.cardValueColor),
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
              // RIWAYAT TRANSAKSI
              const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Riwayat Transaksi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: DonatopiaColors.darkText))),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: filteredHistory.isEmpty && !_isLoading
                    ? const Center(child: Text('Tidak ada riwayat transaksi.'))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredHistory.length,
                        itemBuilder: (_, i) {
                          final h = filteredHistory[i];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(color: DonatopiaColors.softHistoryBackground, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: DonatopiaColors.primaryPink.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2))]),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                Text(h.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: DonatopiaColors.darkText)),
                                Row(children: [
                                  IconButton(icon: const Icon(Icons.edit, size: 18, color: DonatopiaColors.secondaryText), onPressed: () => null, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                                  IconButton(icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent), onPressed: () => null, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                                  Text(h.transactionTime, style: const TextStyle(color: DonatopiaColors.secondaryText)),
                                ]),
                              ]),
                              const SizedBox(height: 10),
                              const Text('Pesanan :', style: TextStyle(fontWeight: FontWeight.w600, color: DonatopiaColors.darkText)),
                              const SizedBox(height: 5),
                              ...h.items.map((item) => Padding(
                                    padding: const EdgeInsets.only(left: 10, bottom: 4),
                                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                      Flexible(child: Text('• ${item.name} ${item.quantity}x', style: const TextStyle(color: DonatopiaColors.darkText))),
                                      Text(_formatPrice(item.pricePerItem), style: const TextStyle(color: DonatopiaColors.darkText)),
                                    ]),
                                  )),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: DonatopiaColors.softHistoryTotalBackground, borderRadius: BorderRadius.circular(10)),
                                child: Column(children: [
                                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Subtotal :'), Text(_formatPrice(h.subtotal))]),
                                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Disc :', style: TextStyle(color: DonatopiaColors.cardValueColor)), Text('- ${_formatPrice(h.discount)}', style: TextStyle(color: DonatopiaColors.cardValueColor))]),
                                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Total :', style: TextStyle(fontWeight: FontWeight.bold)), Text(_formatPrice(h.total), style: const TextStyle(fontWeight: FontWeight.bold))]),
                                ]),
                              ),
                            ]),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}