class OtpVerificationModel {
  final bool success;
  final String message;

  OtpVerificationModel({required this.success, required this.message});

  factory OtpVerificationModel.fromJson(Map<String, dynamic> json) {
    return OtpVerificationModel(
      success: json['success'] ?? false,
      message: json['message'] ?? "Terjadi kesalahan",
    );
  }
}
