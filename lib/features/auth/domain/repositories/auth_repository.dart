import '../../../../shared/models/user_model.dart';

abstract class AuthRepository {
  /// Authenticates a user using email and password and returns their profile info.
  Future<UserModel> login(String email, String password);

  /// Logs out the user from the backend and clears local session.
  Future<void> logout();

  /// Récupère le profil de l'utilisateur connecté.
  Future<Map<String, dynamic>> getProfile();
}

