import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideDetailsDriver {
  final String id;
  final String name;
  final double rating;
  final int totalReviews;
  final String? avatarUrl;

  const RideDetailsDriver({
    required this.id,
    required this.name,
    required this.rating,
    required this.totalReviews,
    this.avatarUrl,
  });
}

class RideDetailsVehicle {
  final String? brand;
  final String? model;
  final String? color;
  final String? plateNumber;
  final int? seats;

  const RideDetailsVehicle({
    this.brand,
    this.model,
    this.color,
    this.plateNumber,
    this.seats,
  });

  String get label {
    final parts =
        [brand, model].where((value) => value != null && value!.isNotEmpty);
    return parts.isEmpty ? 'Vehicle details' : parts.join(' ');
  }
}

class RideDetailsLocation {
  final int? cityId;
  final String name;
  final String? address;
  final double? lat;
  final double? lng;

  const RideDetailsLocation({
    required this.name,
    this.cityId,
    this.address,
    this.lat,
    this.lng,
  });

  LatLng? get latLng {
    if (lat == null || lng == null) {
      return null;
    }
    return LatLng(lat!, lng!);
  }
}

class RidePassenger {
  final String id;
  final String name;
  final String? avatarUrl;

  const RidePassenger({
    required this.id,
    required this.name,
    this.avatarUrl,
  });
}

class RideDetails {
  final String id;
  final RideDetailsDriver driver;
  final RideDetailsLocation departure;
  final RideDetailsLocation destination;
  final DateTime departureTime;
  final double price;
  final int seatsLeft;
  final RideDetailsVehicle vehicle;
  final List<RidePassenger> passengers;
  final int bookedCount;

  const RideDetails({
    required this.id,
    required this.driver,
    required this.departure,
    required this.destination,
    required this.departureTime,
    required this.price,
    required this.seatsLeft,
    required this.vehicle,
    required this.passengers,
    required this.bookedCount,
  });
}
