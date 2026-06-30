// Entité représentant une notification reçue par l'application
import 'package:equatable/equatable.dart';

class AppNotification extends Equatable {
  final String id;
  final String title;
  final String body;
  final String? type; // "entree", "sortie", "paiement", "versement", "rapport"
  final Map<String, dynamic>? data; // données pour navigation
  final DateTime createdAt;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    this.type,
    this.data,
    required this.createdAt,
    this.isRead = false,
  });

  /// Depuis JSON (réponse API Laravel)
  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'],
      data: json['data'] is Map ? Map<String, dynamic>.from(json['data']) : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      isRead: json['read_at'] != null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'type': type,
        'data': data,
        'created_at': createdAt.toIso8601String(),
        'read_at': isRead ? DateTime.now().toIso8601String() : null,
      };

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    String? type,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  List<Object?> get props => [id, title, body, type, data, createdAt, isRead];
}
