class SearchRideDriver {
  final String id;
  final String name;
  final double rating;
  final int totalReviews;
  final String? avatarUrl;

  const SearchRideDriver({
    required this.id,
    required this.name,
    required this.rating,
    required this.totalReviews,
    this.avatarUrl,
  });

  factory SearchRideDriver.fromJson(Map<String, dynamic> json) {
    return SearchRideDriver(
      id: json['id']?.toString() ?? '',
      name: json['full_name']?.toString() ?? 'Unknown',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      totalReviews: (json['total_reviews'] as num?)?.toInt() ?? 0,
      avatarUrl: json['avatar_url']?.toString(),
    );
  }
}

class SearchRideResult {
  final String id;
  final String fromName;
  final String toName;
  final DateTime departureTime;
  final double price;
  final int seatsLeft;
  final SearchRideDriver driver;

  const SearchRideResult({
    required this.id,
    required this.fromName,
    required this.toName,
    required this.departureTime,
    required this.price,
    required this.seatsLeft,
    required this.driver,
  });

  factory SearchRideResult.fromJson(Map<String, dynamic> json) {
    final driver = json['driver'] as Map<String, dynamic>? ?? {};
    final departure = json['departure'] as Map<String, dynamic>? ?? {};
    final destination = json['destination'] as Map<String, dynamic>? ?? {};

    return SearchRideResult(
      id: json['id']?.toString() ?? '',
      fromName: departure['name']?.toString() ?? 'Unknown',
      toName: destination['name']?.toString() ?? 'Unknown',
      departureTime: DateTime.tryParse(
            json['departure_time']?.toString() ?? '',
          ) ??
          DateTime.now(),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      seatsLeft: (json['available_seats'] as num?)?.toInt() ?? 0,
      driver: SearchRideDriver.fromJson(driver),
    );
  }
}
