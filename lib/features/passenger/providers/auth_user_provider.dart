import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ride_link/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final supabase = Supabase.instance.client;

  final authUser = supabase.auth.currentUser;

  if (authUser == null) return null;

  final response =
      await supabase.from('users').select().eq('id', authUser.id).single();

  return UserModel.fromJson(response);
});
