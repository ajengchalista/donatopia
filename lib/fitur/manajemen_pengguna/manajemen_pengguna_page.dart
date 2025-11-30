import 'package:flutter/material.dart';
import 'package:donatopia/widgets/custom_drawer.dart'; 
import 'dart:math'; // Diperlukan untuk menghasilkan ID acak

// ----------------------------------------------------
// MODEL DATA
// ----------------------------------------------------
enum UserRole { admin, petugas }

class User {
  final String id;
  final String name;
  final UserRole role;

  User({required this.id, required this.name, required this.role});
}

// ----------------------------------------------------
// DEFINISI WARNA
// ----------------------------------------------------
class DonatopiaColors {
  static const Color backgroundSoftPink = Color.fromARGB(255, 240, 229, 231); 
  static const Color cardValueColor = Color(0xFFCC6073); 
  static const Color primaryPink = Color(0xFFF48FB1); 
  static const Color darkText = Color(0xFF636363);
  static const Color secondaryText = Color(0xFF999999);
  static const Color barBackgroundWhite = Color(0xFFFFFFFF);
  static const Color searchBarBackground = Color.fromARGB(255, 255, 245, 246);
  static const Color userCardBackground = Color.fromARGB(255, 255, 255, 255); 
  static const Color softPinkText = Color.fromRGBO(247, 178, 190, 1);

  static const Color adminRoleColor = Color(
    0xFFCC6073,
  ); 
  static const Color petugasRoleColor = Color(
    0xFFF48FB1,
  ); 

  static const Color addCardBackground = Color.fromARGB(255, 255, 235, 237);
  static const Color addIconColor = Color(0xFFCC6073);
}

// ----------------------------------------------------
// STATEFUL WIDGET UTAMA
// ----------------------------------------------------
class ManajemenPenggunaPage extends StatefulWidget {
  static const String routeName = '/manajemen-pengguna';

  const ManajemenPenggunaPage({super.key});

  @override
  State<ManajemenPenggunaPage> createState() => _ManajemenPenggunaPageState();
}

class _ManajemenPenggunaPageState extends State<ManajemenPenggunaPage> {
  String _searchText = '';
  late List<User> _allUsers;

  @override
  void initState() {
    super.initState();
    // Data Simulasi Pengguna
    _allUsers = [
      User(id: 'u1', name: 'Andy Hendra', role: UserRole.admin),
      User(id: 'u2', name: 'Jefri Nichol', role: UserRole.petugas),
      User(id: 'u3', name: 'Ajeng Febria', role: UserRole.admin),
      User(id: 'u4', name: 'Eny Sagita', role: UserRole.petugas),
      User(id: 'u5', name: 'Sza', role: UserRole.petugas),
    ];
  }

  List<User> get _filteredUsers {
    if (_searchText.isEmpty) {
      return _allUsers;
    }

    final searchLower = _searchText.toLowerCase();
    return _allUsers.where((user) {
      return user.name.toLowerCase().contains(searchLower);
    }).toList();
  }

  // ----------------------------------------------------
  // METODE BUILD
  // ----------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final filteredUsers = _filteredUsers;

    return Scaffold(
      backgroundColor: DonatopiaColors.backgroundSoftPink,

      // Mengaktifkan endDrawer (Side Bar Kanan)
      endDrawer: const CustomDrawer(currentRoute: ManajemenPenggunaPage.routeName),
      
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. WHITE HEADER (Mirip Produk/Pelanggan)
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
            // Menggunakan Builder untuk mendapatkan Context yang tepat
            child: Builder(
              builder: (headerContext) {
                return _buildHeader(headerContext);
              },
            ),
          ),

          // Konten Utama (Diberi padding horizontal)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 15.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. TITLE SECTION
                  _buildTitleSection(),
                  const SizedBox(height: 15),

                  // 3. SEARCH BAR
                  _buildSearchBar(),
                  const SizedBox(height: 20),

