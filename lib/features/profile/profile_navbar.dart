import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileNavbar extends StatelessWidget {
  const ProfileNavbar({super.key});

  Future<String?> _fetchAvatarUrl() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) {
      return null;
    }

    final response = await client
        .from('users')
        .select('avatar_url')
        .eq('id', user.id)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    final avatarUrl = response['avatar_url'];
    if (avatarUrl is String && avatarUrl.trim().isNotEmpty) {
      return avatarUrl;
    }

    return null;
  }

  void _handleMenuTap(BuildContext context) {
    final scaffold = Scaffold.maybeOf(context);
    if (scaffold != null && scaffold.hasDrawer) {
      scaffold.openDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => _handleMenuTap(context),
            icon: Icon(Icons.menu, color: colors.primary),
          ),
          Text(
            'RideLink',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.primary,
                ),
          ),
          FutureBuilder<String?>(
            future: _fetchAvatarUrl(),
            builder: (context, snapshot) {
              final avatarUrl = snapshot.data;
              return CircleAvatar(
                radius: 18,
                backgroundColor: colors.surfaceContainerHighest,
                backgroundImage:
                    avatarUrl == null ? null : NetworkImage(avatarUrl),
                child: avatarUrl == null
                    ? Icon(Icons.person, color: colors.onSurfaceVariant)
                    : null,
              );
            },
          ),
        ],
      ),
    );
  }
}