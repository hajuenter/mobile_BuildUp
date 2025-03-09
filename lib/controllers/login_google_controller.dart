import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../screens/home_screen.dart';

class LoginGoogleController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final ApiService _apiService = ApiService();

  Future<void> loginWithGoogle(BuildContext context) async {
    try {
      // Sign out dulu hanya jika user ingin mengganti akun
      if (_auth.currentUser != null) {
        await _googleSignIn.signOut();
        await _auth.signOut();
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return; // Jika user membatalkan login
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        final String? email = user.email;

        if (email == null || email.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Email tidak ditemukan pada akun Google"),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Kirim email ke backend untuk verifikasi
        final response = await _apiService.loginWithGoogle(email);

        if (response != null && response['success'] == true) {
          // 🔹 Simpan token ke SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString("token", response["token"]);

          // 🔹 Navigasi ke HomeScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response?['message'] ?? "Login gagal"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print("Error login Google: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Terjadi kesalahan, coba lagi."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
