import '../../domain/entities/user.dart';

class UserModel {
  final String name;
  final String email;
  final UserRole role;

  const UserModel({
    required this.name,
    required this.email,
    required this.role,
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
      email: json['email'] as String,
      role: parsedRole,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'role': role.name,
    };
  }

  User toEntity() => User(name: name, email: email, role: role);
}
