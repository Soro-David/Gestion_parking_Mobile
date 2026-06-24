import '../../domain/repositories/caissier_stat_repository.dart';
import '../../data/repositories/caissier_stat_repository_impl.dart';

class CaissierStatProvider {
  static final CaissierStatRepository repository = CaissierStatRepositoryImpl();
}
