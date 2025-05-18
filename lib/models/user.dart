class User {
  final String id;
  final String name;
  final String username;
  final String number;
  final String email;

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.number,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] as String,
      name: json['name'] as String? ?? '',
      username: json['username'] as String? ?? '',
      number: json['number']?.toString() ?? '',
      email: json['email'] as String? ?? '',
    );
  }
}
