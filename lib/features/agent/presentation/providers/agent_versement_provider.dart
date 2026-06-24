import 'package:parking_mobile/shared/data/repositories/dio_versement_repository.dart';
import 'package:parking_mobile/shared/domain/repositories/versement_repository.dart';

class AgentVersementProvider {
  /// Repository de versements configuré pour l'agent (basePath = '/attendant').
  static final VersementRepository repository = DioVersementRepository(basePath: '/attendant');
}
