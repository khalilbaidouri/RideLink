// services/notification_service.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';

final notificationServiceProvider = Provider<NotificationService>(
    (ref) => NotificationService(Supabase.instance.client));

class NotificationService {
  final SupabaseClient _db;
  const NotificationService(this._db);

  Future<List<NotificationModel>> fetchAll() async {
    final uid = _db.auth.currentUser?.id; // ← cette ligne est obligatoire !

    final res = await _db
        .from('notifications')
        .select()
        .order('created_at', ascending: false)
        .limit(100);
  
    return (res as List)
        .map((r) => NotificationModel.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  Future<void> markRead(String id) async => _db
      .from('notifications')
      .update({'is_read': true}).eq('id', int.parse(id));

  Future<void> markAllRead() async {
    final uid = _db.auth.currentUser!.id;
    await _db
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', uid)
        .eq('is_read', false);
  }

  Future<void> delete(String id) async =>
      _db.from('notifications').delete().eq('id', int.parse(id));
}
