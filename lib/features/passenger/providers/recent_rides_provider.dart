import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ride_link/features/passenger/models/recent_ride.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final recentRidesProvider = FutureProvider<List<RecentRide>>((ref) async {
  final client = Supabase.instance.client;

  final rides = await client
      .from('rides')
      .select('''
    id,
    price,
    available_seats,
    departure_time,
    driver:users!rides_driver_id_fkey (
      id,
      full_name,
      avatar_url,
      rating,
      total_reviews
    ),
    departure:cities!rides_departure_city_id_fkey (
      id,
      name
    ),
    destination:cities!rides_destination_city_id_fkey (
      id,
      name
    )
  ''')
      .eq('status', 'active')
      .order('departure_time', ascending: false)
      .limit(3);

  if (rides.isEmpty) {
    return const [];
  }

  return rides.map<RecentRide>((row) {
    return RecentRide.fromJson(row);
  }).toList();
});
