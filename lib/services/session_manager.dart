import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class SessionManager {
  // 🔹 Simpan sesi user dengan API Key
  static Future<void> saveUserSession(User user, String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("user", jsonEncode(user.toJson()));
    await prefs.setString("api_key", apiKey); // 🔥 Simpan API Key
    await prefs.setInt("lastLoginTime", DateTime.now().millisecondsSinceEpoch);
  }

  // 🔹 Ambil data user dari sesi
  static Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userData = prefs.getString("user");
    if (userData != null) {
      return User.fromJson(jsonDecode(userData));
    }
    return null;
  }

  // 🔹 Ambil API Key dari sesi
  static Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("api_key"); // 🔥 Ambil API Key
  }

  // 🔹 Ambil waktu login terakhir
  static Future<int?> getLastLoginTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("lastLoginTime");
  }

  // 🔹 Hapus sesi saat logout
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("user");
    await prefs.remove("api_key"); // 🔥 Hapus API Key
    await prefs.remove("lastLoginTime");
  }
}
