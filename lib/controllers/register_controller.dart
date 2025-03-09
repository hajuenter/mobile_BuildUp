import '../services/api_service.dart';
import '../responses/register_response.dart';

class RegisterController {
  final ApiService _apiService = ApiService();

  Future<Map<String, String>?> registerUser({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    Map<String, String> errors = {};

    // **Validasi di Flutter sebelum request ke API**
    if (name.isEmpty || name.length < 5) {
      errors["name"] = "Nama harus memiliki minimal 5 huruf.";
    }
    if (email.isEmpty) {
      errors["email"] = "Email tidak boleh kosong.";
    }
    if (password.isEmpty || password.length < 8) {
      errors["password"] = "Password minimal 8 karakter.";
    }
    if (confirmPassword != password) {
      errors["confirmPassword"] = "Konfirmasi password harus sama.";
    }

    if (errors.isNotEmpty) return errors;

    final RegisterResponse? response = await _apiService.registerUser({
      "name": name,
      "email": email,
      "password": password,
      "password_confirmation": confirmPassword,
    });

    if (response != null) {
      if (response.errors != null) {
        return response.errors!.map((key, value) => MapEntry(key, value[0]));
      }
    }
    return null; // Berhasil registrasi
  }
}
