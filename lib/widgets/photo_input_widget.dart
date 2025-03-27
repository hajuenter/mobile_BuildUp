import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PhotoInputWidget extends StatelessWidget {
  final String fieldName;
  final String title;
  final Map<String, File?> imageFiles;
  final Function(String, ImageSource) onImagePicked;
  final Function(String) onImageRemoved;

  const PhotoInputWidget({
    super.key,
    required this.fieldName,
    required this.title,
    required this.imageFiles,
    required this.onImagePicked,
    required this.onImageRemoved,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Center(
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
                const SizedBox(height: 16),
                if (imageFiles[fieldName] != null)
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Image.file(
                            imageFiles[fieldName]!,
                            width: 140,
                            height: 140,
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
                  )
                else
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'Belum ada foto',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.info_outline, size: 14, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      'Maksimal ukuran foto 10MB',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
