import 'package:flutter/material.dart';
import '../controllers/reset_password_controller.dart';
import '../responses/reset_password_response.dart';
import '../widgets/input_password.dart';
import '../widgets/button_primary.dart';
import 'login_screen.dart';
import '../widgets/input_konfir_password.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({super.key, required this.email});

  @override
  ResetPasswordScreenState createState() => ResetPasswordScreenState();
}

class ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final ResetPasswordController _resetPasswordController =
      ResetPasswordController();
  bool _isLoading = false;
  String? passwordError;
  String? confirmPasswordError;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _resetPassword() async {
    setState(() {
      passwordError =
          _passwordController.text.isEmpty ? "Password wajib diisi." : null;
      confirmPasswordError = _confirmPasswordController.text.isEmpty
          ? "Konfirmasi password wajib diisi."
          : null;
    });

    if (passwordError != null || confirmPasswordError != null) {
      return;
    }

    setState(() => _isLoading = true);

    ResetPasswordResponse response =
        await _resetPasswordController.resetPassword(
      email: widget.email,
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    setState(() => _isLoading = false);

    if (response.success) {
      if (!mounted) return; // Pastikan widget masih ada sebelum akses context

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password berhasil diubah!"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } else {
      setState(() {
        passwordError = null;
        confirmPasswordError = null;

        if (response.error == "Password wajib diisi.") {
          passwordError = response.error;
        } else if (response.error == "Minimal panjang password 8 karakter") {
          passwordError = response.error;
        } else if (response.error == "Password tidak valid") {
          passwordError = response.error;
        } else if (response.error == "Password harus mengandung simbol") {
          passwordError = response.error;
        } else if (response.error == "Konfirmasi password wajib diisi.") {
          confirmPasswordError = response.error;
        } else if (response.error == "Konfirmasi password tidak cocok.") {
          confirmPasswordError = response.error;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(response.error ?? "Gagal mengubah password"),
                backgroundColor: Colors.red),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Reset Password"),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black),
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
                          externalError:
                              passwordError, // 🔥 Menampilkan error jika ada
                        ),
                        const SizedBox(height: 15),

                        // Input Konfirmasi Password
                        InputKonfirPassword(
                          controller: _confirmPasswordController,
                          passwordController: _passwordController,
                          externalError:
                              confirmPasswordError, // 🔥 Menampilkan error jika ada
                        ),
                        const SizedBox(height: 15),

                        // Tombol Simpan Password
                        SizedBox(
                          height: 50.0,
                          width: double.infinity,
                          child: ButtonPrimary(
                            text: _isLoading ? '' : 'Simpan Password',
                            onPressed: _isLoading ? null : _resetPassword,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  )
                                : null,
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
