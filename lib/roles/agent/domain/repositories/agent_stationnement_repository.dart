import '../../../../shared/models/parking_entry_model.dart';

abstract class AgentStationnementRepository {
  Future<List<ParkingEntryModel>> getStationnementsEnCours();
}
