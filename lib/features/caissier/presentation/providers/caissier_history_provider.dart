import 'package:parking_mobile/shared/data/repositories/dio_history_repository.dart';
import 'package:parking_mobile/shared/domain/repositories/history_repository.dart';

class CaissierHistoryProvider {
  /// Repository d'historique configuré pour le caissier (basePath = '/caissier').
  static final HistoryRepository repository = DioHistoryRepository(basePath: '/caissier');
}
