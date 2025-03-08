class Validator {
  static List<Map<String, dynamic>> getPasswordValidationRules(
      String password, bool isLogin) {
    List<Map<String, dynamic>> rules = [
      {"isValid": password.isNotEmpty, "text": "Password tidak boleh kosong"},
    ];

    if (!isLogin) {
      // Hanya berlaku untuk Register
      rules.addAll([
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
      ]);
    }

    return rules;
  }

  static Map<String, dynamic>? getFirstInvalidRule(
      String password, bool isLogin) {
    for (var rule in getPasswordValidationRules(password, isLogin)) {
      if (!rule["isValid"]) {
        return rule;
      }
    }
    return null;
  }

  static String validatePasswordConfirmation(
      String password, String confirmPassword) {
    if (confirmPassword.isEmpty) {
      return "Konfirmasi password tidak boleh kosong";
    } else if (confirmPassword != password) {
      return "Password tidak cocok";
    }
    return "";
  }
}
