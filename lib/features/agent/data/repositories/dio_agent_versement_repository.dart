import '../../../../shared/domain/entities/versement.dart';
import '../../domain/repositories/agent_versement_repository.dart';
import '../datasources/agent_versement_remote_datasource.dart';
import '../datasources/dio_agent_versement_remote_datasource.dart';

class DioAgentVersementRepository implements AgentVersementRepository {
  DioAgentVersementRepository({AgentVersementRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? DioAgentVersementRemoteDataSource();

  final AgentVersementRemoteDataSource _remoteDataSource;

  @override
  Future<List<Versement>> getVersements() {
    return _remoteDataSource.getVersements();
  }
  
  @override
  Future<VersementDetail> getVersementDetail(int id) {
    return _remoteDataSource.getVersementDetail(id);
  }
}
