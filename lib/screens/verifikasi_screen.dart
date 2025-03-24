// lib/screens/verifikasi_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/data_cpb_model.dart';
import '../services/api_service.dart';
import '../widgets/section_title_widget.dart';
import '../widgets/dropdown_with_image_widget.dart';
import '../widgets/simple_dropdown_widget.dart';
import '../widgets/user_info_widget.dart';
import '../widgets/image_compressor.dart';
import '../widgets/photo_input_widget.dart';

class VerifikasiScreen extends StatefulWidget {
  final DataCPBModel data;

  const VerifikasiScreen({super.key, required this.data});

  @override
  VerifikasiScreenState createState() => VerifikasiScreenState();
}

class VerifikasiScreenState extends State<VerifikasiScreen> {
  String? selectedPenutupAtap;
  Map<String, File?> imageFiles = {};
  bool _isLoading = false;
  final ApiService _apiService = ApiService(); // Inisialisasi API service
  Map<String, double> kondisiData = {};

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

  // Tambahkan Map untuk nilai Ada/Tidak Ada
  final Map<String, double> nilaiAdaTidakAda = {
    "Ada": 0.0,
    "Tidak Ada": 1.0,
  };

  // Map to store dropdown values
  final Map<String, String?> selectedValues = {
    'kesanggupan_berswadaya': null,
    'tipe': null,
    'penutup_atap': null,
    'rangka_atap': null,
    'kolom': null,
    'ring_balok': null,
    'dinding_pengisi': null,
    'kusen': null,
    'pintu': null,
    'jendela': null,
    'struktur_bawah': null,
    'penutup_lantai': null,
    'pondasi': null,
    'sloof': null,
    'mck': null,
    'air_kotor': null,
  };

  // Mapping for display names
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

  // Sections grouping
  final Map<String, List<String>> sections = {
    'ATAP': ['penutup_atap', 'rangka_atap'],
    'DINDING': ['kolom', 'ring_balok', 'dinding_pengisi'],
    'PINTU DAN JENDELA': ['kusen', 'pintu', 'jendela'],
    'LANTAI': ['struktur_bawah', 'penutup_lantai'],
    'PONDASI': ['pondasi', 'sloof'],
    'SANITASI': ['mck', 'air_kotor'],
  };

  @override
  void initState() {
    super.initState();
    // Initialize image files map
    for (var key in selectedValues.keys) {
      imageFiles[key] = null;
    }

    imageFiles['foto_kk'] = null;
    imageFiles['foto_ktp'] = null;
  }

