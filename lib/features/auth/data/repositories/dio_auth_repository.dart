import 'package:parking_mobile/shared/domain/entities/user.dart';
import 'package:parking_mobile/shared/services/notification_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/dio_auth_remote_datasource.dart';


class DioAuthRepository implements AuthRepository {
  DioAuthRepository({AuthRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? DioAuthRemoteDataSource();

  final AuthRemoteDataSource _remoteDataSource;
  Map<String, dynamic>? _cachedProfile;

  @override
  Future<User> login(String email, String password) async {
    final userModel = await _remoteDataSource.login(email, password);
    // ✓ Mettre à jour le token FCM à chaque connexion
    await NotificationService.instance.onUserLogin();
    return userModel.toEntity();
  }


  @override
  Future<void> logout() async {
    // ✓ Supprimer le token FCM avant la déconnexion
    await NotificationService.instance.onUserLogout();
    await _remoteDataSource.logout();
  }


  @override
  Future<Map<String, dynamic>> getProfile({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedProfile != null) {
      return _cachedProfile!;
    }
    final profile = await _remoteDataSource.getProfile();
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
    final userModel = await _remoteDataSource.updateProfile(
      name: name,
      firstName: firstName,
      email: email,
      phone: phone,
      address: address,
      password: password,
      avatarPath: avatarPath,
    );
    // On force le rafraîchissement du profil au prochain getProfile
    _cachedProfile = null;
    return userModel.toEntity();
  }

  @override
  Future<void> forgotPassword(String email) async {
    await _remoteDataSource.forgotPassword(email);
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    await _remoteDataSource.resetPassword(
      email: email,
      token: token,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }
}
