import '../../domain/entities/caissier_report.dart';

class CaissierReportSessionModel extends CaissierReportSession {
  const CaissierReportSessionModel({
    required super.id,
    required super.licensePlate,
    super.marque,
    super.modele,
    super.startedAt,
    super.endedAt,
    super.durationMinutes,
    required super.amount,
    super.reversementId,
    required super.parkingName,
  });

  factory CaissierReportSessionModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDateTime(String? str) {
      if (str == null) return null;
      return DateTime.tryParse(str);
    }

    return CaissierReportSessionModel(
      id: json['id'] as int,
      licensePlate: json['license_plate'] as String? ?? '',
      marque: json['marque'] as String?,
      modele: json['modele'] as String?,
      startedAt: parseDateTime(json['started_at'] as String?),
      endedAt: parseDateTime(json['ended_at'] as String?),
      durationMinutes: json['duration_minutes'] as int?,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      reversementId: json['reversement_id'] as int?,
      parkingName: json['parking_name'] as String? ?? '—',
    );
  }
}

class CaissierReportStatsModel extends CaissierReportStats {
  const CaissierReportStatsModel({
    required super.totalMontant,
    required super.totalSessions,
    required super.totalReverse,
    required super.totalNonReverse,
  });

  factory CaissierReportStatsModel.fromJson(Map<String, dynamic> json) {
    return CaissierReportStatsModel(
      totalMontant: (json['total_montant'] as num?)?.toDouble() ?? 0.0,
      totalSessions: json['total_sessions'] as int? ?? 0,
      totalReverse: (json['total_reverse'] as num?)?.toDouble() ?? 0.0,
      totalNonReverse: (json['total_non_reverse'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class CaissierReportDataModel extends CaissierReportData {
  const CaissierReportDataModel({
    required super.sessions,
    required super.stats,
    required super.periode,
    required super.dateFrom,
    required super.dateTo,
  });

  factory CaissierReportDataModel.fromJson(Map<String, dynamic> json) {
    final sessionsList = (json['sessions'] as List? ?? [])
        .map((item) => CaissierReportSessionModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return CaissierReportDataModel(
      sessions: sessionsList,
      stats: CaissierReportStatsModel.fromJson(json['stats'] as Map<String, dynamic>? ?? {}),
      periode: (json['filters']?['periode'] as String?) ?? 'jour',
      dateFrom: (json['filters']?['date_from'] as String?) ?? '',
      dateTo: (json['filters']?['date_to'] as String?) ?? '',
    );
  }
}
