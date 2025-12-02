import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:donatopia/widgets/custom_drawer.dart';

class DonatopiaColors {
  static const Color backgroundSoftPink = Color.fromARGB(255, 240, 229, 231);
  static const Color cardValueColor = Color(0xFFCC6073);
  static const Color primaryPink = Color(0xFFF48FB1);
  static const Color darkText = Color(0xFF636363);
  static const Color secondaryText = Color(0xFF999999);
  static const Color floatingCartButtonColor = Color.fromARGB(255, 240, 153, 169);
  static const Color barBackgroundWhite = Color(0xFFFFFFFF);
  static const Color searchBarBackground = Color.fromARGB(255, 255, 245, 246);
  static const Color softPinkText = Color.fromRGBO(247, 178, 190, 1);
  static const Color headerTextColor = softPinkText;
  static const Color cardBackground = Colors.white;
  static const Color cardLabelColor = Color.fromARGB(255, 139, 133, 134);
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
  final supabase = Supabase.instance.client;
  final uuid = const Uuid();

  String? _selectedCategory = 'Semua Kategori';
  String _searchText = '';
  List<Product> _products = [];
  bool _isLoading = true;
  bool _isRefreshing = false; // untuk animasi reload manual

  final List<String> categories = const [
    'Semua Kategori',
    'Glaze',
    'Glaze w/ topping',
    'Chocolate',
    'Crumble',
    'Topped',
  ];

  // Modal controllers
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _minStockController;
  String? _modalSelectedCategory;
  XFile? _pickedImage;
  bool _uploadingImage = false;

  RealtimeChannel? _realtimeChannel;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _priceController = TextEditingController();
    _stockController = TextEditingController();
    _minStockController = TextEditingController();

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
    if (_realtimeChannel != null) supabase.removeChannel(_realtimeChannel!);

