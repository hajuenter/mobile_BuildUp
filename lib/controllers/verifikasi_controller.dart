import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/data_cpb_model.dart';
import '../services/api_service.dart';

class VerifikasiController {
  // Maps for dropdown values and options (tidak berubah)
  final Map<String, double> kondisiValues = {
    "Layak": 0.0,
    "Rusak Ringan": 0.25,
    "Rusak Sedang": 0.5,
    "Rusak Berat": 0.75,
    "Rusak Total": 1.0,
  };

  final Map<String, double> strukturalValues = {
    "Ada": 0.0,
    "Ada Sebagian (75%)": 0.25,
    "Ada Sebagian (50%)": 0.5,
    "Ada Sebagian (25%)": 0.75,
    "Tidak Ada/Kayu/Tanah": 1.0,
  };

  final Map<String, String> pilihanBerswadaya = {
    "1": "Ya",
    "0": "Tidak",
  };

  final Map<String, String> pilihanTipe = {
    "T": "Tembok",
    "K": "Kayu",
  };

  final Map<String, String> pilihanAdaTidakAda = {
    "Ada": "Ada",
    "Tidak Ada": "Tidak Ada",
  };

  final Map<String, double> nilaiAdaTidakAda = {
    "Ada": 0.0,
    "Tidak Ada": 1.0,
  };

  final Map<String, String> displayNames = {
    'kesanggupan_berswadaya': 'Kesanggupan Berswadaya',
    'tipe': 'Tipe Bangunan',
    'penutup_atap': 'Penutup Atap',
    'rangka_atap': 'Rangka Atap',
    'kolom': 'Kolom',
    'ring_balok': 'Ring Balok',
    'dinding_pengisi': 'Dinding Pengisi',
    'kusen': 'Kusen',
    'pintu': 'Pintu',
    'jendela': 'Jendela',
    'struktur_bawah': 'Struktur Bawah',
    'penutup_lantai': 'Penutup Lantai',
    'pondasi': 'Pondasi',
    'sloof': 'Sloof',
    'mck': 'MCK',
    'air_kotor': 'Air Kotor',
  };

  final List<String> strukturalComponents = [
    'kolom',
    'ring_balok',
    'dinding_pengisi',
    'struktur_bawah',
    'penutup_lantai',
  ];

  final Map<String, List<String>> sections = {
    'ATAP': ['penutup_atap', 'rangka_atap'],
    'DINDING': ['kolom', 'ring_balok', 'dinding_pengisi'],
    'PINTU DAN JENDELA': ['kusen', 'pintu', 'jendela'],
    'LANTAI': ['struktur_bawah', 'penutup_lantai'],
    'PONDASI': ['pondasi', 'sloof'],
    'SANITASI': ['mck', 'air_kotor'],
  };

  final ApiService _apiService = ApiService();

  Future<File?> pickImage(ImageSource source, BuildContext context) async {
    final pickedFile = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 100,
    );

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      // Check file size in KB
      int fileSizeInKB = imageFile.lengthSync() ~/ 1024;

