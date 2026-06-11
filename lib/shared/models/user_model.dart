enum UserRole {
  agent,
  caissier,
}

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

  /// Converts the user model into standard JSON format
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'role': role.name,
    };
  }
}
