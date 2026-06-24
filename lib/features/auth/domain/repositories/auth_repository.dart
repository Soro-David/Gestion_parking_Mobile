import 'package:parking_mobile/shared/domain/entities/user.dart';

abstract class AuthRepository {
  Future<User> login(String email, String password);

  Future<void> logout();

  Future<Map<String, dynamic>> getProfile({bool forceRefresh = false});

  Future<User> updateProfile({
    required String name,
    String? firstName,
    required String email,
    String? phone,
    String? address,
    String? password,
    String? avatarPath,
  });
}
