import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ride_link/features/passenger/models/search_ride_result.dart';
import 'package:ride_link/features/passenger/providers/search_ride_notifier.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum SearchOrderBy {
  price,
  time,
  rating,
}

class SearchSortState {
  final SearchOrderBy orderBy;
  final bool ascending;

  const SearchSortState({
    this.orderBy = SearchOrderBy.time,
    this.ascending = true,
  });

  SearchSortState copyWith({
    SearchOrderBy? orderBy,
    bool? ascending,
  }) {
    return SearchSortState(
      orderBy: orderBy ?? this.orderBy,
      ascending: ascending ?? this.ascending,
    );
  }
}

final searchSortProvider = StateProvider<SearchSortState>(
  (ref) => const SearchSortState(),
);

final searchResultsProvider =
    FutureProvider.autoDispose<List<SearchRideResult>>(
  (ref) async {
    final search = ref.watch(searchRideProvider);
    final sort = ref.watch(searchSortProvider);
    if (search.from.isEmpty || search.to.isEmpty) {
      return const [];
    }

    final client = Supabase.instance.client;
    var query = client.from('rides').select('''
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
    ''').eq('status', 'active');

    if (search.seats > 0) {
      query = query.gte('available_seats', search.seats);
    }

    if (search.date != null) {
      final date = search.date!;
      final start = DateTime(date.year, date.month, date.day);
      final end = start.add(const Duration(days: 1));
      query = query
          .gte('departure_time', start.toIso8601String())
          .lt('departure_time', end.toIso8601String());
    }

    if (search.from.isNotEmpty) {
      query = query.ilike('departure.name', '%${search.from}%');
    }

    if (search.to.isNotEmpty) {
      query = query.ilike('destination.name', '%${search.to}%');
    }

    late final List<dynamic> rides;
    switch (sort.orderBy) {
      case SearchOrderBy.price:
        rides = await query.order('price', ascending: sort.ascending);
        break;
      case SearchOrderBy.time:
        rides = await query.order('departure_time', ascending: sort.ascending);
        break;
      case SearchOrderBy.rating:
        rides = await query.order('departure_time', ascending: true);
        break;
    }

    final results = rides
        .map<SearchRideResult>((row) => SearchRideResult.fromJson(row))
        .toList();

    if (sort.orderBy == SearchOrderBy.rating) {
      results.sort((a, b) {
        final value = a.driver.rating.compareTo(b.driver.rating);
        return sort.ascending ? value : -value;
      });
    }

    return results;
  },
);
