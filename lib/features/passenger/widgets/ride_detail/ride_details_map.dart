import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_link/features/passenger/models/ride_details.dart';

class RideDetailsMap extends StatelessWidget {
  const RideDetailsMap({
    super.key,
    required this.details,
    required this.disableGestures,
    required this.onInteractionStart,
    required this.onInteractionEnd,
  });

  final RideDetails details;
  final bool disableGestures;
  final VoidCallback onInteractionStart;
  final VoidCallback onInteractionEnd;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final start = details.departure.latLng;
    final end = details.destination.latLng;

    if (start == null || end == null) {
      return Container(
        color: colors.surfaceContainerHighest,
        alignment: Alignment.center,
        child: Icon(
          Icons.map_outlined,
          size: 48,
          color: colors.onSurfaceVariant,
        ),
      );
    }

    final center = LatLng(
      (start.latitude + end.latitude) / 2,
      (start.longitude + end.longitude) / 2,
    );

    return IgnorePointer(
      ignoring: disableGestures,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(target: center, zoom: 10),
        markers: {
          Marker(markerId: const MarkerId('start'), position: start),
          Marker(markerId: const MarkerId('end'), position: end),
        },
        polylines: {
          Polyline(
            polylineId: const PolylineId('route'),
            points: [start, end],
            color: colors.primary,
            width: 5,
          ),
        },
        zoomControlsEnabled: false,
        myLocationButtonEnabled: false,
        mapToolbarEnabled: false,
        compassEnabled: false,
        onCameraMoveStarted: onInteractionStart,
        onCameraIdle: onInteractionEnd,
        onTap: (_) {
          onInteractionStart();
          onInteractionEnd();
        },
      ),
    );
  }
}
