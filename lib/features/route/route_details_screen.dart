import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'trip_details_screen.dart';

// ─────────────────────────────────────────────
//  Models
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
//  RouteDetailsScreen  (Step 1 of 3)
// ─────────────────────────────────────────────
class RouteDetailsScreen extends StatefulWidget {
  const RouteDetailsScreen({super.key});

  @override
  State<RouteDetailsScreen> createState() => _RouteDetailsScreenState();
}

class _RouteDetailsScreenState extends State<RouteDetailsScreen> {
  // ── Theme ──────────────────────────────────
  static const Color _primary = Color(0xFF1E5C2E);
  static const Color _primaryLight = Color(0xFFE8F5E9);
  static const Color _bg = Color(0xFFF4F5F0);
  static const Color _hint = Color(0xFF9E9E9E);
  static const Color _label = Color(0xFF424242);

  // ── Controllers ────────────────────────────
  final TextEditingController _meetingController = TextEditingController();
  final TextEditingController _dropoffController = TextEditingController();

  // ── State ──────────────────────────────────
  City? _departureCity;
  City? _destinationCity;
  List<City> _cities = [];
  bool _loadingCities = true;

  @override
  void initState() {
    super.initState();
    _fetchCities();
  }

  @override
  void dispose() {
    _meetingController.dispose();
    _dropoffController.dispose();
    super.dispose();
  }

  // ── Fetch cities from Supabase ─────────────
  Future<void> _fetchCities() async {
    try {
      final response = await Supabase.instance.client
          .from('cities')
          .select()
          .order('name', ascending: true);

      final list = (response as List)
          .map((c) => City(
                id: (c['id'] as num).toInt(),
                name: c['name'] as String,
                lat: (c['lat'] as num?)?.toDouble() ?? 0.0,
                lng: (c['lng'] as num?)?.toDouble() ?? 0.0,
              ))
          .toList();

      if (mounted) {
        setState(() {
          _cities = list;
          _loadingCities = false;
        });
      }
    } on PostgrestException catch (e) {
      if (mounted) {
        setState(() => _loadingCities = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur chargement villes: ${e.message}')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingCities = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }

  // ── Swap departure ↔ destination ───────────
  void _swapCities() {
    setState(() {
      final tmp = _departureCity;
      _departureCity = _destinationCity;
      _destinationCity = tmp;
    });
  }

  // ── City picker bottom-sheet ───────────────
  Future<City?> _pickCity(String title) async {
    if (_loadingCities) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chargement des villes...')),
      );
      return null;
    }
    return showModalBottomSheet<City>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CityPickerSheet(
        title: title,
        cities: _cities,
        primary: _primary,
      ),
    );
  }

  // ── Validate & go to Step 2 ────────────────
  void _onNext() {
    if (_departureCity == null || _destinationCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Veuillez choisir les villes de départ et d\'arrivée.')),
      );
      return;
    }
    if (_departureCity!.id == _destinationCity!.id) {
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
            departureCityName: _departureCity!.name,
            destinationCityName: _destinationCity!.name,
            departureCityId: _departureCity!.id,
            destinationCityId: _destinationCity!.id,
            meetingPoint: _meetingController.text.trim(),
            dropoffPoint: _dropoffController.text.trim(),
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _AppBar(primary: _primary),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(primary: _primary),
                    const SizedBox(height: 20),

                    // From / To card
                    _loadingCities
                        ? _buildLoadingCard()
                        : _CityCard(
                            primary: _primary,
                            primaryLight: _primaryLight,
                            departureCity: _departureCity,
                            destinationCity: _destinationCity,
                            onPickDeparture: () async {
                              final c = await _pickCity('Ville de départ');
                              if (c != null) setState(() => _departureCity = c);
                            },
                            onPickDestination: () async {
                              final c = await _pickCity('Ville d\'arrivée');
                              if (c != null)
                                setState(() => _destinationCity = c);
                            },
                            onSwap: _swapCities,
                            hint: _hint,
                            label: _label,
                          ),
                    const SizedBox(height: 14),

                    // Meeting point
                    _PointCard(
                      icon: Icons.directions_walk_rounded,
                      iconBg: const Color(0xFFE8F5E9),
                      iconColor: _primary,
                      title: 'Meeting point',
                      controller: _meetingController,
                      placeholder: 'e.g. Central Station, Platform 4',
                      subtitle:
                          'Describe where passengers should wait for you.',
                      primary: _primary,
                    ),
                    const SizedBox(height: 14),

                    // Drop-off point
                    _PointCard(
                      icon: Icons.flag_rounded,
                      iconBg: const Color(0xFFFFF8E1),
                      iconColor: const Color(0xFFE65100),
                      title: 'Drop-off point',
                      controller: _dropoffController,
                      placeholder: 'e.g. Shopping Mall entrance',
                      subtitle: 'Specific location at the destination.',
                      primary: _primary,
                    ),
                    const SizedBox(height: 14),

                    // Map preview — vraie carte Google Maps
                    _MapPreview(
                      departure: _departureCity,
                      destination: _destinationCity,
                      primary: _primary,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _NextButton(primary: _primary, onTap: _onNext),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Color(0xFF1E5C2E)),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Sub-widgets
// ─────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  final Color primary;
  const _AppBar({required this.primary});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.close, color: Colors.grey.shade600, size: 24),
          ),
          const SizedBox(width: 12),
          Text(
            'Ride Bookings',
            style: TextStyle(
              color: primary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey.shade300,
            child: Icon(Icons.person, color: Colors.grey.shade600, size: 22),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final Color primary;
  const _SectionHeader({required this.primary});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Route Details',
              style: TextStyle(
                color: primary,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'Step 1 of 3',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: 1 / 3,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(primary),
            minHeight: 5,
          ),
        ),
      ],
    );
  }
}

