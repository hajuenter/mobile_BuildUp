class ResetPasswordResponse {
  final bool success;
  final String? message;
  final String? error;

  ResetPasswordResponse({this.success = false, this.message, this.error});
}
