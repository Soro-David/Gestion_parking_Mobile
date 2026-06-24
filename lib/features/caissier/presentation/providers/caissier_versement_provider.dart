import 'package:parking_mobile/shared/data/repositories/dio_versement_repository.dart';
import 'package:parking_mobile/shared/domain/repositories/versement_repository.dart';

class CaissierVersementProvider {
  /// Repository de versements configuré pour le caissier (basePath = '/caissier').
  static final VersementRepository repository = DioVersementRepository(basePath: '/caissier');
}
