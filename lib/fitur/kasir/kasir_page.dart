// kasir_page.dart

import 'package:flutter/material.dart';
import 'package:donatopia/widgets/custom_drawer.dart'; 
import 'package:donatopia/fitur/kasir/keranjang_detail_widget.dart'; 
import 'package:donatopia/fitur/kasir/models.dart'; 

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const CustomDrawer(currentRoute: KasirPage.routeName),
    );
  }
}
class ProductPage extends StatelessWidget {
  const ProductPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Produk')),
      body: const Center(child: Text('Halaman Produk (Placeholder)')),
    );
  }
}

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
}


class KasirPage extends StatefulWidget {
  static const String routeName = '/kasir'; 
    
  const KasirPage({super.key});
 
  @override
  State<KasirPage> createState() => _KasirPageState();
}


class _KasirPageState extends State<KasirPage> {
  bool _showNotification = false;
  String _notificationText = '';

  List<CartItem> _cartItems = [];

  final List<Map<String, dynamic>> donutProductsData = const [
    {"name": "BLUEBERRY BLISS", "price": 23000, "image": "blueberry_bliss.png", "width": 80.0, "height": 90.0},
    {"name": "SUNNY LEMON", "price": 21000, "image": "sunny_lemon.png", "width": 80.0, "height": 50.0},
    {"name": "PINKSBITEZ", "price": 24000, "image": "pinksbitez.png", "width": 65.0, "height": 65.0},
    {"name": "BLUSH BITE", "price": 23000, "image": "blush_bite.png", "width": 55.0, "height": 55.0}, 
    {"name": "SUNNY CRISP", "price": 19000, "image": "sunny_crisp.png", "width": 48.0, "height": 48.0},
    {"name": "CHOCO DRIP", "price": 20000, "image": "choco_drop.png", "width": 62.0, "height": 62.0},
    {"name": "VANILLUSH", "price": 17000, "image": "vanillush.png", "width": 52.0, "height": 52.0}, 
    {"name": "NUT CRAVE", "price": 19000, "image": "nut_crave.png", "width": 58.0, "height": 58.0},
  ];

