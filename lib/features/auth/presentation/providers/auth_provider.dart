import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/dio_auth_repository.dart';

class AuthProvider {
  /// The global static instance of AuthRepository.
  /// 
  /// Initialized to [DioAuthRepository] to consume the backend.
  static final AuthRepository repository = DioAuthRepository();
}