import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../screens/reset_password_screen.dart';

class OtpVerificationController {
  final ApiService apiService = ApiService();

  Future<void> verifyOtp(BuildContext context, String email, String otp) async {
    if (otp.isEmpty || otp.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kode OTP harus 4 digit'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final response = await apiService.verifyOtp(email, otp);

    if (response.data != null && response.data!.success) {
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ResetPasswordScreen(email: email),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.error ?? 'OTP tidak valid'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
