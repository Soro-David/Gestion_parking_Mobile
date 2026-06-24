import 'package:camera/camera.dart';

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

  @override
  Future<String?> extractLicensePlate(XFile imageFile) {
    return _remoteDataSource.extractLicensePlate(imageFile);
  }

  @override
  Future<bool> registerStationnement({
    required int parkingId,
    required String licensePlate,
    String? marque,
    String? modele,
  }) {
    return _remoteDataSource.registerStationnement(
      parkingId: parkingId,
      licensePlate: licensePlate,
      marque: marque,
      modele: modele,
    );
  }

  @override
  Future<Map<String, dynamic>> checkoutParkingSession(int sessionId, {String? paymentMethod, double? amount}) {
    return _remoteDataSource.checkoutParkingSession(sessionId, paymentMethod: paymentMethod, amount: amount);
  }
}
