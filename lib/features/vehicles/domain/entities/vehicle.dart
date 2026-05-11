import 'package:equatable/equatable.dart';

enum VehicleCategory { berline, suv, minivan, pickup, autre }

/// Entité métier représentant un véhicule d'un conducteur.
class Vehicle extends Equatable {
  final String id;
  final String ownerId;
  final String brand;
  final String model;
  final String licensePlate;
  final int totalSeats;
  final VehicleCategory category;
  final String? color;
  final int? year;
  final bool isDefault;

  const Vehicle({
    required this.id,
    required this.ownerId,
    required this.brand,
    required this.model,
    required this.licensePlate,
    required this.totalSeats,
    required this.category,
    this.color,
    this.year,
    this.isDefault = false,
  });

  /// Places offertes aux passagers (conducteur exclu).
  int get availableSeats => totalSeats - 1;

  /// Un véhicule doit avoir au moins 1 place passager et 9 max.
  bool get isValid => totalSeats >= 2 && totalSeats <= 9;

  Vehicle copyWith({
    String? id,
    String? ownerId,
    String? brand,
    String? model,
    String? licensePlate,
    int? totalSeats,
    VehicleCategory? category,
    String? color,
    int? year,
    bool? isDefault,
  }) {
    return Vehicle(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      licensePlate: licensePlate ?? this.licensePlate,
      totalSeats: totalSeats ?? this.totalSeats,
      category: category ?? this.category,
      color: color ?? this.color,
      year: year ?? this.year,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  List<Object?> get props =>
      [id, ownerId, brand, model, licensePlate, totalSeats, category, color, year, isDefault];
}