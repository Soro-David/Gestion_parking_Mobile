import 'package:parking_mobile/shared/domain/entities/parking_entry.dart';
import 'package:parking_mobile/shared/domain/entities/parking_exit.dart';

/// Repository partagé pour l'historique des sessions de stationnement.
/// Utilisé par les deux rôles (agent et caissier) via injection du [basePath].
abstract class HistoryRepository {
  Future<List<ParkingEntry>> getEntryHistory();
  Future<List<ParkingExit>> getExitHistory();
}
