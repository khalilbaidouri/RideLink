import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ride_link/features/passenger/models/popular_route.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final popularRoutesProvider = FutureProvider<List<PopularRoute>>((ref) async {
  final client = Supabase.instance.client;

  final rides = await client.from('rides').select('''
    departure_city_id,
    destination_city_id,
    departure:cities!rides_departure_city_id_fkey (
      id,
      name
    ),
    destination:cities!rides_destination_city_id_fkey (
      id,
      name
    )
  ''');

  if (rides.isEmpty) {
    return [];
  }

  final counts = <String, PopularRoute>{};

  for (final row in rides) {
    final departure = row['departure'] as Map<String, dynamic>?;
    final destination = row['destination'] as Map<String, dynamic>?;

    if (departure == null || destination == null) {
      continue;
    }

    final key = '${departure['id']}|${destination['id']}';

    if (counts.containsKey(key)) {
      final current = counts[key]!;

      counts[key] = PopularRoute.fromJson(
        departure: departure,
        destination: destination,
        count: current.count + 1,
      );
    } else {
      counts[key] = PopularRoute.fromJson(
        departure: departure,
        destination: destination,
        count: 1,
      );
    }
  }

  final routes = counts.values.toList()
    ..sort((a, b) => b.count.compareTo(a.count));

  return routes.take(7).toList();
});
