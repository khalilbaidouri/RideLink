import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─────────────────────────────────────────────
//  Vehicle model
// ─────────────────────────────────────────────
class Vehicle {
  final int id;
  final String brand;
  final String model;
  final String color;
  final String plateNumber;
  final int seats;

  const Vehicle({
    required this.id,
    required this.brand,
    required this.model,
    required this.color,
    required this.plateNumber,
    required this.seats,
  });

  String get displayName => '$brand $model';
  String get subtitle => '$color • $plateNumber';
}

// ─────────────────────────────────────────────
//  RideReviewData model  (passed Step 2 → Step 3)
// ─────────────────────────────────────────────
class RideReviewData {
  final String departureCityName;
  final String destinationCityName;
  final int departureCityId;
  final int destinationCityId;
  final String meetingPoint;
  final String dropoffPoint;
  final double departureLat;
  final double departureLng;
  final double destinationLat;
  final double destinationLng;
  final DateTime departureDateTime;
  final int seats;
  final double price;
  final int vehicleId;
  final String vehicleName;
  final String vehicleColor;
  final String vehiclePlate;

  const RideReviewData({
    required this.departureCityName,
    required this.destinationCityName,
    required this.departureCityId,
    required this.destinationCityId,
    required this.meetingPoint,
    required this.dropoffPoint,
    required this.departureLat,
    required this.departureLng,
    required this.destinationLat,
    required this.destinationLng,
    required this.departureDateTime,
    required this.seats,
    required this.price,
    required this.vehicleId,
    required this.vehicleName,
    required this.vehicleColor,
    required this.vehiclePlate,
  });
}

// ─────────────────────────────────────────────
//  Vehicles async provider
// ─────────────────────────────────────────────
final vehiclesProvider = FutureProvider<List<Vehicle>>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return [];

  final response = await Supabase.instance.client
      .from('vehicles')
      .select()
      .eq('driver_id', user.id)
      .order('created_at', ascending: false);

  return (response as List)
      .map((v) => Vehicle(
            id: (v['id'] as num).toInt(),
            brand: v['brand'] as String? ?? '',
            model: v['model'] as String? ?? '',
            color: v['color'] as String? ?? '',
            plateNumber: v['plate_number'] as String? ?? '',
            seats: (v['seats'] as num?)?.toInt() ?? 4,
          ))
      .toList();
});

// ─────────────────────────────────────────────
//  Trip form state  (date, time, seats, price, vehicle)
// ─────────────────────────────────────────────
class TripFormState {
  final DateTime departureDate;
  final TimeOfDay departureTime;
  final int seats;
  final String price;
  final Vehicle? selectedVehicle;

  const TripFormState({
    required this.departureDate,
    required this.departureTime,
    required this.seats,
    required this.price,
    this.selectedVehicle,
  });

  TripFormState copyWith({
    DateTime? departureDate,
    TimeOfDay? departureTime,
    int? seats,
    String? price,
    Vehicle? selectedVehicle,
  }) =>
      TripFormState(
        departureDate: departureDate ?? this.departureDate,
        departureTime: departureTime ?? this.departureTime,
        seats: seats ?? this.seats,
        price: price ?? this.price,
        selectedVehicle: selectedVehicle ?? this.selectedVehicle,
      );
}

class TripFormNotifier extends StateNotifier<TripFormState> {
  TripFormNotifier()
      : super(TripFormState(
          departureDate: DateTime.now().add(const Duration(days: 1)),
          departureTime: const TimeOfDay(hour: 8, minute: 30),
          seats: 3,
          price: '150',
        ));

  void setDate(DateTime d) => state = state.copyWith(departureDate: d);
  void setTime(TimeOfDay t) => state = state.copyWith(departureTime: t);
  void setSeats(int s) => state = state.copyWith(seats: s);
  void setPrice(String p) => state = state.copyWith(price: p);
  void setVehicle(Vehicle v) => state = state.copyWith(selectedVehicle: v);
}

final tripFormProvider =
    StateNotifierProvider<TripFormNotifier, TripFormState>(
  (ref) => TripFormNotifier(),
);

// ─────────────────────────────────────────────
//  Publish / draft async actions
// ─────────────────────────────────────────────
Future<void> publishRide(RideReviewData d) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) throw Exception('Utilisateur non connecté.');

  await Supabase.instance.client.from('rides').insert({
    'driver_id': user.id,
    'vehicle_id': d.vehicleId,
    'departure_city_id': d.departureCityId,
    'destination_city_id': d.destinationCityId,
    'departure_address': d.meetingPoint.isNotEmpty ? d.meetingPoint : null,
    'destination_address': d.dropoffPoint.isNotEmpty ? d.dropoffPoint : null,
    'departure_time': d.departureDateTime.toUtc().toIso8601String(),
    'price': d.price,
    'available_seats': d.seats,
    'status': 'active',
  });
}

Future<void> saveDraft(RideReviewData d) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) throw Exception('Utilisateur non connecté.');

  await Supabase.instance.client.from('rides').insert({
    'driver_id': user.id,
    'vehicle_id': d.vehicleId,
    'departure_city_id': d.departureCityId,
    'destination_city_id': d.destinationCityId,
    'departure_address': d.meetingPoint.isNotEmpty ? d.meetingPoint : null,
    'destination_address': d.dropoffPoint.isNotEmpty ? d.dropoffPoint : null,
    'departure_time': d.departureDateTime.toUtc().toIso8601String(),
    'price': d.price,
    'available_seats': d.seats,
    'status': 'draft',
  });
}