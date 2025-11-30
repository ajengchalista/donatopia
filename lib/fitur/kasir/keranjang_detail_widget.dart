import 'package:flutter/material.dart';
import 'package:donatopia/fitur/kasir/models.dart'; 
import 'package:donatopia/fitur/kasir/struk_pembayaran_page.dart'; 


class DonatopiaColors {
  static const Color cardBackground = Colors.white;
  static const Color cardValueColor = Color(0xFFCC6073); // Pink gelap/merah muda
  static const Color cardLabelColor = Color.fromARGB(255, 139, 133, 134); // Abu-abu gelap
  static const Color activeButtonBg = Color.fromARGB(255, 250, 124, 147); // Pink terang
  static const Color headerPink = Color.fromARGB(255, 240, 153, 169); 
  static const Color totalDiscountColor = Color(0xFFCC6073);
  static const Color secondaryText = Color(0xFF999999); // PERBAIKAN: Ditambahkan
  static const Color backgroundSoftPink = Color.fromARGB(255, 240, 229, 231); 
}


class KeranjangDetailWidget extends StatefulWidget {
  final List<CartItem> items;
  // Callback untuk memberitahu KasirPage jika keranjang berubah/kosong
  final Function(List<CartItem>)? onCartUpdated; 

  const KeranjangDetailWidget({
    super.key, 
    required this.items,
    this.onCartUpdated
  });

  @override
  State<KeranjangDetailWidget> createState() => _KeranjangDetailWidgetState();
}

class _KeranjangDetailWidgetState extends State<KeranjangDetailWidget> {
  late List<CartItem> _cartItems;
  // State untuk input pelanggan
  String _customerName = ''; 
  final TextEditingController _customerController = TextEditingController();
  String _selectedPaymentMethod = 'Debet'; // Default Debet

  @override
  void initState() {
    super.initState();
    // Inisialisasi keranjang dengan item yang kuantitasnya > 0
    _cartItems = List.from(widget.items.where((item) => item.quantity > 0)); 
    
    // Inisialisasi controller, label default 'Caca' dihapus agar terlihat kosong
    _customerController.text = _customerName;
    _customerController.addListener(() {
        _customerName = _customerController.text;
    });
  }

  @override
  void dispose() {
    _customerController.dispose();
    super.dispose();
  }
  
