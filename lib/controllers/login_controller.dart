import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../responses/login_response.dart';
import '../screens/home_screen.dart';
import '../models/user.dart';

class LoginController {
  final ApiService _apiService = ApiService();

  Future<void> login(
      BuildContext context, String email, String password) async {
    final response = await _apiService.loginUser(email, password);

    if (response["success"] == true) {
      LoginResponse loginResponse = response["data"]; // Ambil data dari API
      await _saveUserData(loginResponse.user);

      // 🔥 Periksa context sebelum menggunakan Navigator atau ScaffoldMessenger
      if (!context.mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(user: loginResponse.user),
        ),
      );
    } else {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response["message"] ?? "Login gagal"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("user", jsonEncode(user.toJson()));
    await prefs.setString(
        "api_key", user.apiKey); // ✅ Hapus `?? ""` karena tidak perlu
    await prefs.setInt("lastLoginTime", DateTime.now().millisecondsSinceEpoch);
  }
}
