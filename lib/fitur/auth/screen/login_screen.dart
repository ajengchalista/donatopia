import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _emailError = '';
  String _passwordError = '';
  String _generalError = ''; // untuk error login (email/pass salah)

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Reset error
    setState(() {
      _emailError = '';
      _passwordError = '';
      _generalError = '';
    });

    // Validasi Email
    if (email.isEmpty) {
      setState(() => _emailError = 'Email wajib diisi.');
      return;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      setState(() => _emailError = 'Format email tidak valid.');
      return;
    }

    // Validasi Password
    if (password.isEmpty) {
      setState(() => _passwordError = 'Kata sandi wajib diisi.');
      return;
    }
    if (password.length < 6) {
      setState(() => _passwordError = 'Kata sandi minimal 6 karakter.');
      return;
    }

    try {
      final response = await Supabase.instance.client.auth
          .signInWithPassword(email: email, password: password);

      if (response.user != null) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      }
    } catch (e) {
      setState(() {
        _generalError = 'kata sandi salah.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 215, 221),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLogo(),
              const SizedBox(height: 15),

              const Text(
                'Donatopia',
                style: TextStyle(
                  color: Color.fromARGB(255, 240, 153, 169),
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'Sistem Kasir & Manajemen',
                style: TextStyle(
                  color: Color.fromRGBO(110, 105, 105, 0.871),
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 40),

              // EMAIL FIELD + ERROR DI BAWAHNYA
              _buildInputField(
                controller: _emailController,
                label: 'Email',
                hint: 'Masukkan email',
                errorText: _emailError,
              ),
              const SizedBox(height: 18),

              // PASSWORD FIELD + ERROR DI BAWAHNYA
              _buildInputField(
                controller: _passwordController,
                label: 'Kata Sandi',
                hint: 'Masukkan kata sandi',
                isPassword: true,
                errorText: _passwordError,
              ),

              // General error (email/pass salah dari server)
              if (_generalError.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _generalError,
                      style: const TextStyle(
                        color: Color(0xFFCC6073),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 35),
              _buildLoginButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 90,
      height: 90,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color.fromARGB(255, 248, 204, 211),
      ),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(60),
          child: Image.asset(
            'assets/images/donatopia.png',
            fit: BoxFit.cover,
            width: 100,
            height: 100,
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isPassword = false,
    String errorText = '',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.black, fontSize: 15),
        ),
        const SizedBox(height: 8),

        TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color.fromARGB(255, 249, 206, 210),
            hintText: hint,
            hintStyle: const TextStyle(color: Color.fromARGB(255, 139, 133, 134), fontSize: 15),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 216, 205, 206),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 240, 169, 179),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          ),
        ),

        // ERROR TEXT UNTUK KOLOM INI
        if (errorText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 3),
            child: Text(
              errorText,
              style: const TextStyle(
                color: Color(0xFFCC6073),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 250, 124, 147),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Login',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}