class ParkingExit {
  final int id;
  final String ticketNumber;
  final String licensePlate;
  final String vehicleType;
  final DateTime entryTime;
  final DateTime exitTime;
  final double amount;
  final String paymentMethod;
  final String status;
  final String zone;
  final String? agentName;
  final String? notes;
  /// ID du parking associé à cette session (utilisé pour les signalements).
  final int? parkingId;

  const ParkingExit({
    required this.id,
    required this.ticketNumber,
    required this.licensePlate,
    required this.vehicleType,
    required this.entryTime,
    required this.exitTime,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.zone,
    this.agentName,
    this.notes,
    this.parkingId,
  });
}
