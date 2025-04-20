import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String message;
  final String svgAsset; // Ganti dari imagePath ke svgAsset
  final String buttonText;
  final VoidCallback onPressed;
  final double logoSize;

  const CustomDialog({
    super.key,
    required this.title,
    required this.message,
    required this.svgAsset,
    required this.buttonText,
    required this.onPressed,
    this.logoSize = 30.0,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Widget contentBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).toInt()),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // SVG dalam lingkaran biru
          // SVG dalam lingkaran putih dengan border biru
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              height: logoSize + 20,
              width: logoSize + 20,
              decoration: BoxDecoration(
                color: Colors.white, // Ubah warna background menjadi putih
                shape: BoxShape.circle,
                border: Border.all(
                  // Tambahkan border biru
                  color: const Color(0xFF0D6EFD),
                  width: 2.0, // Atur ketebalan border sesuai kebutuhan
                ),
              ),
              child: Center(
                child: SvgPicture.asset(
                  svgAsset,
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
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),

          // Pesan
          Text(
            message,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Tombol
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D6EFD),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: onPressed,
              child: Text(
                buttonText,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
