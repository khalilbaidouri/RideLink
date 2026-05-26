import 'package:equatable/equatable.dart';

enum BookingStatus {
  pending,
  confirmed,
  cancelled;

  static BookingStatus fromString(String v) => switch (v) {
    'confirmed' => confirmed,
    'cancelled' => cancelled,
    _           => pending,
  };

  String toLabel() => switch (this) {
    BookingStatus.pending   => 'Pending',
    BookingStatus.confirmed => 'Confirmed',
    BookingStatus.cancelled => 'Cancelled',
  };
}

class PassengerInfo extends Equatable {
  final String id;
  final String fullName;
  final String? avatarUrl;
  final double rating;
  final int totalReviews;

  const PassengerInfo({
    required this.id,
    required this.fullName,
    this.avatarUrl,
    required this.rating,
    required this.totalReviews,
  });

  factory PassengerInfo.fromMap(Map<String, dynamic> m) => PassengerInfo(
        id:           m['id'] as String,
        fullName:     m['full_name'] as String? ?? 'Unknown',
        avatarUrl:    m['avatar_url'] as String?,
        rating:       (m['rating'] as num?)?.toDouble() ?? 0.0,
        totalReviews: m['total_reviews'] as int? ?? 0,
      );

  @override
  List<Object?> get props => [id];
}

class BookingModel extends Equatable {
  final String        id;
  final String        rideId;
  final PassengerInfo passenger;
  final int           seatsReserved;
  final double        totalPrice;
  final BookingStatus status;
  final DateTime      bookedAt;

  const BookingModel({
    required this.id,
    required this.rideId,
    required this.passenger,
    required this.seatsReserved,
    required this.totalPrice,
    required this.status,
    required this.bookedAt,
  });

  factory BookingModel.fromMap(Map<String, dynamic> m) => BookingModel(
        id:            m['id'].toString(),
        rideId:        m['ride_id'].toString(),
        passenger:     PassengerInfo.fromMap(m['users'] as Map<String, dynamic>),
        seatsReserved: m['seats_reserved'] as int,
        totalPrice:    (m['total_price'] as num).toDouble(),
        status:        BookingStatus.fromString(m['status'] as String? ?? 'pending'),
        bookedAt:      DateTime.parse(m['booked_at'] as String),
      );

  BookingModel copyWith({BookingStatus? status}) => BookingModel(
        id:            id,
        rideId:        rideId,
        passenger:     passenger,
        seatsReserved: seatsReserved,
        totalPrice:    totalPrice,
        bookedAt:      bookedAt,
        status:        status ?? this.status,
      );

  @override
  List<Object?> get props => [id, status];
}