class ProfileResponse {
  final String message;
  final User user;

  ProfileResponse({required this.message, required this.user});

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      message: json['message'],
      user: User.fromJson(json['user']),
    );
  }
}

class User {
  final int id;
  final String name;
  final String email;
  final String noHp;
  final String alamat;
  final String foto; // Hanya nama file, bukan URL

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.noHp,
    required this.alamat,
    required this.foto,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      noHp: json['no_hp'] ?? '',
      alamat: json['alamat'] ?? '',
      foto: json['foto'] ?? 'default-profile.png',
    );
  }
}
