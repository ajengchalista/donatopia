import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Tambahkan ini jika diperlukan untuk input number
import 'package:donatopia/widgets/custom_drawer.dart';

// Definisi warna Donatopia
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
  static const Color cardBackground = Colors.white; // Tambahkan dari contoh sebelumnya
  static const Color cardLabelColor = Color.fromARGB(255, 139, 133, 134); // Tambahkan dari contoh sebelumnya
}

class Product {
  final String id; 
  final String name;
  final int price;
  final String image;
  final String category;
  final String? description;
  final int stock;
  final int minStock;

  Product({
    required this.id, 
    required this.name,
    required this.price,
    required this.image,
    required this.category,
    this.description,
    required this.stock,
    required this.minStock,
  });

  Product copyWith({
    String? name,
    int? price,
    String? image,
    String? category,
    String? description,
    int? stock,
    int? minStock,
  }) {
    return Product(
      id: id, 
      name: name ?? this.name,
      price: price ?? this.price,
      image: image ?? this.image,
      category: category ?? this.category,
      description: description ?? this.description,
      stock: stock ?? this.stock,
      minStock: minStock ?? this.minStock,
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
  // --- STATE VARIABLES ---
  String? _selectedCategory = 'Semua Kategori';
  String _searchText = '';

  late List<Product> _products;

  final List<String> categories = const [
    'Semua Kategori', 'Glaze', 'Glaze w/ topping', 'Chocolate', 'Crumble', 'Topped'
  ];

  // Controller untuk Modal Edit/Tambah
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _minStockController;
  String? _modalSelectedCategory;


  @override
  void initState() {
    super.initState();
    _products = [
      Product(id: 'p1', name: "BLUEBERRY BLISS", price: 23000, image: "blueberry_bliss.png", category: "Glaze w/ topping", stock: 15, minStock: 5, description: "Donut glaze blueberry dengan taburan renyah."),
      Product(id: 'p2', name: "SUNNY LEMON", price: 21000, image: "sunny_lemon.png", category: "Glaze w/ topping", stock: 10, minStock: 3, description: "Glaze lemon segar dengan topping biji poppy."),
      Product(id: 'p3', name: "PINKSBITEZ", price: 24000, image: "pinksbitez.png", category: "Glaze w/ topping", stock: 8, minStock: 12, description: "Donut pink mengkilap dengan taburan manis warna-warni."),
      Product(id: 'p4', name: "BLUSH BITE", price: 23000, image: "blush_bite.png", category: "Glaze", stock: 8, minStock: 12, description: "Donut klasik dengan glaze pink lembut."),
      Product(id: 'p5', name: "CHOCO DRIP", price: 20000, image: "choco_drop.png", category: "Chocolate", stock: 20, minStock: 7, description: "Donut cokelat klasik dengan lapisan cokelat lezat."),
      Product(id: 'p6', name: "SUNNY CRISP", price: 19000, image: "sunny_crisp.png", category: "Crumble", stock: 12, minStock: 4, description: "Donut dengan topping crumble gula dan mentega."),
      Product(id: 'p7', name: "VANILLUSH", price: 17000, image: "vanillush.png", category: "Glaze", stock: 18, minStock: 6, description: "Glaze vanila murni dengan garis cokelat."),
      Product(id: 'p8', name: "NUT CRAVE", price: 19000, image: "nut_crave.png", category: "Topped", stock: 9, minStock: 5, description: "Donut dengan topping kacang karamel yang gurih."),
    ];

    // Inisialisasi controller
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _priceController = TextEditingController();
    _stockController = TextEditingController();
    _minStockController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    super.dispose();
  }

  // --- LOGIC METHODS ---

  String _getNewId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  List<Product> get _filteredProducts { //filter produk
    Iterable<Product> products = _products;

    if (_selectedCategory != 'Semua Kategori' && _selectedCategory != null) {
      products = products.where((product) => product.category == _selectedCategory);
    }
    if (_searchText.isNotEmpty) { //filter pencarian
      final searchLower = _searchText.toLowerCase();
      products = products.where((product) {
        final nameLower = product.name.toLowerCase();
        return nameLower.contains(searchLower);
      });
    }
    return products.toList();
  }

  String _formatPrice(int price) {
    String priceStr = price.toString();
    String formatted = priceStr.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp. $formatted';
  }

  void _confirmDeleteProduct(Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('Konfirmasi Hapus'),
          content: Text('Anda yakin ingin menghapus produk "${product.name}" dari daftar?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(), 
              child: const Text('Batal', style: TextStyle(color: DonatopiaColors.darkText)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: DonatopiaColors.cardValueColor, 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.of(context).pop(); 
                _deleteProduct(product); 
              },
              child: const Text('Ya, Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _deleteProduct(Product product) {
    setState(() {
      // Hapus produk dari list berdasarkan ID unik
      _products.removeWhere((p) => p.id == product.id);
    });

    // Tampilkan notifikasi
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Produk "${product.name}" berhasil dihapus.'),
        backgroundColor: DonatopiaColors.cardValueColor,
      ),
    );
  }

  void _showAddProductModal() { //kategori
    _nameController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _stockController.clear();
    _minStockController.clear();
    // Gunakan kategori pertama yang bukan 'Semua Kategori' sebagai default
    _modalSelectedCategory = categories.firstWhere((c) => c != 'Semua Kategori'); 

    _showProductModal(null);
  }

  void _showEditProductModal(Product product) {
    _nameController.text = product.name;
    _descriptionController.text = product.description ?? '';
    _priceController.text = product.price.toString(); 
    _stockController.text = product.stock.toString();
    _minStockController.text = product.minStock.toString();
    _modalSelectedCategory = product.category;

    _showProductModal(product);
  }

  void _showProductModal(Product? productToEdit) {
    final bool isEditing = productToEdit != null;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(20.0),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Judul Modal
                        Text(
                          isEditing ? 'Edit Produk' : 'Tambah Produk Baru',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: DonatopiaColors.cardValueColor,
                          ),
                        ),
                        const Divider(color: DonatopiaColors.backgroundSoftPink),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            // Nama Produk
                            Expanded(child: _buildModalTextField(
                              controller: _nameController,
                              label: 'Nama Produk *',
                            )),
                            const SizedBox(width: 10),
                            // Kategori (Dropdown)
                            Expanded(child: _buildModalCategoryDropdown(setModalState)),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Deskripsi
                        _buildModalTextField(
                          controller: _descriptionController,
                          label: 'Deskripsi',
                          maxLines: 3,
                          isOptional: true,
                        ),
                        const SizedBox(height: 10),

                        // Form Grid (Harga, Stok, Stok Minimal)
                        Row(
                          children: [
                            // Harga
                            Expanded(child: _buildModalTextField(
                              controller: _priceController,
                              label: 'Harga (Angka Saja) *',
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Opsional: Hanya izinkan angka
                            )),
                            const SizedBox(width: 10),
                            // Stok
                            Expanded(child: _buildModalTextField(
                              controller: _stockController,
                              label: 'Stok *',
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            )),
                            const SizedBox(width: 10),
                            // Stok Minimal
                            Expanded(child: _buildModalTextField(
                              controller: _minStockController,
                              label: 'Stok Minimal *',
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            )),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Tombol Aksi (Batal & Simpan)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Tombol Batal
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Batal', style: TextStyle(color: DonatopiaColors.darkText)),
                            ),
                            const SizedBox(width: 10),
                            // Tombol Simpan
                            ElevatedButton(
                              onPressed: () => _saveProduct(productToEdit, context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: DonatopiaColors.primaryPink,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: Text(isEditing ? 'Simpan Perubahan' : 'Tambah Produk', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        );
      },
    );
  }

  void _saveProduct(Product? originalProduct, BuildContext dialogContext) { //simpan produk
    if (_formKey.currentState!.validate()) {
      // 1. Ambil data baru
      final newName = _nameController.text;
      final newDescription = _descriptionController.text.isEmpty ? null : _descriptionController.text;
      // Gunakan int.parse karena validator sudah memastikan input adalah angka
      final newPrice = int.parse(_priceController.text); 
      final newStock = int.parse(_stockController.text);
      final newMinStock = int.parse(_minStockController.text);
      final newCategory = _modalSelectedCategory!;

      if (originalProduct != null) {
        final updatedProduct = originalProduct.copyWith(
          name: newName,
          category: newCategory,
          description: newDescription,
          price: newPrice,
          stock: newStock,
          minStock: newMinStock,
        );

        setState(() {
          final index = _products.indexWhere((p) => p.id == originalProduct.id);
          if (index != -1) {
            _products[index] = updatedProduct;
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Produk "${updatedProduct.name}" berhasil diubah!'),
            backgroundColor: DonatopiaColors.primaryPink, 
          ),
        );

      } else {
        final newProduct = Product(
          id: _getNewId(), 
          name: newName,
          price: newPrice,
          image: "default_donut.png", // Asumsi gambar default
          category: newCategory,
          description: newDescription,
          stock: newStock,
          minStock: newMinStock,
        );

        setState(() {
          _products.add(newProduct);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Produk "${newProduct.name}" berhasil ditambahkan!'),
            backgroundColor: DonatopiaColors.primaryPink,
          ),
        );
      }

      // 3. Tutup modal
      Navigator.of(dialogContext).pop();
    }
  }

  // --- WIDGET PEMBANTU (MODAL) ---

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
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: DonatopiaColors.darkText,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          inputFormatters: inputFormatters, // Menggunakan inputFormatters
          style: const TextStyle(fontSize: 14, color: DonatopiaColors.darkText),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            fillColor: DonatopiaColors.searchBarBackground,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: DonatopiaColors.secondaryText.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: DonatopiaColors.cardValueColor, width: 1.5),
            ),
          ),
          validator: (value) {
            if (!isOptional && (value == null || value.isEmpty)) {
              return 'Kolom ini wajib diisi.';
            }
            if (keyboardType == TextInputType.number && value != null && value.isNotEmpty) {
              if (int.tryParse(value) == null) {
                return 'Hanya angka yang diizinkan.';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildModalCategoryDropdown(StateSetter setModalState) {
    final List<String> modalCategories = categories.where((c) => c != 'Semua Kategori').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 4.0),
          child: Text(
            'Kategori *',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: DonatopiaColors.darkText,
            ),
          ),
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
              icon: const Icon(Icons.keyboard_arrow_down, color: DonatopiaColors.secondaryText),
              isExpanded: true,
              style: const TextStyle(
                fontSize: 14,
                color: DonatopiaColors.darkText,
              ),
              dropdownColor: Colors.white,
              items: modalCategories.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setModalState(() {
                  _modalSelectedCategory = newValue;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
  
  // --- WIDGET UTAMA (BUILD) ---
  @override
  Widget build(BuildContext context) { 
    return Scaffold(
      backgroundColor: DonatopiaColors.backgroundSoftPink,
      
      // >>> INI ADALAH IMPLEMENTASI SIDEBAR (DRAWER KANAN) <<<
      endDrawer: const CustomDrawer(currentRoute: ProdukPage.routeName),
      
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProductModal,
        backgroundColor: DonatopiaColors.primaryPink,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        elevation: 8,
        child: const Icon(Icons.add, size: 30),
      ),

      body: Column(
        children: [
          // Header (termasuk tombol menu untuk Sidebar)
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
            child: _buildHeader(context), // Menggunakan context untuk akses Scaffold.of
          ),
          
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 5.0),
            child: _buildSearchBar(), 
          ),
      
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 5.0, 16.0, 10.0),
            child: _buildCategoryDropdown(), 
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0, left: 16.0, right: 16.0),
              child: GridView.builder(
                padding: EdgeInsets.zero,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  // Menggunakan 3 kolom
                  crossAxisCount: 3, 
                  // Rasio aspek yang dioptimalkan untuk 3 kolom
                  childAspectRatio: 0.68, 
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = _filteredProducts[index];
                  // Panggil _buildProductCard dengan objek Product
                  return _buildProductCard(product); 
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET PEMBANTU (HALAMAN) ---
  
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
          hintText: 'Cari produk...',
          border: InputBorder.none,
          hintStyle: TextStyle(color: DonatopiaColors.secondaryText, fontSize: 14, fontWeight: FontWeight.w400),
          prefixIcon: Icon(Icons.search, color: DonatopiaColors.secondaryText, size: 20),
          prefixIconConstraints: BoxConstraints(minWidth: 35),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
      decoration: BoxDecoration(
        color: DonatopiaColors.searchBarBackground,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: DonatopiaColors.secondaryText.withOpacity(0.4), width: 1.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory, 
          icon: const Icon(Icons.keyboard_arrow_down, color: DonatopiaColors.secondaryText),
          isExpanded: true,
          style: const TextStyle(
            fontSize: 16,
            color: DonatopiaColors.darkText,
            fontWeight: FontWeight.w500,
          ),
          dropdownColor: Colors.white,
          
          items: categories.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value, 
              child: Text(
                value,
                style: TextStyle(
                  fontWeight: value == 'Semua Kategori' ? FontWeight.w400 : FontWeight.w500, 
                  color: value == 'Semua Kategori' ? DonatopiaColors.secondaryText : DonatopiaColors.darkText,
                ),
              ),
            );
          }).toList(),
          
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedCategory = newValue; 
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    String formattedPrice = _formatPrice(product.price);
    // Menggunakan ID sebagai bagian dari path gambar default jika ada
    final String fullImagePath = 'assets/images/${product.image}'; 
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: DonatopiaColors.backgroundSoftPink, width: 2),
        boxShadow: [
          BoxShadow(color: const Color.fromARGB(255, 253, 188, 188).withOpacity(0.05), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Gambar Produk
            Flexible(
              flex: 3, 
              child: Align(
                alignment: Alignment.center,
                child: Image.asset(
                  fullImagePath, 
                  width: 80, 
                  height: 85, 
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback untuk Gambar yang tidak ditemukan
                    return const Icon(Icons.broken_image, color: DonatopiaColors.secondaryText, size: 50);
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Nama Produk
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Text(
                product.name, 
                textAlign: TextAlign.left, 
                style: const TextStyle(
                  fontSize: 10, 
                  fontWeight: FontWeight.w800, 
                  color: DonatopiaColors.darkText, 
                  height: 1.1
                ),
                maxLines: 2, 
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            // Kategori
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Text(
                product.category.toLowerCase(), 
                textAlign: TextAlign.left, 
                style: const TextStyle(
                  fontSize: 9, 
                  fontWeight: FontWeight.w400, 
                  color: DonatopiaColors.secondaryText
                )
              ),
            ),
            
            // Harga
            Padding(
              padding: const EdgeInsets.only(top: 4.0, bottom: 8.0, left: 4.0),
              child: Text(
                formattedPrice, 
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontSize: 10, 
                  fontWeight: FontWeight.bold, 
                  color: DonatopiaColors.cardValueColor
                )
              ),
            ),
            
            const Spacer(), 
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0), 
              child: InkWell(
                onTap: () {
                  // Aksi: Tampilkan Modal Edit Produk
                  _showEditProductModal(product); 
                },
                child: Container(
                  height: 25, 
                  decoration: BoxDecoration(
                    color: DonatopiaColors.searchBarBackground,
                    borderRadius: BorderRadius.circular(8), 
                    border: Border.all(color: DonatopiaColors.backgroundSoftPink)
                  ),
                  child: const Center(
                    child: Icon(Icons.edit, color: DonatopiaColors.darkText, size: 18) 
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                _confirmDeleteProduct(product);
              },
              child: Container(
                height: 25,
                decoration: BoxDecoration(
                  color: DonatopiaColors.cardValueColor, // Warna merah gelap untuk Delete
                  borderRadius: BorderRadius.circular(8), 
                ),
                child: const Center(
                  child: Icon(Icons.delete_outline, color: Colors.white, size: 18) 
                ),
              ),
            ),
          ],
        ),
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
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22.5),
                color: DonatopiaColors.headerTextColor.withOpacity(0.1),
              ),
              child: ClipRRect( 
                borderRadius: BorderRadius.circular(22.5),
                child: Image.asset(
                  'assets/images/donatopia.png', 
                  fit: BoxFit.cover, 
                  width: 45, 
                  height: 45, 
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.donut_large, color: DonatopiaColors.cardValueColor, size: 28);
                  },
                ),
              ),
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
                  'Produk',
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
        
        // >>> INI ADALAH TOMBOL UNTUK MEMBUKA SIDEBAR <<<
        Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: DonatopiaColors.darkText, size: 28),
              onPressed: () => Scaffold.of(context).openEndDrawer(), 
            );
          }
        ),
      ],
    );
  }
}