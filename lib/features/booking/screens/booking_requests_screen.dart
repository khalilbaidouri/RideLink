import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/booking_provider.dart';
import '../models/booking_model.dart';
import '../widgets/booking_card.dart';
import '../widgets/booking_empty_state.dart';
import '../widgets/booking_error_state.dart';
import '../widgets/booking_shimmer.dart';

class BookingRequestsScreen extends ConsumerStatefulWidget {
  const BookingRequestsScreen({super.key});

  @override
  ConsumerState<BookingRequestsScreen> createState() =>
      _BookingRequestsScreenState();
}

class _BookingRequestsScreenState extends ConsumerState<BookingRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(bookingRequestsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF3),
      appBar: _buildAppBar(),
      body: asyncState.when(
        loading: () => const BookingShimmer(),
        error: (e, _) => BookingErrorState(
          onRetry: () => ref.invalidate(bookingRequestsProvider),
        ),
        data: (_) => Column(
          children: [
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _BookingList(
                    bookings: ref.watch(pendingBookingsProvider),
                    emptyMessage: 'No pending requests at the moment.',
                  ),
                  _BookingList(
                    bookings: ref.watch(confirmedBookingsProvider),
                    emptyMessage: 'No confirmed bookings yet.',
                  ),
                  _BookingList(
                    bookings: ref.watch(cancelledBookingsProvider),
                    emptyMessage: 'No cancelled bookings.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF7FAF3),
      elevation: 0,
      scrolledUnderElevation: 1,
      titleSpacing: 16,
      title: const Text(
        'Booking Requests',
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Color(0xFF181D18),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Color(0xFF005127)),
          onPressed: () => ref.invalidate(bookingRequestsProvider),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    final pending = ref.watch(pendingBookingsProvider).length;
    final confirmed = ref.watch(confirmedBookingsProvider).length;
    final cancelled = ref.watch(cancelledBookingsProvider).length;

    return Container(
      color: const Color(0xFFF7FAF3),
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF005127),
        unselectedLabelColor: const Color(0xFF6B7280),
        indicatorColor: const Color(0xFF005127),
        indicatorWeight: 2.5,
        labelStyle: const TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        tabs: [
          _TabItem(label: 'Pending', count: pending),
          _TabItem(label: 'Confirmed', count: confirmed),
          _TabItem(label: 'Cancelled', count: cancelled),
        ],
      ),
    );
  }
}

// ── Tab item with counter badge ───────────────────────────────────────────────
class _TabItem extends StatelessWidget {
  final String label;
  final int count;

  const _TabItem({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF005127),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Booking list per tab ──────────────────────────────────────────────────────
class _BookingList extends ConsumerWidget {
  final List<BookingModel> bookings;
  final String emptyMessage;

  const _BookingList({
    required this.bookings,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (bookings.isEmpty) {
      return BookingEmptyState(message: emptyMessage);
    }

    return RefreshIndicator(
      color: const Color(0xFF005127),
      onRefresh: () => ref.refresh(bookingRequestsProvider.future),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        itemCount: bookings.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => BookingCard(
          booking: bookings[i],
          onAccept: () => _handleAccept(context, ref, bookings[i]),
          onReject: () => _handleReject(context, ref, bookings[i]),
        ),
      ),
    );
  }

  Future<void> _handleAccept(
      BuildContext context, WidgetRef ref, BookingModel booking) async {
    final confirmed = await _showConfirmDialog(
      context,
      title: 'Accept Request',
      message: 'Accept ${booking.passenger.fullName}\'s booking request?',
      confirmLabel: 'Accept',
      confirmColor: const Color(0xFF005127),
    );
    if (confirmed == true) {
      await ref.read(bookingRequestsProvider.notifier).accept(booking.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${booking.passenger.fullName}\'s request accepted!'),
            backgroundColor: const Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _handleReject(
      BuildContext context, WidgetRef ref, BookingModel booking) async {
    final confirmed = await _showConfirmDialog(
      context,
      title: 'Reject Request',
      message: 'Reject ${booking.passenger.fullName}\'s booking request?',
      confirmLabel: 'Reject',
      confirmColor: const Color(0xFFC62828),
    );
    if (confirmed == true) {
      await ref.read(bookingRequestsProvider.notifier).reject(booking.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${booking.passenger.fullName}\'s request rejected.'),
            backgroundColor: const Color(0xFFC62828),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<bool?> _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(false), // ✅ fixed
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => dialogContext.pop(true), // ✅ fixed
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              confirmLabel,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}