class Versement {
  final int id;
  final double amount;
  final double reste;
  final String status;
  final DateTime date;

  const Versement({
    required this.id,
    required this.amount,
    required this.reste,
    required this.status,
    required this.date,
  });
}

class VersementDetail {
  final int id;
  final double amount;
  final double reste;
  final String status;
  final DateTime date;
  final String info;

  const VersementDetail({
    required this.id,
    required this.amount,
    required this.reste,
    required this.status,
    required this.date,
    required this.info,
  });
}
