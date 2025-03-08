import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputOtp extends StatelessWidget {
  final TextEditingController controller;

  const InputOtp({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly, // Hanya menerima angka
        LengthLimitingTextInputFormatter(
            4), // Batasi panjang input menjadi 4 digit
      ],
      cursorColor: Colors.black,
      decoration: InputDecoration(
        labelText: 'OTP',
        labelStyle: TextStyle(
          color: Colors.grey[700],
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
        floatingLabelStyle: const TextStyle(
          color: Colors.black,
          fontSize: 14,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white, width: 3),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black, width: 2),
        ),
        prefixIcon: const Icon(Icons.security, color: Colors.grey),
      ),
    );
  }
}
