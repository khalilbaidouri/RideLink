import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/route_providers.dart';
import '../widgets/city_card.dart';
import '../widgets/city_picker_sheet.dart';
import '../widgets/map_preview.dart';
import '../widgets/point_card.dart';
import 'trip_details_screen.dart';

class RouteDetailsScreen extends ConsumerStatefulWidget {
  const RouteDetailsScreen({super.key});

  @override
  ConsumerState<RouteDetailsScreen> createState() => _RouteDetailsScreenState();
}

class _RouteDetailsScreenState extends ConsumerState<RouteDetailsScreen> {
  static const Color _primary = Color(0xFF1E5C2E);
  static const Color _bg = Color(0xFFF4F5F0);

  final _meetingCtrl = TextEditingController();
  final _dropoffCtrl = TextEditingController();

  @override
  void dispose() {
    _meetingCtrl.dispose();
    _dropoffCtrl.dispose();
    super.dispose();
  }

  Future<void> _openPicker(String title, bool isDeparture) async {
    final cities = ref.read(citiesProvider).value;
    if (cities == null) return;

    final city = await showModalBottomSheet<City>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CityPickerSheet(title: title, cities: cities),
    );

    if (city == null) return;
    final notifier = ref.read(routeSelectionProvider.notifier);
    isDeparture ? notifier.setDeparture(city) : notifier.setDestination(city);
  }

  void _onNext() {
    final sel = ref.read(routeSelectionProvider);
    if (sel.departureCity == null || sel.destinationCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Veuillez choisir les villes de départ et d\'arrivée.')),
      );
      return;
    }
    if (sel.departureCity!.id == sel.destinationCity!.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'La ville de départ et d\'arrivée doivent être différentes.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TripDetailsScreen(
          routeData: RouteData(
            departureCityName: sel.departureCity!.name,
            destinationCityName: sel.destinationCity!.name,
            departureCityId: sel.departureCity!.id,
            destinationCityId: sel.destinationCity!.id,
            meetingPoint: _meetingCtrl.text.trim(),
            dropoffPoint: _dropoffCtrl.text.trim(),
            departureLat: sel.departureCity!.lat,
            departureLng: sel.departureCity!.lng,
            destinationLat: sel.destinationCity!.lat,
            destinationLng: sel.destinationCity!.lng,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final citiesAsync = ref.watch(citiesProvider);
    final sel = ref.watch(routeSelectionProvider);
    final notifier = ref.read(routeSelectionProvider.notifier);

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // AppBar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child:
                        Icon(Icons.close, color: Colors.grey.shade600, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text('Ride Bookings',
                      style: TextStyle(
                          color: _primary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3)),
                  const Spacer(),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey.shade300,
                    child: Icon(Icons.person,
                        color: Colors.grey.shade600, size: 22),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Step header
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Text('Route Details',
                                  style: TextStyle(
                                      color: _primary,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5),
                                  overflow: TextOverflow.ellipsis),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text('Step 1 of 3',
                                  style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 13),
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: 1 / 3,
                            backgroundColor: Colors.grey.shade200,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(_primary),
                            minHeight: 5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // City card
                    citiesAsync.when(
                      loading: () => Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFF1E5C2E)),
                        ),
                      ),
                      error: (e, _) => Text('Erreur: $e'),
                      data: (_) => CityCard(
                        departureCity: sel.departureCity,
                        destinationCity: sel.destinationCity,
                        onPickDeparture: () =>
                            _openPicker('Ville de départ', true),
                        onPickDestination: () =>
                            _openPicker('Ville d\'arrivée', false),
                        onSwap: notifier.swap,
                      ),
                    ),
                    const SizedBox(height: 14),

                    PointCard(
                      icon: Icons.directions_walk_rounded,
                      iconBg: const Color(0xFFE8F5E9),
                      iconColor: _primary,
                      primary: _primary,
                      title: 'Meeting point',
                      placeholder: 'e.g. Central Station, Platform 4',
                      subtitle:
                          'Describe where passengers should wait for you.',
                      controller: _meetingCtrl,
                    ),
                    const SizedBox(height: 14),

                    PointCard(
                      icon: Icons.flag_rounded,
                      iconBg: const Color(0xFFFFF8E1),
                      iconColor: const Color(0xFFE65100),
                      primary: _primary,
                      title: 'Drop-off point',
                      placeholder: 'e.g. Shopping Mall entrance',
                      subtitle: 'Specific location at the destination.',
                      controller: _dropoffCtrl,
                    ),
                    const SizedBox(height: 14),

                    MapPreview(
                      departureName: sel.departureCity?.name,
                      destinationName: sel.destinationCity?.name,
                      departureLat: sel.departureCity?.lat,
                      departureLng: sel.departureCity?.lng,
                      destinationLat: sel.destinationCity?.lat,
                      destinationLng: sel.destinationCity?.lng,
                      primary: _primary,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Next button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Next',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}