import 'package:camera/camera.dart';
import '../../../../shared/models/parking_entry_model.dart';

abstract class CaissierStationnementRepository {
  Future<List<ParkingEntryModel>> getStationnementsEnCours();

  /// Extract license plate via OCR
  Future<String?> extractLicensePlate(XFile imageFile);

  /// Register a new parking session (check‑in)
  Future<bool> registerStationnement({
    required int parkingId,
    required String licensePlate,
    String? marque,
    String? modele,
  });

  /// Checkout an existing session (check‑out)
  Future<Map<String, dynamic>> checkoutParkingSession(int sessionId);
}
