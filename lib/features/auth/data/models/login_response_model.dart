class LoginResponseModel {
  final String accessToken;
  final String userName;
  final String riderId;
  final int expiresIn;

  LoginResponseModel({
    required this.accessToken,
    required this.userName,
    required this.riderId,
    required this.expiresIn,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      accessToken: json['AccessToken'] ?? json['accessToken'] ?? '',
      userName: json['UserName'] ?? json['userName'] ?? '',
      riderId: json['RiderId'] ?? json['riderId'] ?? '',
      expiresIn: json['ExpiresIn'] ?? json['expiresIn'] ?? 0,
    );
  }
}
