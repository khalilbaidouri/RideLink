import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─────────────────────────────────────────────
//  Model
// ─────────────────────────────────────────────
class BookingItem {
  final int id;
  final int rideId;
  final String departureCityName;
  final String destinationCityName;
  final DateTime departureTime;
  final double totalPrice;
  final String bookingStatus;
  final String rideStatus;
  final String driverName;
  final String? driverAvatarUrl;
  final String driverId;
  final bool hasReview;

  const BookingItem({
    required this.id,
    required this.rideId,
    required this.departureCityName,
    required this.destinationCityName,
    required this.departureTime,
    required this.totalPrice,
    required this.bookingStatus,
    required this.rideStatus,
    required this.driverName,
    this.driverAvatarUrl,
    required this.driverId,
    required this.hasReview,
  });

  bool get isCompleted => rideStatus == 'completed';
  bool get isCancelled =>
      bookingStatus == 'cancelled' || rideStatus == 'cancelled';
  bool get isUpcoming =>
      !isCompleted && !isCancelled && bookingStatus == 'confirmed';
}

// ─────────────────────────────────────────────
//  RidesScreen
// ─────────────────────────────────────────────
class RidesScreen extends StatefulWidget {
  const RidesScreen({super.key});

  @override
  State<RidesScreen> createState() => _RidesScreenState();
}

class _RidesScreenState extends State<RidesScreen>
    with SingleTickerProviderStateMixin {
  static const Color _primary = Color(0xFF1E5C2E);
  static const Color _bg = Color(0xFFF4F5F0);

  late TabController _tabController;
  List<BookingItem> _bookings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchBookings() async {
    setState(() => _loading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        if (mounted) setState(() => _loading = false);
        return;
      }

      final bookingsRes =
          await Supabase.instance.client.from('bookings').select('''
            id,
            ride_id,
            total_price,
            status,
            ride:rides(
              id,
              status,
              departure_time,
              driver_id,
              departure_city:cities!rides_departure_city_id_fkey(name),
              destination_city:cities!rides_destination_city_id_fkey(name),
              driver:users!driver_id(full_name, avatar_url)
            )
          ''').eq('passenger_id', user.id).order('booked_at', ascending: false);

      final rideIds = (bookingsRes as List)
          .map((b) => (b['ride_id'] as num).toInt())
          .toList();

      Set<int> reviewedRideIds = {};
      if (rideIds.isNotEmpty) {
        final reviewsRes = await Supabase.instance.client
            .from('reviews')
            .select('ride_id')
            .eq('reviewer_id', user.id)
            .inFilter('ride_id', rideIds);

        reviewedRideIds = (reviewsRes as List)
            .map((r) => (r['ride_id'] as num).toInt())
            .toSet();
      }

      final list = bookingsRes.map((b) {
        final ride = b['ride'] as Map<String, dynamic>? ?? {};
        final driver = ride['driver'] as Map<String, dynamic>? ?? {};
        final depCity = ride['departure_city'] as Map<String, dynamic>? ?? {};
        final destCity =
            ride['destination_city'] as Map<String, dynamic>? ?? {};
        final rideId = (b['ride_id'] as num).toInt();

        return BookingItem(
          id: (b['id'] as num).toInt(),
          rideId: rideId,
          departureCityName: depCity['name'] as String? ?? '—',
          destinationCityName: destCity['name'] as String? ?? '—',
          departureTime: DateTime.parse(ride['departure_time'] as String? ??
              DateTime.now().toIso8601String()),
          totalPrice: (b['total_price'] as num?)?.toDouble() ?? 0,
          bookingStatus: b['status'] as String? ?? 'pending',
          rideStatus: ride['status'] as String? ?? 'active',
          driverName: driver['full_name'] as String? ?? 'Driver',
          driverAvatarUrl: driver['avatar_url'] as String?,
          driverId: ride['driver_id'] as String? ?? '',
          hasReview: reviewedRideIds.contains(rideId),
        );
      }).toList();

      if (mounted) {
        setState(() {
          _bookings = list;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading bookings: $e')),
        );
      }
    }
  }

  List<BookingItem> get _upcoming =>
      _bookings.where((b) => b.isUpcoming).toList();
  List<BookingItem> get _completed =>
      _bookings.where((b) => b.isCompleted).toList();
  List<BookingItem> get _cancelled =>
      _bookings.where((b) => b.isCancelled).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: _primary))
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _BookingsList(
                          bookings: _upcoming,
                          emptyMessage: 'No upcoming rides',
                          emptyIcon: Icons.directions_car_outlined,
                          onReview: _openReviewSheet,
                          onRefresh: _fetchBookings,
                        ),
                        _BookingsList(
                          bookings: _completed,
                          emptyMessage: 'No completed rides yet',
                          emptyIcon: Icons.check_circle_outline,
                          onReview: _openReviewSheet,
                          onRefresh: _fetchBookings,
                        ),
                        _BookingsList(
                          bookings: _cancelled,
                          emptyMessage: 'No cancelled rides',
                          emptyIcon: Icons.cancel_outlined,
                          onReview: _openReviewSheet,
                          onRefresh: _fetchBookings,
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('My Rides',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: _primary,
                        letterSpacing: -0.5)),
                SizedBox(height: 2),
                Text('Your booking history',
                    style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E))),
              ],
            ),
          ),
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey.shade300,
            child: Icon(Icons.person, color: Colors.grey.shade600, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey.shade600,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        indicator: BoxDecoration(
          color: _primary,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        padding: const EdgeInsets.all(4),
        tabs: const [
          Tab(text: 'Upcoming'),
          Tab(text: 'Completed'),
          Tab(text: 'Cancelled'),
        ],
      ),
    );
  }

  void _openReviewSheet(BookingItem booking) {
    const months = [
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
      'Dec'
    ];
    final dt = booking.departureTime;
    final rideDate = '${dt.day} ${months[dt.month - 1]}';

    context.push(
      '/passenger/rides/review',
      extra: {
        'rideId': booking.rideId,
        'reviewedUserId': booking.driverId,
        'reviewedUserName': booking.driverName,
        'reviewedUserAvatarUrl': booking.driverAvatarUrl,
        'departureCity': booking.departureCityName,
        'destinationCity': booking.destinationCityName,
        'rideDate': rideDate,
      },
    ).then((_) => _fetchBookings());
  }
}

