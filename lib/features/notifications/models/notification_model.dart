// models/notification_model.dart
import 'package:equatable/equatable.dart';

enum NotificationType {
  bookingAccepted, bookingRejected, bookingRequest,
  rideCancelled, rideReminder, reviewReceived, system;

  static NotificationType fromString(String v) => switch (v) {
    'booking_accepted'  => bookingAccepted,
    'booking_rejected'  => bookingRejected,
    'booking_request'   => bookingRequest,
    'ride_cancelled'    => rideCancelled,
    'ride_reminder'     => rideReminder,
    'review_received'   => reviewReceived,
    _                   => system,
  };
}

class NotificationModel extends Equatable {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final Map<String, dynamic> payload;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.payload,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> m) =>
    NotificationModel(
      id: m['id'].toString(),  // ← bigint → String
      userId:    m['user_id'] as String,
      type:      NotificationType.fromString(m['type'] as String),
      title:     m['title'] as String,
      body:      m['body'] as String,
      payload:   (m['payload'] as Map<String, dynamic>?) ?? {},
      isRead:    m['is_read'] as bool,
      createdAt: DateTime.parse(m['created_at'] as String),
    );

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
    id: id, userId: userId, type: type, title: title,
    body: body, payload: payload, createdAt: createdAt,
    isRead: isRead ?? this.isRead,
  );

  @override
  List<Object?> get props => [id, isRead];
}