import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationsNotifier extends AsyncNotifier<List<NotificationModel>> {
  RealtimeChannel? _channel;

  @override
  Future<List<NotificationModel>> build() async {
    ref.onDispose(() {
      _channel?.unsubscribe();
    });

    final list =
        await ref.read(notificationServiceProvider).fetchAll();

    _subscribeRealtime();

    return list;
  }

  void _subscribeRealtime() {
    final userId =
        Supabase.instance.client.auth.currentUser?.id;

    if (userId == null) return;

    _channel = Supabase.instance.client
        .channel('notifications_channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            final newItem = NotificationModel.fromMap(payload.newRecord);

            final current = state.valueOrNull ?? [];

            state = AsyncData([
              newItem,
              ...current,
            ]);
          },
        )
        .subscribe();
  }

  Future<void> markRead(String id) async {
    await ref
        .read(notificationServiceProvider)
        .markRead(id);

    final current = state.valueOrNull ?? [];

    state = AsyncData(
      current.map((n) {
        if (n.id == id) {
          return n.copyWith(isRead: true);
        }
        return n;
      }).toList(),
    );
  }

  Future<void> markAllRead() async {
    await ref
        .read(notificationServiceProvider)
        .markAllRead();

    final current = state.valueOrNull ?? [];

    state = AsyncData(
      current
          .map((n) => n.copyWith(isRead: true))
          .toList(),
    );
  }

  Future<void> delete(String id) async {
    await ref
        .read(notificationServiceProvider)
        .delete(id);

    final current = state.valueOrNull ?? [];

    state = AsyncData(
      current.where((n) => n.id != id).toList(),
    );
  }
}

final notificationsNotifierProvider =
    AsyncNotifierProvider<NotificationsNotifier, List<NotificationModel>>(
  NotificationsNotifier.new,
);

final unreadCountProvider = Provider<int>((ref) {
  final list =
      ref.watch(notificationsNotifierProvider).valueOrNull ?? [];

  return list.where((n) => !n.isRead).length;
});