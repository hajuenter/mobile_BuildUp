import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../responses/send_otp_response.dart';
import '../screens/otp_verification_screen.dart';

class SendOtpController {
  final ApiService _apiService = ApiService();

  Future<void> sendOtp(BuildContext context, String email) async {
    final responseData = await _apiService.sendOtp(email);

    // ✅ Pastikan response tidak null sebelum parsing
    if (responseData != null) {
      final response = SendOtpResponse.fromJson(responseData);

      if (response.success) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OtpVerificationScreen(email: email),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Terjadi kesalahan, coba lagi."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
