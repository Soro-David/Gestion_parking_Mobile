import '../../../../shared/data/models/parking_entry_model.dart';
import '../../../../shared/data/models/parking_exit_model.dart';

abstract class AgentHistoryRemoteDataSource {
  Future<List<ParkingEntryModel>> getEntryHistory();

  Future<List<ParkingExitModel>> getExitHistory();
}