class _CityCard extends StatelessWidget {
  final Color primary, primaryLight, hint, label;
  final City? departureCity, destinationCity;
  final VoidCallback onPickDeparture, onPickDestination, onSwap;

  const _CityCard({
    required this.primary,
    required this.primaryLight,
    required this.departureCity,
    required this.destinationCity,
    required this.onPickDeparture,
    required this.onPickDestination,
    required this.onSwap,
    required this.hint,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('From',
                  style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              _CityField(
                icon: Icons.location_on_outlined,
                iconColor: primary,
                value: departureCity?.name,
                placeholder: 'Enter departure city',
                hint: hint,
                onTap: onPickDeparture,
              ),
              const SizedBox(height: 14),
              Text('To',
                  style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              _CityField(
                icon: Icons.navigation_outlined,
                iconColor: Colors.grey.shade600,
                value: destinationCity?.name,
                placeholder: 'Enter destination city',
                hint: hint,
                onTap: onPickDestination,
              ),
            ],
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: GestureDetector(
                onTap: onSwap,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade200, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child:
                      Icon(Icons.swap_vert_rounded, color: primary, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CityField extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String? value;
  final String placeholder;
  final Color hint;
  final VoidCallback onTap;

  const _CityField({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.placeholder,
    required this.hint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F7F3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value ?? placeholder,
                style: TextStyle(
                  color: value != null ? const Color(0xFF1A1A1A) : hint,
                  fontSize: 15,
                  fontWeight: value != null ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PointCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg, iconColor, primary;
  final String title, placeholder, subtitle;
  final TextEditingController controller;

  const _PointCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.controller,
    required this.placeholder,
    required this.subtitle,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: iconBg, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              filled: true,
              fillColor: const Color(0xFFF6F7F3),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(subtitle,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Map Preview — vraie carte Google Maps
// ─────────────────────────────────────────────

class _MapPreview extends StatefulWidget {
  final City? departure, destination;
  final Color primary;

  const _MapPreview({
    required this.departure,
    required this.destination,
    required this.primary,
  });

  @override
  State<_MapPreview> createState() => _MapPreviewState();
}

class _MapPreviewState extends State<_MapPreview> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  bool _mapReady = false;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(31.7917, -7.0926), // Centre du Maroc
    zoom: 5,
  );

  @override
  void didUpdateWidget(_MapPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Redessine la route dès que départ ou destination change
    if (oldWidget.departure != widget.departure ||
        oldWidget.destination != widget.destination) {
      if (_mapReady) _drawRoute();
    }
  }

  Future<void> _drawRoute() async {
    if (widget.departure == null || widget.destination == null) {
      // Réinitialise la carte si une ville est désélectionnée
      setState(() {
        _markers.clear();
        _polylines.clear();
      });
      final controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(_initialPosition),
      );
      return;
    }

    final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) return;

    // Utilise les coordonnées lat/lng directement depuis Supabase
    final origin = '${widget.departure!.lat},${widget.departure!.lng}';
    final destination = '${widget.destination!.lat},${widget.destination!.lng}';

    final url = 'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=$origin'
        '&destination=$destination'
        '&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body);

      if (data['status'] != 'OK') return;

      final route = data['routes'][0];
      final leg = route['legs'][0];

      final startLoc = leg['start_location'];
      final endLoc = leg['end_location'];

      final startLatLng = LatLng(
        (startLoc['lat'] as num).toDouble(),
        (startLoc['lng'] as num).toDouble(),
      );
      final endLatLng = LatLng(
        (endLoc['lat'] as num).toDouble(),
        (endLoc['lng'] as num).toDouble(),
      );

      // Décode la polyline
      final encoded = route['overview_polyline']['points'] as String;
      final decodedPoints = PolylinePoints().decodePolyline(encoded);
      final polylineCoords =
          decodedPoints.map((e) => LatLng(e.latitude, e.longitude)).toList();

      // Anime la caméra pour afficher les deux villes
      final controller = await _controller.future;
      final swLat = startLatLng.latitude < endLatLng.latitude
          ? startLatLng.latitude
          : endLatLng.latitude;
      final swLng = startLatLng.longitude < endLatLng.longitude
          ? startLatLng.longitude
          : endLatLng.longitude;
      final neLat = startLatLng.latitude > endLatLng.latitude
          ? startLatLng.latitude
          : endLatLng.latitude;
      final neLng = startLatLng.longitude > endLatLng.longitude
          ? startLatLng.longitude
          : endLatLng.longitude;

      controller.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(swLat, swLng),
            northeast: LatLng(neLat, neLng),
          ),
          60,
        ),
      );

      setState(() {
        _markers.clear();
        _polylines.clear();

        _markers.add(Marker(
          markerId: const MarkerId('start'),
          position: startLatLng,
          infoWindow: InfoWindow(title: widget.departure!.name),
        ));

        _markers.add(Marker(
          markerId: const MarkerId('end'),
          position: endLatLng,
          infoWindow: InfoWindow(title: widget.destination!.name),
        ));

        _polylines.add(Polyline(
          polylineId: const PolylineId('route'),
          points: polylineCoords,
          color: widget.primary,
          width: 4,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
        ));
      });
    } catch (_) {
      // Silently ignore network errors for preview
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Stack(
          children: [
            // Vraie carte Google Maps
            GoogleMap(
              initialCameraPosition: _initialPosition,
              markers: _markers,
              polylines: _polylines,
              mapType: MapType.normal,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              compassEnabled: false,
              rotateGesturesEnabled: false,
              scrollGesturesEnabled: false,
              zoomGesturesEnabled: false,
              tiltGesturesEnabled: false,
              onMapCreated: (GoogleMapController c) {
                if (!_controller.isCompleted) {
                  _controller.complete(c);
                }
                setState(() => _mapReady = true);
                _drawRoute();
              },
            ),

            // Badge "Preview on Map" en bas à gauche
            Positioned(
              bottom: 14,
              left: 14,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 2)),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.map_outlined, size: 16, color: widget.primary),
                    const SizedBox(width: 6),
                    const Text(
                      'Preview on Map',
                      style: TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontWeight: FontWeight.w600,
                          fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),

            // Indicateur de chargement si les villes sont sélectionnées
            // mais la route n'est pas encore tracée
            if (widget.departure != null &&
                widget.destination != null &&
                _polylines.isEmpty)
              const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF1E5C2E),
                  strokeWidth: 2.5,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Next Button
// ─────────────────────────────────────────────
class _NextButton extends StatelessWidget {
  final Color primary;
  final VoidCallback onTap;

  const _NextButton({required this.primary, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton.icon(
          onPressed: onTap,
          icon: const SizedBox.shrink(),
          label: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Next',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3)),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded, size: 20),
            ],
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  City Picker Bottom Sheet
// ─────────────────────────────────────────────
class _CityPickerSheet extends StatefulWidget {
  final String title;
  final List<City> cities;
  final Color primary;

  const _CityPickerSheet({
    required this.title,
    required this.cities,
    required this.primary,
  });

  @override
  State<_CityPickerSheet> createState() => _CityPickerSheetState();
}

class _CityPickerSheetState extends State<_CityPickerSheet> {
  late List<City> _filtered;
  final TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filtered = widget.cities;
    _search.addListener(() {
      final q = _search.text.toLowerCase();
      setState(() {
        _filtered = widget.cities
            .where((c) => c.name.toLowerCase().contains(q))
            .toList();
      });
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              widget.title,
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: widget.primary),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _search,
              decoration: InputDecoration(
                hintText: 'Rechercher une ville…',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFF4F5F0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Text(
                      'Aucune ville trouvée',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final city = _filtered[i];
                      return ListTile(
                        leading:
                            Icon(Icons.location_city, color: widget.primary),
                        title: Text(city.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.w500)),
                        onTap: () => Navigator.pop(context, city),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
