import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../responses/login_response.dart';
import '../responses/otp_verification_response.dart';
import '../responses/register_response.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.35.97:8000/api';
  // Ganti dengan IP yang sesuai dengan jaringan lokal backend Laravel

  Future<RegisterResponse?> registerUser(Map<String, dynamic> userData) async {
    final String url = '$baseUrl/register';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 201 || response.statusCode == 422) {
        return RegisterResponse.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print("Error: $e");
    }
    return null;
  }

  Future<LoginResponse?> loginUser(String email, String password) async {
    final String url = '$baseUrl/login';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        LoginResponse loginResponse = LoginResponse.fromJson(responseData);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", loginResponse.token);

        return loginResponse;
      } else {
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
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

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Simpan token ke SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", responseData["token"]);

        return responseData;
      } else {
        final responseData = jsonDecode(response.body);
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

  Future<OtpVerificationResponse> verifyOtp(String email, String otp) async {
    final String url = '$baseUrl/verif-otp';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "otp": otp}),
      );

      return OtpVerificationResponse.fromResponse(response.body);
    } catch (e) {
      return OtpVerificationResponse(error: "Terjadi kesalahan, coba lagi");
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
