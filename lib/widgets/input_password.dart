import 'package:flutter/material.dart';
import '../core/validator.dart';

class InputPassword extends StatefulWidget {
  final TextEditingController controller;
  final bool showValidation;
  final String? externalError;
  final bool isLogin; // 🔹 Tambahkan parameter isLogin

  const InputPassword({
    super.key,
    required this.controller,
    this.showValidation = true,
    this.externalError,
    required this.isLogin, // 🔹 Wajib diisi untuk menentukan validasi
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
    final firstInvalidRule =
        Validator.getFirstInvalidRule(value, widget.isLogin);

    setState(() {
      _hasError = firstInvalidRule != null;
      errorText = _hasError ? firstInvalidRule!["text"] : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      cursorColor: Colors.black,
      controller: widget.controller,
      focusNode: _focusNode,
      obscureText: !_isPasswordVisible,
      onChanged: _validatePassword, // ✅ Langsung pakai fungsi tanpa error
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
          borderSide: BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: _hasError ? Colors.red : Colors.white,
            width: 3,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: _hasError ? Colors.red : Colors.black,
            width: 2,
          ),
        ),
        errorText: errorText, // ✅ Menampilkan error jika ada
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
