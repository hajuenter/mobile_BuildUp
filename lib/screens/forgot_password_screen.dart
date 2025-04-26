import 'package:flutter/material.dart';
import '../widgets/input_email.dart';
import '../widgets/button_primary.dart';
import '../controllers/send_otp_controller.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ForgotPasswordScreenState createState() => ForgotPasswordScreenState();
}

class ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final SendOtpController _sendOtpController = SendOtpController();
  bool _isLoading = false;
  String? _emailError;

  void _handleSendOtp() async {
    String email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _emailError = "Email tidak boleh kosong";
      });
      return;
    }

    setState(() {
      _emailError = null;
      _isLoading = true;
    });

    String? errorMessage = await _sendOtpController.sendOtp(context, email);

    if (errorMessage != null) {
      setState(() {
        _emailError = errorMessage;
      });
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Lupa Password'),
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
                          aspectRatio: 4 / 2,
                          child: SvgPicture.asset(
                            'assets/logonew.svg',
                            width: constraints.maxWidth * 0.25,
                            height: constraints.maxHeight * 0.12,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Masukkan Email Anda',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 15),
                        InputEmail(
                          controller: _emailController,
                          externalError: _emailError,
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          height: 50.0,
                          width: double.infinity,
                          child: ButtonPrimary(
                            text: _isLoading ? '' : 'Kirim OTP',
                            onPressed: _isLoading ? null : _handleSendOtp,
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
