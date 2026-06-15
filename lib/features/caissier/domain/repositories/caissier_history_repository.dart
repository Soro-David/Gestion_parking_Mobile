import '../../../../shared/models/parking_entry_model.dart';
import '../../../../shared/models/parking_exit_model.dart';

abstract class CaissierHistoryRepository {
  Future<List<ParkingEntryModel>> getEntryHistory();
  Future<List<ParkingExitModel>> getExitHistory();
}

