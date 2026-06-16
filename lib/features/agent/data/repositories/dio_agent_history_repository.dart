import '../../../../shared/domain/entities/parking_entry.dart';
import '../../../../shared/domain/entities/parking_exit.dart';
import '../../domain/repositories/agent_history_repository.dart';
import '../datasources/agent_history_remote_datasource.dart';
import '../datasources/dio_agent_history_remote_datasource.dart';

class DioAgentHistoryRepository implements AgentHistoryRepository {
  DioAgentHistoryRepository({AgentHistoryRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? DioAgentHistoryRemoteDataSource();

  final AgentHistoryRemoteDataSource _remoteDataSource;

  @override
  Future<List<ParkingEntry>> getEntryHistory() {
    return _remoteDataSource.getEntryHistory();
  }

  @override
  Future<List<ParkingExit>> getExitHistory() {
    return _remoteDataSource.getExitHistory();
  }
}
