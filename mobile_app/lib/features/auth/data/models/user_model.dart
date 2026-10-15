/// Model thông tin người dùng trong ứng dụng
class UserModel {
  final int id;
  final String name;
  final String phone;
  final String role;
  final String? email;
  final String? avatarUrl;
  final int points;
  final String membershipTier;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    this.email,
    this.avatarUrl,
    this.points = 1250,
    this.membershipTier = 'Vàng',
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      role: json['role'] as String? ?? 'Customer',
      email: json['email'] as String? ?? 'nguyenvanan@gmail.com',
      avatarUrl: json['avatarUrl'] as String? ??
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500',
      points: json['points'] as int? ?? 1250,
      membershipTier: json['membershipTier'] as String? ?? 'Vàng',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'role': role,
      'email': email,
      'avatarUrl': avatarUrl,
      'points': points,
      'membershipTier': membershipTier,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? phone,
    String? role,
    String? email,
    String? avatarUrl,
    int? points,
    String? membershipTier,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      points: points ?? this.points,
      membershipTier: membershipTier ?? this.membershipTier,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
