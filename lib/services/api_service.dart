import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://172.16.115.71:8000/api';
  // ganti dengan ip dengan jaringan yang sama
  // jalankan server laravel dengan php artisan serve --host=0.0.0.0 --port=8000

  Future<Map<String, dynamic>?> registerUser(
      Map<String, dynamic> userData, String url) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(userData),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return responseData;
      } else {
        return responseData;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }
}
