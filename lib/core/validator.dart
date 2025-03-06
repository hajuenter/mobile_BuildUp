class Validator {
  static List<Map<String, dynamic>> getPasswordValidationRules(
      String password) {
    return [
      {"isValid": password.isNotEmpty, "text": "Password tidak boleh kosong"},
      {"isValid": password.length >= 8, "text": "Minimal 8 karakter"},
      {
        "isValid": RegExp(r'[A-Z]').hasMatch(password),
        "text": "Harus mengandung huruf besar"
      },
      {
        "isValid": RegExp(r'[a-z]').hasMatch(password),
        "text": "Harus mengandung huruf kecil"
      },
      {
        "isValid": RegExp(r'[0-9]').hasMatch(password),
        "text": "Harus mengandung angka"
      },
      {
        "isValid": RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password),
        "text": "Harus mengandung simbol"
      },
    ];
  }

  /// 🔹 Ambil Aturan Pertama yang Tidak Valid
  static Map<String, dynamic>? getFirstInvalidRule(String password) {
    for (var rule in getPasswordValidationRules(password)) {
      if (!rule["isValid"]) {
        return rule;
      }
    }
    return null; // ✅ Semua valid
  }

  /// 🔹 Validasi Konfirmasi Password
  static String validatePasswordConfirmation(
      String password, String confirmPassword) {
    if (confirmPassword.isEmpty) {
      return "Konfirmasi password tidak boleh kosong";
    } else if (confirmPassword != password) {
      return "Password tidak cocok";
    }
    return ""; // ✅ Tidak ada error jika cocok
  }
}
