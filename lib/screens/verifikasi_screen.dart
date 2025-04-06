import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/data_cpb_model.dart';
import '../controllers/verifikasi_controller.dart';
import '../widgets/section_title_widget.dart';
import '../widgets/dropdown_with_image_widget.dart';
import '../widgets/simple_dropdown_widget.dart';
import '../widgets/user_info_widget.dart';
import '../widgets/photo_input_widget.dart';
import '../services/api_service.dart';

class VerifikasiScreen extends StatefulWidget {
  final DataCPBModel data;
  final bool isEditing;

  const VerifikasiScreen({
    super.key,
    required this.data,
    this.isEditing = false,
  });

  @override
  VerifikasiScreenState createState() => VerifikasiScreenState();
}

class VerifikasiScreenState extends State<VerifikasiScreen> {
  final VerifikasiController _controller = VerifikasiController();

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

  // Map to store image files
  Map<String, File?> imageFiles = {};

  bool _isLoading = false;
  int? verifikasiId;
  Map<String, String?> serverImageUrls = {};
  @override
  void initState() {
    super.initState();
    // Initialize image files map
    for (var key in selectedValues.keys) {
      imageFiles[key] = null;
      serverImageUrls[key] = null;
    }

    imageFiles['foto_kk'] = null;
    imageFiles['foto_ktp'] = null;
    serverImageUrls['foto_kk'] = null;
    serverImageUrls['foto_ktp'] = null;

    if (widget.isEditing) {
      _loadExistingData();
    }
  }

  Future<void> _loadExistingData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final existingData =
          await ApiService().getVerifikasiByNIK(widget.data.nik);

