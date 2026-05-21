import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/notification_model.dart';
import '../providers/notification_provider.dart';
import '../widgets/notification_card.dart';
import '../widgets/notification_empty_state.dart';
import '../widgets/notification_error_state.dart';
import '../widgets/notification_shimmer.dart';
import '../widgets/unread_badge.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(notificationsNotifierProvider);
    final unread     = ref.watch(unreadCountProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF3),
      appBar: _buildAppBar(context, ref, unread),
      body: asyncState.when(
        loading: () => const NotificationShimmer(),
        error:   (e, _) => NotificationErrorState(
          onRetry: () => ref.invalidate(notificationsNotifierProvider),
        ),
        data: (list) => list.isEmpty
            ? const NotificationEmptyState()
            : RefreshIndicator(
                color: const Color(0xFF005127),
                onRefresh: () =>
                    ref.refresh(notificationsNotifierProvider.future),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => NotificationCard(
                    notification: list[i],
                    onTap: () {
                      ref
                          .read(notificationsNotifierProvider.notifier)
                          .markRead(list[i].id);
                      _navigate(context, list[i]);
                    },
                    onDelete: () => ref
                        .read(notificationsNotifierProvider.notifier)
                        .delete(list[i].id),
                  ),
                ),
              ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, WidgetRef ref, int unread) {
    return AppBar(
      backgroundColor: const Color(0xFFF7FAF3),
      elevation: 0,
      scrolledUnderElevation: 1,
      titleSpacing: 16,
      title: Row(
        children: [
          const Text(
            'Notifications',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF181D18),
            ),
          ),
          if (unread > 0) ...[
            const SizedBox(width: 8),
            UnreadBadge(count: unread),
          ],
        ],
      ),
      actions: [
        if (unread > 0)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: () => ref
                  .read(notificationsNotifierProvider.notifier)
                  .markAllRead(),
              child: const Text(
                'Mark all read',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  color: Color(0xFF005127),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _navigate(BuildContext ctx, NotificationModel n) {
    final p = n.payload;
    if (p['ride_id'] != null) {
      ctx.go('/rides/${p['ride_id']}');
    } else if (p['booking_id'] != null) {
      ctx.go('/bookings/${p['booking_id']}');
    }
  }
}