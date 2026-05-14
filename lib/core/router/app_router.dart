import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ride_link/features/auth/forgot_password.dart';
import 'package:ride_link/features/auth/login.dart';
import 'package:ride_link/features/auth/reset_email_sent.dart';
import 'package:ride_link/features/auth/signup.dart';
import 'package:ride_link/features/cities/presentation/screens/city_picker_screen.dart';
import 'package:ride_link/features/driver/activity_screen.dart';
import 'package:ride_link/features/driver/alerts_screen.dart';
import 'package:ride_link/features/driver/dashboard_screen.dart';
import 'package:ride_link/features/driver/settings_screen.dart';
import 'package:ride_link/features/home/home_screen.dart';
import 'package:ride_link/features/home/messages_screen.dart';
import 'package:ride_link/features/home/profile_screen.dart';
import 'package:ride_link/features/home/rides_screen.dart';
import 'package:ride_link/core/router/app_shell.dart';
import 'package:ride_link/features/onboarding/onboarding_screen.dart';
import 'package:ride_link/features/vehicles/presentation/screens/vehicles_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final GoRouter appRouter = _createRouter();

const List<NavigationDestination> _passengerDestinations = [
  NavigationDestination(
    icon: Icon(Icons.home_outlined),
    selectedIcon: Icon(Icons.home),
    label: 'Home',
  ),
  NavigationDestination(
    icon: Icon(Icons.route_outlined),
    selectedIcon: Icon(Icons.route),
    label: 'Rides',
  ),
  NavigationDestination(
    icon: Icon(Icons.chat_bubble_outline),
    selectedIcon: Icon(Icons.chat_bubble),
    label: 'Messages',
  ),
  NavigationDestination(
    icon: Icon(Icons.person_outline),
    selectedIcon: Icon(Icons.person),
    label: 'Profile',
  ),
];

const List<NavigationDestination> _driverDestinations = [
  NavigationDestination(
    icon: Icon(Icons.dashboard_outlined),
    selectedIcon: Icon(Icons.dashboard),
    label: 'Dashboard',
  ),
  NavigationDestination(
    icon: Icon(Icons.query_stats_outlined),
    selectedIcon: Icon(Icons.query_stats),
    label: 'Activity',
  ),
  NavigationDestination(
    icon: Icon(Icons.notifications_outlined),
    selectedIcon: Icon(Icons.notifications),
    label: 'Alerts',
  ),
  NavigationDestination(
    icon: Icon(Icons.settings_outlined),
    selectedIcon: Icon(Icons.settings),
    label: 'Settings',
  ),
];

GoRouter _createRouter() {
  final authClient = Supabase.instance.client;
  final roleCache = _RoleCache();

  return GoRouter(
    initialLocation: '/onboarding',
    refreshListenable: _GoRouterRefreshStream(
      authClient.auth.onAuthStateChange,
    ),
    redirect: (context, state) async {
      final isLoggedIn = authClient.auth.currentSession != null;
      final location = state.matchedLocation;
      final isPassengerArea = location.startsWith('/passenger');
      final isDriverArea = location.startsWith('/driver');
      final isAuthFlow = location == '/login' ||
          location == '/signup' ||
          location == '/onboarding' ||
          location == '/forgot-password' ||
          location == '/reset-email-sent';

      if (!isLoggedIn) {
        roleCache.reset();
        if (isPassengerArea || isDriverArea) {
          return '/login';
        }
        return null;
      }

      final role = await roleCache.getRole(authClient);
      final isDriver = _isDriverRole(role);
      final homeLocation = isDriver ? '/driver/dashboard' : '/passenger/home';

      if (isAuthFlow) {
        return homeLocation;
      }

      if (isDriver && isPassengerArea) {
        return '/driver/dashboard';
      }

      if (!isDriver && isDriverArea) {
        return '/passenger/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const Login()),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-email-sent',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return ResetEmailSentScreen(email: email);
        },
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(
          navigationShell: navigationShell,
          destinations: _passengerDestinations,
        ),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/passenger/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/passenger/rides',
              builder: (context, state) => const RidesScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/passenger/messages',
              builder: (context, state) => const MessagesScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/passenger/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ]),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(
          navigationShell: navigationShell,
          destinations: _driverDestinations,
        ),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/driver/dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/driver/activity',
              builder: (context, state) => const ActivityScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/driver/alerts',
              builder: (context, state) => const AlertsScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/driver/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ]),
        ],
      ),
      GoRoute(
        path: '/passenger/cities',
        builder: (context, state) => const CityPickerScreen(
          title: 'Choisir une ville',
        ),
      ),
      GoRoute(
        path: '/passenger/vehicles',
        builder: (context, state) => const VehiclesScreen(),
      ),
    ],
  );
}

class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class _RoleCache {
  String? _cachedRole;
  Future<String>? _inFlight;

  Future<String> getRole(SupabaseClient client) {
    if (_cachedRole != null) {
      return Future.value(_cachedRole);
    }

    if (_inFlight != null) {
      return _inFlight!;
    }

    _inFlight = _loadRole(client);
    return _inFlight!;
  }

  void reset() {
    _cachedRole = null;
    _inFlight = null;
  }

  Future<String> _loadRole(SupabaseClient client) async {
    try {
      final user = client.auth.currentUser;
      if (user == null) {
        _cachedRole = 'PASSENGER';
        return _cachedRole!;
      }

      final data = await client
          .from('users')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      final role = (data?['role'] as String?)?.toUpperCase() ?? 'PASSENGER';
      _cachedRole = role;
      return role;
    } catch (_) {
      _cachedRole = 'PASSENGER';
      return _cachedRole!;
    } finally {
      _inFlight = null;
    }
  }
}

bool _isDriverRole(String role) {
  return role == 'DRIVER' || role == 'BOTH';
}
