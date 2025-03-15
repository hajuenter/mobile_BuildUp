import '../responses/reset_password_response.dart';
import '../services/api_service.dart';
import '../services/session_manager.dart';

class ResetPasswordController {
  final ApiService _apiService = ApiService();

  Future<ResetPasswordResponse> resetPassword({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (password.isEmpty) {
      return ResetPasswordResponse(error: "Password wajib diisi.");
    }
    if (password.length < 8) {
      return ResetPasswordResponse(
          error: "Minimal panjang password 8 karakter");
    }
    if (!RegExp(r'^(?=.*[A-Z])(?=.*[0-9])').hasMatch(password)) {
      return ResetPasswordResponse(error: "Password tidak valid");
    }
    if (!RegExp(r'^(?=.*[!@#\$%^&*(),.?":{}|<>])').hasMatch(password)) {
      return ResetPasswordResponse(error: "Password harus mengandung simbol");
    }
    if (confirmPassword.isEmpty) {
      return ResetPasswordResponse(error: "Konfirmasi password wajib diisi.");
    }
    if (password != confirmPassword) {
      return ResetPasswordResponse(error: "Konfirmasi password tidak cocok.");
    }

    final response =
        await _apiService.resetPassword(email, password, confirmPassword);

    if (response != null && response['success'] == true) {
      await SessionManager.clearSession();
      return ResetPasswordResponse(
          success: true, message: "Password berhasil diperbarui!");
    } else if (response != null && response['errors'] != null) {
      return ResetPasswordResponse(error: response['errors'].values.first[0]);
    } else {
      return ResetPasswordResponse(error: "Gagal mengubah password.");
    }
  }
}
