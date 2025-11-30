import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:donatopia/fitur/auth/screen/login_screen.dart'; 
// 1. Asumsi class DashboardScreen punya static routeName
import 'package:donatopia/fitur/dashboard/dashboard_screen.dart'; 
import 'package:donatopia/fitur/kasir/kasir_page.dart'; 
import 'package:donatopia/fitur/produk/produk_page.dart'; 
import 'package:donatopia/fitur/pelanggan/pelanggan_page.dart'; 
// 2. Mengubah asumsi nama class import menjadi StokPage
import 'package:donatopia/fitur/stok/stok_page.dart'; 
// 3. Mengubah asumsi nama class import menjadi LaporanPenjualanPage
import 'package:donatopia/fitur/laporan/laporan_penjualan.dart'; 


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase
  await Supabase.initialize(
    // Penting: Pastikan URL dan anonKey disembunyikan dalam produksi
    url: 'https://goyqzckzuomyekonggli.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdveXF6Y2t6dW9teWVrb25nZ2xpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI0NzA0MTAsImV4cCI6MjA3ODA0NjQxMH0.SGCEmThI0GsI6F51_E38F_7Y8S0w46e64tbTctncSG4',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Asumsi: Semua Page memiliki static const String routeName = 'nama_rute_di_sini';
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Donatopia Kasir', 
      
      // Definisikan Routes (Rute)
      routes: {
        // Rute awal
        '/': (context) => const LoginPage(), 

        // Rute Dashboard (Menggunakan DashboardScreen)
        DashboardScreen.routeName: (context) => const DashboardScreen(), 

        // Rute Fitur
        ProdukPage.routeName: (context) => const ProdukPage(),
        KasirPage.routeName: (context) => const KasirPage(), 
        PelangganPage.routeName: (context) => const PelangganPage(),
        
        // Menggunakan StokPage (mengoreksi StokBarangPage)
        StokBarangPage.routeName: (context) => const StokBarangPage(), 
        
        // Menggunakan LaporanPenjualanPage
        LaporanPenjualanPage.routeName: (context) => const LaporanPenjualanPage(),
      },
      
      initialRoute: '/',
    );
  }
}