import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ride_link/core/server/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DriverDashboardStats {
  final String name;
  final int totalRides;
  final double totalEarnings;
  final double averageRating;
  final int totalReviews;
  final double weeklyChangePercent;
  final List<DriverActivityItem> activities;

  const DriverDashboardStats({
    required this.name,
    required this.totalRides,
    required this.totalEarnings,
    required this.averageRating,
    required this.totalReviews,
    required this.weeklyChangePercent,
    required this.activities,
  });
}

enum DriverActivityKind {
  rideCompleted,
  payout,
  feedback,
}

class DriverActivityItem {
  final DriverActivityKind kind;
  final String title;
  final String subtitle;
  final String? amountText;
  final String? badgeText;
  final double? rating;
  final DateTime occurredAt;

  const DriverActivityItem({
    required this.kind,
    required this.title,
    required this.subtitle,
    this.amountText,
    this.badgeText,
    this.rating,
    required this.occurredAt,
  });
}

final driverDashboardProvider = FutureProvider<DriverDashboardStats>((ref) async {
  final user = supabase.auth.currentUser;
  if (user == null) {
    throw AuthException('No authenticated user found.');
  }

  final userData = await supabase
      .from('users')
      .select('full_name, rating, total_reviews')
      .eq('id', user.id)
      .maybeSingle();

    final fullName = (userData?['full_name'] as String?)?.trim();
    final name = fullName != null && fullName.isNotEmpty
      ? fullName
      : (user.email ?? 'Driver');
  final rating = (userData?['rating'] ?? 0) is num
      ? (userData?['rating'] as num).toDouble()
      : double.tryParse('${userData?['rating']}') ?? 0;
  final totalReviews = (userData?['total_reviews'] ?? 0) is num
      ? (userData?['total_reviews'] as num).toInt()
      : int.tryParse('${userData?['total_reviews']}') ?? 0;

    final ridesResponse = await supabase
      .from('rides')
      .select('id, created_at, status, price, departure_address, destination_address')
      .eq('driver_id', user.id)
      .not('status', 'eq', 'cancelled')
      .order('created_at', ascending: false);

  final rides = ridesResponse.cast<Map<String, dynamic>>();
  final totalRides = rides.length;
  final rideIds = rides
      .map((ride) => ride['id'])
      .whereType<num>()
      .map((id) => id.toInt())
      .toList();

  final now = DateTime.now();
  final sevenDaysAgo = now.subtract(const Duration(days: 7));
  final fourteenDaysAgo = now.subtract(const Duration(days: 14));
  final recentCount = rides.where((ride) {
    final createdAt = DateTime.tryParse('${ride['created_at']}');
    return createdAt != null && createdAt.isAfter(sevenDaysAgo);
  }).length;
  final previousCount = rides.where((ride) {
    final createdAt = DateTime.tryParse('${ride['created_at']}');
    return createdAt != null &&
        createdAt.isAfter(fourteenDaysAgo) &&
        createdAt.isBefore(sevenDaysAgo);
  }).length;

  final weeklyChangePercent =
      _calculateChangePercent(recentCount, previousCount);

  double totalEarnings = 0;
  if (rideIds.isNotEmpty) {
    final bookingsResponse = await supabase
        .from('bookings')
        .select('total_price, status, ride_id')
        .inFilter('ride_id', rideIds)
        .eq('status', 'confirmed');

    totalEarnings = bookingsResponse.fold<double>(0, (sum, row) {
      final value = row['total_price'];
      if (value is num) {
        return sum + value.toDouble();
      }
      if (value is String) {
        return sum + (double.tryParse(value) ?? 0);
      }
      return sum;
    });
  }

  final activities = await _loadRecentActivities(
    userId: user.id,
    rides: rides,
  );

  return DriverDashboardStats(
    name: name,
    totalRides: totalRides,
    totalEarnings: totalEarnings,
    averageRating: rating,
    totalReviews: totalReviews,
    weeklyChangePercent: weeklyChangePercent,
    activities: activities,
  );
});

