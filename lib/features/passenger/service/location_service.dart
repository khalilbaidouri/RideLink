import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<String?> getCurrentCity() async {
    try {
      // 1. Check if location service is on
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      // 2. Check / request permission
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // 3. Guard — covers denied, deniedForever, and unresolved
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      // 4. Get position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low, // faster, enough for a city
      );

      // 5. Reverse-geocode
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) return null;

      // 6. locality can be null or empty — fall back to subAdminArea (province)
      final city = placemarks.first.locality?.trim();
      if (city != null && city.isNotEmpty) return city;

      final fallback = placemarks.first.subAdministrativeArea?.trim();
      return (fallback?.isNotEmpty == true) ? fallback : null;
    } catch (e) {
      debugPrint('LocationService error: $e');
      return null;
    }
  }
}
