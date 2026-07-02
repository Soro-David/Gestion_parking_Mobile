import '../../../../shared/domain/entities/statistiques.dart';

abstract class CaissierStatRepository {
  Future<Statistiques> getStats({bool forceRefresh = false});
}
