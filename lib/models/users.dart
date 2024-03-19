class User {
  final String userId;
  final String fullname;
  final String username;
  final String password;

  User({
    required this.userId,
    required this.fullname,
    required this.password,
    required this.username,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'],
      fullname: json['fullname'],
      username: json['username'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'fullname': fullname,
      'username': username,
      'password': password,
    };
  }
}
