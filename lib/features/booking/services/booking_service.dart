import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/booking_model.dart';

final bookingServiceProvider = Provider<BookingService>(
  (ref) => BookingService(Supabase.instance.client),
);

class BookingService {
  final SupabaseClient _db;
  const BookingService(this._db);

  // Fetch all booking requests for the current driver's rides
  Future<List<BookingModel>> fetchBookingRequests() async {
    final driverId = _db.auth.currentUser?.id;
    if (driverId == null) return [];

    final res = await _db
        .from('bookings')
        .select('''
          id,
          ride_id,
          seats_reserved,
          total_price,
          status,
          booked_at,
          users!passenger_id (
            id,
            full_name,
            avatar_url,
            rating,
            total_reviews
          )
        ''')
        .inFilter(
          'ride_id',
          await _getDriverRideIds(driverId),
        )
        .order('booked_at', ascending: false);

    return (res as List)
        .map((r) => BookingModel.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  // Accept a booking request
 Future<void> acceptBooking(String id) async {
  await _db
      .from('bookings')
      .update({'status': 'confirmed'})
      .eq('id', int.parse(id));
}

Future<void> rejectBooking(String id) async {
  await _db
      .from('bookings')
      .update({'status': 'cancelled'})
      .eq('id', int.parse(id));
}
  // Helper: get all ride IDs belonging to the current driver
  Future<List<int>> _getDriverRideIds(String driverId) async {
    final res = await _db
        .from('rides')
        .select('id')
        .eq('driver_id', driverId);

    return (res as List).map((r) => r['id'] as int).toList();
  }
}