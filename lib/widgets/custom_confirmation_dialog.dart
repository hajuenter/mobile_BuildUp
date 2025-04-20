import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String cancelText;
  final String confirmText;
  final Color confirmColor;
  final Color cancelColor;
  final IconData confirmIcon;
  final IconData cancelIcon;
  final String? logoSvgAsset;
  final double logoSize;

  const CustomConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.cancelText = "Batal",
    this.confirmText = "Konfirmasi",
    this.confirmColor = Colors.red,
    this.cancelColor = Colors.grey,
    this.confirmIcon = Icons.check_circle,
    this.cancelIcon = Icons.cancel,
    this.logoSvgAsset,
    this.logoSize = 30.0,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Widget contentBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Logo Aplikasi (jika ada)
          // Logo Aplikasi (jika ada)
          if (logoSvgAsset != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                height: logoSize +
                    20, // Ukuran lingkaran sedikit lebih besar dari logo
                width: logoSize + 20,
                decoration: BoxDecoration(
                  color:
                      Colors.white, // Ubah warna latar belakang menjadi putih
                  shape: BoxShape.circle, // Bentuk lingkaran
                  border: Border.all(
                    // Tambahkan border biru
                    color: const Color(0xFF0D6EFD),
                    width: 2.0, // Atur ketebalan border
                  ),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    logoSvgAsset!,
                    height: logoSize,
                    width: logoSize,
                  ),
                ),
              ),
            ),

          // Judul
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Pesan
          Text(
            message,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Tombol-tombol
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              // Tombol Batal
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(false),
                icon: Icon(cancelIcon, color: Colors.white),
                label: Text(
                  cancelText,
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cancelColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              // Tombol Konfirmasi
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(true),
                icon: Icon(confirmIcon, color: Colors.white),
                label: Text(
                  confirmText,
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: confirmColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Function untuk menampilkan dialog konfirmasi
Future<bool> showCustomConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  String cancelText = "Batal",
  String confirmText = "Konfirmasi",
  Color confirmColor = Colors.red,
  Color cancelColor = Colors.grey,
  IconData confirmIcon = Icons.check_circle,
  IconData cancelIcon = Icons.cancel,
  String? logoSvgAsset,
  double logoSize = 30.0,
}) async {
  return await showDialog(
        context: context,
        builder: (context) => CustomConfirmationDialog(
          title: title,
          message: message,
          cancelText: cancelText,
          confirmText: confirmText,
          confirmColor: confirmColor,
          cancelColor: cancelColor,
          confirmIcon: confirmIcon,
          cancelIcon: cancelIcon,
          logoSvgAsset: logoSvgAsset,
          logoSize: logoSize,
        ),
      ) ??
      false;
}
