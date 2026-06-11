class ParkingExitModel {
  final int id;
  final String ticketNumber;
  final String licensePlate;
  final String vehicleType;
  final DateTime entryTime;
  final DateTime exitTime;
  final double amount;
  final String paymentMethod;
  final String status; // 'regle', 'impaye'
  final String zone;
  final String? agentName;
  final String? notes;

  ParkingExitModel({
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
  });

  factory ParkingExitModel.fromJson(Map<String, dynamic> json) {
    return ParkingExitModel(
      id: json['id'] as int,
      ticketNumber: json['ticket_number'] ?? '',
      licensePlate: json['license_plate'] ?? '',
      vehicleType: json['vehicle_type'] ?? '',
      entryTime: json['entry_time'] != null
          ? DateTime.parse(json['entry_time'])
          : DateTime.now(),
      exitTime: json['exit_time'] != null
          ? DateTime.parse(json['exit_time'])
          : DateTime.now(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['payment_method'] ?? 'espèces',
      status: json['status'] ?? 'regle',
      zone: json['zone'] ?? '',
      agentName: json['agent_name'],
      notes: json['notes'],
    );
  }

  factory ParkingExitModel.fromCaissierApi(Map<String, dynamic> json) {
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

    DateTime exitTime = DateTime.now();
    final exitTimeStr = json['ended_at'] ?? json['exited_at'] ?? json['finished_at'] ?? json['exit_time'] ?? json['exitTime'];
    if (exitTimeStr != null) {
      try {
        exitTime = DateTime.parse(exitTimeStr);
      } catch (_) {}
    }

    final amountVal = json['amount'] ?? json['amount_paid'] ?? json['price'] ?? json['montant'] ?? 0.0;

    return ParkingExitModel(
      id: json['id'] as int? ?? 0,
      ticketNumber: json['ticket_number'] ?? json['ticketNumber'] ?? 'TK-${json['id']}',
      licensePlate: json['license_plate'] ?? json['licensePlate'] ?? '',
      vehicleType: vehicleType,
      entryTime: entryTime,
      exitTime: exitTime,
      amount: (amountVal is num) ? amountVal.toDouble() : double.tryParse(amountVal.toString()) ?? 0.0,
      paymentMethod: json['payment_method'] ?? json['paymentMethod'] ?? json['payment_mode'] ?? 'espèces',
      status: json['status'] == 'paid' || json['status'] == 'regle' ? 'regle' : 'impaye',
      zone: json['parking_name'] ?? json['parkingName'] ?? json['zone'] ?? 'Parking',
      agentName: json['agent_name'] ?? json['agentName'] ?? 'Agent',
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticket_number': ticketNumber,
      'license_plate': licensePlate,
      'vehicle_type': vehicleType,
      'entry_time': entryTime.toIso8601String(),
      'exit_time': exitTime.toIso8601String(),
      'amount': amount,
      'payment_method': paymentMethod,
      'status': status,
      'zone': zone,
      'agent_name': agentName,
      'notes': notes,
    };
  }
}
