import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/dio_auth_remote_datasource.dart';

class DioAuthRepository implements AuthRepository {
  DioAuthRepository({AuthRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? DioAuthRemoteDataSource();

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<User> login(String email, String password) async {
    final userModel = await _remoteDataSource.login(email, password);
    return userModel.toEntity();
  }

  @override
  Future<void> logout() async {
    await _remoteDataSource.logout();
  }

  @override
  Future<Map<String, dynamic>> getProfile() async {
    return await _remoteDataSource.getProfile();
  }
}
