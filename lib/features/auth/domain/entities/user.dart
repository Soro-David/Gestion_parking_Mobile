enum UserRole {
  agent,
  caissier,
}

class User {
  final String name;
  final String email;
  final UserRole role;

  const User({
    required this.name,
    required this.email,
    required this.role,
  });
}
