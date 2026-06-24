import '../../domain/repositories/caissier_report_repository.dart';
import '../../data/repositories/dio_caissier_report_repository.dart';

class CaissierReportProvider {
  static final CaissierReportRepository repository = DioCaissierReportRepository();
}
