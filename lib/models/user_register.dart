class UserRegister {
  final int id;
  final String name;
  final String email;

  UserRegister({
    required this.id,
    required this.name,
    required this.email,
  });

  factory UserRegister.fromJson(Map<String, dynamic> json) {
    return UserRegister(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}
