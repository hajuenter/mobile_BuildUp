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

    if (name.isEmpty) {
      errors["name"] = "Nama tidak boleh kosong.";
    } else if (name.length < 5) {
      errors["name"] = "Nama harus memiliki minimal 5 huruf.";
    } else if (!RegExp(r"^[a-zA-Z .' ]+$").hasMatch(name)) {
      errors["name"] = "Nama tidak valid.";
    }

    if (email.isEmpty) {
      errors["email"] = "Email tidak boleh kosong.";
    } else if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
        .hasMatch(email)) {
      errors["email"] = "Format email tidak valid.";
    } else if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
        .hasMatch(email)) {
      errors["email"] = "Format email tidak valid.";
    } else if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
        .hasMatch(email)) {
      errors["email"] = "Format email tidak valid.";
    } else if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
            .hasMatch(email) ||
        email.endsWith('.')) {
      errors["email"] = "Format email tidak valid.";
    }

    if (password.isEmpty) {
      errors["password"] = "Password tidak boleh kosong.";
    } else if (password.length < 8) {
      errors["password"] = "Password minimal 8 karakter.";
    } else if (!RegExp(r'[A-Z]').hasMatch(password)) {
      errors["password"] = "Password harus mengandung huruf besar.";
    } else if (!RegExp(r'[a-z]').hasMatch(password)) {
      errors["password"] = "Password harus mengandung huruf kecil.";
    } else if (!RegExp(r'\d').hasMatch(password)) {
      errors["password"] = "Password harus mengandung angka.";
    } else if (!RegExp(r'[\W_]').hasMatch(password)) {
      errors["password"] = "Password harus mengandung simbol.";
    }

    if (confirmPassword.isEmpty) {
      errors["confirmPassword"] = "Konfirmasi password tidak boleh kosong.";
    } else if (confirmPassword != password) {
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
