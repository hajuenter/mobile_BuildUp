import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class DropdownWithImageWidget extends StatelessWidget {
  final String fieldName;
  final String title;
  final Map<String, double> kondisiValues;
  final Map<String, String?> selectedValues;
  final Map<String, File?> imageFiles;
  final Function(String, String) onValueChanged;
  final Function(String, ImageSource) onImagePicked;
  final Function(String) onImageRemoved;
  final List<String>? options;

  const DropdownWithImageWidget({
    super.key,
    required this.fieldName,
    required this.title,
    required this.kondisiValues,
    required this.selectedValues,
    required this.imageFiles,
    required this.onValueChanged,
    required this.onImagePicked,
    required this.onImageRemoved,
    this.options,
  });

  @override
  Widget build(BuildContext context) {
    final dropdownOptions = options ?? kondisiValues.keys.toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            isExpanded: true,
            value: selectedValues[fieldName],
            hint: const Text('Pilih Opsi'),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: kondisiValues.keys.map((String key) {
              return DropdownMenuItem<String>(
                value: key,
                child: Text(key),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                onValueChanged(fieldName, value);
              }
            },
            dropdownColor: Colors.white,
            alignment: AlignmentDirectional.bottomStart,
          ),
          const SizedBox(height: 8),
          _buildImageSection(context),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: () => onImagePicked(fieldName, ImageSource.gallery),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.photo_library, size: 18, color: Colors.black),
                SizedBox(width: 6),
                Text(
                  'Pilih Foto dari Galeri',
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => onImagePicked(fieldName, ImageSource.camera),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.camera_alt, size: 18, color: Colors.black),
                SizedBox(width: 6),
                Text(
                  'Ambil Foto',
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (imageFiles[fieldName] != null)
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Image.file(
                      imageFiles[fieldName]!,
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        onImageRemoved(fieldName);
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