                  // 4. ADD BUTTONS
                  _buildAddButtons(),
                  const SizedBox(height: 25),

                  // 5. DAFTAR ADMIN & PETUGAS (Title)
                  const Text(
                    'Daftar Admin & Petugas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: DonatopiaColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // 6. USER LIST
                  ...filteredUsers.map((user) => _buildUserCard(user)).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // 1. WIDGET HEADER (Logo dan Menu) - TIDAK BERUBAH
  // ----------------------------------------------------
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // Ganti Ikon Cart dengan Gambar Asset (donatopia.png, ukuran 48)
            Container(
              width: 48, // Ukuran baru
              height: 48, // Ukuran baru
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: DonatopiaColors.primaryPink.withOpacity(0.1),
              ),
              // Menggunakan Image.asset untuk menampilkan gambar
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  'assets/images/donatopia.png', 
                  fit: BoxFit.cover, // Memastikan gambar mengisi container
                  width: 48,
                  height: 48,
                  // Jika donatopia.png memiliki latar belakang, ini akan membantu
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
                  'Manajemen Pengguna',
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

        // Ikon Menu/Sidebar
        IconButton(
          icon: const Icon(
            Icons.menu,
            color: DonatopiaColors.darkText,
            size: 28,
          ),
          onPressed: () {
            // Menggunakan Context yang diberikan Builder
            Scaffold.of(context).openEndDrawer(); 
          },
        ),
      ],
    );
  }

  // ----------------------------------------------------
  // 2. WIDGET TITLE SECTION - TIDAK BERUBAH
  // ----------------------------------------------------
  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Manajemen Pengguna',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: DonatopiaColors.cardValueColor, // Warna Pink Gelap
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Kelola admin dan petugas sistem Anda',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: DonatopiaColors.secondaryText.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------
  // 3. WIDGET SEARCH BAR - TIDAK BERUBAH
  // ----------------------------------------------------
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: DonatopiaColors.searchBarBackground,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: DonatopiaColors.secondaryText.withOpacity(0.4),
          width: 1.0,
        ),
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchText = value;
          });
        },
        decoration: const InputDecoration(
          hintText: 'Cari',
          border: InputBorder.none,
          hintStyle: TextStyle(
            color: DonatopiaColors.secondaryText,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: DonatopiaColors.secondaryText,
            size: 24,
          ),
          prefixIconConstraints: BoxConstraints(minWidth: 35),
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // 4. WIDGET ADD BUTTONS (Tambah Admin & Petugas) - TIDAK BERUBAH
  // ----------------------------------------------------
  Widget _buildAddButtons() {
    return Row(
      children: [
        // Tambah Admin
        Expanded(
          child: _buildAddCard(
            'Tambah Admin',
            Icons.person_add_alt_1,
            DonatopiaColors.adminRoleColor,
            () => _showAddUserModal(UserRole.admin),
          ),
        ),
        const SizedBox(width: 15),
        // Tambah Petugas
        Expanded(
          child: _buildAddCard(
            'Tambah Petugas',
            Icons.person_add_alt_1,
            DonatopiaColors.petugasRoleColor,
            () => _showAddUserModal(UserRole.petugas),
          ),
        ),
      ],
    );
  }

  Widget _buildAddCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: DonatopiaColors.addCardBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: color.withOpacity(0.5), 
              width: 1.5 // Nilai ini sudah 1.5
            ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // 6. WIDGET USER CARD - TIDAK BERUBAH
  // ----------------------------------------------------
  Widget _buildUserCard(User user) {
    final isPetugas = user.role == UserRole.petugas;
    final roleText = isPetugas ? 'Petugas' : 'Admin';
    final roleColor = isPetugas
        ? DonatopiaColors.petugasRoleColor
        : DonatopiaColors.adminRoleColor;

    return Card(
      elevation: 0, 
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
        decoration: BoxDecoration(
          color: DonatopiaColors.userCardBackground,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama Pengguna
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: DonatopiaColors.darkText,
                  ),
                ),
                const SizedBox(height: 5),
                // Role Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    roleText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: roleColor,
                    ),
                  ),
                ),
              ],
            ),

            // Tombol Hapus (Mirip ikon keranjang sampah warna pink)
            GestureDetector(
              onTap: () => _confirmDeleteUser(user),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: roleColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.delete_outline, color: roleColor, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // FUNGSI MODAL TAMBAH PENGGUNA (TIDAK BERUBAH)
  // ----------------------------------------------------

  void _showAddUserModal(UserRole role) {
    String roleName = role == UserRole.admin ? 'Admin' : 'Petugas';
    TextEditingController nameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    
    // Fungsi untuk menambahkan pengguna ke list (simulasi penyimpanan)
    void addUser(String name, UserRole role) {
      if (name.isNotEmpty) {
        final newUser = User(
          // Menghasilkan ID acak sederhana
          id: 'u${_allUsers.length + 1 + Random().nextInt(100)}',
          name: name,
          role: role,
        );
        setState(() {
          _allUsers.add(newUser);
        });
        Navigator.of(context).pop(); // Tutup modal
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$roleName "${name}" berhasil ditambahkan.')),
        );
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          contentPadding: const EdgeInsets.all(0),
          content: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Modal
                  Text(
                    'Tambah $roleName Baru',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: DonatopiaColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Lengkapi formulir untuk menambahkan pengguna baru',
                    style: TextStyle(
                      fontSize: 14,
                      color: DonatopiaColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Input Nama Lengkap
                  const Text(
                    'Nama Lengkap',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: DonatopiaColors.darkText,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildInputTextField(
                    controller: nameController,
                    hint: 'Masukkan Nama Lengkap',
                  ),
                  const SizedBox(height: 15),

                  // Input Password
                  const Text(
                    'Password',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: DonatopiaColors.darkText,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildInputTextField(
                    controller: passwordController,
                    hint: 'Masukkan Password',
                    isPassword: true,
                  ),
                  const SizedBox(height: 20),

                  // Tombol Aksi (Batal & Simpan)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Tombol Batal
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(
                                color: DonatopiaColors.primaryPink,
                                width: 1,
                              ),
                            ),
                          ),
                          child: const Text(
                            'Batal',
                            style: TextStyle(
                              color: DonatopiaColors.primaryPink,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      // Tombol Simpan
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Panggil fungsi simpan
                            addUser(nameController.text, role);
                            // Password diabaikan untuk sementara (simulasi)
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DonatopiaColors.primaryPink.withOpacity(0.8),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Simpan',
                            style: TextStyle(
                              color: DonatopiaColors.barBackgroundWhite,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ----------------------------------------------------
  // WIDGET BANTUAN UNTUK TEXTFIELD - TIDAK BERUBAH
  // ----------------------------------------------------
  Widget _buildInputTextField({
    required TextEditingController controller,
    required String hint,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: DonatopiaColors.searchBarBackground, // Warna pink muda
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: DonatopiaColors.darkText, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: DonatopiaColors.secondaryText),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // FUNGSI MODAL HAPUS PENGGUNA (TIDAK BERUBAH)
  // ----------------------------------------------------

  void _confirmDeleteUser(User user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text('Konfirmasi Hapus'),
          content: Text(
            'Apakah Anda yakin ingin menghapus pengguna "${user.name}"?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Batal',
                style: TextStyle(color: DonatopiaColors.secondaryText),
              ),
            ),
            TextButton(
              onPressed: () {
                // Implementasi logika hapus pengguna di sini
                setState(() {
                  _allUsers.removeWhere((u) => u.id == user.id);
                });
                Navigator.of(context).pop();
                // Opsional: tampilkan SnackBar konfirmasi
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}