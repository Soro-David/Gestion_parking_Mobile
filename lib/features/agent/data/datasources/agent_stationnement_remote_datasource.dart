import '../../../../shared/data/models/parking_entry_model.dart';

abstract class AgentStationnementRemoteDataSource {
  Future<List<ParkingEntryModel>> getStationnementsEnCours();
}
