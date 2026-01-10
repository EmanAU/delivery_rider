class LoginRequestModel {
  final String username;
  final String passwordHash;

  LoginRequestModel({required this.username, required this.passwordHash});

  Map<String, dynamic> toJson() {
    return {'Username': username, 'PasswordHash': passwordHash};
  }
}
