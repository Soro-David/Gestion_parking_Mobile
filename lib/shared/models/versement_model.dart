class VersementModel {
  final int id;
  final double amount;
  final double reste;
  final String status;
  final DateTime date;

  VersementModel({
    required this.id,
    required this.amount,
    required this.reste,
    required this.status,
    required this.date,
  });

  factory VersementModel.fromJson(Map<String, dynamic> json) => VersementModel(
        id: json['id'] as int,
        amount: ((json['paid_amount'] ?? json['amount'] ?? 0) as num).toDouble(),
        reste: ((json['remaining_debt'] ?? json['reste'] ?? 0) as num).toDouble(),
        status: json['status'] as String? ?? 'Validé',
        date: DateTime.parse((json['created_at'] ?? json['date'] ?? DateTime.now().toIso8601String()) as String),
      );
}

class VersementDetailModel {
  final int id;
  final double amount;
  final double reste;
  final String status;
  final DateTime date;
  final String info;

  VersementDetailModel({
    required this.id,
    required this.amount,
    required this.reste,
    required this.status,
    required this.date,
    required this.info,
  });

  factory VersementDetailModel.fromJson(Map<String, dynamic> json) =>
      VersementDetailModel(
        id: json['id'] as int,
        amount: ((json['paid_amount'] ?? json['amount'] ?? 0) as num).toDouble(),
        reste: ((json['remaining_debt'] ?? json['reste'] ?? 0) as num).toDouble(),
        status: json['status'] as String? ?? 'Validé',
        date: DateTime.parse((json['created_at'] ?? json['date'] ?? DateTime.now().toIso8601String()) as String),
        info: json['note'] as String? ?? json['info'] as String? ?? '',
      );
}
