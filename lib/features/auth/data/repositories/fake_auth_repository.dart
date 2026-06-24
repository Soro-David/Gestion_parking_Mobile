import 'package:parking_mobile/shared/domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  Map<String, dynamic>? _cachedProfile;
  @override
  Future<User> login(String email, String password) async {
    // Simulate network delay (e.g., API call) of 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    final emailClean = email.trim().toLowerCase();

    if (emailClean == 'agent@gmail.com') {
      return const User(
        name: 'Agent Smart',
        email: 'agent@gmail.com',
        role: UserRole.agent,
      );
    } else if (emailClean == 'caissier@gmail.com') {
      return const User(
        name: 'Caissier Smart',
        email: 'caissier@gmail.com',
        role: UserRole.caissier,
      );
    } else {
      // Throw exception for any other user, simulating a 401 Unauthorized API error
      throw Exception('Identifiants invalides ou utilisateur non autorisé.');
    }
  }

  @override
  Future<void> logout() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<Map<String, dynamic>> getProfile({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedProfile != null) {
      return _cachedProfile!;
    }
    await Future.delayed(const Duration(seconds: 1));
    final profile = {
      "user": {
        "id": 4,
        "name": "Kone",
        "first_name": "mamadou",
        "email": "caissier@gmail.com",
        "phone": "0303930021",
        "role": "caissier",
        "avatar_url": "https://avatar.iran.liara.run/public/boy",
      },
      "profile": {
        "id": 1,
        "user_id": 4,
        "created_by": 3,
        "created_at": "2026-05-20T09:09:51.000000Z",
        "updated_at": "2026-05-20T09:09:51.000000Z",
      },
    };
    _cachedProfile = profile;
    return profile;
  }

  @override
  Future<User> updateProfile({
    required String name,
    String? firstName,
    required String email,
    String? phone,
    String? address,
    String? password,
    String? avatarPath,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    if (_cachedProfile != null && _cachedProfile!['user'] != null) {
      final user = _cachedProfile!['user'] as Map<String, dynamic>;
      user['name'] = name;
      user['email'] = email;
      if (firstName != null) user['first_name'] = firstName;
      if (phone != null) user['phone'] = phone;
      if (address != null) user['address'] = address;
      // Note: we don't handle avatar upload in fake repository
    }
    return User(
      name: name,
      firstName: firstName,
      email: email,
      phone: phone,
      address: address,
      role: UserRole.agent,
    );
  }
}
