import '../../../../shared/domain/entities/parking_entry.dart';
import '../../domain/repositories/agent_stationnement_repository.dart';
import '../datasources/agent_stationnement_remote_datasource.dart';
import '../datasources/dio_agent_stationnement_remote_datasource.dart';

class DioAgentStationnementRepository implements AgentStationnementRepository {
  DioAgentStationnementRepository({AgentStationnementRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? DioAgentStationnementRemoteDataSource();

  final AgentStationnementRemoteDataSource _remoteDataSource;

  @override
  Future<List<ParkingEntry>> getStationnementsEnCours() {
    return _remoteDataSource.getStationnementsEnCours();
  }
}
