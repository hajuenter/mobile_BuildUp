import 'dart:convert';
import '../models/otp_verification_model.dart';

class OtpVerificationResponse {
  final OtpVerificationModel? data;
  final String? error;

  OtpVerificationResponse({this.data, this.error});

  factory OtpVerificationResponse.fromResponse(String responseBody) {
    final jsonData = jsonDecode(responseBody);

    if (jsonData['success'] == true) {
      return OtpVerificationResponse(
        data: OtpVerificationModel.fromJson(jsonData),
      );
    } else {
      return OtpVerificationResponse(
        error: jsonData['message'] ?? "Verifikasi gagal",
      );
    }
  }
}
