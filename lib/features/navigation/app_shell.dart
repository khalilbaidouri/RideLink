import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final response = await Supabase.instance.client
          .from('users')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      if (mounted) {
        setState(() {
          _userRole = (response?['role'] as String?)?.toLowerCase();
        });
      }
    } catch (_) {}
  }

  bool get _canPublishRide {
    if (_userRole == null) return false;
    return _userRole == 'driver' || _userRole == 'both';
  }

  void _onDestinationSelected(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.navigationShell,

      // ── Bouton "+" flottant centré ────────
      floatingActionButton: _canPublishRide
          ? FloatingActionButton(
              onPressed: () => context.push('/app/route-details'),
              backgroundColor: const Color(0xFF1E5C2E),
              foregroundColor: Colors.white,
              elevation: 4,
              shape: const CircleBorder(),
              child: const Icon(Icons.add_rounded, size: 28),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // ── Bottom Navigation Bar ─────────────
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        color: Colors.white,
        elevation: 8,
        child: Row(
          children: [
            // Home
            _NavItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              label: 'Home',
              isActive: widget.navigationShell.currentIndex == 0,
              onTap: () => _onDestinationSelected(0),
            ),
            // Rides
            _NavItem(
              icon: Icons.route_outlined,
              activeIcon: Icons.route,
              label: 'Rides',
              isActive: widget.navigationShell.currentIndex == 1,
              onTap: () => _onDestinationSelected(1),
            ),

            // Espace central pour le FAB
            const Expanded(child: SizedBox()),

            // Messages
            _NavItem(
              icon: Icons.chat_bubble_outline,
              activeIcon: Icons.chat_bubble,
              label: 'Messages',
              isActive: widget.navigationShell.currentIndex == 2,
              onTap: () => _onDestinationSelected(2),
            ),
            // Profile
            _NavItem(
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              label: 'Profile',
              isActive: widget.navigationShell.currentIndex == 3,
              onTap: () => _onDestinationSelected(3),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Nav Item
// ─────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  static const Color _primary = Color(0xFF1E5C2E);
  static const Color _unselected = Color(0xFF9E9E9E);

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color:
                    isActive ? _primary.withOpacity(0.10) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isActive ? activeIcon : icon,
                color: isActive ? _primary : _unselected,
                size: 24,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color: isActive ? _primary : _unselected,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
