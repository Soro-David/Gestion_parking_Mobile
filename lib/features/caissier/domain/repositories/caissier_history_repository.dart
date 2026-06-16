import '../../../../shared/domain/entities/parking_entry.dart';
import '../../../../shared/domain/entities/parking_exit.dart';

abstract class CaissierHistoryRepository {
  Future<List<ParkingEntry>> getEntryHistory();

  Future<List<ParkingExit>> getExitHistory();
}
