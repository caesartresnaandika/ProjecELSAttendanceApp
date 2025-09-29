// lib/models/user_model.dart

class User {
  final String id;
  final String name;
  final String username;
  final String? imageUrl;
  final String position;
  final String? email;

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.position,
    this.imageUrl,
    this.email,
  });

  // ✅ BLOK INI YANG DIPERBAIKI
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['employee_user_id'] as String,
      name: json['employee_user_name'] as String,
      username: json['employee_user_username'] as String,
      imageUrl: json['employee_user_image'] as String?,
      position: json['employee_group_id'] as String,
      email: json['employee_user_email'] as String?, // Tetap aman karena nullable
    );
  }
}