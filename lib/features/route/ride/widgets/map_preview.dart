import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPreview extends StatefulWidget {
  final String? departureName;
  final String? destinationName;
  final double? departureLat;
  final double? departureLng;
  final double? destinationLat;
  final double? destinationLng;
  final double height;
  final Color primary;
  final bool showBadge;

  const MapPreview({
    super.key,
    this.departureName,
    this.destinationName,
    this.departureLat,
    this.departureLng,
    this.destinationLat,
    this.destinationLng,
    this.height = 200,
    required this.primary,
    this.showBadge = false,
  });

  @override
  State<MapPreview> createState() => _MapPreviewState();
}

class _MapPreviewState extends State<MapPreview> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  bool _mapReady = false;

  static const CameraPosition _initial = CameraPosition(
    target: LatLng(31.7917, -7.0926),
    zoom: 5,
  );

  @override
  void didUpdateWidget(MapPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    final changed = oldWidget.departureLat != widget.departureLat ||
        oldWidget.departureLng != widget.departureLng ||
        oldWidget.destinationLat != widget.destinationLat ||
        oldWidget.destinationLng != widget.destinationLng;
    if (changed && _mapReady) _drawRoute();
  }

  Future<void> _drawRoute() async {
    final hasAll = widget.departureLat != null &&
        widget.departureLng != null &&
        widget.destinationLat != null &&
        widget.destinationLng != null;

    final ctrl = await _controller.future;

    if (!hasAll) {
      setState(() {
        _markers.clear();
        _polylines.clear();
      });
      ctrl.animateCamera(CameraUpdate.newCameraPosition(_initial));
      return;
    }

    final start = LatLng(widget.departureLat!, widget.departureLng!);
    final end = LatLng(widget.destinationLat!, widget.destinationLng!);

    ctrl.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(
            start.latitude < end.latitude ? start.latitude : end.latitude,
            start.longitude < end.longitude ? start.longitude : end.longitude,
          ),
          northeast: LatLng(
            start.latitude > end.latitude ? start.latitude : end.latitude,
            start.longitude > end.longitude ? start.longitude : end.longitude,
          ),
        ),
        60,
      ),
    );

    setState(() {
      _markers
        ..clear()
        ..add(Marker(
          markerId: const MarkerId('start'),
          position: start,
          infoWindow: InfoWindow(title: widget.departureName ?? ''),
        ))
        ..add(Marker(
          markerId: const MarkerId('end'),
          position: end,
          infoWindow: InfoWindow(title: widget.destinationName ?? ''),
        ));

      _polylines
        ..clear()
        ..add(Polyline(
          polylineId: const PolylineId('route'),
          points: [start, end],
          color: widget.primary,
          width: 4,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
        ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: widget.height,
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: _initial,
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
              onMapCreated: (c) {
                if (!_controller.isCompleted) _controller.complete(c);
                setState(() => _mapReady = true);
                _drawRoute();
              },
            ),
            if (widget.showBadge)
              Positioned(
                bottom: 14,
                left: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 9),
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
                      Icon(Icons.map_outlined,
                          size: 16, color: widget.primary),
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
          ],
        ),
      ),
    );
  }
}