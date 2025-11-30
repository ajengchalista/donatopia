import 'package:flutter/material.dart';
import 'package:donatopia/fitur/dashboard/dashboard_screen.dart';
import 'package:donatopia/fitur/kasir/kasir_page.dart';
import 'package:donatopia/fitur/produk/produk_page.dart';
import 'package:donatopia/fitur/pelanggan/pelanggan_page.dart';
import 'package:donatopia/fitur/manajemen_pengguna/manajemen_pengguna_page.dart';
import 'package:donatopia/fitur/laporan/laporan_penjualan.dart';
import 'package:donatopia/fitur/stok/stok_page.dart';

// ✅ IMPORT KRITIS: PASTIKAN INI ADALAH LOKASI LOGIN PAGE ANDA
import 'package:donatopia/fitur/auth/screen/login_screen.dart'; 

// Definisi Warna
const Color primaryRedPink = Color(0xFFCC6073); 
const Color highlightPink = Color(0xFFFDE6E9); 
const Color cardLabelColor = Color.fromARGB(255, 139, 133, 134); 
const Color darkText = Colors.black87;

PreferredSize buildCustomAppBar() {
  return PreferredSize(
    preferredSize: const Size.fromHeight(56.0),
    child: AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      title: const Text('Donatopia', style: TextStyle(color: Colors.black87)),
      automaticallyImplyLeading: false,
      actions: [
        Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.black54),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    ),
  );
}

class CustomDrawer extends StatelessWidget {
  final String currentRoute;
  const CustomDrawer({super.key, required this.currentRoute});

  // Route constants
  static const String routeDashboard = '/dashboard';
  static const String routeKasir = '/kasir';
  static const String routeProduk = '/produk';
  static const String routePelanggan = '/pelanggan';
  static const String routeLaporan = '/laporan';
  static const String routeManajemen = '/manajemen';
  static const String routeStokBarang = '/stok';


  // ----------------------------------------------------
  // FUNGSI 1: Logika Navigasi Aman ke Halaman Login (THE FIX)
  // ----------------------------------------------------
  void _handleLogout(BuildContext context) {
    // Navigasi yang aman: menghapus semua route sebelumnya dan menavigasi ke halaman Login.
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()), 
      (Route<dynamic> route) => false, 
    );
  }

  // ----------------------------------------------------
  // FUNGSI 2: Menampilkan Dialog Konfirmasi Logout
  // ----------------------------------------------------
  void _showLogoutConfirmation(BuildContext context) {
    // Tutup drawer terlebih dahulu sebelum dialog muncul
    if (Scaffold.of(context).isEndDrawerOpen) {
        Navigator.of(context).pop(); 
    }

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          // Styling
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          
          title: const Text(
            'Konfirmasi Logout',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.bold, 
              color: darkText
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'Apakah Anda yakin ingin keluar dari akun Anda?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14, 
                  color: cardLabelColor
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Tombol Batal
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      style: TextButton.styleFrom(
                        backgroundColor: highlightPink, 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text('Batal', style: TextStyle(color: primaryRedPink, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                
                // Tombol Logout
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: TextButton(
                      onPressed: () {
                        // Tutup dialog DULU
                        Navigator.of(dialogContext).pop(); 
                        
                        // Lakukan logout dan navigasi ke halaman Login yang sesungguhnya
                        _handleLogout(dialogContext);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: primaryRedPink, 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text('Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10), // Padding bawah
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 250,
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // Header Menu
          Container(
            padding: const EdgeInsets.only(top: 40, bottom: 20, left: 16, right: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Menu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.black54),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Profil Admin
          _buildUserHeader(),

          const SizedBox(height: 10),

          // Dashboard
          _buildDrawerItem(
            context,
            icon: Icons.dashboard_outlined,
            title: 'Dashboard',
            route: DashboardScreen.routeName,
            onTap: () => _navigateTo(context, const DashboardScreen()),
          ),

          // Kasir
          _buildDrawerItem(
            context,
            icon: Icons.shopping_cart_outlined,
            title: 'Kasir',
            route: routeKasir,
            onTap: () => _navigateTo(context, const KasirPage()),
          ),

          // Produk
          _buildDrawerItem(
            context,
            icon: Icons.inventory_2_outlined,
            title: 'Produk',
            route: ProdukPage.routeName,
            onTap: () => _navigateTo(context, const ProdukPage()),
          ),

          // Pelanggan
          _buildDrawerItem(
            context,
            icon: Icons.person_outline,
            title: 'Pelanggan',
            route: PelangganPage.routeName,
            onTap: () => _navigateTo(context, const PelangganPage()),
          ),

          // Manajemen Pengguna
          _buildDrawerItem(
            context,
            icon: Icons.people_alt_outlined,
            title: 'Manajemen Pengguna',
            route: ManajemenPenggunaPage.routeName,
            onTap: () => _navigateTo(context, const ManajemenPenggunaPage()),
          ),

          // Laporan
          _buildDrawerItem(
            context,
            icon: Icons.bar_chart_outlined,
            title: 'Laporan',
            route: LaporanPenjualanPage.routeName,
            onTap: () => _navigateTo(context, const LaporanPenjualanPage()),
          ),

          // Stok (placeholder)
          _buildDrawerItem(
            context,
            icon: Icons.storage_outlined,
            title: 'Stok',
            route: StokBarangPage.routeName,
            onTap: () => _navigateTo(context, const StokBarangPage()),
          ),

          const SizedBox(height: 30),

          // Logout
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.pop(context); // Tutup drawer
    // Pengecekan route name agar tidak navigasi ulang ke halaman yang sama
    final currentRouteName = ModalRoute.of(context)?.settings.name;
    final targetRouteName = page is DashboardScreen ? DashboardScreen.routeName : 
                              page is KasirPage ? routeKasir : 
                              page is ProdukPage ? ProdukPage.routeName : 
                              page is PelangganPage ? PelangganPage.routeName : 
                              page is ManajemenPenggunaPage ? ManajemenPenggunaPage.routeName : 
                              page is LaporanPenjualanPage ? LaporanPenjualanPage.routeName : 
                              page is StokBarangPage ? StokBarangPage.routeName : 
                              '';
                                
    if (currentRouteName != targetRouteName) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => page,
          settings: RouteSettings(name: targetRouteName),
        ),
      );
    }
  }

  Widget _buildUserHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 45, height: 45,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: highlightPink),
            child: ClipOval(
              child: Image.asset(
                'assets/images/donatopia.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.account_circle, color: primaryRedPink, size: 30),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Admin Toko', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
              Text('Admin', style: TextStyle(fontSize: 12, color: cardLabelColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
    VoidCallback? onTap,
  }) {
    final bool isActive = currentRoute == route;
    final Color bgColor = isActive ? highlightPink : Colors.white;
    final Color iconColor = isActive ? primaryRedPink : cardLabelColor;
    final Color textColor = isActive ? primaryRedPink : darkText;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 24),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          // Panggil fungsi konfirmasi logout
          onTap: () => _showLogoutConfirmation(context), 
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: const Row(
              children: [
                Icon(Icons.logout, color: primaryRedPink, size: 24),
                SizedBox(width: 16),
                Text('Logout', style: TextStyle(color: primaryRedPink, fontWeight: FontWeight.w600, fontSize: 15)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}