    super.dispose();
  }

  void _setupRealtime() {
    _realtimeChannel = supabase.channel('produk-channel');
    _realtimeChannel!
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'produk',
          callback: (_) => _loadProducts(),
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
          _isRefreshing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Gagal memuat produk: $e', isError: true);
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    }
  }

  // Manual Refresh dengan animasi
  Future<void> _manualRefresh() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    await _loadProducts();
    _showSnackBar('Data berhasil diperbarui');
  }

  String _imageUrlWithCacheBust(String? url) {
    if (url == null || url.isEmpty) return 'assets/images/default.png';
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$url?t=$timestamp';
  }

  Future<String?> _uploadImage(XFile image, String productId) async {
    final bytes = await image.readAsBytes();
    final fileName = '$productId.jpg';
    await supabase.storage.from('products').uploadBinary(
          fileName,
          bytes,
          fileOptions: FileOptions(upsert: true),
        );
    final publicUrl = supabase.storage.from('products').getPublicUrl(fileName);
    return '$publicUrl?ts=${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> _deleteProduct(Product product) async {
    try {
      if (product.imageUrl != null) {
        final fileName = Uri.parse(product.imageUrl!).pathSegments.last.split('?').first;
        await supabase.storage.from('products').remove([fileName]).catchError((_) {});
      }
      await supabase.from('produk').delete().eq('id', product.id);
      _showSnackBar('Produk "${product.name}" berhasil dihapus');
    } catch (e) {
      _showSnackBar('Gagal menghapus: $e', isError: true);
    }
  }

  Future<void> _saveProduct(Product? original) async {
  // Validasi form
  if (!_formKey.currentState!.validate()) return;

  // Ambil value dari controller
  final name = _nameController.text.trim();
  final desc = _descriptionController.text.trim().isEmpty
      ? null
      : _descriptionController.text.trim();
  final price = num.tryParse(_priceController.text) ?? 0;
  final stock = int.tryParse(_stockController.text) ?? 0;
  final minStock = int.tryParse(_minStockController.text) ?? 0;
  final category = _modalSelectedCategory ?? 'Glaze';

  // Set loading state
  if (mounted) {
    setState(() {
      _uploadingImage = true;
    });
  }

  try {
    String? imageUrl;

    // Upload gambar jika ada
    if (_pickedImage != null) {
      final idForUpload = original?.id ?? uuid.v4();
      imageUrl = await _uploadImage(_pickedImage!, idForUpload);
    }

    if (original != null) {
      // === UPDATE PRODUK ===
      final Map<String, dynamic> updateData = {
        'nama': name,
        'harga': price,
        'kategori': category,
        'deskripsi': desc,
        'stok': stock,
        'min_stok': minStock,
      };

      // Hanya tambahkan foto jika ada gambar baru
      if (imageUrl != null) {
        updateData['foto'] = imageUrl;
      }

      await supabase.from('produk').update(updateData).eq('id', original.id);
      _showSnackBar('Produk "$name" berhasil diperbarui');
    } 
    else {
      // === TAMBAH PRODUK BARU ===
      final newId = uuid.v4();
      final Map<String, dynamic> insertData = {
        'id': newId,
        'nama': name,
        'harga': price,
        'kategori': category,
        'deskripsi': desc,
        'stok': stock,
        'min_stok': minStock,
      };

      // Hanya tambahkan foto jika ada
      if (imageUrl != null) {
        insertData['foto'] = imageUrl;
      }

      await supabase.from('produk').insert(insertData);
      _showSnackBar('Produk "$name" berhasil ditambahkan');
    }

    // Reset picked image
    _pickedImage = null;

    // Tutup modal
    if (mounted) {
      Navigator.of(context).pop();
    }
  } catch (e) {
    _showSnackBar('Gagal menyimpan produk: $e', isError: true);
  } finally {
    // Matikan loading
    if (mounted) {
      setState(() {
        _uploadingImage = false;
      });
    }
  }
}


  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red[700] : DonatopiaColors.primaryPink,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  List<Product> get _filteredProducts {
    var list = _products;
    if (_selectedCategory != 'Semua Kategori' && _selectedCategory != null) {
      list = list.where((p) => p.category == _selectedCategory).toList();
    }
    if (_searchText.isNotEmpty) {
      final q = _searchText.toLowerCase();
      list = list.where((p) => p.name.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  String _formatPrice(num price) {
    final str = price.toStringAsFixed(0);
    return 'Rp. ${str.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (img != null && mounted) {
      setState(() => _pickedImage = img);
    }
  }

  void _showAddProductModal() {
    _nameController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _stockController.clear();
    _minStockController.clear();
    _modalSelectedCategory = 'Glaze';
    _pickedImage = null;
    _showProductModal(null);
  }

  void _showEditProductModal(Product p) {
    _nameController.text = p.name;
    _descriptionController.text = p.description ?? '';
    _priceController.text = p.price.toString();
    _stockController.text = p.stock.toString();
    _minStockController.text = (p.minStock ?? 0).toString();
    _modalSelectedCategory = p.category;
    _pickedImage = null;
    _showProductModal(p);
  }

  void _showProductModal(Product? productToEdit) {
    final isEdit = productToEdit != null;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: DonatopiaColors.primaryPink.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5)),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEdit ? 'Edit Produk' : 'Tambah Produk Baru',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: DonatopiaColors.cardValueColor),
                      ),
                      const Divider(color: DonatopiaColors.backgroundSoftPink),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: _buildModalTextField(controller: _nameController, label: 'Nama Produk *')),
                          const SizedBox(width: 10),
                          Expanded(child: _buildModalCategoryDropdown(setModalState)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildModalTextField(
                        controller: _descriptionController,
                        label: 'Deskripsi',
                        maxLines: 3,
                        isOptional: true,
                      ),
                      const SizedBox(height: 10),
                      if (_pickedImage != null || productToEdit?.imageUrl != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: _pickedImage != null
                                ? Image.file(File(_pickedImage!.path), height: 120, width: double.infinity, fit: BoxFit.cover)
                                : Image.network(_imageUrlWithCacheBust(productToEdit!.imageUrl), height: 120, fit: BoxFit.cover),
                          ),
                        ),
                      TextButton.icon(
                        onPressed: () async {
                          await _pickImage();
                          setModalState(() {});
                        },
                        icon: const Icon(Icons.photo),
                        label: Text(_pickedImage == null ? 'Pilih Foto (opsional)' : 'Ganti Foto'),
                        style: TextButton.styleFrom(foregroundColor: DonatopiaColors.cardValueColor),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildModalTextField(
                              controller: _priceController,
                              label: 'Harga *',
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildModalTextField(
                              controller: _stockController,
                              label: 'Stok *',
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildModalTextField(
                              controller: _minStockController,
                              label: 'Stok Minimal *',
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Batal', style: TextStyle(color: DonatopiaColors.darkText)),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: _uploadingImage ? null : () => _saveProduct(productToEdit),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: DonatopiaColors.primaryPink,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: _uploadingImage
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : Text(isEdit ? 'Simpan Perubahan' : 'Tambah Produk', style: const TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModalTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool isOptional = false,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: DonatopiaColors.darkText)),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          inputFormatters: inputFormatters,
          style: const TextStyle(fontSize: 14, color: DonatopiaColors.darkText),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            fillColor: DonatopiaColors.searchBarBackground,
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: DonatopiaColors.secondaryText.withOpacity(0.5))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: DonatopiaColors.cardValueColor, width: 1.5)),
          ),
          validator: (v) {
            if (!isOptional && (v == null || v.trim().isEmpty)) return 'Wajib diisi';
            if (keyboardType == TextInputType.number && v != null && v.isNotEmpty && int.tryParse(v) == null) return 'Harus angka';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildModalCategoryDropdown(StateSetter setModalState) {
    final modalCats = categories.where((c) => c != 'Semua Kategori').toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 4),
          child: Text('Kategori *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: DonatopiaColors.darkText)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: DonatopiaColors.searchBarBackground,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: DonatopiaColors.secondaryText.withOpacity(0.5)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _modalSelectedCategory,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: DonatopiaColors.secondaryText),
              style: const TextStyle(fontSize: 14, color: DonatopiaColors.darkText),
              items: modalCats.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setModalState(() => _modalSelectedCategory = v),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DonatopiaColors.backgroundSoftPink,
      endDrawer: const CustomDrawer(currentRoute: ProdukPage.routeName),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProductModal,
        backgroundColor: DonatopiaColors.primaryPink,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 8,
        child: const Icon(Icons.add, size: 30),
      ),
      body: Column(
        children: [
          // HEADER DENGAN ICON RELOAD
          Container(
            padding: const EdgeInsets.fromLTRB(16, 45, 16, 10),
            decoration: BoxDecoration(
              color: DonatopiaColors.barBackgroundWhite,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: _buildHeader(context),
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

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 45, height: 45,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(22.5), color: DonatopiaColors.headerTextColor.withOpacity(0.1)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22.5),
                child: Image.asset('assets/images/donatopia.png', fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.donut_large, color: DonatopiaColors.cardValueColor)),
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Donatopia', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: DonatopiaColors.cardValueColor)),
                Text('Produk', style: TextStyle(fontSize: 14, color: DonatopiaColors.secondaryText)),
              ],
            ),
          ],
        ),
        Row(
          children: [
            // ICON RELOAD
            IconButton(
              icon: _isRefreshing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: DonatopiaColors.cardValueColor),
                    )
                  : const Icon(Icons.refresh, color: DonatopiaColors.darkText, size: 26),
              onPressed: _manualRefresh,
              tooltip: 'Refresh Data',
            ),
            const SizedBox(width: 8),
            // ICON SIDEBAR
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu, color: DonatopiaColors.darkText, size: 28),
                onPressed: () => Scaffold.of(ctx).openEndDrawer(),
              ),
            ),
          ],
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
          hintText: 'Cari produk...',
          border: InputBorder.none,
          hintStyle: TextStyle(color: DonatopiaColors.secondaryText),
          prefixIcon: Icon(Icons.search, color: DonatopiaColors.secondaryText, size: 20),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              flex: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  _imageUrlWithCacheBust(p.imageUrl),
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Image.asset('assets/images/default.png', fit: BoxFit.contain),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator(strokeWidth: 2, color: DonatopiaColors.primaryPink));
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(p.name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: DonatopiaColors.darkText), maxLines: 2, overflow: TextOverflow.ellipsis),
            Text(p.category, style: const TextStyle(fontSize: 9, color: DonatopiaColors.secondaryText)),
            Text(_formatPrice(p.price), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: DonatopiaColors.cardValueColor)),
            const Spacer(),
            InkWell(onTap: () => _showEditProductModal(p), child: Container(height: 25, decoration: BoxDecoration(color: DonatopiaColors.searchBarBackground, borderRadius: BorderRadius.circular(8)), child: const Center(child: Icon(Icons.edit, size: 18, color: DonatopiaColors.darkText)))),
            const SizedBox(height: 4),
            InkWell(onTap: () => _confirmDelete(p), child: Container(height: 25, decoration: BoxDecoration(color: DonatopiaColors.cardValueColor, borderRadius: BorderRadius.circular(8)), child: const Center(child: Icon(Icons.delete_outline, size: 18, color: Colors.white)))),
          ],
        ),
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
            style: ElevatedButton.styleFrom(backgroundColor: DonatopiaColors.cardValueColor),
            onPressed: () {
              Navigator.pop(context);
              _deleteProduct(p);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}