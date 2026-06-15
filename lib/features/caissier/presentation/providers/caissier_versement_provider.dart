import '../../data/repositories/dio_caissier_versement_repository.dart';
import '../../domain/repositories/caissier_versement_repository.dart';

class CaissierVersementProvider {
  static final CaissierVersementRepository repository =
      DioCaissierVersementRepository();
}
