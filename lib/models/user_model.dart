// Di dalam file: lib/models/user_model.dart

class User {
  final String id;
  final String name;
  final String username;
  final String? imageUrl; // Tanda tanya (?) berarti boleh null
  final String position;

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.position,
    this.imageUrl,
  });

  // Factory constructor untuk membuat instance User dari JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      // Pastikan semua key di sini sama persis dengan di JSON
      id: json['sales_user_id'],
      name: json['sales_user_name'],
      username: json['sales_user_username'],
      imageUrl: json['sales_user_image'],
      position: json['sales_group_id'],
    );
  }
}