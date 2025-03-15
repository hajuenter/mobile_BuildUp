import 'package:flutter/material.dart';

class InputEmail extends StatefulWidget {
  final TextEditingController controller;
  final String?
      externalError; // 🔹 Tambahkan ini untuk menerima error dari luar

  const InputEmail({
    super.key,
    required this.controller,
    this.externalError, // 🔹 Parameter opsional
  });

  @override
  InputEmailState createState() => InputEmailState();
}

class InputEmailState extends State<InputEmail> {
  String? errorText;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && widget.controller.text.isEmpty) {
        setState(() {
          errorText = "Email tidak boleh kosong";
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant InputEmail oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 🔹 Perbarui error jika externalError berubah
    if (widget.externalError != oldWidget.externalError) {
      setState(() {
        errorText = widget.externalError;
      });
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _validateInput(String value) {
    setState(() {
      errorText = value.isEmpty ? "Email tidak boleh kosong" : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      cursorColor: Colors.black,
      controller: widget.controller,
      focusNode: _focusNode,
      keyboardType: TextInputType.emailAddress,
      onChanged: _validateInput, // ✅ Hapus error saat mulai mengetik
      decoration: InputDecoration(
        labelText: 'Email',
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
        errorText: errorText, // ✅ Gunakan error dari internal & external
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        prefixIcon: const Icon(Icons.email, color: Colors.grey),
      ),
    );
  }
}
