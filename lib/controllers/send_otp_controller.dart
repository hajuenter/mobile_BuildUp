import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../screens/otp_verification_screen.dart';

class SendOtpController {
  final ApiService apiService = ApiService();

  Future<void> sendOtp(BuildContext context, String email) async {
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email tidak boleh kosong'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final response = await apiService.sendOtp(email);

    if (response != null && response['success'] == true) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => OtpVerificationScreen(email: email),
        ),
      );
    } else {
      // Tampilkan pesan error dari API jika ada
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response?['error'] ?? 'Terjadi kesalahan, coba lagi'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
