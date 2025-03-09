import '../models/user_register.dart';

class RegisterResponse {
  final String? message;
  final UserRegister? user;
  final Map<String, List<String>>? errors;

  RegisterResponse({this.message, this.user, this.errors});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      message: json['message'],
      user:
          json.containsKey('user') ? UserRegister.fromJson(json['user']) : null,
      errors: json.containsKey('errors')
          ? Map<String, List<String>>.from(json['errors'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'user': user?.toJson(),
      'errors': errors,
    };
  }
}
