class RecentRideDriver {
  final String id;
  final String name;
  final double rating;
  final int totalRides;
  final String? avatarUrl;

  const RecentRideDriver({
    required this.id,
    required this.name,
    required this.rating,
    required this.totalRides,
    this.avatarUrl,
  });

  factory RecentRideDriver.fromJson(Map<String, dynamic> json) {
    return RecentRideDriver(
      id: json['id']?.toString() ?? '',
      name: json['full_name']?.toString() ?? 'Unknown',
      avatarUrl: json['avatar_url']?.toString(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      totalRides: (json['total_reviews'] as num?)?.toInt() ?? 0,
    );
  }
}

class RecentRide {
  final String id;
  final String fromName;
  final String toName;
  final DateTime departureTime;
  final double price;
  final int seatsLeft;
  final RecentRideDriver driver;
  final String? tag;

  const RecentRide({
    required this.id,
    required this.fromName,
    required this.toName,
    required this.departureTime,
    required this.price,
    required this.seatsLeft,
    required this.driver,
    this.tag,
  });

  factory RecentRide.fromJson(Map<String, dynamic> json) {
    final driver = json['driver'] as Map<String, dynamic>? ?? {};
    final departure = json['departure'] as Map<String, dynamic>? ?? {};
    final destination = json['destination'] as Map<String, dynamic>? ?? {};

    return RecentRide(
      id: json['id'].toString(),
      fromName: departure['name']?.toString() ?? 'Unknown',
      toName: destination['name']?.toString() ?? 'Unknown',
      departureTime: DateTime.tryParse(
            json['departure_time']?.toString() ?? '',
          ) ??
          DateTime.now(),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      seatsLeft: (json['available_seats'] as num?)?.toInt() ?? 0,
      driver: RecentRideDriver.fromJson(driver),
      tag: json['tag']?.toString(),
    );
  }
}
