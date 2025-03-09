import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/input_password.dart';
import '../widgets/button_primary.dart';
import 'login_screen.dart';
import '../widgets/input_konfir_password.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email; // Tambahkan email sebagai parameter

  const ResetPasswordScreen({super.key, required this.email});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false; // Untuk menunjukkan status loading

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _resetPassword() async {
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    if (password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Password tidak boleh kosong'),
            backgroundColor: Colors.red),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Konfirmasi password tidak cocok'),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final response = await _apiService.resetPassword(
      widget.email,
      password,
      confirmPassword,
    );

    setState(() {
      _isLoading = false;
    });

    if (response != null && response['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
              'Password berhasil diubah!',
              style: TextStyle(color: Colors.white), // Teks putih
            ),
            backgroundColor: Colors.green),
      );

      // Kembali ke halaman login setelah reset password sukses
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false, // Hapus semua halaman sebelumnya
      );
    } else if (response != null && response['errors'] != null) {
      String errorMessage =
          response['errors'].values.first[0]; // Ambil error pertama
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(errorMessage, style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.red),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
              'Gagal mengubah password',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Reset Password"),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        titleTextStyle: const TextStyle(
          color: Colors.black,
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 40,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: constraints.maxWidth * 0.08),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        AspectRatio(
                          aspectRatio: 3 / 2,
                          child: SvgPicture.asset(
                            'assets/logonew.svg',
                            width: constraints.maxWidth * 0.25,
                            height: constraints.maxHeight * 0.12,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Masukkan Password Baru',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Mohon masukkan password baru Anda',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),
                        // Input Password Baru
                        InputPassword(
                          controller: _passwordController,
                          showValidation: false,
                          isLogin: false,
                        ),
                        const SizedBox(height: 15),
                        // Input Konfirmasi Password
                        InputKonfirPassword(
                          controller: _confirmPasswordController,
                          passwordController: _passwordController,
                        ),
                        const SizedBox(height: 15),
                        // Tombol Simpan Password
                        SizedBox(
                          height: 50.0,
                          width: double.infinity,
                          child: _isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                )) // Tampilkan loading jika sedang proses
                              : ButtonPrimary(
                                  text: 'Simpan Password',
                                  onPressed: _resetPassword,
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
