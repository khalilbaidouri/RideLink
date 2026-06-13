import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─────────────────────────────────────────────
//  City model
// ─────────────────────────────────────────────
class City {
  final int id;
  final String name;
  final double lat;
  final double lng;

  const City({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
  });
}

// ─────────────────────────────────────────────
//  RouteData model  (passed Step 1 → Step 2)
// ─────────────────────────────────────────────
class RouteData {
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

  const RouteData({
    required this.departureCityName,
    required this.destinationCityName,
    required this.departureCityId,
    required this.destinationCityId,
    this.meetingPoint = '',
    this.dropoffPoint = '',
    this.departureLat = 0.0,
    this.departureLng = 0.0,
    this.destinationLat = 0.0,
    this.destinationLng = 0.0,
  });
}

// ─────────────────────────────────────────────
//  Cities async provider
// ─────────────────────────────────────────────
final citiesProvider = FutureProvider<List<City>>((ref) async {
  final response = await Supabase.instance.client
      .from('cities')
      .select()
      .order('name', ascending: true);

  return (response as List)
      .map((c) => City(
            id: (c['id'] as num).toInt(),
            name: c['name'] as String,
            lat: (c['lat'] as num?)?.toDouble() ?? 0.0,
            lng: (c['lng'] as num?)?.toDouble() ?? 0.0,
          ))
      .toList();
});

// ─────────────────────────────────────────────
//  Route selection state
// ─────────────────────────────────────────────
class RouteSelectionState {
  final City? departureCity;
  final City? destinationCity;

  const RouteSelectionState({this.departureCity, this.destinationCity});

  RouteSelectionState copyWith({City? departureCity, City? destinationCity}) =>
      RouteSelectionState(
        departureCity: departureCity ?? this.departureCity,
        destinationCity: destinationCity ?? this.destinationCity,
      );
}

class RouteSelectionNotifier extends StateNotifier<RouteSelectionState> {
  RouteSelectionNotifier() : super(const RouteSelectionState());

  void setDeparture(City city) => state = state.copyWith(departureCity: city);
  void setDestination(City city) =>
      state = state.copyWith(destinationCity: city);

  void swap() => state = RouteSelectionState(
        departureCity: state.destinationCity,
        destinationCity: state.departureCity,
      );
}

final routeSelectionProvider =
    StateNotifierProvider<RouteSelectionNotifier, RouteSelectionState>(
  (ref) => RouteSelectionNotifier(),
);