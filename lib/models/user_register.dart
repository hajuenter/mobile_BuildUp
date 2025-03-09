class UserRegister {
  final int id;
  final String name;
  final String email;
  final String role;

  UserRegister({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory UserRegister.fromJson(Map<String, dynamic> json) {
    return UserRegister(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'] ?? 'user', // Default role user
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
    };
  }
}
