import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../screens/home_screen.dart'; // Pastikan path ini sesuai dengan lokasi HomeScreen Anda

class LoginController {
  final ApiService _apiService = ApiService();

  Future<void> login(
      String email, String password, BuildContext context) async {
    try {
      final result = await _apiService.loginUser(email, password);

      if (result != null && result.containsKey("error")) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result["error"],
              style: const TextStyle(
                  color: Colors.white), // Pastikan teks tetap terbaca
            ),
            backgroundColor: Colors.red, // Warna merah
          ),
        );
      } else {
        // Jika login sukses, pindah ke HomeScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Terjadi kesalahan, coba lagi!")),
      );
    }
  }
}
