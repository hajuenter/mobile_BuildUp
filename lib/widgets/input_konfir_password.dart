import 'package:flutter/material.dart';
import '../core/validator.dart';

class InputKonfirPassword extends StatefulWidget {
  final TextEditingController controller;
  final TextEditingController passwordController;
  final String? externalError; // 🔹 Tambahkan untuk menerima error dari luar

  const InputKonfirPassword({
    super.key,
    required this.controller,
    required this.passwordController,
    this.externalError, // 🔹 Parameter opsional
  });

  @override
  InputKonfirPasswordState createState() => InputKonfirPasswordState();
}

class InputKonfirPasswordState extends State<InputKonfirPassword> {
  bool _isPasswordVisible = false;
  String? errorText;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _validatePassword();
      }
    });
  }

  @override
  void didUpdateWidget(covariant InputKonfirPassword oldWidget) {
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

  void _validatePassword() {
    final validationMessage = Validator.validatePasswordConfirmation(
      widget.passwordController.text,
      widget.controller.text,
    );

    setState(() {
      errorText = validationMessage.isNotEmpty ? validationMessage : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      cursorColor: Colors.black,
      controller: widget.controller,
      focusNode: _focusNode,
      obscureText: !_isPasswordVisible,
      onChanged: (value) => _validatePassword(),
      decoration: InputDecoration(
        labelText: 'Konfirmasi Password',
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
          borderSide: BorderSide(
            color: errorText != null
                ? Colors.red
                : Colors.white, // Jika error, merah. Jika tidak, putih.
            width: 3,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: errorText != null
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
        prefixIcon: const Icon(Icons.lock_reset, color: Colors.grey),
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
