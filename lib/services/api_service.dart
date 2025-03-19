import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../responses/login_response.dart';
import '../responses/otp_verification_response.dart';
import '../responses/register_response.dart';
import '../responses/profile_response.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import '../responses/data_cpb_response.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.224.97:8000/api';
  static const String baseImageUrl = 'http://192.168.224.97:8000/up/profile/';
  static const String baseImageUrlCPB = 'http://192.168.224.97:8000/';
  final Dio _dio = Dio();

  ApiService() {
    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {"Content-Type": "application/json"},
    );

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final apiKey = await _getApiKey();
        if (apiKey != null) {
          options.headers["X-API-KEY"] = apiKey; // Ubah ini
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        debugPrint("Dio Error: ${e.response?.data ?? e.message}");
        return handler.next(e);
      },
    ));
  }

  Dio get dio => _dio;

  // API Key
  Future<String?> _getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("api_key");
  }

  Future<bool> isApiAlive() async {
    try {
      final response = await dio.get('/status');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<void> _saveApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("api_key", apiKey);
  }
  // End API Key

  // Auth
  Future<RegisterResponse?> registerUser(Map<String, dynamic> userData) async {
    try {
      final response = await _dio.post('/register', data: userData);
      RegisterResponse registerResponse =
          RegisterResponse.fromJson(response.data);

      if (registerResponse.user?.apiKey != null) {
        await _saveApiKey(registerResponse.user!.apiKey!);
      }

      return registerResponse;
    } on DioException catch (e) {
      debugPrint("Register Error: ${e.response?.data ?? e.message}");
      return null;
    }
  }

  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    try {
      final response = await _dio
          .post('/login', data: {"email": email, "password": password});

      if (response.statusCode == 200) {
        LoginResponse loginResponse = LoginResponse.fromJson(response.data);

        if (loginResponse.user.apiKey.isNotEmpty) {
          await _saveApiKey(loginResponse.user.apiKey);
        }

        return {
          "success": true,
          "message": "Login berhasil",
          "data": loginResponse
        };
      }
    } on DioException catch (e) {
      // Tangani error berdasarkan status kode
      if (e.response?.statusCode == 401) {
        return {"success": false, "message": "Email atau password salah"};
      } else if (e.response?.statusCode == 403) {
        return {
          "success": false,
          "message": e.response?.data["message"] ?? "Akses ditolak"
        };
      }

      // Jika error lain
      return {"success": false, "message": "Terjadi kesalahan saat login"};
    }

    return {"success": false, "message": "Login gagal"};
  }

  Future<Map<String, dynamic>> loginWithGoogle(String email) async {
    try {
      final response = await _dio.post('/google-login', data: {"email": email});

      if (response.statusCode == 200 && response.data.containsKey("api_key")) {
        await _saveApiKey(response.data["api_key"]);
        return {
          "success": true,
          "api_key": response.data["api_key"],
          "user": response.data["user"]
        };
      }
    } on DioException catch (e) {
      // Pastikan menangani error 401 dengan benar
      if (e.response?.statusCode == 401) {
        return {
          "success": false,
          "message": e.response?.data["message"] ??
              "Email tidak terdaftar atau belum diverifikasi"
        };
      }

      // Jika error lain, tampilkan pesan default
      return {
        "success": false,
        "message": "Terjadi kesalahan saat login dengan Google"
      };
    }
    return {"success": false, "message": "Akun anda tidak terdaftar"};
  }

  Future<Map<String, dynamic>?> sendOtp(String email) async {
    try {
      final response = await _dio.post('/send-otp', data: {"email": email});
      return response.data;
    } on DioException catch (e) {
      debugPrint("Send OTP Error: ${e.response?.data ?? e.message}");

      // Ambil pesan error dari API jika tersedia
      if (e.response != null && e.response?.data is Map<String, dynamic>) {
        return e.response?.data; // Langsung return error dari API
      }

      return {"success": false, "message": "Terjadi kesalahan, coba lagi"};
    }
  }

  Future<OtpVerificationResponse> verifyOtp(String email, String otp) async {
    try {
      final response =
          await _dio.post('/verif-otp', data: {"email": email, "otp": otp});
      return OtpVerificationResponse.fromResponse(jsonEncode(response.data));
    } on DioException catch (e) {
      debugPrint("OTP Verification Error: ${e.response?.data ?? e.message}");

      // Ambil pesan error dari API jika tersedia
      if (e.response != null && e.response?.data is Map<String, dynamic>) {
        final errorMessage =
            e.response?.data["message"] ?? "Terjadi kesalahan, coba lagi";
        return OtpVerificationResponse(error: errorMessage);
      }

      // Jika tidak ada pesan error dari API, gunakan pesan default
      return OtpVerificationResponse(error: "Terjadi kesalahan, coba lagi");
    }
  }

  Future<Map<String, dynamic>?> resetPassword(
      String email, String password, String confirmPassword) async {
    try {
      final response = await _dio.post('/reset-password', data: {
        'email': email,
        'password': password,
        'password_confirmation': confirmPassword,
      });
      return response.data;
    } on DioException catch (e) {
      debugPrint("Reset Password Error: ${e.response?.data ?? e.message}");
      return {"error": "Terjadi kesalahan, coba lagi"};
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    debugPrint("Logout berhasil, API Key dihapus.");
  }
  // End Auth

  // Profile
  Future<ProfileResponse> updateProfile({
    required String name,
    required String email,
    required String noHp,
    required String alamat,
    File? image,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'name': name,
        'email': email,
        'no_hp': noHp,
        'alamat': alamat,
        if (image != null)
          'foto': await MultipartFile.fromFile(
            image.path,
            filename: image.path.split('/').last,
            contentType: MediaType("image", "jpeg"),
          ),
      });

      Response response = await _dio.post(
        '$baseUrl/profile-update',
        data: formData,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'multipart/form-data',
            'X-API-KEY': await _getApiKey(),
          },
        ),
      );

      return ProfileResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        // Menangkap response dari server
        if (e.response!.statusCode == 422) {
          // Error validasi dari Laravel
          final errors = e.response!.data['errors'];
          if (errors != null) {
            throw Exception(_parseValidationErrors(errors));
          }
        } else if (e.response!.statusCode == 401) {
          throw Exception("API Key tidak valid atau sesi berakhir.");
        } else if (e.response!.statusCode == 500) {
          throw Exception("Terjadi kesalahan server, coba lagi nanti.");
        }
      }

      throw Exception("Gagal memperbarui profil: ${e.message}");
    }
  }

  String _parseValidationErrors(Map<String, dynamic> errors) {
    List<String> messages = [];

    errors.forEach((key, value) {
      if (value is List) {
        messages.addAll(value.map((msg) => "• $msg"));
      }
    });

    return messages.isNotEmpty
        ? messages.join("\n")
        : "Terjadi kesalahan validasi.";
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      Response response = await _dio.post(
        '$baseUrl/profile',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'X-API-KEY': await _getApiKey(), // Tambahkan API Key di sini
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return {"success": true, "user": response.data['user']};
      } else {
        return {"success": false, "message": "Gagal mengambil data profil"};
      }
    } catch (e) {
      return {"success": false, "message": "Terjadi kesalahan: $e"};
    }
  }
  // End Profile

  // data CPB
  Future<DataCPBResponse> getDataCPB() async {
    try {
      Response response = await _dio.get(
        '$baseUrl/dataCPB',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'X-API-KEY': await _getApiKey(),
          },
        ),
      );

      return DataCPBResponse.fromJson(response.data);
    } catch (e) {
      throw Exception("Gagal mengambil data CPB: $e");
    }
  }

  Future<DataCPBResponse> deleteDataCPB(int id) async {
    try {
      Response response = await _dio.delete(
        '$baseUrl/dataCPB/$id',
        options: Options(headers: {
          'Accept': 'application/json',
          'X-API-KEY': await _getApiKey(),
        }),
      );

      return DataCPBResponse.fromJson(response.data);
    } catch (e) {
      return DataCPBResponse(
        status: false,
        message: "Gagal menghapus data: $e",
        data: [],
      );
    }
  }
  // Data CPB End
}
