import 'dart:io';
import 'package:image/image.dart' as img;

class ImageCompressor {
  static Future<File> compressImage(File file) async {
    final image = img.decodeImage(await file.readAsBytes());

    if (image == null) return file; // Jika gagal decode, kembalikan file asli

    // Resize gambar dengan lebar maksimum 800px
    final resizedImage = img.copyResize(image, width: 800);

    // Simpan hasil kompresi ke file baru
    final compressedFile = File(file.path)
      ..writeAsBytesSync(img.encodeJpg(resizedImage, quality: 75));

    return compressedFile;
  }
}
