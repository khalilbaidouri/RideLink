import 'package:flutter/material.dart';
import '../models/notification_model.dart';

class NotificationIcon extends StatelessWidget {
  final NotificationType type;
  const NotificationIcon({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final config = _iconConfig(type);

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: config['bgColor'] as Color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        config['icon'] as IconData,
        color: config['iconColor'] as Color,
        size: 22,
      ),
    );
  }

  Map<String, dynamic> _iconConfig(NotificationType type) {
    switch (type) {
      case NotificationType.bookingAccepted:
        return {
          'icon':      Icons.check_circle_outline_rounded,
          'bgColor':   const Color(0xFFE8F5E9),
          'iconColor': const Color(0xFF2E7D32),
        };
      case NotificationType.bookingRejected:
        return {
          'icon':      Icons.cancel_outlined,
          'bgColor':   const Color(0xFFFFEBEE),
          'iconColor': const Color(0xFFC62828),
        };
      case NotificationType.bookingRequest:
        return {
          'icon':      Icons.person_add_alt_1_outlined,
          'bgColor':   const Color(0xFFE3F2FD),
          'iconColor': const Color(0xFF1565C0),
        };
      case NotificationType.rideCancelled:
        return {
          'icon':      Icons.directions_car_outlined,
          'bgColor':   const Color(0xFFFFF3E0),
          'iconColor': const Color(0xFFE65100),
        };
      case NotificationType.rideReminder:
        return {
          'icon':      Icons.access_time_rounded,
          'bgColor':   const Color(0xFFF3E5F5),
          'iconColor': const Color(0xFF6A1B9A),
        };
      case NotificationType.reviewReceived:
        return {
          'icon':      Icons.star_outline_rounded,
          'bgColor':   const Color(0xFFFFF8E1),
          'iconColor': const Color(0xFFF9A825),
        };
      case NotificationType.system:
        return {
          'icon':      Icons.info_outline_rounded,
          'bgColor':   const Color(0xFFEEEEEE),
          'iconColor': const Color(0xFF424242),
        };
    }
  }
}