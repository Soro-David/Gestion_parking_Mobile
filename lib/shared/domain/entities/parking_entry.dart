class ParkingEntry {
  final int id;
  final String ticketNumber;
  final String licensePlate;
  final String vehicleType;
  final DateTime entryTime;
  final String zone;
  final String status;
  final String? agentName;
  final String? notes;
  final String? photoUrl;
  /// Tarif horaire applicable (en FCFA). Vient du backend.
  /// null = non connu (fallback à un calcul local).
  final double? pricePerHour;

  const ParkingEntry({
    required this.id,
    required this.ticketNumber,
    required this.licensePlate,
    required this.vehicleType,
    required this.entryTime,
    required this.zone,
    required this.status,
    this.agentName,
    this.notes,
    this.photoUrl,
    this.pricePerHour,
  });
}
