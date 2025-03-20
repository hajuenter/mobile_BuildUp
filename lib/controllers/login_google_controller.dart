import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/user.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart'; // Tambahkan halaman login untuk redirect jika sesi habis

class LoginGoogleController {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final ApiService _apiService = ApiService();
  static const int sessionDuration = 7200000; // 2 jam dalam milidetik

  Future<void> loginWithGoogle(BuildContext context) async {
    try {
      // 🔹 Jika user sebelumnya sudah login, logout terlebih dahulu
      if (_auth.currentUser != null) {
        await _googleSignIn.signOut();
        await _auth.signOut();
      }

      // 🔹 Login dengan Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return; // Jika user membatalkan login

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final firebase_auth.AuthCredential credential =
          firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final firebase_auth.UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final firebase_auth.User? user = userCredential.user;

      if (user != null) {
        final String? email = user.email;
        if (email == null || email.isEmpty) {
          if (context.mounted) {
            _showErrorMessage(
                context, "Email tidak ditemukan pada akun Google");
          }
          return;
        }

        // 🔹 Kirim email ke backend untuk verifikasi
        final response = await _apiService.loginWithGoogle(email);

        if (response['success'] == true) {
          // 🔹 Parsing user dari response
          User userData = User.fromJson(response['user']);

          // 🔹 Simpan API Key & user di SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString("api_key", userData.apiKey);
          await prefs.setString("user", jsonEncode(response["user"]));
          await prefs.setInt("lastLoginTime",
              DateTime.now().millisecondsSinceEpoch); // Simpan waktu login

          // 🔹 Navigasi ke HomeScreen dengan data user
          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => HomeScreen(user: userData)),
            );
          }
        } else {
          if (context.mounted) {
            _showErrorMessage(context, response['message'] ?? "Login gagal");
          }
        }
      }
    } catch (e) {
      debugPrint("Error login Google: $e");
      if (context.mounted) {
        _showErrorMessage(context, "Terjadi kesalahan, coba lagi.");
      }
    }
  }

  Future<void> checkSession(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final String? apiKey = prefs.getString("api_key");

    if (apiKey == null || apiKey.isEmpty) {
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    }
  }

  // 🔹 Fungsi untuk menampilkan pesan error
  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
