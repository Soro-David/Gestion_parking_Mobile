import '../../data/repositories/dio_agent_versement_repository.dart';
import '../../domain/repositories/agent_versement_repository.dart';

class AgentVersementProvider {
  static final AgentVersementRepository repository =
      DioAgentVersementRepository();
}
