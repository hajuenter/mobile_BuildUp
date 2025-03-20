import '../models/verifikasi_model.dart';

class VerifikasiResponse {
  final bool success;
  final String message;
  final VerifikasiModel? data;
  final Map<String, dynamic>? errors;

  VerifikasiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  factory VerifikasiResponse.fromJson(Map<String, dynamic> json) {
    return VerifikasiResponse(
      success: json['status'] == 'success',
      message: json['message'] ?? '',
      data: json.containsKey('data')
          ? VerifikasiModel.fromJson(json['data'])
          : null,
      errors: json.containsKey('errors') ? json['errors'] : null,
    );
  }
}
