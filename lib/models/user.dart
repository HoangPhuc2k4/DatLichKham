class User {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String phone;
  final String role; // 'user' hoặc 'admin'

  User({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.role,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      password: map['password'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      role: map['role'] as String? ?? 'user',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'role': role,
    };
  }

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    String? phone,
    String? role,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      role: role ?? this.role,
    );
  }
}

