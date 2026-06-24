import 'package:parking_mobile/shared/domain/entities/user.dart';

class UserModel {
  final String name;
  final String? firstName;
  final String email;
  final String? phone;
  final String? address;
  final UserRole role;
  final String? avatarUrl;

  const UserModel({
    required this.name,
    this.firstName,
    required this.email,
    this.phone,
    this.address,
    required this.role,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final roleStr = json['role'] as String?;
    UserRole parsedRole = UserRole.agent;

    if (roleStr == 'caissier') {
      parsedRole = UserRole.caissier;
    } else if (roleStr == 'attendant' || roleStr == 'agent') {
      parsedRole = UserRole.agent;
    }

    return UserModel(
      name: json['name'] as String,
      firstName: json['first_name'] as String?,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      role: parsedRole,
      avatarUrl: User.sanitizeAvatarUrl(json['avatar_url'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'first_name': firstName,
      'email': email,
      'phone': phone,
      'address': address,
      'role': role.name,
      'avatar_url': avatarUrl,
    };
  }

  User toEntity() => User(
        name: name,
        firstName: firstName,
        email: email,
        phone: phone,
        address: address,
        role: role,
        avatarUrl: avatarUrl,
      );
}
