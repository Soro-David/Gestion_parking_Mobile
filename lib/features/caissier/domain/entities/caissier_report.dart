class CaissierReportSession {
  final int id;
  final String licensePlate;
  final String? marque;
  final String? modele;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final int? durationMinutes;
  final double amount;
  final int? reversementId;
  final String parkingName;

  const CaissierReportSession({
    required this.id,
    required this.licensePlate,
    this.marque,
    this.modele,
    this.startedAt,
    this.endedAt,
    this.durationMinutes,
    required this.amount,
    this.reversementId,
    required this.parkingName,
  });
}

class CaissierReportStats {
  final double totalMontant;
  final int totalSessions;
  final double totalReverse;
  final double totalNonReverse;

  const CaissierReportStats({
    required this.totalMontant,
    required this.totalSessions,
    required this.totalReverse,
    required this.totalNonReverse,
  });
}

class CaissierReportData {
  final List<CaissierReportSession> sessions;
  final CaissierReportStats stats;
  final String periode;
  final String dateFrom;
  final String dateTo;

  const CaissierReportData({
    required this.sessions,
    required this.stats,
    required this.periode,
    required this.dateFrom,
    required this.dateTo,
  });
}
