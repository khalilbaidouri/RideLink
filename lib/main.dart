import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ride_link/features/route/route_details_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/auth/forgot_password.dart';
import 'features/auth/login.dart';
import 'features/auth/reset_email_sent.dart';
import 'features/auth/signup.dart';
import 'features/home/home_screen.dart';
import 'features/home/messages_screen.dart';
import 'features/home/profile_screen.dart';
import 'features/home/rides_screen.dart';
import 'features/navigation/app_shell.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/driver/activity_screen.dart';
import 'features/driver/alerts_screen.dart';
import 'features/driver/dashboard_screen.dart';
import 'features/driver/settings_screen.dart';
import 'theme/ride_link_theme.dart';
import 'features/cities/presentation/screens/city_picker_screen.dart';
import 'features/vehicles/presentation/screens/vehicles_screen.dart';
import 'features/notifications/screens/notifications_screen.dart';

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
    // ← placeholder central pour le FAB
    icon: SizedBox.shrink(),
    label: '',
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );
  runApp(ProviderScope(child: RideLinkApp()));
}

class RideLinkApp extends StatelessWidget {
  RideLinkApp({super.key});

  late final GoRouter _router = _createRouter();

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
        GoRoute(
          path: '/login',
          builder: (context, state) => const Login(),
        ),GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationsScreen(),
        ),
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

        // ─── PASSENGER SHELL ───────────────────────────────────────────
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

        // ─── DRIVER SHELL ──────────────────────────────────────────────
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) => AppShell(
            navigationShell: navigationShell,
            destinations: _driverDestinations,
            showAddButton: true, // ← AJOUT
            onAddButtonPressed: () => // ← AJOUT
                context.push('/driver/route-details'), // ← AJOUT
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
              // ← placeholder branch pour index 2
              GoRoute(
                path: '/driver/new-route',
                builder: (context, state) => const RouteDetailsScreen(),
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

        // ─── ROUTES STANDALONE ─────────────────────────────────────────
        GoRoute(
          path: '/driver/route-details', // ← AJOUT
          builder: (context, state) => // ← AJOUT
              const RouteDetailsScreen(), // ← AJOUT
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'RideLink',
      theme: RideLinkTheme.light,
      themeMode: ThemeMode.light,
      routerConfig: _router,
    );
  }
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
