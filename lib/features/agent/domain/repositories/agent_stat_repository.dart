import '../../../../shared/domain/entities/statistiques.dart';

abstract class AgentStatRepository {
  Future<Statistiques> getStats();
}
