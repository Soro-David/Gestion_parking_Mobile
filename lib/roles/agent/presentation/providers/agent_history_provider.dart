import '../../data/repositories/dio_agent_history_repository.dart';
import '../../domain/repositories/agent_history_repository.dart';

class AgentHistoryProvider {
  static final AgentHistoryRepository repository = DioAgentHistoryRepository();
}
