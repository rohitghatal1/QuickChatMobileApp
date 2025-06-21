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
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '' ,
      name: json['name']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      number: json['number']?.toString() ?? '',
      email: json['email'] as String? ?? '',
    );
  }
}
