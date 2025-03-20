import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/data_cpb_model.dart';

class VerifikasiScreen extends StatefulWidget {
  final DataCPBModel data;

  const VerifikasiScreen({super.key, required this.data});

  @override
  VerifikasiScreenState createState() => VerifikasiScreenState();
}

class VerifikasiScreenState extends State<VerifikasiScreen> {
  String? selectedPenutupAtap;
  Map<String, File?> imageFiles = {};

  final Map<String, double> kondisiValues = {
    "Baik Sekali": 1.0,
    "Baik": 0.75,
    "Cukup": 0.5,
    "Kurang": 0.25,
    "Kurang Sekali": 0.0,
  };

  final Map<String, String> pilihanBerswadaya = {
    "1": "Ya",
    "0": "Tidak",
  };

  final Map<String, String> pilihanTipe = {
    "T": "Tembok",
    "K": "Kayu",
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
  }

  Future<void> _pickImage(String fieldName, ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        imageFiles[fieldName] = File(pickedFile.path);
      });
    }
  }

  Widget _buildDropdownWithImage(String fieldName, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 16), // Sesuai dengan _buildDropdown
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            isExpanded: true, // Samakan dengan _buildDropdown
            value: selectedValues[fieldName],
            hint: const Text('Pilih Opsi'),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20), // Sesuai dengan _buildDropdown
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(8), // Sesuai dengan _buildDropdown
              ),
            ),
            items: kondisiValues.keys.map((String key) {
              return DropdownMenuItem<String>(
                value: key,
                child: Text(key),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedValues[fieldName] = value;
              });
            },
            dropdownColor: Colors.white,
            alignment: AlignmentDirectional.bottomStart,
          ),
          const SizedBox(height: 8),
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => _pickImage(fieldName, ImageSource.gallery),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.photo_library,
                          size: 18, color: Colors.black),
                      const SizedBox(width: 6),
                      const Text(
                        'Pilih Foto dari Galeri',
                        style: TextStyle(fontSize: 14, color: Colors.black),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _pickImage(fieldName, ImageSource.camera),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.camera_alt,
                          size: 18, color: Colors.black),
                      const SizedBox(width: 6),
                      const Text(
                        'Ambil Foto',
                        style: TextStyle(fontSize: 14, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildDropdown(
      String fieldName, String hint, Map<String, String> options) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 16), // Tambahkan padding di kiri & kanan
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            displayNames[fieldName]!,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            isExpanded:
                true, // Agar dropdown tidak terpotong dan sesuai dengan lebar elemen
            value: selectedValues[fieldName],
            hint: Text(hint),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            items: options.entries.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedValues[fieldName] = value;
              });
            },
            dropdownColor: Colors.white,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
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
            onPressed: () {
              // Save logic here
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Nama: ${widget.data.nama}",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
            ),
            SizedBox(height: 8),
            Text(
              "NIK: ${widget.data.nik}",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
            ),
            SizedBox(height: 16),
            _buildDropdown("kesanggupan_berswadaya",
                "Pilih Kesanggupan Berswadaya", pilihanBerswadaya),
            _buildDropdown("tipe", "Pilih Tipe Bangunan", pilihanTipe),
            const SizedBox(height: 30),
            const Divider(thickness: 2, color: Colors.black),
            ...sections.entries.map((entry) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(entry.key),
                    ...entry.value.map((field) => _buildDropdownWithImage(
                          field,
                          displayNames[field] ?? field,
                        )),
                    const SizedBox(height: 30),
                    const Divider(thickness: 2, color: Colors.black),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
