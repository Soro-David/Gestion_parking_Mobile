import '../entities/caissier_report.dart';

abstract class CaissierReportRepository {
  Future<CaissierReportData> getReport({
    required String periode,
    String? dateFrom,
    String? dateTo,
    bool forceRefresh = false,
  });
}
