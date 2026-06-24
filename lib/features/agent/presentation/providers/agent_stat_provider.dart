import '../../domain/repositories/agent_stat_repository.dart';
import '../../data/repositories/agent_stat_repository_impl.dart';

class AgentStatProvider {
  static final AgentStatRepository repository = AgentStatRepositoryImpl();
}
