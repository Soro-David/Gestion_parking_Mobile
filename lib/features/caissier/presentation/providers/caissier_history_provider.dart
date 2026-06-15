import '../../data/repositories/dio_caissier_history_repository.dart';
import '../../domain/repositories/caissier_history_repository.dart';

class CaissierHistoryProvider {
  static final CaissierHistoryRepository repository = DioCaissierHistoryRepository();
}
