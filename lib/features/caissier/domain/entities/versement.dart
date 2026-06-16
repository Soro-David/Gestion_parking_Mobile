
class Versement {
  final String? code;
  final String? numero; // New field
  final DateTime? dateVersement; // New field
  final String? modePaiement; // New field
  final double? montant; // Renamed from montantVersement
  final String? nomDeposit;
  final String? prenomDeposit;
  final String? nomUtilisateur; // New field for caissier name

  const Versement({
    this.code,
    this.numero,
    this.dateVersement,
    this.modePaiement,
    this.montant,
    this.nomDeposit,
    this.prenomDeposit,
    this.nomUtilisateur,
  });

  Versement copyWith({
    String? code,
    String? numero,
    DateTime? dateVersement,
    String? modePaiement,
    double? montant,
    String? nomDeposit,
    String? prenomDeposit,
    String? nomUtilisateur,
  }) {
    return Versement(
      code: code ?? this.code,
      numero: numero ?? this.numero,
      dateVersement: dateVersement ?? this.dateVersement,
      modePaiement: modePaiement ?? this.modePaiement,
      montant: montant ?? this.montant,
      nomDeposit: nomDeposit ?? this.nomDeposit,
      prenomDeposit: prenomDeposit ?? this.prenomDeposit,
      nomUtilisateur: nomUtilisateur ?? this.nomUtilisateur,
    );
  }

  factory Versement.fromJson(Map<String, dynamic> json) {
    return Versement(
      code: json['code']?.toString(),
      numero: json['numero']?.toString(),
      dateVersement: json['dateVersement'] != null
          ? DateTime.parse(json['dateVersement'])
          : null,
      modePaiement: json['modePaiement']?.toString(),
      montant: json['montant'] != null ? (json['montant'] as num).toDouble() : null,
      nomDeposit: json['nomDeposit']?.toString(),
      prenomDeposit: json['prenomDeposit']?.toString(),
      nomUtilisateur: json['nomUtilisateur']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'numero': numero,
      'dateVersement': dateVersement?.toIso8601String(),
      'modePaiement': modePaiement,
      'montant': montant,
      'nomDeposit': nomDeposit,
      'prenomDeposit': prenomDeposit,
      'nomUtilisateur': nomUtilisateur,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Versement &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          numero == other.numero &&
          dateVersement == other.dateVersement &&
          modePaiement == other.modePaiement &&
          montant == other.montant &&
          nomDeposit == other.nomDeposit &&
          prenomDeposit == other.prenomDeposit &&
          nomUtilisateur == other.nomUtilisateur;

  @override
  int get hashCode =>
      code.hashCode ^
      numero.hashCode ^
      dateVersement.hashCode ^
      modePaiement.hashCode ^
      montant.hashCode ^
      nomDeposit.hashCode ^
      prenomDeposit.hashCode ^
      nomUtilisateur.hashCode;

  @override
  String toString() {
    return 'Versement{code: $code, numero: $numero, dateVersement: $dateVersement, modePaiement: $modePaiement, montant: $montant, nomDeposit: $nomDeposit, prenomDeposit: $prenomDeposit, nomUtilisateur: $nomUtilisateur}';
  }
}