      if (existingData != null && existingData.isNotEmpty) {
        final idValue = existingData['id'];
        if (idValue is String) {
          verifikasiId = int.tryParse(idValue) ?? 0;
        } else if (idValue is int) {
          verifikasiId = idValue;
        } else if (idValue is double) {
          verifikasiId = idValue.toInt();
        } else {
          verifikasiId = 0;
        }

        // Tambahkan validasi ID
        if (verifikasiId == null || verifikasiId! <= 0) {
          throw Exception("ID verifikasi tidak valid atau tidak ditemukan");
        }

        if (mounted) {
          setState(() {
            // Handle kesanggupan_berswadaya - mengkonversi berbagai tipe data yang mungkin
            var kesanggupanValue = existingData['kesanggupan_berswadaya'];
            if (kesanggupanValue is bool) {
              selectedValues['kesanggupan_berswadaya'] =
                  kesanggupanValue ? "1" : "0";
            } else if (kesanggupanValue is int) {
              selectedValues['kesanggupan_berswadaya'] =
                  kesanggupanValue == 1 ? "1" : "0";
            } else if (kesanggupanValue is String) {
              selectedValues['kesanggupan_berswadaya'] =
                  (kesanggupanValue == "1" ||
                          kesanggupanValue.toLowerCase() == "true")
                      ? "1"
                      : "0";
            } else {
              // Default jika tidak bisa menentukan
              selectedValues['kesanggupan_berswadaya'] = "0";
            }

            selectedValues['tipe'] = existingData['tipe'];
            // Pastikan semua nilai memiliki default yang valid jika data dari server null
            for (String field in _controller.strukturalComponents) {
              double value = _parseNumericValue(existingData[field] ?? 0.0);
              selectedValues[field] =
                  _findKeyByValue(_controller.strukturalValues, value);

              // Tambahkan pengecekan nilai hasil
              if (selectedValues[field] == null) {
                selectedValues[field] = _controller.strukturalValues.keys.first;
              }
            }
            // Tangani komponen dengan nilai Ada/Tidak Ada
            for (String field in ['pondasi', 'sloof', 'air_kotor']) {
              double value = _parseNumericValue(existingData[field]);
              selectedValues[field] = value == 1.0 ? "Tidak Ada" : "Ada";
            }

            // Tangani komponen struktural
            for (String field in _controller.strukturalComponents) {
              double value = _parseNumericValue(existingData[field]);
              selectedValues[field] =
                  _findKeyByValue(_controller.strukturalValues, value);
            }

            // Tangani komponen lain menggunakan kondisiValues
            for (var entry in _controller.sections.entries) {
              for (String field in entry.value) {
                // Lewati field yang sudah ditangani
                if (_controller.strukturalComponents.contains(field) ||
                    [
                      'pondasi',
                      'sloof',
                      'air_kotor',
                      'kesanggupan_berswadaya',
                      'tipe'
                    ].contains(field)) {
                  continue;
                }

                double value = _parseNumericValue(existingData[field]);
                selectedValues[field] =
                    _findKeyByValue(_controller.kondisiValues, value);
              }
            }

            final baseImageUrl = ApiService.baseImageUrlEditVerifCPB;
            if (existingData['foto_ktp'] != null) {
              serverImageUrls['foto_ktp'] =
                  baseImageUrl + existingData['foto_ktp'];
            }

            if (existingData['foto_kk'] != null) {
              serverImageUrls['foto_kk'] =
                  baseImageUrl + existingData['foto_kk'];
            }

            // Mengisi URL gambar komponen
            for (var component in [
              'penutup_atap',
              'rangka_atap',
              'kolom',
              'ring_balok',
              'dinding_pengisi',
              'kusen',
              'pintu',
              'jendela',
              'struktur_bawah',
              'penutup_lantai',
              'pondasi',
              'sloof',
              'mck',
              'air_kotor'
            ]) {
              if (existingData['foto_$component'] != null) {
                serverImageUrls[component] =
                    baseImageUrl + existingData['foto_$component'];
              } else {
                debugPrint(
                    "No existing data found for NIK: ${widget.data.nik}");
                // Handle case when no data is found
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Data verifikasi tidak ditemukan'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              }
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  double _parseNumericValue(dynamic value) {
    if (value is int) {
      return value.toDouble();
    } else if (value is double) {
      return value;
    } else if (value is String) {
      return double.tryParse(value) ?? 0.0;
    } else {
      return 0.0;
    }
  }

  String _findKeyByValue(Map<String, double> map, double value) {
    return map.entries
        .firstWhere((entry) => (entry.value - value).abs() < 0.001,
            orElse: () => MapEntry(map.keys.first, map.values.first))
        .key;
  }

  Future<void> _pickImage(String fieldName, ImageSource source) async {
    final pickedFile = await _controller.pickImage(source, context);

    if (pickedFile != null) {
      setState(() {
        imageFiles[fieldName] = pickedFile;
      });
    }
  }

  Future<void> _saveData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });
    bool success;
    if (widget.isEditing && verifikasiId != null) {
      // Update data yang sudah ada
      success = await _controller.updateData(
        context: context,
        id: verifikasiId!,
        data: widget.data,
        selectedValues: selectedValues,
        imageFiles: imageFiles,
      );
    } else {
      // Simpan data baru
      success = await _controller.saveData(
        context: context,
        data: widget.data,
        selectedValues: selectedValues,
        imageFiles: imageFiles,
      );
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D6EFD),
        title: Text(
          widget.isEditing ? 'Edit Data Verifikasi' : 'Data Verifikasi',
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
                  options: _controller.pilihanBerswadaya,
                  displayNames: _controller.displayNames,
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
                  options: _controller.pilihanTipe,
                  displayNames: _controller.displayNames,
                  selectedValues: selectedValues,
                  onChanged: (fieldName, value) {
                    setState(() {
                      selectedValues[fieldName] = value;
                    });
                  },
                ),

                const SizedBox(height: 16),

                const Divider(thickness: 2, color: Colors.black),
                SectionTitleWidget(title: 'DOKUMEN'),

                PhotoInputWidget(
                  fieldName: 'foto_ktp',
                  title: 'Foto KTP',
                  imageFiles: imageFiles,
                  serverImageUrl: serverImageUrls['foto_ktp'],
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
                  serverImageUrl: serverImageUrls['foto_kk'],
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
                ...(_controller.sections.entries.map((entry) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionTitleWidget(title: entry.key),
                        ...entry.value.map(
                          (field) => DropdownWithImageWidget(
                            fieldName: field,
                            title: _controller.displayNames[field] ?? field,
                            // Determine kondisi values based on component type
                            kondisiValues:
                                _controller.strukturalComponents.contains(field)
                                    ? _controller.strukturalValues
                                    : (field == 'pondasi' ||
                                            field == 'sloof' ||
                                            field == 'air_kotor')
                                        ? _controller.nilaiAdaTidakAda
                                        : _controller.kondisiValues,
                            selectedValues: selectedValues,
                            imageFiles: imageFiles,
                            // Determine dropdown options based on component type
                            options: _controller.strukturalComponents
                                    .contains(field)
                                ? _controller.strukturalValues.keys.toList()
                                : (field == 'pondasi' ||
                                        field == 'sloof' ||
                                        field == 'air_kotor')
                                    ? _controller.pilihanAdaTidakAda.keys
                                        .toList()
                                    : _controller.kondisiValues.keys.toList(),
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
                            serverImageUrl: serverImageUrls[field],
                          ),
                        ),
                        const SizedBox(height: 30),
                        const Divider(thickness: 2, color: Colors.black),
                      ],
                    ))),

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
