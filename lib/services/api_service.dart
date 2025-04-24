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
import '../responses/verifikasi_response.dart';
import '../responses/home_statistik_response.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.198.97:8000/api';
  static const String baseImageUrl = 'http://192.168.198.97:8000/up/profile/';
  static const String baseImageUrlCPB = 'http://192.168.198.97:8000/';
  static const String baseImageUrlEditVerifCPB = 'http://192.168.198.97:8000/';
  final Dio _dio = Dio();

  ApiService() {
    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 50),
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

  // Home
  Future<HomeStatistikResponse> getHomeStatistik() async {
    try {
      Response response = await _dio.get(
        '$baseUrl/home',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'X-API-KEY': await _getApiKey(),
          },
        ),
      );

      return HomeStatistikResponse.fromJson(response.data);
    } catch (e) {
      throw Exception("Gagal mengambil data statistik: $e");
    }
  }
  // Home End

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

  // Hapus Data Verifikasi CPB berdasarkan ID CPB
  Future<VerifikasiResponse> deleteVerifikasiCPBByCpbId(int cpbId) async {
    try {
      debugPrint(
          '🟢 Mengirim permintaan hapus ke: $baseUrl/delete/verifcpb/by-cpb/$cpbId');

      Response response =
          await _dio.delete('$baseUrl/delete/verifcpb/by-cpb/$cpbId',
              options: Options(headers: {
                'Accept': 'application/json',
                'X-API-KEY': await _getApiKey(),
              }));

      // Periksa jika respons bukan null dan adalah Map
      if (response.data != null && response.data is Map<String, dynamic>) {
        return VerifikasiResponse.fromJson(response.data);
      }

      // Jika respons null atau bukan format yang diharapkan
      return VerifikasiResponse(
        success: response.statusCode == 200,
        message: response.statusCode == 200
            ? 'Data berhasil dihapus'
            : 'Format respons tidak sesuai',
        errors: response.statusCode != 200
            ? {'response': 'Format respons tidak valid'}
            : null,
      );
    } catch (e) {
      debugPrint('🔴 Error: ${e.toString()}');

      if (e is DioException &&
          e.response != null &&
          e.response?.data is Map<String, dynamic>) {
        return VerifikasiResponse.fromJson(e.response?.data);
      }

      return VerifikasiResponse(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
        errors: {'exception': e.toString()},
      );
    }
  }
  // Hapus Data Verifikasi CPB End

  // Add Data Verifikasi
  Future<VerifikasiResponse> addVerifikasiCPB({
    required File fotoKK,
    required File fotoKTP,
    required String nik,
    required bool kesanggupanBerswadaya,
    required String tipe,
    required double penutupAtap,
    required double rangkaAtap,
    required double kolom,
    required double ringBalok,
    required double dindingPengisi,
    required double kusen,
    required double pintu,
    required double jendela,
    required double strukturBawah,
    required double penutupLantai,
    required double pondasi,
    required double sloof,
    required double mck,
    required double airKotor,
    required File fotoPenutupAtap,
    required File fotoRangkaAtap,
    required File fotoKolom,
    required File fotoRingBalok,
    required File fotoDindingPengisi,
    required File fotoKusen,
    required File fotoPintu,
    required File fotoJendela,
    required File fotoStrukturBawah,
    required File fotoPenutupLantai,
    required File fotoPondasi,
    required File fotoSloof,
    required File fotoMck,
    required File fotoAirKotor,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'foto_kk': await MultipartFile.fromFile(
          fotoKK.path,
          filename: 'foto_kk_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: MediaType("image", "jpeg"),
        ),
        'foto_ktp': await MultipartFile.fromFile(
          fotoKTP.path,
          filename: 'foto_ktp_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: MediaType("image", "jpeg"),
        ),
        'nik': nik,
        'kesanggupan_berswadaya': kesanggupanBerswadaya ? 1 : 0,
        'tipe': tipe,
        'penutup_atap': penutupAtap.toString(),
        'rangka_atap': rangkaAtap.toString(),
        'kolom': kolom.toString(),
        'ring_balok': ringBalok.toString(),
        'dinding_pengisi': dindingPengisi.toString(),
        'kusen': kusen.toString(),
        'pintu': pintu.toString(),
        'jendela': jendela.toString(),
        'struktur_bawah': strukturBawah.toString(),
        'penutup_lantai': penutupLantai.toString(),
        'pondasi': pondasi.toString(),
        'sloof': sloof.toString(),
        'mck': mck.toString(),
        'air_kotor': airKotor.toString(),
        'foto_penutup_atap': await MultipartFile.fromFile(
          fotoPenutupAtap.path,
          filename: 'penutup_atap_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: MediaType("image", "jpeg"),
        ),
        'foto_rangka_atap': await MultipartFile.fromFile(
          fotoRangkaAtap.path,
          filename: 'rangka_atap_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: MediaType("image", "jpeg"),
        ),
        'foto_kolom': await MultipartFile.fromFile(
          fotoKolom.path,
          filename: 'kolom_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: MediaType("image", "jpeg"),
        ),
        'foto_ring_balok': await MultipartFile.fromFile(
          fotoRingBalok.path,
          filename: 'ring_balok_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: MediaType("image", "jpeg"),
        ),
        'foto_dinding_pengisi': await MultipartFile.fromFile(
          fotoDindingPengisi.path,
          filename:
              'dinding_pengisi_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: MediaType("image", "jpeg"),
        ),
        'foto_kusen': await MultipartFile.fromFile(
          fotoKusen.path,
          filename: 'kusen_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: MediaType("image", "jpeg"),
        ),
        'foto_pintu': await MultipartFile.fromFile(
          fotoPintu.path,
          filename: 'pintu_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: MediaType("image", "jpeg"),
        ),
        'foto_jendela': await MultipartFile.fromFile(
          fotoJendela.path,
          filename: 'jendela_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: MediaType("image", "jpeg"),
        ),
        'foto_struktur_bawah': await MultipartFile.fromFile(
          fotoStrukturBawah.path,
          filename:
              'struktur_bawah_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: MediaType("image", "jpeg"),
        ),
        'foto_penutup_lantai': await MultipartFile.fromFile(
          fotoPenutupLantai.path,
          filename:
              'penutup_lantai_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: MediaType("image", "jpeg"),
        ),
        'foto_pondasi': await MultipartFile.fromFile(
          fotoPondasi.path,
          filename: 'pondasi_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: MediaType("image", "jpeg"),
        ),
        'foto_sloof': await MultipartFile.fromFile(
          fotoSloof.path,
          filename: 'sloof_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: MediaType("image", "jpeg"),
        ),
        'foto_mck': await MultipartFile.fromFile(
          fotoMck.path,
          filename: 'mck_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: MediaType("image", "jpeg"),
        ),
        'foto_air_kotor': await MultipartFile.fromFile(
          fotoAirKotor.path,
          filename: 'air_kotor_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: MediaType("image", "jpeg"),
        ),
      });

      Response response = await _dio.post(
        '$baseUrl/verifikasiCPB',
        data: formData,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'multipart/form-data',
            'X-API-KEY': await _getApiKey(),
          },
          sendTimeout: const Duration(minutes: 2),
          receiveTimeout: const Duration(minutes: 2),
        ),
      );

      return VerifikasiResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint("Verifikasi CPB Error: ${e.response?.data ?? e.message}");

      if (e.response != null) {
        if (e.response!.statusCode == 422) {
          // Validation errors
          return VerifikasiResponse(
            success: false,
            message: "Validasi gagal",
            errors: e.response!.data['errors'],
          );
        } else if (e.response!.statusCode == 401) {
          return VerifikasiResponse(
            success: false,
            message: "Sesi tidak valid atau telah berakhir",
          );
        }
      }

      return VerifikasiResponse(
        success: false,
        message: "Gagal menambahkan data verifikasi: ${e.message}",
      );
    } catch (e) {
      return VerifikasiResponse(
        success: false,
        message: "Terjadi kesalahan: $e",
      );
    }
  }
  // Add Data Verifikasi End

  // Update Data Verif CPB
  Future<VerifikasiResponse> updateVerifikasiCPB({
    required int id,
    required String nik,
    required bool kesanggupanBerswadaya,
    required String tipe,
    required double penutupAtap,
    required double rangkaAtap,
    required double kolom,
    required double ringBalok,
    required double dindingPengisi,
    required double kusen,
    required double pintu,
    required double jendela,
    required double strukturBawah,
    required double penutupLantai,
    required double pondasi,
    required double sloof,
    required double mck,
    required double airKotor,
    File? fotoKK,
    File? fotoKTP,
    File? fotoPenutupAtap,
    File? fotoRangkaAtap,
    File? fotoKolom,
    File? fotoRingBalok,
    File? fotoDindingPengisi,
    File? fotoKusen,
    File? fotoPintu,
    File? fotoJendela,
    File? fotoStrukturBawah,
    File? fotoPenutupLantai,
    File? fotoPondasi,
    File? fotoSloof,
    File? fotoMck,
    File? fotoAirKotor,
  }) async {
    try {
      // Mapping file-file
      final fileFields = {
        'foto_kk': fotoKK,
        'foto_ktp': fotoKTP,
        'foto_penutup_atap': fotoPenutupAtap,
        'foto_rangka_atap': fotoRangkaAtap,
        'foto_kolom': fotoKolom,
        'foto_ring_balok': fotoRingBalok,
        'foto_dinding_pengisi': fotoDindingPengisi,
        'foto_kusen': fotoKusen,
        'foto_pintu': fotoPintu,
        'foto_jendela': fotoJendela,
        'foto_struktur_bawah': fotoStrukturBawah,
        'foto_penutup_lantai': fotoPenutupLantai,
        'foto_pondasi': fotoPondasi,
        'foto_sloof': fotoSloof,
        'foto_mck': fotoMck,
        'foto_air_kotor': fotoAirKotor,
      };

      final mappedFiles = await _mapFiles(fileFields);

      final formData = FormData.fromMap({
        '_method':
            'PUT', // Gunakan _method agar Laravel menangkap ini sebagai PUT
        'nik': nik,
        'kesanggupan_berswadaya': kesanggupanBerswadaya ? '1' : '0',
        'tipe': tipe,
        'penutup_atap': penutupAtap.toString(),
        'rangka_atap': rangkaAtap.toString(),
        'kolom': kolom.toString(),
        'ring_balok': ringBalok.toString(),
        'dinding_pengisi': dindingPengisi.toString(),
        'kusen': kusen.toString(),
        'pintu': pintu.toString(),
        'jendela': jendela.toString(),
        'struktur_bawah': strukturBawah.toString(),
        'penutup_lantai': penutupLantai.toString(),
        'pondasi': pondasi.toString(),
        'sloof': sloof.toString(),
        'mck': mck.toString(),
        'air_kotor': airKotor.toString(),
        ...mappedFiles,
      });

      debugPrint('===== REQUEST DATA =====');
      debugPrint('URL: ${'$baseUrl/updateVerifCPB/$id'}');
      debugPrint('Method: POST (with _method PUT)');
      debugPrint('Form Fields:');
      for (var field in formData.fields) {
        debugPrint('${field.key}: ${field.value}');
      }
      debugPrint('Files:');
      for (var file in formData.files) {
        debugPrint('${file.key}: ${file.value.filename}');
      }

      final response = await _dio.post(
        '$baseUrl/updateVerifCPB/$id',
        data: formData,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'X-API-KEY': await _getApiKey(),
          },
          sendTimeout: const Duration(minutes: 2),
          receiveTimeout: const Duration(minutes: 2),
        ),
      );

      return VerifikasiResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('Error: ${e.response?.data ?? e.message}');
      debugPrint('Stack trace: ${e.stackTrace}');
      return VerifikasiResponse(
        success: false,
        message: 'Gagal update data: ${e.message}',
        errors: e.response?.data['errors'],
      );
    }
  }

  // Helper untuk mengubah file menjadi MultipartFile
  Future<Map<String, MultipartFile>> _mapFiles(Map<String, File?> files) async {
    final result = <String, MultipartFile>{};

    for (var entry in files.entries) {
      final file = entry.value;
      if (file != null) {
        result[entry.key] = await MultipartFile.fromFile(file.path,
            filename: file.path.split('/').last);
      }
    }

    return result;
  }

  // Get Data Verif by NIK
  Future<Map<String, dynamic>?> getVerifikasiByNIK(String nik) async {
    try {
      Response response = await _dio.get(
        '$baseUrl/getVerifCPB',
        queryParameters: {'nik': nik},
        options: Options(
          headers: {
            'Accept': 'application/json',
            'X-API-KEY': await _getApiKey(),
          },
        ),
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching verifikasi data: $e');
      return null;
    }
  }
  // Get Data Verif by NIK End
}
