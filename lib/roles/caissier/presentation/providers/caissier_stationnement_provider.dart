import '../../data/repositories/dio_caissier_stationnement_repository.dart';
import '../../domain/repositories/caissier_stationnement_repository.dart';

class CaissierStationnementProvider {
  static final CaissierStationnementRepository repository = DioCaissierStationnementRepository();
}
