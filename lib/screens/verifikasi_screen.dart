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

class VerifikasiScreen extends StatefulWidget {
  final DataCPBModel data;

  const VerifikasiScreen({super.key, required this.data});

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

    final success = await _controller.saveData(
      context: context,
      data: widget.data,
      selectedValues: selectedValues,
      imageFiles: imageFiles,
    );

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
