class User {
  final String id;
  final String name;
  final String username;
  final String? imageUrl;

  User({
    required this.id,
    required this.name,
    required this.username,
    this.imageUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      imageUrl: json['imageUrl'],
    );
  }
}