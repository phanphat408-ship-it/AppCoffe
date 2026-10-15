import 'user_model.dart';

/// Model phản hồi khi đăng nhập / đăng ký thành công
class AuthResponseModel {
  final String token;
  final DateTime? expiresAt;
  final UserModel user;

  const AuthResponseModel({
    required this.token,
    this.expiresAt,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'] as String? ?? '',
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'] as String)
          : null,
      user: json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : const UserModel(id: 0, name: '', phone: '', role: 'Customer'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'expiresAt': expiresAt?.toIso8601String(),
      'user': user.toJson(),
    };
  }
}
