class Signalement {
  final int id;
  final int userId;
  final int parkingId;
  final String licensePlate;
  final String motif;
  final DateTime createdAt;
  final String? userName;
  final String? parkingName;

  const Signalement({
    required this.id,
    required this.userId,
    required this.parkingId,
    required this.licensePlate,
    required this.motif,
    required this.createdAt,
    this.userName,
    this.parkingName,
  });

  factory Signalement.fromJson(Map<String, dynamic> json) {
    // Extraire le nom de l'utilisateur
    String? name;
    if (json['user'] is Map) {
      final userMap = json['user'] as Map<String, dynamic>;
      final firstName = userMap['first_name'] ?? '';
      final lastName = userMap['name'] ?? '';
      name = '$firstName $lastName'.trim();
      if (name.isEmpty) {
        name = userMap['name'];
      }
    }

    // Extraire le nom du parking
    String? pName;
    if (json['parking'] is Map) {
      pName = (json['parking'] as Map<String, dynamic>)['name'];
    }

    return Signalement(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      userId: json['user_id'] is int ? json['user_id'] : int.parse(json['user_id'].toString()),
      parkingId: json['parking_id'] is int ? json['parking_id'] : int.parse(json['parking_id'].toString()),
      licensePlate: json['license_plate'] ?? '',
      motif: json['motif'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      userName: name,
      parkingName: pName,
    );
  }
}
