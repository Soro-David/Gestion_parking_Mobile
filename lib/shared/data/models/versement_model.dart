import 'package:parking_mobile/shared/domain/entities/versement.dart';

class VersementModel extends Versement {
  const VersementModel({
    required super.id,
    required super.amount,
    required super.reste,
    required super.status,
    required super.date,
  });

  factory VersementModel.fromJson(Map<String, dynamic> json) => VersementModel(
        id: json['id'] as int,
        amount: ((json['paid_amount'] ?? json['amount'] ?? 0) as num).toDouble(),
        reste: ((json['remaining_debt'] ?? json['reste'] ?? 0) as num).toDouble(),
        status: json['status'] as String? ?? 'Validé',
        date: DateTime.parse(
          (json['created_at'] ?? json['date'] ?? DateTime.now().toIso8601String()) as String,
        ),
      );
}

class VersementDetailModel extends VersementDetail {
  const VersementDetailModel({
    required super.id,
    required super.amount,
    required super.reste,
    required super.status,
    required super.date,
    required super.info,
  });

  factory VersementDetailModel.fromJson(Map<String, dynamic> json) => VersementDetailModel(
        id: json['id'] as int,
        amount: ((json['paid_amount'] ?? json['amount'] ?? 0) as num).toDouble(),
        reste: ((json['remaining_debt'] ?? json['reste'] ?? 0) as num).toDouble(),
        status: json['status'] as String? ?? 'Validé',
        date: DateTime.parse(
          (json['created_at'] ?? json['date'] ?? DateTime.now().toIso8601String()) as String,
        ),
        info: json['note'] as String? ?? json['info'] as String? ?? '',
      );
}
