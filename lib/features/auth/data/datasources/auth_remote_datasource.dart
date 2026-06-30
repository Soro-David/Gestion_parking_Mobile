import 'package:parking_mobile/shared/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);

  Future<void> logout();

  Future<Map<String, dynamic>> getProfile();

  Future<UserModel> updateProfile({
    required String name,
    String? firstName,
    required String email,
    String? phone,
    String? address,
    String? password,
    String? avatarPath,
  });

  Future<void> forgotPassword(String email);

  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  });
}
