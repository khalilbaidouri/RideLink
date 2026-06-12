import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => _MapSampleState();
}

class _MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(31.7917, -7.0926), // Maroc
    zoom: 5,
  );

  Future<void> _getRoute() async {
    final origin = _originController.text.trim();
    final destination = _destinationController.text.trim();

    if (origin.isEmpty || destination.isEmpty) {
      _showMessage("Remplis départ et destination");
      return;
    }

    final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      _showMessage("Clé API manquante");
      return;
    }

    final url = 'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=${Uri.encodeComponent(origin)}'
        '&destination=${Uri.encodeComponent(destination)}'
        '&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body);

      if (data['status'] != 'OK') {
        _showMessage("Erreur API: ${data['status']}");
        return;
      }

      final route = data['routes'][0];
      final leg = route['legs'][0];

      final startLoc = leg['start_location'];
      final endLoc = leg['end_location'];

      final startLatLng = LatLng(startLoc['lat'], startLoc['lng']);
      final endLatLng = LatLng(endLoc['lat'], endLoc['lng']);

      final polylinePoints = PolylinePoints();
      final encoded = route['overview_polyline']['points'];

      final decodedPoints = polylinePoints.decodePolyline(encoded);

      final polylineCoordinates =
          decodedPoints.map((e) => LatLng(e.latitude, e.longitude)).toList();

      final GoogleMapController controller = await _controller.future;

      controller.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(
              startLatLng.latitude < endLatLng.latitude
                  ? startLatLng.latitude
                  : endLatLng.latitude,
              startLatLng.longitude < endLatLng.longitude
                  ? startLatLng.longitude
                  : endLatLng.longitude,
            ),
            northeast: LatLng(
              startLatLng.latitude > endLatLng.latitude
                  ? startLatLng.latitude
                  : endLatLng.latitude,
              startLatLng.longitude > endLatLng.longitude
                  ? startLatLng.longitude
                  : endLatLng.longitude,
            ),
          ),
          100,
        ),
      );

      setState(() {
        _markers.clear();
        _polylines.clear();

        _markers.add(
          Marker(
            markerId: const MarkerId("start"),
            position: startLatLng,
            infoWindow: const InfoWindow(title: "Départ"),
          ),
        );

        _markers.add(
          Marker(
            markerId: const MarkerId("end"),
            position: endLatLng,
            infoWindow: const InfoWindow(title: "Destination"),
          ),
        );

        _polylines.add(
          Polyline(
            polylineId: const PolylineId("route"),
            points: polylineCoordinates,
            width: 5,
          ),
        );
      });
    } catch (e) {
      _showMessage("Erreur: $e");
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Itinéraire Google Maps"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: _originController,
                  decoration: InputDecoration(
                    hintText: "Point de départ",
                    prefixIcon: const Icon(Icons.location_on),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _destinationController,
                  decoration: InputDecoration(
                    hintText: "Destination",
                    prefixIcon: const Icon(Icons.flag),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _getRoute,
                    child: const Text("Tracer l'itinéraire"),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: _initialPosition,
              markers: _markers,
              polylines: _polylines,
              mapType: MapType.normal,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
          ),
        ],
      ),
    );
  }   
}
