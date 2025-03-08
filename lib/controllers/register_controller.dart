import '../services/api_service.dart';

class RegisterController {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>?> registerUser({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    Map<String, dynamic> errors = _validateInputs(
      name: name,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );

    if (errors.isNotEmpty) {
      return errors;
    }

    final Map<String, dynamic> userData = {
      "name": name,
      "email": email,
      "password": password,
      "password_confirmation": confirmPassword,
    };

    final String url = '${ApiService.baseUrl}/register';
    final response = await _apiService.registerUser(userData, url);

    if (response != null) {
      if (response.containsKey('errors')) {
        return response['errors'];
      } else if (response.containsKey('user')) {
        return null;
      }
    }
    return {"error": "Registrasi gagal. Periksa kembali data Anda!"};
  }

  // **Validasi di Flutter (Tanpa Bebani API)**
  Map<String, dynamic> _validateInputs({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    Map<String, dynamic> errors = {};

    if (name.isEmpty) {
      errors['name'] = ['Nama tidak boleh kosong.'];
    } else if (name.length < 5) {
      errors['name'] = ['Nama harus memiliki minimal 5 huruf.'];
    } else if (!RegExp(r"^[A-Za-z\s\'.]+$").hasMatch(name)) {
      errors['name'] = ['Nama hanya boleh mengandung huruf.'];
    } else if (name.length > 255) {
      errors['name'] = ['Nama tidak boleh lebih dari 255 karakter.'];
    }

    if (email.isEmpty) {
      errors['email'] = ['Email tidak boleh kosong.'];
    } else if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(email)) {
      errors['email'] = ['Format email tidak valid.'];
    } else if (email.length > 255) {
      errors['email'] = ['Email tidak boleh lebih dari 255 karakter.'];
    }

    if (password.isEmpty) {
      errors['password'] = ['Password tidak boleh kosong.'];
    } else if (password.length < 8) {
      errors['password'] = ['Password minimal harus 8 karakter.'];
    }

    if (confirmPassword.isEmpty) {
      errors['password_confirmation'] = [
        'Konfirmasi password tidak boleh kosong.'
      ];
    } else if (confirmPassword != password) {
      errors['password_confirmation'] = [
        'Konfirmasi password harus sama dengan password.'
      ];
    }

    return errors;
  }
}
