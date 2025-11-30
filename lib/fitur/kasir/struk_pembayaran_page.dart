import 'package:flutter/material.dart';
import 'package:donatopia/fitur/kasir/models.dart'; 

class DonatopiaColors {
  static const Color backgroundSoftPink = Color.fromARGB(255, 240, 229, 231);
  static const Color cardValueColor = Color(0xFFCC6073);
  static const Color headerPink = Color.fromARGB(255, 240, 153, 169);
  static const Color darkText = Color(0xFF636363);
  static const Color activeButtonBg = Color.fromARGB(255, 250, 124, 147);
}

class StrukPembayaranPage extends StatelessWidget {
  final String customerName;
  final List<CartItem> cartItems;
  final double subtotal;
  final double discount;
  final double total;
  final String paymentMethod;

  const StrukPembayaranPage({
    super.key,
    required this.customerName,
    required this.cartItems,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.paymentMethod,
  });

  final String _storeName = 'Donatopia';
  final String _address = 'Jl. Trisula Panggang Lele';
  final String _phone = '089689708118';
  final String _ig = 'ig : Donatopia';
  
  // Tanggal Transaksi
  String _getFormattedDate() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year}, ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  // Nomor Transaksi Random
  String _generateTransactionNumber() {
    final now = DateTime.now();
    // Format: TRX20251015167153 (TRX + YYYYMMDD + random 3 digit)
    final datePart = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final randomPart = (now.millisecondsSinceEpoch % 1000000).toString().padLeft(6, '0');
    return 'TRX$datePart$randomPart';
  }

  String _formatRupiah(double amount, {bool includeRp = true}) {
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
    return includeRp ? 'Rp. $result' : result;
  }

  @override
  Widget build(BuildContext context) {
    // Transaksi data yang akan ditampilkan
    final transactionDate = _getFormattedDate();
    final transactionNo = _generateTransactionNumber();

    return Scaffold(
      backgroundColor: DonatopiaColors.backgroundSoftPink,
      appBar: AppBar(
        title: const Text('Struk Pembayaran'),
        backgroundColor: DonatopiaColors.headerPink,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Container(
          // Ukuran Struk dinamis (sesuai gambar)
          margin: const EdgeInsets.all(25.0),
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: DonatopiaColors.headerPink, width: 2),
            // Bayangan pinggiran pink
            boxShadow: [
              BoxShadow(
                color: DonatopiaColors.headerPink.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Header Toko ---
              Text(
                _storeName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: DonatopiaColors.cardValueColor, // Warna pink gelap
                ),
              ),
              Text(_address, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: DonatopiaColors.darkText)),
              Text(_phone, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: DonatopiaColors.darkText)),
              Text(_ig, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: DonatopiaColors.darkText)),
              const Divider(height: 30, thickness: 1, color: Colors.black54),

              // --- Detail Transaksi ---
              _buildTransactionDetail('No. Transaksi :', transactionNo),
              _buildTransactionDetail('Tanggal :', transactionDate),
              _buildTransactionDetail('Kasir :', 'Admin Toko'), // Tetap Admin Toko
              _buildTransactionDetail('Pelanggan :', customerName),
              const SizedBox(height: 15),

              // --- Daftar Item ---
              ...cartItems.map((item) {
                // Total harga per item
                final itemTotal = _formatRupiah(item.price * item.quantity);
                // Detail Qty dan Harga Satuan
                final itemDetail = '${item.quantity} X ${_formatRupiah(item.price.toDouble())}';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            itemTotal.split(' ')[1], // Hanya angka tanpa Rp.
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Text(
                        itemDetail,
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                );
              }).toList(),

              const Divider(height: 20, thickness: 1),

              // --- Ringkasan Total ---
              _buildSummaryRow('Subtotal :', subtotal),
              _buildSummaryRow('Disc :', discount, isDiscount: true),
              const SizedBox(height: 5),
              _buildSummaryRow('Total :', total, isTotal: true),
              const SizedBox(height: 15),

              // --- Detail Pembayaran ---
              _buildTransactionDetail('Pembayaran :', paymentMethod, isBoldValue: true),
              const SizedBox(height: 30),

              // --- Penutup ---
              const Text(
                'Terima kasih atas kunjungan Anda!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              ),
              Text(
                '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      // --- Tombol Cetak ---
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              // Logika Cetak Struk (misalnya, membuat PDF atau menutup halaman)
              Navigator.pop(context); // Kembali ke KasirPage
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DonatopiaColors.activeButtonBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Cetak Struk',
              style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionDetail(String label, String value, {bool isBoldValue = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBoldValue ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false, bool isDiscount = false}) {
    // Mengambil hanya angka tanpa 'Rp.'
    final formattedAmount = _formatRupiah(amount, includeRp: false);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? DonatopiaColors.cardValueColor : Colors.black,
            ),
          ),
          Text(
            isTotal || isDiscount ? 'Rp. $formattedAmount' : formattedAmount,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isTotal ? DonatopiaColors.cardValueColor : (isDiscount ? DonatopiaColors.cardValueColor : Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}