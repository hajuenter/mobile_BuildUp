import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../widgets/input_email.dart';
import '../widgets/input_password.dart';
import '../widgets/button_primary.dart';
import '../widgets/input_text_field.dart';
import '../widgets/input_konfir_password.dart';
import '../controllers/register_controller.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final RegisterController _registerController = RegisterController();

  Map<String, String> _errors = {};
  bool _isLoading = false; // 🔹 State untuk loading

  void _handleRegister() async {
    setState(() {
      _isLoading = true;
      _errors.clear();
    });

    final errorMessages = await _registerController.registerUser(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    if (errorMessages == null) {
      if (!mounted) return; // Cek apakah widget masih ada

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Registrasi berhasil, silakan tunggu konfirmasi Admin!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    } else {
      setState(() {
        _errors = errorMessages;
      });
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                    child: AbsorbPointer(
                      absorbing: _isLoading,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AspectRatio(
                            aspectRatio: 3 / 2,
                            child: SvgPicture.asset(
                              'assets/logonew.svg', // Gunakan SvgPicture.asset
                              width: constraints.maxWidth * 0.25,
                              height: constraints.maxHeight * 0.12,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Buat Akun Baru",
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Mohon input data dengan baik dan benar',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),

                          InputTextField(
                            label: "Nama",
                            controller: _nameController,
                            icon: Icons.person,
                            externalError: _errors["name"],
                          ),
                          const SizedBox(height: 15),

                          InputEmail(
                            controller: _emailController,
                            externalError: _errors["email"],
                          ),
                          const SizedBox(height: 15),

                          InputPassword(
                            controller: _passwordController,
                            showValidation: true,
                            externalError: _errors["password"],
                            isLogin: false,
                          ),
                          const SizedBox(height: 15),

                          InputKonfirPassword(
                            controller: _confirmPasswordController,
                            passwordController: _passwordController,
                            externalError: _errors["confirmPassword"],
                          ),
                          const SizedBox(height: 25),

                          // 🔹 Tombol Daftar dengan Loading
                          SizedBox(
                            height: 50.0,
                            width: double.infinity,
                            child: ButtonPrimary(
                              text: "Daftar",
                              onPressed: _isLoading ? null : _handleRegister,
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 10),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Sudah punya akun? "),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    PageRouteBuilder(
                                      transitionDuration:
                                          const Duration(milliseconds: 200),
                                      pageBuilder: (context, animation,
                                              secondaryAnimation) =>
                                          const LoginScreen(),
                                      transitionsBuilder: (context, animation,
                                          secondaryAnimation, child) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Login",
                                  style: TextStyle(
                                    color: Color(0xFF0D6EFD),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 5,
                          )
                        ],
                      ),
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
