import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ride_link/features/passenger/models/ride_details.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final rideDetailsProvider =
    FutureProvider.autoDispose.family<RideDetails, String>((ref, rideId) async {
  final client = Supabase.instance.client;
  final parsedId = int.tryParse(rideId);

  final rideQuery = client.from('rides').select('''
    id,
    price,
    available_seats,
    departure_time,
    departure_address,
    destination_address,
    driver:users!rides_driver_id_fkey (
      id,
      full_name,
      avatar_url,
      rating,
      total_reviews
    ),
    vehicle:vehicles!rides_vehicle_id_fkey (
      id,
      brand,
      model,
      color,
      plate_number,
      seats
    ),
    departure:cities!rides_departure_city_id_fkey (
      id,
      name,
      lat,
      lng
    ),
    destination:cities!rides_destination_city_id_fkey (
      id,
      name,
      lat,
      lng
    )
  ''');

  final rideRow = parsedId == null
      ? await rideQuery.eq('id', rideId).maybeSingle()
      : await rideQuery.eq('id', parsedId).maybeSingle();

  if (rideRow == null) {
    throw StateError('Ride not found');
  }

  final driverRow = rideRow['driver'] as Map<String, dynamic>? ?? {};
  final departureRow = rideRow['departure'] as Map<String, dynamic>? ?? {};
  final destinationRow = rideRow['destination'] as Map<String, dynamic>? ?? {};
  final vehicleRow = rideRow['vehicle'] as Map<String, dynamic>? ?? {};

  final bookingsQuery = client.from('bookings').select('''
    id,
    passenger:users!bookings_passenger_id_fkey (
      id,
      full_name,
      avatar_url
    )
  ''');

  final bookings = parsedId == null
      ? await bookingsQuery.eq('ride_id', rideId).eq('status', 'confirmed')
      : await bookingsQuery.eq('ride_id', parsedId).eq('status', 'confirmed');

  final passengers = bookings
      .map<RidePassenger>((row) {
        final passenger = row['passenger'] as Map<String, dynamic>? ?? {};
        return RidePassenger(
          id: passenger['id']?.toString() ?? '',
          name: passenger['full_name']?.toString() ?? 'Passenger',
          avatarUrl: passenger['avatar_url']?.toString(),
        );
      })
      .where((passenger) => passenger.id.isNotEmpty)
      .toList();

  return RideDetails(
    id: rideRow['id']?.toString() ?? rideId,
    driver: RideDetailsDriver(
      id: driverRow['id']?.toString() ?? '',
      name: driverRow['full_name']?.toString() ?? 'Driver',
      rating: (driverRow['rating'] as num?)?.toDouble() ?? 0,
      totalReviews: (driverRow['total_reviews'] as num?)?.toInt() ?? 0,
      avatarUrl: driverRow['avatar_url']?.toString(),
    ),
    departure: RideDetailsLocation(
      cityId: (departureRow['id'] as num?)?.toInt(),
      name: departureRow['name']?.toString() ?? 'Departure',
      address: rideRow['departure_address']?.toString(),
      lat: (departureRow['lat'] as num?)?.toDouble(),
      lng: (departureRow['lng'] as num?)?.toDouble(),
    ),
    destination: RideDetailsLocation(
      cityId: (destinationRow['id'] as num?)?.toInt(),
      name: destinationRow['name']?.toString() ?? 'Destination',
      address: rideRow['destination_address']?.toString(),
      lat: (destinationRow['lat'] as num?)?.toDouble(),
      lng: (destinationRow['lng'] as num?)?.toDouble(),
    ),
    departureTime: DateTime.tryParse(
          rideRow['departure_time']?.toString() ?? '',
        ) ??
        DateTime.now(),
    price: (rideRow['price'] as num?)?.toDouble() ?? 0,
    seatsLeft: (rideRow['available_seats'] as num?)?.toInt() ?? 0,
    vehicle: RideDetailsVehicle(
      brand: vehicleRow['brand']?.toString(),
      model: vehicleRow['model']?.toString(),
      color: vehicleRow['color']?.toString(),
      plateNumber: vehicleRow['plate_number']?.toString(),
      seats: (vehicleRow['seats'] as num?)?.toInt(),
    ),
    passengers: passengers,
    bookedCount: passengers.length,
  );
});
