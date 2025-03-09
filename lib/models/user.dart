class User {
  final int id;
  final String? name;
  final String? email;
  final String? role;
  final String? noHp;
  final String? foto;
  final String? alamat;
  final String? token;

  User({
    required this.id,
    this.name,
    this.email,
    this.role,
    this.noHp,
    this.foto,
    this.alamat,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      noHp: json['no_hp'] ?? '',
      foto: json['foto'] ?? '',
      alamat: json['alamat'] ?? '',
      token: json['token'],
    );
  }
}
