class UserRegister {
  final int id;
  final String name;
  final String email;
  final String? apiKey; // Tambahkan API Key

  UserRegister({
    required this.id,
    required this.name,
    required this.email,
    this.apiKey,
  });

  factory UserRegister.fromJson(Map<String, dynamic> json) {
    return UserRegister(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      apiKey: json['api_key'], // Pastikan ini sesuai dengan API response
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'api_key': apiKey,
    };
  }
}
