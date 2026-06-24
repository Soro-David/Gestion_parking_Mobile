import '../../domain/repositories/agent_stat_repository.dart';
import '../datasources/agent_stat_remote_datasource.dart';
import '../../../../shared/domain/entities/statistiques.dart';

class AgentStatRepositoryImpl implements AgentStatRepository {
  final AgentStatRemoteDataSource remoteDataSource;

  AgentStatRepositoryImpl({AgentStatRemoteDataSource? remoteDataSource})
      : remoteDataSource = remoteDataSource ?? AgentStatRemoteDataSource();

  @override
  Future<Statistiques> getStats() async {
    return await remoteDataSource.getStats();
  }
}
