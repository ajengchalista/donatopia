import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:donatopia/widgets/custom_drawer.dart';

final supabase = Supabase.instance.client;

class DonatopiaColors {
  static const Color backgroundSoftPink = Color.fromARGB(255, 240, 229, 231);
  static const Color cardValueColor = Color(0xFFCC6073);
  static const Color primaryPink = Color(0xFFF48FB1);
  static const Color darkText = Color(0xFF636363);
  static const Color secondaryText = Color(0xFF999999);
  static const Color barBackgroundWhite = Color(0xFFFFFFFF);
  static const Color searchBarBackground = Color.fromARGB(255, 255, 245, 246);
  static const Color headerTextColor = Color.fromRGBO(247, 178, 190, 1);
  static const Color accentAction = Color.fromARGB(255, 242, 150, 167);
}

class Product {
  final String id;
  final String name;
  final num price;
  final String? imageUrl;
  final String category;
  final String? description;
  final int stock;
  final int? minStock;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
    required this.category,
    this.description,
    required this.stock,
    this.minStock,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      name: map['nama'] as String,
      price: map['harga'] as num,
      imageUrl: map['foto'] as String?,
      category: map['kategori'] ?? 'Glaze',
      description: map['deskripsi'] as String?,
      stock: (map['stok'] as num?)?.toInt() ?? 0,
      minStock: map['min_stok'] as int?,
    );
  }
}

class ProdukPage extends StatefulWidget {
  static const String routeName = '/produk';
  const ProdukPage({super.key});

  @override
  State<ProdukPage> createState() => _ProdukPageState();
}

class _ProdukPageState extends State<ProdukPage> {
  final uuid = const Uuid();

  String? _selectedCategory = 'Semua Kategori';
  String _searchText = '';
  List<Product> _products = [];
  bool _isLoading = true;

  final List<String> categories = const [
    'Semua Kategori',
    'Glaze',
    'Glaze w/ topping',
    'Chocolate',
    'Crumble',
    'Topped',
  ];

  // Modal Controllers
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _minStockController = TextEditingController();
  String? _modalSelectedCategory = 'Glaze';
  XFile? _pickedImage;
  bool _uploadingImage = false;