// ─────────────────────────────────────────────
//  Bookings List
// ─────────────────────────────────────────────
class _BookingsList extends StatelessWidget {
  final List<BookingItem> bookings;
  final String emptyMessage;
  final IconData emptyIcon;
  final void Function(BookingItem) onReview;
  final Future<void> Function() onRefresh;

  const _BookingsList({
    required this.bookings,
    required this.emptyMessage,
    required this.emptyIcon,
    required this.onReview,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return _EmptyState(message: emptyMessage, icon: emptyIcon);
    }
    return RefreshIndicator(
      color: const Color(0xFF1E5C2E),
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        itemCount: bookings.length,
        itemBuilder: (_, i) => _BookingCard(
          booking: bookings[i],
          onReview: () => onReview(bookings[i]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Booking Card
// ─────────────────────────────────────────────
class _BookingCard extends StatelessWidget {
  static const Color _primary = Color(0xFF1E5C2E);
  final BookingItem booking;
  final VoidCallback onReview;

  const _BookingCard({required this.booking, required this.onReview});

  String _formatDate(DateTime dt) {
    const months = [
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
      'Dec'
    ];
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}  •  $h:$m $period';
  }

  Color get _statusColor {
    if (booking.isCancelled) return Colors.red.shade600;
    if (booking.isCompleted) return _primary;
    return const Color(0xFF1565C0);
  }

  Color get _statusBg {
    if (booking.isCancelled) return Colors.red.shade50;
    if (booking.isCompleted) return const Color(0xFFD6EDDA);
    return const Color(0xFFE3F0FF);
  }

  String get _statusLabel {
    if (booking.isCancelled) return 'Cancelled';
    if (booking.isCompleted) return 'Completed';
    return 'Confirmed';
  }

  @override
  Widget build(BuildContext context) {
    final canReview = booking.isCompleted && !booking.hasReview;

    return GestureDetector(
      onTap: canReview ? onReview : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          // Highlight border when review is available
          border: canReview
              ? Border.all(color: const Color(0xFF1E5C2E), width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            // ── "Tap to review" banner ──────────────────────
            if (canReview)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: const BoxDecoration(
                  color: Color(0xFF1E5C2E),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(14),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star_outline_rounded,
                        size: 14, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      'Tap anywhere to leave a review',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

            // ── Main card content ───────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _statusBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(_statusLabel,
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _statusColor)),
                      ),
                      Text(
                        '${booking.totalPrice.toStringAsFixed(0)} MAD',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Route connector
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.grey.shade400, width: 2)),
                        ),
                        Container(
                            width: 2, height: 28, color: Colors.grey.shade300),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: _primary),
                        ),
                      ]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(booking.departureCityName,
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1A1A1A))),
                            const SizedBox(height: 14),
                            Text(booking.destinationCityName,
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1A1A1A))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 5),
                    Text(_formatDate(booking.departureTime),
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500)),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    CircleAvatar(
                      radius: 13,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: booking.driverAvatarUrl != null
                          ? NetworkImage(booking.driverAvatarUrl!)
                          : null,
                      child: booking.driverAvatarUrl == null
                          ? Icon(Icons.person,
                              size: 15, color: Colors.grey.shade500)
                          : null,
                    ),
                    const SizedBox(width: 7),
                    Text(booking.driverName,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500)),
                  ]),
                ],
              ),
            ),

            // ── Review footer — only for completed rides ────
            if (booking.isCompleted) ...[
              Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: booking.hasReview
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_rounded,
                              size: 16, color: Colors.grey.shade400),
                          const SizedBox(width: 6),
                          Text('Review submitted',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade400,
                                  fontWeight: FontWeight.w500)),
                        ],
                      )
                    : SizedBox(
                        width: double.infinity,
                        height: 42,
                        child: ElevatedButton.icon(
                          onPressed: onReview,
                          icon:
                              const Icon(Icons.star_outline_rounded, size: 18),
                          label: const Text('Leave a Review',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Empty State
// ─────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const _EmptyState({required this.message, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
                color: Color(0xFFEEF4ED), shape: BoxShape.circle),
            child: const Icon(Icons.directions_car_outlined,
                color: Color(0xFF1E5C2E), size: 34),
          ),
          const SizedBox(height: 16),
          Text(message,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}