      // Limit file size to 15 MB (15360 KB)
      if (fileSizeInKB > 15360) {
        if (!context.mounted) return null; // Cek apakah widget masih terpasang
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ukuran gambar terlalu besar. Maksimal 15 MB.'),
            backgroundColor: Colors.red,
          ),
        );
        return null;
      }

      return imageFile;
    }
    return null;
  }

  // Fungsi validasi yang dimodifikasi dengan parameter isEditing
  bool validateForm(
      Map<String, String?> selectedValues, Map<String, File?> imageFiles,
      {bool isEditing = false}) {
    // Check if kesanggupan_berswadaya and tipe are selected
    if (selectedValues['kesanggupan_berswadaya'] == null ||
        selectedValues['tipe'] == null) {
      return false;
    }

    // Check if all condition fields have values
    for (var sectionFields in sections.values) {
      for (var field in sectionFields) {
        if (selectedValues[field] == null) {
          return false;
        }
      }
    }

    // Jika mode editing, tidak perlu validasi keberadaan gambar
    if (!isEditing) {
      // Validasi gambar hanya saat menambah data baru
      for (var sectionFields in sections.values) {
        for (var field in sectionFields) {
          if (imageFiles[field] == null) {
            return false;
          }
        }
      }

      // Check if KTP and KK images are selected
      if (imageFiles['foto_ktp'] == null || imageFiles['foto_kk'] == null) {
        return false;
      }
    }

    return true;
  }

  Map<String, double> calculateKondisiData(
      Map<String, String?> selectedValues) {
    Map<String, double> kondisiData = {};

    // Pastikan semua field memiliki nilai default
    const defaultValues = {
      'penutup_atap': 0.0,
      'rangka_atap': 0.0,
      'kolom': 0.0,
      'ring_balok': 0.0,
      'dinding_pengisi': 0.0,
      'kusen': 0.0,
      'pintu': 0.0,
      'jendela': 0.0,
      'struktur_bawah': 0.0,
      'penutup_lantai': 0.0,
      'pondasi': 0.0,
      'sloof': 0.0,
      'mck': 0.0,
      'air_kotor': 0.0,
    };

    defaultValues.forEach((key, defaultValue) {
      final value = selectedValues[key]?.trim();

      if (value == null || value.isEmpty) {
        kondisiData[key] = defaultValue;
        return;
      }

      // Handle khusus untuk field yang menggunakan pilihan berbeda
      if (key == 'pondasi' || key == 'sloof' || key == 'air_kotor') {
        kondisiData[key] = value == "Ada" ? 0.0 : 1.0;
      } else if (strukturalComponents.contains(key)) {
        kondisiData[key] = strukturalValues[value] ?? defaultValue;
      } else {
        kondisiData[key] = kondisiValues[value] ?? defaultValue;
      }
    });

    return kondisiData;
  }

  Future<bool> saveData({
    required BuildContext context,
    required DataCPBModel data,
    required Map<String, String?> selectedValues,
    required Map<String, File?> imageFiles,
  }) async {
    try {
      // Validate form
      if (!validateForm(selectedValues, imageFiles)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Harap lengkapi semua input yang diperlukan'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }

      // Additional checks for KTP and KK images
      if (imageFiles['foto_ktp'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto KTP belum dipilih'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }

      if (imageFiles['foto_kk'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto KK belum dipilih'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }

      // Prepare data for API
      final nik = data.nik;
      final kesanggupanBerswadaya =
          selectedValues['kesanggupan_berswadaya'] == '1';
      final tipe = selectedValues['tipe'] ?? '';

      // Calculate kondisi data
      final kondisiData = calculateKondisiData(selectedValues);

      // Call API service
      final response = await _apiService.addVerifikasiCPB(
        fotoKK: imageFiles['foto_kk']!,
        fotoKTP: imageFiles['foto_ktp']!,
        nik: nik,
        kesanggupanBerswadaya: kesanggupanBerswadaya,
        tipe: tipe,
        penutupAtap: double.parse(kondisiData['penutup_atap'].toString()),
        rangkaAtap: double.parse(kondisiData['rangka_atap'].toString()),
        kolom: double.parse(kondisiData['kolom'].toString()),
        ringBalok: double.parse(kondisiData['ring_balok'].toString()),
        dindingPengisi: double.parse(kondisiData['dinding_pengisi'].toString()),
        kusen: double.parse(kondisiData['kusen'].toString()),
        pintu: double.parse(kondisiData['pintu'].toString()),
        jendela: double.parse(kondisiData['jendela'].toString()),
        strukturBawah: double.parse(kondisiData['struktur_bawah'].toString()),
        penutupLantai: double.parse(kondisiData['penutup_lantai'].toString()),
        pondasi: double.parse(kondisiData['pondasi'].toString()),
        sloof: double.parse(kondisiData['sloof'].toString()),
        mck: double.parse(kondisiData['mck'].toString()),
        airKotor: double.parse(kondisiData['air_kotor'].toString()),
        fotoPenutupAtap: imageFiles['penutup_atap']!,
        fotoRangkaAtap: imageFiles['rangka_atap']!,
        fotoKolom: imageFiles['kolom']!,
        fotoRingBalok: imageFiles['ring_balok']!,
        fotoDindingPengisi: imageFiles['dinding_pengisi']!,
        fotoKusen: imageFiles['kusen']!,
        fotoPintu: imageFiles['pintu']!,
        fotoJendela: imageFiles['jendela']!,
        fotoStrukturBawah: imageFiles['struktur_bawah']!,
        fotoPenutupLantai: imageFiles['penutup_lantai']!,
        fotoPondasi: imageFiles['pondasi']!,
        fotoSloof: imageFiles['sloof']!,
        fotoMck: imageFiles['mck']!,
        fotoAirKotor: imageFiles['air_kotor']!,
      );

      if (response.success) {
        if (!context.mounted) return true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message.isNotEmpty
                ? response.message
                : 'Data berhasil disimpan'),
            backgroundColor: Colors.green,
          ),
        );
        return true;
      } else {
        if (!context.mounted) return false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message.isNotEmpty
                ? response.message
                : 'Data gagal disimpan'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    } catch (e) {
      if (!context.mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  Future<bool> updateData({
    required BuildContext context,
    required int id,
    required DataCPBModel data,
    required Map<String, String?> selectedValues,
    required Map<String, File?> imageFiles,
  }) async {
    try {
      if (!validateForm(selectedValues, imageFiles, isEditing: true)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Harap lengkapi semua data dropdown yang diperlukan'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }

      final nik = data.nik;
      if (nik.isEmpty) {
        throw Exception("NIK tidak boleh kosong");
      }
      final kesanggupanBerswadaya =
          selectedValues['kesanggupan_berswadaya'] == '1';
      final tipe = selectedValues['tipe'] ?? '';

      if (tipe.isEmpty) {
        return false;
      }

      // Calculate kondisi data
      final kondisiData = calculateKondisiData(selectedValues);
      debugPrint("Data sebelum dikirim ke API:");
      debugPrint("NIK: $nik");
      debugPrint("Tipe: $tipe");
      debugPrint("Kesanggupan: $kesanggupanBerswadaya");
      kondisiData.forEach((key, value) {
        debugPrint("$key: $value");
      });
      // Call API service with all required parameters explicitly
      final response = await _apiService.updateVerifikasiCPB(
        id: id,
        nik: nik,
        kesanggupanBerswadaya: kesanggupanBerswadaya,
        tipe: tipe,
        penutupAtap: kondisiData['penutup_atap'] ?? 0,
        rangkaAtap: kondisiData['rangka_atap'] ?? 0,
        kolom: kondisiData['kolom'] ?? 0,
        ringBalok: kondisiData['ring_balok'] ?? 0,
        dindingPengisi: kondisiData['dinding_pengisi'] ?? 0,
        kusen: kondisiData['kusen'] ?? 0,
        pintu: kondisiData['pintu'] ?? 0,
        jendela: kondisiData['jendela'] ?? 0,
        strukturBawah: kondisiData['struktur_bawah'] ?? 0,
        penutupLantai: kondisiData['penutup_lantai'] ?? 0,
        pondasi: kondisiData['pondasi'] ?? 0,
        sloof: kondisiData['sloof'] ?? 0,
        mck: kondisiData['mck'] ?? 0,
        airKotor: kondisiData['air_kotor'] ?? 0,
        // Pass image files
        fotoKK: imageFiles['foto_kk'],
        fotoKTP: imageFiles['foto_ktp'],
        fotoPenutupAtap: imageFiles['penutup_atap'],
        fotoRangkaAtap: imageFiles['rangka_atap'],
        fotoKolom: imageFiles['kolom'],
        fotoRingBalok: imageFiles['ring_balok'],
        fotoDindingPengisi: imageFiles['dinding_pengisi'],
        fotoKusen: imageFiles['kusen'],
        fotoPintu: imageFiles['pintu'],
        fotoJendela: imageFiles['jendela'],
        fotoStrukturBawah: imageFiles['struktur_bawah'],
        fotoPenutupLantai: imageFiles['penutup_lantai'],
        fotoPondasi: imageFiles['pondasi'],
        fotoSloof: imageFiles['sloof'],
        fotoMck: imageFiles['mck'],
        fotoAirKotor: imageFiles['air_kotor'],
      );

      if (response.success) {
        if (!context.mounted) return true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message.isNotEmpty
                ? response.message
                : 'Data berhasil diperbarui'),
            backgroundColor: Colors.green,
          ),
        );
        return true;
      } else {
        if (!context.mounted) return false;

        // Display more detailed error message
        String errorMessage = response.message.isNotEmpty
            ? response.message
            : 'Data gagal diperbarui';

        // Add detailed validation errors if available
        if (response.errors != null && response.errors!.isNotEmpty) {
          errorMessage += '\nDetail: ${response.errors.toString()}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    } catch (e) {
      if (!context.mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }
}
