class User {
  final int? userId;
  final String name;
  final String email;

  User({
    this.userId,
    required this.name,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userId: map['user_id'],
      name: map['name'],
      email: map['email'],
    );
  }
}
