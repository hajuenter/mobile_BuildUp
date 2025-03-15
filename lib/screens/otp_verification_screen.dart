import 'dart:async';
import 'package:flutter/material.dart';
import '../controllers/otp_verification_controller.dart';
import '../widgets/button_primary.dart';
import '../widgets/input_otp.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  const OtpVerificationScreen({super.key, required this.email});

  @override
  OtpVerificationScreenState createState() => OtpVerificationScreenState();
}

class OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  final OtpVerificationController _controller = OtpVerificationController();
  bool _isLoading = false;
  String? _errorText;

  Timer? _timer;
  int _remainingSeconds = 300; // 5 menit (300 detik)

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        _showTimeoutMessage();
      }
    });
  }

  void _showTimeoutMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Waktu OTP habis, silakan minta OTP baru."),
        backgroundColor: Colors.red,
      ),
    );

    // Navigasi kembali ke Forgot Password Screen
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    setState(() {
      _errorText = null; // ✅ Reset error sebelum validasi
      _isLoading = true;
    });

    String otp = _otpController.text.trim();

    // ✅ Jika OTP kosong atau kurang dari 4 digit, tampilkan error
    if (otp.isEmpty || otp.length != 4) {
      setState(() {
        _errorText = "Kode OTP harus diisi dan terdiri dari 4 digit";
        _isLoading = false;
      });
      return;
    }

    await _controller.verifyOtp(
      context,
      widget.email,
      otp,
      onError: (String error) {
        setState(() {
          _errorText = error;
          _isLoading = false;
        });
      },
    );

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Verifikasi OTP"),
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
                          "Masukkan 4 digit kode OTP",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),

                        // ✅ Input OTP yang otomatis menangani error
                        InputOtp(
                          controller: _otpController,
                          externalError:
                              _errorText, // Kirim error ke input field
                        ),

                        const SizedBox(height: 5),

                        // ✅ Timer
                        Text(
                          _remainingSeconds > 0
                              ? "Sisa waktu: ${_formatTime(_remainingSeconds)}"
                              : "Waktu habis, kembali ke Lupa Password",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _remainingSeconds > 0
                                ? Colors.black
                                : Colors.red,
                          ),
                        ),

                        const SizedBox(height: 10),

                        SizedBox(
                          height: 50.0,
                          width: double.infinity,
                          child: ButtonPrimary(
                            text: _isLoading ? '' : 'Verifikasi OTP',
                            onPressed: _isLoading ? null : _verifyOtp,
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
