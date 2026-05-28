import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum BookingStatus {
  none,
  pending,
  confirmed,
}

final rideBookingStatusProvider =
    FutureProvider.family<BookingStatus, String>((ref, rideId) async {
  final client = Supabase.instance.client;
  final user = client.auth.currentUser;
  if (user == null) {
    return BookingStatus.none;
  }

  final parsedId = int.tryParse(rideId);
  var query = client
      .from('bookings')
      .select('status')
      .eq('passenger_id', user.id)
      .inFilter('status', const ['pending', 'confirmed']);

  query = parsedId == null
      ? query.eq('ride_id', rideId)
      : query.eq('ride_id', parsedId);

  final row = await query.maybeSingle();
  if (row == null) {
    return BookingStatus.none;
  }

  final status = row['status']?.toString();
  if (status == 'confirmed') {
    return BookingStatus.confirmed;
  }
  if (status == 'pending') {
    return BookingStatus.pending;
  }

  return BookingStatus.none;
});
