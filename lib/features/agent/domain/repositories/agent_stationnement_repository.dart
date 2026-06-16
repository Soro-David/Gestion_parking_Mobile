import '../../../../shared/domain/entities/parking_entry.dart';

abstract class AgentStationnementRepository {
  Future<List<ParkingEntry>> getStationnementsEnCours();
}
