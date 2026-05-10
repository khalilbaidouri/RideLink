import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/city.dart';

// ---------------------------------------------------------------------------
// Catalogue statique des villes marocaines
// En production : remplacer par un appel Supabase via un Repository.
// ---------------------------------------------------------------------------

const List<City> _kMoroccanCities = [
  City(id: '1',  name: 'Casablanca',   nameAr: 'الدار البيضاء', region: 'Casablanca-Settat',          latitude: 33.5731, longitude: -7.5898),
  City(id: '2',  name: 'Rabat',        nameAr: 'الرباط',        region: 'Rabat-Salé-Kénitra',          latitude: 34.0209, longitude: -6.8416),
  City(id: '3',  name: 'Marrakech',    nameAr: 'مراكش',         region: 'Marrakech-Safi',              latitude: 31.6295, longitude: -7.9811),
  City(id: '4',  name: 'Fès',          nameAr: 'فاس',           region: 'Fès-Meknès',                  latitude: 34.0331, longitude: -5.0003),
  City(id: '5',  name: 'Tanger',       nameAr: 'طنجة',          region: 'Tanger-Tétouan-Al Hoceïma',   latitude: 35.7595, longitude: -5.8340),
  City(id: '6',  name: 'Agadir',       nameAr: 'أكادير',        region: 'Souss-Massa',                 latitude: 30.4278, longitude: -9.5981),
  City(id: '7',  name: 'Meknès',       nameAr: 'مكناس',         region: 'Fès-Meknès',                  latitude: 33.8935, longitude: -5.5473),
  City(id: '8',  name: 'Oujda',        nameAr: 'وجدة',          region: 'Oriental',                    latitude: 34.6814, longitude: -1.9086),
  City(id: '9',  name: 'Kenitra',      nameAr: 'القنيطرة',      region: 'Rabat-Salé-Kénitra',          latitude: 34.2610, longitude: -6.5802),
  City(id: '10', name: 'Tétouan',      nameAr: 'تطوان',         region: 'Tanger-Tétouan-Al Hoceïma',   latitude: 35.5785, longitude: -5.3684),
  City(id: '11', name: 'Safi',         nameAr: 'آسفي',          region: 'Marrakech-Safi',              latitude: 32.2994, longitude: -9.2372),
  City(id: '12', name: 'El Jadida',    nameAr: 'الجديدة',       region: 'Casablanca-Settat',           latitude: 33.2316, longitude: -8.5007),
  City(id: '13', name: 'Béni Mellal',  nameAr: 'بني ملال',      region: 'Béni Mellal-Khénifra',        latitude: 32.3373, longitude: -6.3498),
  City(id: '14', name: 'Nador',        nameAr: 'الناظور',       region: 'Oriental',                    latitude: 35.1740, longitude: -2.9287),
  City(id: '15', name: 'Settat',       nameAr: 'سطات',          region: 'Casablanca-Settat',           latitude: 33.0017, longitude: -7.6194),
  City(id: '16', name: 'Khouribga',    nameAr: 'خريبكة',        region: 'Béni Mellal-Khénifra',        latitude: 32.8811, longitude: -6.9063),
  City(id: '17', name: 'Berrechid',    nameAr: 'برشيد',         region: 'Casablanca-Settat',           latitude: 33.2655, longitude: -7.5880),
  City(id: '18', name: 'Khémisset',    nameAr: 'الخميسات',      region: 'Rabat-Salé-Kénitra',          latitude: 33.8241, longitude: -6.0659),
  City(id: '19', name: 'Essaouira',    nameAr: 'الصويرة',       region: 'Marrakech-Safi',              latitude: 31.5085, longitude: -9.7595),
  City(id: '20', name: 'Ouarzazate',   nameAr: 'ورزازات',       region: 'Drâa-Tafilalet',              latitude: 30.9335, longitude: -6.9370),
];

// ---------------------------------------------------------------------------
// Helpers GPS — Formule de Haversine
// ---------------------------------------------------------------------------

double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
  const r = 6371.0;
  final dLat = _deg2rad(lat2 - lat1);
  final dLon = _deg2rad(lon2 - lon1);
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) *
          sin(dLon / 2) * sin(dLon / 2);
  return r * 2 * atan2(sqrt(a), sqrt(1 - a));
}

double _deg2rad(double deg) => deg * (pi / 180);

// ---------------------------------------------------------------------------
// Type alias pour la position GPS
// ---------------------------------------------------------------------------

typedef UserLocation = ({double lat, double lon});

// ---------------------------------------------------------------------------
// Provider 1 : liste complète des villes actives
// ---------------------------------------------------------------------------

final citiesProvider = Provider<List<City>>((ref) {
  return _kMoroccanCities.where((c) => c.isActive).toList();
});

// ---------------------------------------------------------------------------
// Provider 2 : query de recherche
// Riverpod 3 : NotifierProvider remplace StateProvider
// ---------------------------------------------------------------------------

class CitySearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query;
  void clear() => state = '';
}

final citySearchQueryProvider =
    NotifierProvider<CitySearchQueryNotifier, String>(
  CitySearchQueryNotifier.new,
);

// ---------------------------------------------------------------------------
// Provider 3 : liste filtrée selon la recherche
// ---------------------------------------------------------------------------

final filteredCitiesProvider = Provider<List<City>>((ref) {
  final all = ref.watch(citiesProvider);
  final query = ref.watch(citySearchQueryProvider).trim().toLowerCase();
  if (query.isEmpty) return all;
  return all
      .where((c) =>
          c.name.toLowerCase().contains(query) ||
          c.nameAr.contains(query) ||
          c.region.toLowerCase().contains(query))
      .toList();
});

// ---------------------------------------------------------------------------
// Provider 4 : position GPS
// Riverpod 3 : NotifierProvider remplace StateProvider
// ---------------------------------------------------------------------------

class UserLocationNotifier extends Notifier<UserLocation?> {
  @override
  UserLocation? build() => null;

  void setLocation(double lat, double lon) => state = (lat: lat, lon: lon);
  void clear() => state = null;
}

final userLocationProvider =
    NotifierProvider<UserLocationNotifier, UserLocation?>(
  UserLocationNotifier.new,
);

// ---------------------------------------------------------------------------
// Provider 5 : villes triées par distance GPS
// ---------------------------------------------------------------------------

final nearbyCitiesProvider =
    Provider<List<({City city, double distanceKm})>?>((ref) {
  final location = ref.watch(userLocationProvider);
  if (location == null) return null;

  final cities = ref.watch(citiesProvider);
  final result = cities.map((c) {
    final d =
        _haversineKm(location.lat, location.lon, c.latitude, c.longitude);
    return (city: c, distanceKm: d);
  }).toList()
    ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
  return result;
});

// ---------------------------------------------------------------------------
// Provider 6 : distance entre deux villes (utilisé par M4)
// ---------------------------------------------------------------------------

final distanceBetweenProvider =
    Provider.family<double?, (String, String)>((ref, ids) {
  final all = ref.watch(citiesProvider);
  try {
    final a = all.firstWhere((c) => c.id == ids.$1);
    final b = all.firstWhere((c) => c.id == ids.$2);
    return _haversineKm(a.latitude, a.longitude, b.latitude, b.longitude);
  } catch (_) {
    return null;
  }
});