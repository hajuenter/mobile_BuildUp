import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../screens/reset_password_screen.dart';

class OtpVerificationController {
  final ApiService apiService = ApiService();

  Future<void> verifyOtp(
    BuildContext context,
    String email,
    String otp, {
    required Function(String) onError,
  }) async {
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
      onError(response.error ?? 'OTP tidak valid');
    }
  }
}
