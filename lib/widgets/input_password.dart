import 'package:flutter/material.dart';
import '../core/validator.dart';

class InputPassword extends StatefulWidget {
  final TextEditingController controller;
  final bool showValidation;
  final String?
      externalError; // 🔹 Tambahkan ini untuk menerima error dari luar

  const InputPassword({
    super.key,
    required this.controller,
    this.showValidation = true,
    this.externalError, // 🔹 Parameter opsional
  });

  @override
  _InputPasswordState createState() => _InputPasswordState();
}

class _InputPasswordState extends State<InputPassword> {
  bool _isPasswordVisible = false;
  bool _hasError = false;
  final FocusNode _focusNode = FocusNode();
  String? errorText;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _validatePassword(widget.controller.text);
      }
    });
  }

  @override
  void didUpdateWidget(covariant InputPassword oldWidget) {
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

  void _validatePassword(String value) {
    final firstInvalidRule = Validator.getFirstInvalidRule(value);

    setState(() {
      _hasError = firstInvalidRule != null;
      errorText = _hasError
          ? firstInvalidRule!["text"]
          : null; // ✅ Null jika tidak ada error
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      cursorColor: Colors.black,
      controller: widget.controller,
      focusNode: _focusNode,
      obscureText: !_isPasswordVisible,
      onChanged: _validatePassword,
      decoration: InputDecoration(
        labelText: 'Password',
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
          borderSide:
              BorderSide(color: Colors.grey), // Default jika tidak ada error
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: _hasError
                ? Colors.red
                : Colors.white, // Jika error, merah. Jika tidak, putih.
            width: 3,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: _hasError
                ? Colors.red
                : Colors.black, // Jika error, merah. Jika tidak, hitam.
            width: 2,
          ),
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
        prefixIcon: const Icon(Icons.lock, color: Colors.grey),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey[700],
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
      ),
    );
  }
}
