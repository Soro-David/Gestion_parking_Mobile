import '../../data/repositories/dio_agent_stationnement_repository.dart';
import '../../domain/repositories/agent_stationnement_repository.dart';

class AgentStationnementProvider {
  static final AgentStationnementRepository repository = DioAgentStationnementRepository();
}
