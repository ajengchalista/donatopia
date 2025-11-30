import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  // Login dengan Email dan Password
  Future<String?> login(String email, String password) async {
    try {
      final res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      final session = res.session;
      
      // Mengembalikan 'Login berhasil' jika session tidak null, atau pesan gagal
      return session != null ? null : "Login gagal";
      
    } catch (e) {
      // Mengembalikan pesan error jika terjadi exception
      return e.toString();
    }
  }

  // Registrasi Akun Baru
  Future<String?> register(String email, String password) async {
    try {
      await supabase.auth.signUp(
        email: email,
        password: password,
      );
      
      // Mengembalikan null jika berhasil
      return null;
      
    } on AuthException catch (e) {
      // Mengembalikan pesan error dari Supabase Auth
      return e.message;
    } catch (e) {
      // Mengembalikan pesan error umum
      return e.toString();
    }
  }

  // Logout
  Future<void> logout() async {
    await supabase.auth.signOut();
  }
}