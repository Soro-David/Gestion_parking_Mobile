class VersementModel {
  final int id;
  final double amount;
  final String status;
  final DateTime date;

  VersementModel({
    required this.id,
    required this.amount,
    required this.status,
    required this.date,
  });

  factory VersementModel.fromJson(Map<String, dynamic> json) => VersementModel(
        id: json['id'] as int,
        amount: (json['amount'] as num).toDouble(),
        status: json['status'] as String,
        date: DateTime.parse(json['date'] as String),
      );
}

class VersementDetailModel {
  final int id;
  final double amount;
  final String status;
  final DateTime date;
  final String info; // additional info field

  VersementDetailModel({
    required this.id,
    required this.amount,
    required this.status,
    required this.date,
    required this.info,
  });

  factory VersementDetailModel.fromJson(Map<String, dynamic> json) =>
      VersementDetailModel(
        id: json['id'] as int,
        amount: (json['amount'] as num).toDouble(),
        status: json['status'] as String,
        date: DateTime.parse(json['date'] as String),
        info: json['info'] as String? ?? '',
      );
}
