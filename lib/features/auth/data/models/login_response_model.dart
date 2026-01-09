class LoginResponseModel {
  final String accessToken;
  final String userName;
  final int expiresIn;

  LoginResponseModel({
    required this.accessToken,
    required this.userName,
    required this.expiresIn,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      accessToken: json['AccessToken'] ?? json['accessToken'] ?? '',
      userName: json['UserName'] ?? json['userName'] ?? '',
      expiresIn: json['ExpiresIn'] ?? json['expiresIn'] ?? 0,
    );
  }
}
