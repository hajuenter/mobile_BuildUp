import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../responses/login_response.dart';
import '../screens/home_screen.dart';

class LoginController {
  final ApiService _apiService = ApiService();

  Future<void> login(
      BuildContext context, String email, String password) async {
    LoginResponse? response = await _apiService.loginUser(email, password);

    if (response != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login gagal, cek kembali email dan password"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
