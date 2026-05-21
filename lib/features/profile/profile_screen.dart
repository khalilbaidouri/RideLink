import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/user_model.dart';
import 'profile_navbar.dart';
import '../vehicles/domain/entities/vehicle.dart';
import '../vehicles/providers/vehicles_provider.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  late final Future<UserModel> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _fetchProfile();
  }

  Future<UserModel> _fetchProfile() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) {
      throw StateError('No authenticated user found.');
    }

    final data = await client
        .from('users')
        .select(
          'id, full_name, email, phone, avatar_url, role, rating, total_reviews, created_at',
        )
        .eq('id', user.id)
        .single();

    final normalized = <String, dynamic>{
      ...data,
      'id': user.id,
      'email': data['email'] ?? user.email ?? '',
      'created_at':
          data['created_at'] ?? DateTime.now().toIso8601String(),
      'rating': data['rating'] ?? 0,
      'total_reviews': data['total_reviews'] ?? 0,
    };

    return UserModel.fromJson(normalized);
  }

  @override
  Widget build(BuildContext context) {
    final vehiclesState = ref.watch(vehiclesProvider);
    final vehicles = ref.watch(sortedVehiclesProvider);

    return FutureBuilder<UserModel>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Unable to load profile',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        }

        final user = snapshot.data!;
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ProfileNavbar(),
              _ProfileHeaderCard(user: user),
              const SizedBox(height: 18),
              _VehiclesSection(
                isLoading: vehiclesState.isLoading,
                vehicles: vehicles,
                errorMessage: vehiclesState.error,
                onAddPressed: () {
                  context.push('/passenger/vehicles');
                },
              ),
              const SizedBox(height: 18),
              _ProfileMenuCard(
                onBookings: () => context.go('/passenger/rides'),
                onRides: () => context.go('/passenger/rides'),
                onNotifications: () => context.go('/passenger/messages'),
                onSettings: () => context.go('/passenger/profile/settings'),
                onLogout: () => _signOut(context),
                notificationsCount: 3,
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMenuSnack(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label tapped')),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await Supabase.instance.client.auth.signOut();
    } on AuthException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to log out')),
      );
    }
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final ratingText = user.rating.toStringAsFixed(2);

    return Card(
      elevation: 2,
      shadowColor: colors.shadow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: colors.surfaceContainerHighest,
                  backgroundImage: user.avatarUrl != null &&
                          user.avatarUrl!.trim().isNotEmpty
                      ? NetworkImage(user.avatarUrl!)
                      : null,
                  child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                      ? Icon(
                          Icons.person,
                          size: 44,
                          color: colors.onSurfaceVariant,
                        )
                      : null,
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: colors.secondaryContainer,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colors.surface,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.verified,
                      size: 16,
                      color: colors.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              user.fullName,
              style: textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...List.generate(
                  5,
                  (index) => Icon(
                    Icons.star,
                    size: 18,
                    color: index < user.rating.round().clamp(0, 5)
                        ? const Color(0xFFF4B740)
                        : colors.outlineVariant,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  ratingText,
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '(${user.totalReviews} reviews)',
                  style: textTheme.labelMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Divider(color: colors.outlineVariant),
            const SizedBox(height: 16),
            _InfoRow(
              icon: Icons.email_outlined,
              label: 'Email',
              value: user.email,
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.call_outlined,
              label: 'Phone',
              value: user.phone,
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Role',
                style: textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  user.role.replaceAll('_', ' ').toUpperCase(),
                  style: textTheme.labelMedium?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: colors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value.isEmpty ? '-' : value,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VehiclesSection extends StatelessWidget {
  const _VehiclesSection({
    required this.isLoading,
    required this.vehicles,
    required this.errorMessage,
    required this.onAddPressed,
  });

  final bool isLoading;
  final List<Vehicle> vehicles;
  final String? errorMessage;
  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('My Vehicles', style: textTheme.headlineSmall),
            TextButton.icon(
              onPressed: onAddPressed,
              icon: Icon(Icons.add_circle_outline, color: colors.primary),
              label: Text(
                'Add Vehicle',
                style: textTheme.labelLarge?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                shape: const StadiumBorder(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else if (errorMessage != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              errorMessage!,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else if (vehicles.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              'No vehicles yet. Tap Add Vehicle to link one.',
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          )
        else
          Column(
            children: vehicles
                .map((vehicle) => _VehicleTile(vehicle: vehicle))
                .toList(),
          ),
      ],
    );
  }
}

class _VehicleTile extends StatelessWidget {
  const _VehicleTile({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                colors: [
                  colors.primary.withValues(alpha: 0.2),
                  colors.primaryContainer.withValues(alpha: 0.5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(
              _categoryIcon(vehicle.category),
              color: colors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${vehicle.brand} ${vehicle.model}',
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${vehicle.licensePlate} - ${vehicle.color ?? 'Color'}',
                  style: textTheme.labelMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
        ],
      ),
    );
  }

  IconData _categoryIcon(VehicleCategory category) {
    return switch (category) {
      VehicleCategory.suv => Icons.directions_car_filled_outlined,
      VehicleCategory.minivan => Icons.airport_shuttle_outlined,
      VehicleCategory.pickup => Icons.local_shipping_outlined,
      _ => Icons.directions_car_outlined,
    };
  }
}

class _ProfileMenuCard extends StatelessWidget {
  const _ProfileMenuCard({
    required this.onBookings,
    required this.onRides,
    required this.onNotifications,
    required this.onSettings,
    required this.onLogout,
    required this.notificationsCount,
  });

  final VoidCallback onBookings;
  final VoidCallback onRides;
  final VoidCallback onNotifications;
  final VoidCallback onSettings;
  final VoidCallback onLogout;
  final int notificationsCount;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 2,
      shadowColor: colors.shadow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Column(
        children: [
          _MenuRow(
            icon: Icons.calendar_today_outlined,
            label: 'My Bookings',
            onTap: onBookings,
          ),
          _MenuDivider(colors: colors),
          _MenuRow(
            icon: Icons.directions_car_outlined,
            label: 'My Rides',
            onTap: onRides,
          ),
          _MenuDivider(colors: colors),
          _MenuRow(
            icon: Icons.notifications_none_outlined,
            label: 'Notifications',
            onTap: onNotifications,
            trailing: notificationsCount > 0
                ? _NotificationBadge(count: notificationsCount)
                : null,
          ),
          _MenuDivider(colors: colors),
          _MenuRow(
            icon: Icons.settings_outlined,
            label: 'Settings',
            onTap: onSettings,
          ),
          _MenuDivider(colors: colors),
          _MenuRow(
            icon: Icons.logout,
            label: 'Logout',
            onTap: onLogout,
            labelStyle: textTheme.labelLarge?.copyWith(
              color: colors.error,
              fontWeight: FontWeight.w700,
            ),
            iconColor: colors.error,
          ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.labelStyle,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;
  final TextStyle? labelStyle;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? colors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: labelStyle ?? textTheme.labelLarge,
              ),
            ),
            if (trailing != null) ...[
              trailing!,
              const SizedBox(width: 8),
            ],
            Icon(
              Icons.chevron_right,
              color: colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuDivider extends StatelessWidget {
  const _MenuDivider({required this.colors});

  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: colors.outlineVariant,
      height: 1,
      indent: 16,
      endIndent: 16,
    );
  }
}

class _NotificationBadge extends StatelessWidget {
  const _NotificationBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.error,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count',
        style: textTheme.labelMedium?.copyWith(
          color: colors.onError,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}