  void _addToCart(String productName, int price) {
    setState(() {
      final index = _cartItems.indexWhere((item) => item.name == productName);

      if (index != -1) {
        _cartItems[index].quantity++;
      } else {
        _cartItems.add(CartItem(name: productName, price: price.toDouble(), quantity: 1));
      }

      _notificationText = productName; 
      _showNotification = true;
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showNotification = false;
        });
      }
    });
  }

  void _showCartDetails() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      builder: (BuildContext context) {
        return KeranjangDetailWidget(
          items: _cartItems, 
          onCartUpdated: (updatedItems) {
            setState(() {
              _cartItems = updatedItems;
            });
          },
        );
      },
    );
  }

  String _formatPrice(int price) {
    String priceStr = price.toString();
    String formatted = priceStr.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp. $formatted';
  }

  int get _totalCartCount {
    return _cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const CustomDrawer(currentRoute: KasirPage.routeName), 
        
      backgroundColor: DonatopiaColors.backgroundSoftPink, 
      
      body: Stack(
        children: [
          Column(
            children: [
              // HEADER
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
                child: Builder(
                  builder: (innerContext) => _buildHeader(innerContext),
                ), 
              ),
              
              // SEARCH BAR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0), 
                child: _buildSearchBar(),
              ),

              // PRODUCT GRID
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0, left: 16.0, right: 16.0),
                  child: GridView.builder(
                    padding: EdgeInsets.zero, 
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, 
                      childAspectRatio: 0.80, 
                      crossAxisSpacing: 10, 
                      mainAxisSpacing: 10, 
                    ),
                    itemCount: donutProductsData.length,
                    itemBuilder: (context, index) {
                      final product = donutProductsData[index];
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
          
          _buildFloatingCartButton(), 
          
          _buildNotificationBanner(),
        ],
      ),
    );
  }

  // --- Widget Pembantu: Notifikasi Banner ---
  Widget _buildNotificationBanner() {
    return Positioned(
      top: 160, 
      right: 16, 
      child: AnimatedOpacity(
        opacity: _showNotification ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: IgnorePointer(
          ignoring: !_showNotification, 
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              color: DonatopiaColors.searchBarBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: DonatopiaColors.primaryPink.withOpacity(0.5), width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: DonatopiaColors.primaryPink.withOpacity(0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline, color: DonatopiaColors.cardValueColor, size: 18),
                const SizedBox(width: 8),
                Text(
                  '$_notificationText ditambahkan',
                  style: const TextStyle(
                    color: DonatopiaColors.darkText,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 15),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showNotification = false;
                    });
                  },
                  child: const Icon(Icons.close, color: DonatopiaColors.secondaryText, size: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // --- Widget Pembantu: Header (Tombol Sidebar) ---
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
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset('assets/images/donatopia.png', width: 35, height: 35, fit: BoxFit.contain), 
                ],
              ),
            ),
            const SizedBox(width: 10), 
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Donatopia', style: TextStyle(color: DonatopiaColors.softPinkText, fontSize: 14, fontWeight: FontWeight.w800)),
                Text('Kasir', style: TextStyle(fontSize: 12, color: DonatopiaColors.darkText)),
              ],
            ),
          ],
        ),
        
        // TOMBOL UNTUK MEMBUKA SIDEBAR
        IconButton(
          icon: const Icon(Icons.menu, color: DonatopiaColors.darkText, size: 28), 
          onPressed: () {
            // 3. TAMBAHAN: Panggil openEndDrawer dengan aman
            Scaffold.of(context).openEndDrawer(); 
            
          },
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
        border: Border.all(
          color: DonatopiaColors.secondaryText.withOpacity(0.4), 
          width: 1.0
        ), 
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Cari produk...',
          border: InputBorder.none,
          hintStyle: TextStyle(color: DonatopiaColors.secondaryText, fontSize: 14, fontWeight: FontWeight.w400),
          prefixIcon: Icon(Icons.search, color: DonatopiaColors.secondaryText, size: 20),
          prefixIconConstraints: BoxConstraints(minWidth: 35), 
        ),
      ),
    );
  }

  Widget _buildProductCard(String name, int price, String imageAsset, double width, double height) {
    String formattedPrice = _formatPrice(price); 
    final String fullImagePath = 'assets/images/$imageAsset';
    
    return GestureDetector(
      onTap: () {
        _addToCart(name, price);
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
              width: width, height: height, margin: const EdgeInsets.only(bottom: 2), 
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10), 
                image: DecorationImage(image: AssetImage(fullImagePath), fit: BoxFit.cover),
              ),
            ),
            
            Text(name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: DonatopiaColors.darkText, height: 1.1)),
            Text(formattedPrice, style: const TextStyle(fontSize: 7, fontWeight: FontWeight.w500, color: DonatopiaColors.primaryPink)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFloatingCartButton() {
    return Positioned(
      bottom: 30, right: 20, 
      child: Stack(
        children: [
          // Tombol Keranjang Utama
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              color: DonatopiaColors.primaryPink, 
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: DonatopiaColors.primaryPink.withOpacity(0.5), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 3)),
              ],
            ),
            child: Material(
              color: Colors.transparent, 
              child: InkWell(
                onTap: _showCartDetails, 
                child: const Center(child: Icon(Icons.shopping_cart, color: Colors.white, size: 28)),
              ),
            ),
          ),
          
          // Badge (Counter)
          if (_totalCartCount > 0)
            Positioned(
              right: 0, 
              top: 0, 
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: DonatopiaColors.cardValueColor, 
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2), 
                ),
                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                child: Center(
                  child: Text(
                    _totalCartCount.toString(), 
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}