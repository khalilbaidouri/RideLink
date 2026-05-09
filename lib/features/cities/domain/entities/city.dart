import 'package:equatable/equatable.dart';

/// Entité métier représentant une ville marocaine.
/// Immuable — aucune dépendance à Flutter ou Supabase.
class City extends Equatable {
  final String id;
  final String name;
  final String nameAr;
  final String region;
  final double latitude;
  final double longitude;
  final bool isActive;

  const City({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.region,
    required this.latitude,
    required this.longitude,
    this.isActive = true,
  });

  @override
  List<Object?> get props =>
      [id, name, nameAr, region, latitude, longitude, isActive];
}