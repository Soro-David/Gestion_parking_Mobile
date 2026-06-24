import 'package:parking_mobile/shared/data/repositories/dio_history_repository.dart';
import 'package:parking_mobile/shared/domain/repositories/history_repository.dart';

class AgentHistoryProvider {
  /// Repository d'historique configuré pour l'agent (basePath = '/attendant').
  static final HistoryRepository repository = DioHistoryRepository(basePath: '/attendant');
}
