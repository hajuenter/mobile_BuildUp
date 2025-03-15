import 'package:flutter/material.dart';

class InputOtp extends StatefulWidget {
  final TextEditingController controller;
  final String? externalError; // ✅ Error dari luar

  const InputOtp({super.key, required this.controller, this.externalError});

  @override
  InputOtpState createState() => InputOtpState();
}

class InputOtpState extends State<InputOtp> {
  String? errorText;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && widget.controller.text.isEmpty) {
        setState(() {
          errorText = "Kode OTP tidak boleh kosong";
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant InputOtp oldWidget) {
    super.didUpdateWidget(oldWidget);
    // ✅ Jika `externalError` berubah, update errorText
    if (widget.externalError != oldWidget.externalError) {
      setState(() {
        errorText = widget.externalError;
      });
    }
  }

  void _validateInput(String value) {
    setState(() {
      errorText = value.isEmpty ? "Kode OTP tidak boleh kosong" : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      cursorColor: Colors.black,
      controller: widget.controller,
      focusNode: _focusNode,
      keyboardType: TextInputType.number,
      maxLength: 4,
      textAlign: TextAlign.center,
      onChanged: _validateInput, // ✅ Error hilang saat mulai mengetik
      decoration: InputDecoration(
        labelText: 'Kode OTP',
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
        counterText: "",
      ),
    );
  }
}
