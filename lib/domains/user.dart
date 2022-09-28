class User {
  final int id;
  final String email;
  final String role;

  User(this.email, this.id, this.role);

  User.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        email = json['email'],
        role = json['role'];
}