  Future<void> _pickImage(String fieldName, ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      File compressedFile = await ImageCompressor.compressImage(imageFile);

      int fileSizeInKB = compressedFile.lengthSync() ~/ 1024;
      if (fileSizeInKB > 2048) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Ukuran gambar masih terlalu besar setelah dikompresi. Pilih gambar lain!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        imageFiles[fieldName] = compressedFile;
      });
    }
  }

  Future<void> _saveData() async {
    // Validasi form
    if (!_validateForm()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap lengkapi semua input yang diperlukan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (imageFiles['foto_ktp'] == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto KTP belum dipilih'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (imageFiles['foto_kk'] == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto KK belum dipilih'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Persiapkan data untuk API
      final nik = widget.data.nik;
      final kesanggupanBerswadaya =
          selectedValues['kesanggupan_berswadaya'] == '1';
      final tipe = selectedValues['tipe'] ?? '';

      // Mengambil nilai kondisi dan mengkonversi ke double
      // Mengambil nilai kondisi dan mengkonversi ke double
      Map<String, double> kondisiData = {};
      for (var sectionFields in sections.values) {
        for (var field in sectionFields) {
          final value = selectedValues[field]?.trim();

          // Logika penanganan nilai berdasarkan jenis komponen
          if (field == 'pondasi' || field == 'sloof' || field == 'air_kotor') {
            // Komponen dengan Ada/Tidak Ada
            if (value == "Ada") {
              kondisiData[field] = 0.0;
            } else {
              kondisiData[field] = 1.0;
            }
          } else if (strukturalComponents.contains(field)) {
            // Komponen struktural menggunakan strukturalValues
            kondisiData[field] = strukturalValues[value] ?? 0.0;
          } else if (value != null && kondisiValues.containsKey(value)) {
            // Komponen lain menggunakan kondisiValues
            kondisiData[field] = kondisiValues[value]!;
          } else {
            kondisiData[field] = 0.0;
          }
        }
      }
      if (imageFiles['foto_ktp'] == null || imageFiles['foto_kk'] == null) {
        setState(() {
          _isLoading = false;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto KTP dan KK belum dipilih'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      for (var section in sections.entries) {
        for (var field in section.value) {
          if (imageFiles[field] == null) {
            setState(() {
              _isLoading = false;
            });
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('Foto untuk ${displayNames[field]} belum dipilih'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
        }
      }

      // Panggil API service
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

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      if (response.success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message.isNotEmpty
                ? response.message
                : 'Data berhasil disimpan'),
            backgroundColor: Colors.green,
          ),
        );
        if (!mounted) return;
        Navigator.pop(context, true); // Kembali dengan status sukses
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message.isNotEmpty
                ? response.message
                : 'Data gagal disimpan'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool _validateForm() {
    bool isValid = true;

    // Periksa apakah kesanggupan_berswadaya dan tipe sudah dipilih
    if (selectedValues['kesanggupan_berswadaya'] == null ||
        selectedValues['tipe'] == null) {
      isValid = false;
    }

    // Periksa apakah semua field kondisi sudah memiliki nilai
    for (var sectionFields in sections.values) {
      for (var field in sectionFields) {
        if (selectedValues[field] == null) {
          isValid = false;
          break;
        }
      }
    }

    for (var sectionFields in sections.values) {
      for (var field in sectionFields) {
        if (imageFiles[field] == null) {
          isValid = false;
          break;
        }
      }
    }

    if (imageFiles['foto_ktp'] == null || imageFiles['foto_kk'] == null) {
      isValid = false;
    }

    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D6EFD),
        title: const Text(
          'Data Verifikasi',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: _isLoading ? null : _saveData,
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UserInfoWidget(data: widget.data),
                const SizedBox(height: 16),

                SimpleDropdownWidget(
                  fieldName: "kesanggupan_berswadaya",
                  hint: "Pilih Kesanggupan Berswadaya",
                  options: pilihanBerswadaya,
                  displayNames: displayNames,
                  selectedValues: selectedValues,
                  onChanged: (fieldName, value) {
                    setState(() {
                      selectedValues[fieldName] = value;
                    });
                  },
                ),

                SimpleDropdownWidget(
                  fieldName: "tipe",
                  hint: "Pilih Tipe Bangunan",
                  options: pilihanTipe,
                  displayNames: displayNames,
                  selectedValues: selectedValues,
                  onChanged: (fieldName, value) {
                    setState(() {
                      selectedValues[fieldName] = value;
                    });
                  },
                ),

                const SizedBox(height: 16),

                // Tambahkan bagian untuk foto KTP dan KK
                const Divider(thickness: 2, color: Colors.black),
                SectionTitleWidget(title: 'DOKUMEN'),

                PhotoInputWidget(
                  fieldName: 'foto_ktp',
                  title: 'Foto KTP',
                  imageFiles: imageFiles,
                  onImagePicked: _pickImage,
                  onImageRemoved: (fieldName) {
                    setState(() {
                      imageFiles[fieldName] = null;
                    });
                  },
                ),

                PhotoInputWidget(
                  fieldName: 'foto_kk',
                  title: 'Foto Kartu Keluarga',
                  imageFiles: imageFiles,
                  onImagePicked: _pickImage,
                  onImageRemoved: (fieldName) {
                    setState(() {
                      imageFiles[fieldName] = null;
                    });
                  },
                ),

                const SizedBox(height: 30),
                const Divider(thickness: 2, color: Colors.black),

                // Building all sections dynamically
                ...sections.entries.map((entry) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionTitleWidget(title: entry.key),
                        ...entry.value.map(
                          (field) => // Tambahkan parameter untuk menentukan tipe dropdown
                              DropdownWithImageWidget(
                            fieldName: field,
                            title: displayNames[field] ?? field,
                            // Menentukan nilai kondisi berdasarkan jenis komponen
                            kondisiValues: strukturalComponents.contains(field)
                                ? strukturalValues
                                : (field == 'pondasi' ||
                                        field == 'sloof' ||
                                        field == 'air_kotor')
                                    ? nilaiAdaTidakAda
                                    : kondisiValues,
                            selectedValues: selectedValues,
                            imageFiles: imageFiles,
                            // Menentukan pilihan opsi dropdown berdasarkan jenis komponen
                            options: strukturalComponents.contains(field)
                                ? strukturalValues.keys.toList()
                                : (field == 'pondasi' ||
                                        field == 'sloof' ||
                                        field == 'air_kotor')
                                    ? pilihanAdaTidakAda.keys.toList()
                                    : kondisiValues.keys.toList(),
                            onValueChanged: (fieldName, value) {
                              setState(() {
                                selectedValues[fieldName] = value;
                              });
                            },
                            onImagePicked: _pickImage,
                            onImageRemoved: (fieldName) {
                              setState(() {
                                imageFiles[fieldName] = null;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 30),
                        const Divider(thickness: 2, color: Colors.black),
                      ],
                    )),

                const SizedBox(height: 20),

                Center(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D6EFD),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Simpan Data',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withAlpha(76),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
