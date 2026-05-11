class VehicleModel {
  final String id;
  final String driverId;
  final String brand;
  final String model;
  final String color;
  final String plateNumber;
  final int seats;
  final DateTime createdAt;

  VehicleModel({
    required this.id,
    required this.driverId,
    required this.brand,
    required this.model,
    required this.color,
    required this.plateNumber,
    required this.seats,
    required this.createdAt,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'].toString(),
      driverId: json['driver_id'].toString(),
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      color: json['color'] ?? '',
      plateNumber: json['plate_number'] ?? '',
      seats: json['seats'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driver_id': driverId,
      'brand': brand,
      'model': model,
      'color': color,
      'plate_number': plateNumber,
      'seats': seats,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Display helper
  String get displayName => '$brand $model';
  String get displayPlate => plateNumber.toUpperCase();
}