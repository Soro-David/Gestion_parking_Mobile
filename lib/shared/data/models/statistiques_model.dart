import '../../domain/entities/statistiques.dart';

class StatistiquesModel extends Statistiques {
  const StatistiquesModel({
    required super.totalEncaisser,
    required super.stationnements,
    required super.encaisseNonVerse,
    required super.dette,
  });

  factory StatistiquesModel.fromResponses(List<dynamic> responses) {
    double parseDouble(dynamic data, String key) {
      if (data is Map<String, dynamic>) {
        final val = data[key];
        if (val is num) return val.toDouble();
        if (val is String) return double.tryParse(val) ?? 0.0;
      }
      return 0.0;
    }

    int parseInt(dynamic data, String key) {
      if (data is Map<String, dynamic>) {
        final val = data[key];
        if (val is int) return val;
        if (val is num) return val.toInt();
        if (val is String) return int.tryParse(val) ?? 0;
      }
      return 0;
    }

    return StatistiquesModel(
      totalEncaisser: parseDouble(responses[0].data, 'total_encaisser'),
      stationnements: parseInt(responses[1].data, 'stationnement_en_cours'),
      encaisseNonVerse: parseDouble(responses[2].data, 'encaisse_non_verse'),
      dette: parseDouble(responses[3].data, 'dette'),
    );
  }
}
