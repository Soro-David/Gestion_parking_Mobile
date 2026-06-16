import '../../../../shared/domain/entities/parking_entry.dart';
import '../../../../shared/domain/entities/parking_exit.dart';
import '../../domain/repositories/caissier_history_repository.dart';
import '../datasources/caissier_history_remote_datasource.dart';
import '../datasources/dio_caissier_history_remote_datasource.dart';

class DioCaissierHistoryRepository implements CaissierHistoryRepository {
  DioCaissierHistoryRepository({CaissierHistoryRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? DioCaissierHistoryRemoteDataSource();

  final CaissierHistoryRemoteDataSource _remoteDataSource;

  @override
  Future<List<ParkingEntry>> getEntryHistory() {
    return _remoteDataSource.getEntryHistory();
  }

  @override
  Future<List<ParkingExit>> getExitHistory() {
    return _remoteDataSource.getExitHistory();
  }
}
