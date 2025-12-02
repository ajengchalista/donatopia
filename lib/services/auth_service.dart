import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient supabase = Supabase.instance.client;

  /// -------------------------
  /// LOGIN USER
  /// -------------------------
  Future<String?> login(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session != null) {
        return null; // sukses
      } else {
        return "Email atau password salah!";
      }
    } on AuthException catch (e) {
      return e.message; // error dari Supabase
    } catch (e) {
      return e.toString();
    }
  }

  /// -------------------------
  /// REGISTER USER BARU
  /// -------------------------
  Future<String?> register(String email, String password) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return null; // sukses
      } else {
        return "Pendaftaran gagal!";
      }
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  /// -------------------------
  /// LOGOUT USER
  /// -------------------------
  Future<void> logout() async {
    await supabase.auth.signOut();
  }
}