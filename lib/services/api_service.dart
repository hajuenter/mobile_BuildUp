import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.142.97:8000/api';
  // Ganti dengan IP yang sesuai dengan jaringan lokal backend Laravel

  Future<Map<String, dynamic>?> registerUser(
      Map<String, dynamic> userData, String url) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(userData),
      );

      return jsonDecode(response.body);
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final String url = '$baseUrl/login';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        return {"error": responseData['message'] ?? "Login gagal"};
      }
    } catch (e) {
      print("Error: $e");
      return {"error": "Terjadi kesalahan, coba lagi"};
    }
  }

  Future<Map<String, dynamic>?> loginWithGoogle(String email) async {
    final String url = '$baseUrl/google-login';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        return {"error": responseData['message'] ?? "Login Google gagal"};
      }
    } catch (e) {
      print("Error: $e");
      return {"error": "Terjadi kesalahan, coba lagi"};
    }
  }

  Future<Map<String, dynamic>?> sendOtp(String email) async {
    final String url = '$baseUrl/send-otp';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else if (response.statusCode == 422) {
        // Jika ada error validasi dari backend (misalnya email tidak valid)
        return {"error": responseData['message'] ?? "Format email salah"};
      } else {
        return {"error": responseData['message'] ?? "Gagal mengirim OTP"};
      }
    } catch (e) {
      print("Error: $e");
      return {"error": "Terjadi kesalahan, coba lagi"};
    }
  }

  Future<Map<String, dynamic>?> verifyOtp(String email, String otp) async {
    final String url = '$baseUrl/verif-otp';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "otp": otp}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        return {"error": responseData['message'] ?? "Verifikasi gagal"};
      }
    } catch (e) {
      print("Error: $e");
      return {"error": "Terjadi kesalahan, coba lagi"};
    }
  }

  Future<Map<String, dynamic>?> resetPassword(
      String email, String password, String confirmPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password'),
        body: {
          'email': email,
          'password': password,
          'password_confirmation': confirmPassword,
        },
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 422) {
        return jsonDecode(response.body);
      } else {
        print("Error: Tidak dapat mengubah password.");
        return null;
      }
    } catch (e) {
      print("Exception: $e");
      return null;
    }
  }
}