  RealtimeChannel? _realtimeChannel;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _setupRealtime();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    _realtimeChannel?.unsubscribe();
    super.dispose();
  }

  void _setupRealtime() {
    _realtimeChannel = supabase
        .channel('produk-realtime')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'produk',
          callback: (payload) => _loadProducts(),
        )
        .subscribe();
  }

  Future<void> _loadProducts() async {
    try {
      final data = await supabase
          .from('produk')
          .select()
          .order('created_at', ascending: false);

      final List<Product> loaded = (data as List)
          .map((e) => Product.fromMap(e as Map<String, dynamic>))
          .toList();

      if (mounted) {
        setState(() {
          _products = loaded;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar('Gagal memuat produk', isError: true);
      }
    }
  }

  String _imageUrlWithCacheBust(String? url) {
    if (url == null || url.isEmpty) return 'assets/images/default.png';
    return '$url?ts=${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<String?> _uploadImage(XFile image, String productId) async {
    final bytes = await image.readAsBytes();
    final fileName = '$productId.jpg';
    await supabase.storage.from('products').uploadBinary(
          fileName,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );
    return supabase.storage.from('products').getPublicUrl(fileName);
  }

  Future<void> _deleteProduct(Product p) async {
    try {
      if (p.imageUrl != null) {
        try {
          final fileName = Uri.parse(p.imageUrl!).pathSegments.last.split('?').first;
          await supabase.storage.from('products').remove([fileName]);
        } catch (_) {}
      }
      await supabase.from('produk').delete().eq('id', p.id);
      _showSnackBar('Produk "${p.name}" dihapus');
    } catch (e) {
      _showSnackBar('Gagal menghapus', isError: true);
    }
  }

  Future<void> _saveProduct(Product? editProduct) async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final desc = _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim();
    final priceText = _priceController.text.trim();
    final stockText = _stockController.text.trim();
    final minStockText = _minStockController.text.trim();

    final price = num.tryParse(priceText);
    final stock = int.tryParse(stockText);
    final minStock = minStockText.isEmpty ? null : int.tryParse(minStockText);

    if (price == null || price <= 0) {
      _showSnackBar('Harga harus berupa angka dan lebih dari 0', isError: true);
      return;
    }
    if (stock == null || stock < 0) {
      _showSnackBar('Stok harus berupa angka dan tidak boleh negatif', isError: true);
      return;
    }

    final category = _modalSelectedCategory ?? 'Glaze';
    setState(() => _uploadingImage = true);

    try {
      String? imageUrl;
      if (_pickedImage != null) {
        final id = editProduct?.id ?? uuid.v4();
        imageUrl = await _uploadImage(_pickedImage!, id);
      }

      if (editProduct != null) {
        await supabase.from('produk').update({
          'nama': name,
          'harga': price,
          'kategori': category,
          'deskripsi': desc,
          'stok': stock,
          if (minStock != null) 'min_stok': minStock,
          if (imageUrl != null) 'foto': imageUrl,
        }).eq('id', editProduct.id);
        _showSnackBar('Produk berhasil diperbarui');
      } else {
        final newId = uuid.v4();
        await supabase.from('produk').insert({
          'id': newId,
          'nama': name,
          'harga': price,
          'kategori': category,
          'deskripsi': desc,
          'stok': stock,
          if (minStock != null) 'min_stok': minStock,
          if (imageUrl != null) 'foto': imageUrl,
        });
        _showSnackBar('Produk berhasil ditambahkan');
      }

      _pickedImage = null;
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showSnackBar('Gagal menyimpan produk', isError: true);
    } finally {
      if (mounted) setState(() => _uploadingImage = false);
    }
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
        backgroundColor: isError ? Colors.red[700] : DonatopiaColors.accentAction,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  List<Product> get _filteredProducts {
    var list = _products;
    if (_selectedCategory != 'Semua Kategori' && _selectedCategory != null) {
      list = list.where((p) => p.category == _selectedCategory).toList();
    }
    if (_searchText.isNotEmpty) {
      list = list.where((p) => p.name.toLowerCase().contains(_searchText.toLowerCase())).toList();
    }
    return list;
  }

  String _formatPrice(num price) {
    final str = price.toStringAsFixed(0);
    return 'Rp. ${str.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  Future<void> _pickImage() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (img != null && mounted) setState(() => _pickedImage = img);
  }

  // INI YANG PENTING: BOLEH KETIK HURUF, TAPI VALIDASI KETAT
  Widget _buildNumberField(TextEditingController c, String label, {bool optional = false}) {
    return TextFormField(
      controller: c,
      keyboardType: TextInputType.numberWithOptions(decimal: false),
      // TIDAK ADA FILTER → BOLEH KETIK HURUF, SIMBOL, APA SAJA
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: DonatopiaColors.searchBarBackground,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        errorStyle: const TextStyle(fontSize: 11),
      ),
      validator: (value) {
        if (optional && (value == null || value.trim().isEmpty)) return null;
        if (value == null || value.trim().isEmpty) return 'Wajib diisi';

        final cleaned = value.trim();
        if (!RegExp(r'^\d+$').hasMatch(cleaned)) {
          return 'Hanya boleh angka';
        }

        final number = int.parse(cleaned);
        if (number < 0) return 'Tidak boleh negatif';
        if (label.contains('Harga') && number == 0) return 'Harga minimal 1';

        return null;
      },
    );
  }

  Widget _buildModalTextField(TextEditingController c, String label, {int maxLines = 1, bool optional = false}) {
    return TextFormField(
      controller: c,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: DonatopiaColors.searchBarBackground,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      validator: (v) => !optional && (v == null || v.isEmpty) ? 'Wajib diisi' : null,
    );
  }

  Widget _buildModalCategoryDropdown(StateSetter setModalState) {
    return DropdownButtonFormField<String>(
      value: _modalSelectedCategory,
      items: categories.where((c) => c != 'Semua Kategori').map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
      onChanged: (v) => setModalState(() => _modalSelectedCategory = v),
      decoration: InputDecoration(
        labelText: 'Kategori *',
        filled: true,
        fillColor: DonatopiaColors.searchBarBackground,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (v) => v == null ? 'Pilih kategori' : null,
    );
  }

  void _showProductModal([Product? editProduct]) {
    final isEdit = editProduct != null;
    if (!isEdit) {
      _nameController.clear();
      _descriptionController.clear();
      _priceController.clear();
      _stockController.clear();
      _minStockController.clear();
      _modalSelectedCategory = 'Glaze';
      _pickedImage = null;
    } else {
      _nameController.text = editProduct!.name;
      _descriptionController.text = editProduct.description ?? '';
      _priceController.text = editProduct.price.toString();
      _stockController.text = editProduct.stock.toString();
      _minStockController.text = (editProduct.minStock ?? '').toString();
      _modalSelectedCategory = editProduct.category;
      _pickedImage = null;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(builder: (context, setModalState) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: DonatopiaColors.primaryPink.withOpacity(0.2), blurRadius: 10)],
              ),
              child: Form(
                key: _formKey,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(isEdit ? 'Edit Produk' : 'Tambah Produk Baru',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: DonatopiaColors.cardValueColor)),
                  const Divider(color: DonatopiaColors.backgroundSoftPink),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: _buildModalTextField(_nameController, 'Nama Produk *', optional: false)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildModalCategoryDropdown(setModalState)),
                  ]),
                  const SizedBox(height: 10),
                  _buildModalTextField(_descriptionController, 'Deskripsi', maxLines: 3, optional: true),
                  const SizedBox(height: 10),
                  if (_pickedImage != null || editProduct?.imageUrl != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: _pickedImage != null
                            ? Image.file(File(_pickedImage!.path), height: 120, width: double.infinity, fit: BoxFit.cover)
                            : Image.network(_imageUrlWithCacheBust(editProduct!.imageUrl), height: 120, fit: BoxFit.cover),
                      ),
                    ),
                  TextButton.icon(
                    onPressed: () async { await _pickImage(); setModalState(() {}); },
                    icon: const Icon(Icons.photo),
                    label: Text(_pickedImage == null ? 'Pilih Foto (opsional)' : 'Ganti Foto'),
                    style: TextButton.styleFrom(foregroundColor: DonatopiaColors.cardValueColor),
                  ),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: _buildNumberField(_priceController, 'Harga *')),
                    const SizedBox(width: 10),
                    Expanded(child: _buildNumberField(_stockController, 'Stok *')),
                    const SizedBox(width: 10),
                    Expanded(child: _buildNumberField(_minStockController, 'Stok Minimal', optional: true)),
                  ]),
                  const SizedBox(height: 20),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal', style: TextStyle(color: DonatopiaColors.darkText))),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _uploadingImage ? null : () => _saveProduct(editProduct),
                      style: ElevatedButton.styleFrom(backgroundColor: DonatopiaColors.primaryPink, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      child: _uploadingImage
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(isEdit ? 'Simpan Perubahan' : 'Tambah Produk', style: const TextStyle(color: Colors.white)),
                    ),
                  ]),
                ]),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: DonatopiaColors.searchBarBackground,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: DonatopiaColors.secondaryText.withOpacity(0.4)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: DonatopiaColors.secondaryText),
          style: const TextStyle(fontSize: 16, color: DonatopiaColors.darkText, fontWeight: FontWeight.w500),
          items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          onChanged: (v) => setState(() => _selectedCategory = v),
        ),
      ),
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
          hintText: 'Cari produk...',
          border: InputBorder.none,
          hintStyle: TextStyle(color: DonatopiaColors.secondaryText),
          prefixIcon: Icon(Icons.search, color: DonatopiaColors.secondaryText, size: 20),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DonatopiaColors.backgroundSoftPink,
      endDrawer: const CustomDrawer(currentRoute: ProdukPage.routeName),
      floatingActionButton: FloatingActionButton(
        onPressed: _showProductModal,
        backgroundColor: DonatopiaColors.accentAction,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 8,
        child: const Icon(Icons.add, size: 30),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 45, 16, 10),
            decoration: BoxDecoration(
              color: DonatopiaColors.barBackgroundWhite,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [
                Container(
                  width: 45, height: 45,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(22.5), color: DonatopiaColors.headerTextColor.withOpacity(0.1)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22.5),
                    child: Image.asset('assets/images/donatopia.png', fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.donut_large, color: DonatopiaColors.cardValueColor)),
                  ),
                ),
                const SizedBox(width: 10),
                const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Donatopia', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: DonatopiaColors.cardValueColor)),
                  Text('Produk', style: TextStyle(fontSize: 14, color: DonatopiaColors.secondaryText)),
                ]),
              ]),
              Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.menu, color: DonatopiaColors.darkText, size: 28), onPressed: () => Scaffold.of(ctx).openEndDrawer())),
            ]),
          ),

          Padding(padding: const EdgeInsets.fromLTRB(16, 10, 16, 5), child: _buildSearchBar()),
          Padding(padding: const EdgeInsets.fromLTRB(16, 5, 16, 10), child: _buildCategoryDropdown()),

          _isLoading
              ? const Expanded(child: Center(child: CircularProgressIndicator(color: DonatopiaColors.primaryPink)))
              : Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10, left: 16, right: 16),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.68,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: _filteredProducts.length,
                      itemBuilder: (_, i) => _buildProductCard(_filteredProducts[i]),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product p) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: DonatopiaColors.backgroundSoftPink, width: 2),
        boxShadow: [BoxShadow(color: const Color.fromARGB(255, 253, 188, 188).withOpacity(0.05), blurRadius: 5)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Flexible(
            flex: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                _imageUrlWithCacheBust(p.imageUrl),
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Image.asset('assets/images/default.png', fit: BoxFit.contain),
                loadingBuilder: (context, child, loadingProgress) => loadingProgress == null ? child : const Center(child: CircularProgressIndicator(strokeWidth: 2, color: DonatopiaColors.primaryPink)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(p.name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: DonatopiaColors.darkText), maxLines: 2, overflow: TextOverflow.ellipsis),
          Text(p.category, style: const TextStyle(fontSize: 9, color: DonatopiaColors.secondaryText)),
          Text(_formatPrice(p.price), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: DonatopiaColors.cardValueColor)),
          const Spacer(),
          InkWell(onTap: () => _showProductModal(p), child: Container(height: 25, decoration: BoxDecoration(color: DonatopiaColors.searchBarBackground, borderRadius: BorderRadius.circular(8)), child: const Center(child: Icon(Icons.edit, size: 18, color: DonatopiaColors.darkText)))),
          const SizedBox(height: 4),
          InkWell(
            onTap: () => _confirmDelete(p),
            child: Container(
              height: 25,
              decoration: BoxDecoration(color: DonatopiaColors.accentAction, borderRadius: BorderRadius.circular(8)),
              child: const Center(child: Icon(Icons.delete_outline, size: 18, color: Colors.white)),
            ),
          ),
        ]),
      ),
    );
  }

  void _confirmDelete(Product p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Konfirmasi Hapus'),
        content: Text('Yakin ingin menghapus "${p.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: DonatopiaColors.accentAction),
            onPressed: () { Navigator.pop(context); _deleteProduct(p); },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}