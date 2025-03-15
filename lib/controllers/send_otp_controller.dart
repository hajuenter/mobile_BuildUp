import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../responses/send_otp_response.dart';
import '../screens/otp_verification_screen.dart';

class SendOtpController {
  final ApiService _apiService = ApiService();

  Future<String?> sendOtp(BuildContext context, String email) async {
    final responseData = await _apiService.sendOtp(email);

    if (!context.mounted) return null; // Cek apakah widget masih ada

    if (responseData != null) {
      final response = SendOtpResponse.fromJson(responseData);

      if (response.success) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OtpVerificationScreen(email: email),
          ),
        );
        return null; // Tidak ada error
      } else {
        return response.message; // Mengembalikan pesan error dari API
      }
    } else {
      return "Email tidak terdaftar.";
    }
  }
}
