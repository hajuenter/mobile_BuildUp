class SendOtpResponse {
  final bool success;
  final String message;

  SendOtpResponse({required this.success, required this.message});

  factory SendOtpResponse.fromJson(Map<String, dynamic> json) {
    return SendOtpResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? "Terjadi kesalahan",
    );
  }
}
