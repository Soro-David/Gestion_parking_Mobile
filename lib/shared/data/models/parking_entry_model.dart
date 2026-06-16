import '../../domain/entities/parking_entry.dart';

class ParkingEntryModel extends ParkingEntry {
  const ParkingEntryModel({
    required super.id,
    required super.ticketNumber,
    required super.licensePlate,
    required super.vehicleType,
    required super.entryTime,
    required super.zone,
    required super.status,
    super.agentName,
    super.notes,
    super.photoUrl,
  });

  factory ParkingEntryModel.fromJson(Map<String, dynamic> json) {
    return ParkingEntryModel(
      id: json['id'] as int,
      ticketNumber: json['ticket_number'] ?? '',
      licensePlate: json['license_plate'] ?? '',
      vehicleType: json['vehicle_type'] ?? '',
      entryTime: json['entry_time'] != null
          ? DateTime.parse(json['entry_time'])
          : DateTime.now(),
      zone: json['zone'] ?? '',
      status: json['status'] ?? 'en_cours',
      agentName: json['agent_name'],
      notes: json['notes'],
      photoUrl: json['photo_url'],
    );
  }

  factory ParkingEntryModel.fromCaissierApi(Map<String, dynamic> json) {
    final marque = json['marque'] as String?;
    final modele = json['modele'] as String?;
    final vehicleType = (marque != null || modele != null)
        ? '${marque ?? ""} ${modele ?? ""}'.trim()
        : '';

    DateTime entryTime = DateTime.now();
    if (json['started_at'] != null) {
      try {
        entryTime = DateTime.parse(json['started_at']);
      } catch (_) {}
    }

    return ParkingEntryModel(
      id: json['id'] as int? ?? 0,
      ticketNumber: json['ticket_number'] ?? json['ticketNumber'] ?? 'TK-${json['id']}',
      licensePlate: json['license_plate'] ?? json['licensePlate'] ?? '',
      vehicleType: vehicleType,
      entryTime: entryTime,
      zone: json['parking_name'] ?? json['parkingName'] ?? json['zone'] ?? 'Parking',
      status: json['status'] == 'occupied' ? 'en_cours' : (json['status'] ?? 'en_cours'),
      agentName: json['agent_name'] ?? json['agentName'] ?? 'Agent',
      notes: json['notes'],
      photoUrl: json['photo_url'] ?? json['photoUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticket_number': ticketNumber,
      'license_plate': licensePlate,
      'vehicle_type': vehicleType,
      'entry_time': entryTime.toIso8601String(),
      'zone': zone,
      'status': status,
      'agent_name': agentName,
      'notes': notes,
      'photo_url': photoUrl,
    };
  }
}