  double get _subtotal {
    return _cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  double get _discount {
    // Logika diskon sesuai gambar: Diskon Rp 4.000 jika subtotal >= Rp 10.000
    return _subtotal >= 10000.0 ? 4000.0 : 0.0;
  }

  double get _total {
    double total = _subtotal - _discount;
    // Pastikan total tidak negatif
    return total > 0 ? total : 0.0;
  }

  void _updateQuantity(CartItem item, int change) {
    setState(() {
      item.quantity += change;
      if (item.quantity <= 0) {
        _cartItems.remove(item);
      }
    });
    // Panggil callback untuk update state di KasirPage
    widget.onCartUpdated?.call(_cartItems);
  }

  void _removeItem(CartItem item) {
    setState(() {
      _cartItems.remove(item);
    });
    widget.onCartUpdated?.call(_cartItems);
  }

  String _formatRupiah(double amount) {
    String value = amount.toStringAsFixed(0);
    String result = '';
    int count = 0;
    for (int i = value.length - 1; i >= 0; i--) {
        count++;
        result = value[i] + result;
        if (count % 3 == 0 && i != 0) {
            result = '.' + result;
        }
    }
    return 'Rp $result';
  }


  @override
  Widget build(BuildContext context) {
    final double maxHeight = MediaQuery.of(context).size.height * 0.9; 

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      color: DonatopiaColors.backgroundSoftPink, 
      child: Container(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
        decoration: const BoxDecoration(
          color: DonatopiaColors.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildCartHeader(context),
            const SizedBox(height: 10),

            _buildCustomerInput(),
            const SizedBox(height: 10),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0), 
                child: _cartItems.isEmpty 
                    ? _buildEmptyCart()
                    : ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: _cartItems.length,
                        itemBuilder: (context, index) {
                          return _buildCartItem(_cartItems[index]);
                        },
                      ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                children: [
                  const Divider(thickness: 1, height: 20),
                  // Ringkasan Total
                  _buildSummaryRow('Subtotal:', _formatRupiah(_subtotal).split(' ')[1]), 
                  const SizedBox(height: 5),
                  _buildSummaryRow('Disc:', _formatRupiah(_discount).split(' ')[1], color: DonatopiaColors.totalDiscountColor),
                  const SizedBox(height: 5),
                  _buildSummaryRow('Total:', _formatRupiah(_total).split(' ')[1], isTotal: true, color: DonatopiaColors.totalDiscountColor),
                  const SizedBox(height: 10),

                  _buildPaymentMethodDropdown(),
                  const SizedBox(height: 15),

                  _buildPayButton(context),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
  // --- Widget Pembantu: Header & Input ---

  Widget _buildCartHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          '🛒 Keranjang (1)', 
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildCustomerInput() {
    return Container(
      padding: const EdgeInsets.only(left: 12, top: 4, bottom: 4, right: 12),
      decoration: BoxDecoration(
        color: DonatopiaColors.headerPink.withOpacity(0.2), 
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.person, color: Colors.black87, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: IntrinsicHeight(
              child: TextField(
                controller: _customerController,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Pelanggan',
                  hintText: _customerName.isEmpty ? '' : null, // Placeholder 'Caca'
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.remove_shopping_cart, size: 50, color: DonatopiaColors.cardLabelColor.withOpacity(0.5)),
          const SizedBox(height: 10),
          const Text('Keranjang kosong', style: TextStyle(color: DonatopiaColors.cardLabelColor)),
        ],
      ),
    );
  }
  
  // --- Widget Pembantu: Item Keranjang ---

  Widget _buildCartItem(CartItem item) {
    final itemTotal = item.price * item.quantity;
    return Container(
      margin: const EdgeInsets.only(bottom: 10.0), 
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: DonatopiaColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: DonatopiaColors.headerPink.withOpacity(0.3))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 5),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _formatRupiah(item.price), 
                style: const TextStyle(fontSize: 14, color: DonatopiaColors.secondaryText),
              ),
              
              // Kontrol Kuantitas
              Row(
                children: [
                  // Tombol Minus
                  _buildQuantityButton(Icons.remove, () => _updateQuantity(item, -1), isLeft: true, isRed: true),
                  // Display Quantity
                  Container(
                    width: 30,
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      border: Border.symmetric(horizontal: BorderSide(color: DonatopiaColors.cardLabelColor.withOpacity(0.3)))
                    ),
                    child: Text(
                      item.quantity.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                  // Tombol Plus
                  _buildQuantityButton(Icons.add, () => _updateQuantity(item, 1), isLeft: false, isRed: true),
                ],
              ),

              // Tombol Hapus & Total Harga
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _removeItem(item),
                    child: const Icon(
                      Icons.delete,
                      color: DonatopiaColors.totalDiscountColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Total Harga Item
                  Text(
                    _formatRupiah(itemTotal).split(' ')[1], 
                    style: const TextStyle(
                      color: DonatopiaColors.cardValueColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback onTap, {required bool isLeft, required bool isRed}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: DonatopiaColors.cardLabelColor.withOpacity(0.3)),
        borderRadius: BorderRadius.horizontal(
          left: isLeft ? const Radius.circular(5) : Radius.zero,
          right: isLeft ? Radius.zero : const Radius.circular(5),
        )
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
          child: Icon(
            icon, 
            size: 18, 
            color: isRed ? DonatopiaColors.cardValueColor : DonatopiaColors.cardLabelColor
          ),
        ),
      ),
    );
  }


  // --- Widget Pembantu: Ringkasan & Pembayaran ---

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14, 
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.black : Colors.black87,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodDropdown() {
    final List<Map<String, dynamic>> paymentOptions = [
      {'value': 'Debet', 'label': 'Debet', 'icon': Icons.credit_card, 'icon_color': Colors.blue},
      {'value': 'Tunai', 'label': 'Tunai', 'icon': Icons.attach_money, 'icon_color': Colors.green[700]},
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Metode Pembayaran', style: TextStyle(fontSize: 14, color: Colors.black54)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: DonatopiaColors.cardLabelColor.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedPaymentMethod,
              icon: const Icon(Icons.keyboard_arrow_down),
              isExpanded: true,
              items: paymentOptions
                  .map<DropdownMenuItem<String>>((option) {
                return DropdownMenuItem<String>(
                  value: option['value'] as String,
                  child: Row(
                    children: [
                      Icon(option['icon'] as IconData, size: 20, color: option['icon_color'] as Color),
                      const SizedBox(width: 8),
                      Text(option['label'] as String),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedPaymentMethod = newValue;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPayButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        // Tombol non-aktif jika keranjang kosong
        onPressed: _cartItems.isEmpty ? null : () {
          widget.onCartUpdated?.call(_cartItems); 
          
          Navigator.pop(context); // Tutup modal keranjang
          
          // ❗ NAVIGASI KE HALAMAN STRUK
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StrukPembayaranPage(
                customerName: _customerName.isEmpty ? 'Umum' : _customerName,
                cartItems: _cartItems,
                subtotal: _subtotal,
                discount: _discount,
                total: _total,
                paymentMethod: _selectedPaymentMethod,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: DonatopiaColors.activeButtonBg,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          foregroundColor: _cartItems.isEmpty ? Colors.black38 : Colors.white, 
          elevation: 0,
        ),
        child: const Text(
          'Bayar Sekarang',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}