Future<List<DriverActivityItem>> _loadRecentActivities({
  required String userId,
  required List<Map<String, dynamic>> rides,
}) async {
  final activities = <DriverActivityItem>[];
  final completedRides = rides
      .where((ride) => ride['status'] == 'completed')
      .take(3)
      .toList();

  if (completedRides.isNotEmpty) {
    final rideIds = completedRides
        .map((ride) => ride['id'])
        .whereType<num>()
        .map((id) => id.toInt())
        .toList();

    final bookingsResponse = await supabase
        .from('bookings')
        .select('ride_id, seats_reserved')
        .inFilter('ride_id', rideIds)
        .eq('status', 'confirmed');

    final seatsByRide = <int, int>{};
    for (final row in bookingsResponse) {
      final rideId = row['ride_id'];
      final seats = row['seats_reserved'];
      if (rideId is num) {
        seatsByRide[rideId.toInt()] =
            (seatsByRide[rideId.toInt()] ?? 0) + (seats as int? ?? 0);
      }
    }

    for (final ride in completedRides) {
      final rideId = (ride['id'] as num?)?.toInt();
      final createdAt = DateTime.tryParse('${ride['created_at']}') ?? DateTime.now();
      final passengers = rideId != null ? (seatsByRide[rideId] ?? 0) : 0;
      final departure = (ride['departure_address'] as String?)?.trim();
      final destination = (ride['destination_address'] as String?)?.trim();
      final routeTitle = departure != null && destination != null
          ? '$departure to $destination'
          : 'Ride completed';
      final price = ride['price'];
      final amountText = price is num
          ? '+${_formatCurrency(price.toDouble())}'
          : null;

      activities.add(
        DriverActivityItem(
          kind: DriverActivityKind.rideCompleted,
          title: routeTitle,
          subtitle: '${_formatRelative(createdAt)} • $passengers passengers',
          amountText: amountText,
          badgeText: 'Completed',
          occurredAt: createdAt,
        ),
      );
    }
  }

  final latestBooking = await supabase
      .from('bookings')
      .select('total_price, booked_at')
      .eq('status', 'confirmed')
      .order('booked_at', ascending: false)
      .limit(1)
      .maybeSingle();

  if (latestBooking != null) {
    final bookedAt = DateTime.tryParse('${latestBooking['booked_at']}') ??
        DateTime.now();
    final totalPrice = latestBooking['total_price'];
    final payoutText = totalPrice is num
        ? '-${_formatCurrency(totalPrice.toDouble())}'
        : null;

    activities.add(
      DriverActivityItem(
        kind: DriverActivityKind.payout,
        title: 'Payout processed',
        subtitle: _formatCalendarTime(bookedAt),
        amountText: payoutText,
        badgeText: 'Transfer',
        occurredAt: bookedAt,
      ),
    );
  }

  final latestReview = await supabase
      .from('reviews')
      .select('rating, comment, created_at')
      .eq('reviewed_user_id', userId)
      .order('created_at', ascending: false)
      .limit(1)
      .maybeSingle();

  if (latestReview != null) {
    final createdAt = DateTime.tryParse('${latestReview['created_at']}') ??
        DateTime.now();
    final rating = latestReview['rating'] is num
        ? (latestReview['rating'] as num).toDouble()
        : double.tryParse('${latestReview['rating']}') ?? 0;
    final comment = (latestReview['comment'] as String?)?.trim();
    final subtitle = comment != null && comment.isNotEmpty
        ? comment
        : 'New feedback received';

    activities.add(
      DriverActivityItem(
        kind: DriverActivityKind.feedback,
        title: 'New ${rating.toStringAsFixed(0)}-star rating',
        subtitle: subtitle,
        rating: rating,
        badgeText: 'Feedback',
        occurredAt: createdAt,
      ),
    );
  }

  activities.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
  return activities.take(3).toList();
}

double _calculateChangePercent(int current, int previous) {
  if (previous <= 0) {
    return current == 0 ? 0 : 100;
  }
  return ((current - previous) / previous) * 100;
}

String _formatRelative(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);
  if (difference.inMinutes < 1) {
    return 'Just now';
  }
  if (difference.inMinutes < 60) {
    return '${difference.inMinutes} mins ago';
  }
  if (difference.inHours < 24) {
    return '${difference.inHours} hours ago';
  }
  return _formatCalendarTime(dateTime);
}

String _formatCalendarTime(DateTime dateTime) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final date = DateTime(dateTime.year, dateTime.month, dateTime.day);
  final time = _formatTime(dateTime);

  if (date == today) {
    return 'Today, $time';
  }
  if (date == today.subtract(const Duration(days: 1))) {
    return 'Yesterday, $time';
  }

  final monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final month = monthNames[dateTime.month - 1];
  return '$month ${dateTime.day}, $time';
}

String _formatTime(DateTime dateTime) {
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String _formatCurrency(double value) {
  final rounded = value.toStringAsFixed(2);
  final parts = rounded.split('.');
  final whole = parts.first.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => ',',
  );
  return '\$$whole.${parts.last}';
}
