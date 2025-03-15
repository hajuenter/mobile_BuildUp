class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? noHp;
  final String? foto;
  final String? alamat;
  final String apiKey; // 🔥 API Key harus String, bukan Map!

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.noHp,
    this.foto,
    this.alamat,
    required this.apiKey,
  });

  // 🔹 Konversi JSON ke Object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      noHp: json['no_hp'],
      foto: json['foto'],
      alamat: json['alamat'],
      apiKey:
          json['api_key'] is Map ? json['api_key']['api_key'] : json['api_key'],
    );
  }

  // 🔹 Konversi Object ke JSON untuk disimpan di SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "role": role,
      "no_hp": noHp,
      "foto": foto,
      "alamat": alamat,
      "api_key": apiKey, // 🔥 Pastikan ini hanya String, bukan Map
    };
  }
}
