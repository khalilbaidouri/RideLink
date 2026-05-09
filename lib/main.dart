import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ← AJOUT
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
import 'theme/ride_link_theme.dart';
import 'features/cities/presentation/screens/city_picker_screen.dart';   // ← AJOUT
import 'features/vehicles/presentation/screens/vehicles_screen.dart';     // ← AJOUT

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );
  runApp(ProviderScope(child: RideLinkApp())); // ← MODIFIÉ
}

class RideLinkApp extends StatelessWidget {
  RideLinkApp({super.key});

  late final GoRouter _router = _createRouter();

  GoRouter _createRouter() {
    final authClient = Supabase.instance.client;

    return GoRouter(
      initialLocation: '/onboarding',
      refreshListenable: _GoRouterRefreshStream(
        authClient.auth.onAuthStateChange,
      ),
      redirect: (context, state) {
        final isLoggedIn = authClient.auth.currentSession != null;
        final location = state.matchedLocation;
        final isAuthFlow =
          location == '/login' ||
          location == '/signup' ||
          location == '/onboarding' ||
          location == '/forgot-password' ||
          location == '/reset-email-sent';

        if (!isLoggedIn) {
          if (location.startsWith('/app')) {
            return '/login';
          }
          return null;
        }

        if (isAuthFlow) {
          return '/app/home';
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
          builder: (context, state, navigationShell) =>
              AppShell(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/app/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/app/rides',
                builder: (context, state) => const RidesScreen(),
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/app/messages',
                builder: (context, state) => const MessagesScreen(),
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/app/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ]),
          ],
        ),
        GoRoute(                                                           // ← AJOUT
          path: '/app/cities',                                             // ← AJOUT
          builder: (context, state) => const CityPickerScreen(            // ← AJOUT
            title: 'Choisir une ville',                                   // ← AJOUT
          ),                                                               // ← AJOUT
        ),                                                                 // ← AJOUT
        GoRoute(                                                           // ← AJOUT
          path: '/app/vehicles',                                           // ← AJOUT
          builder: (context, state) => const VehiclesScreen(),            // ← AJOUT
        ),                                                                 // ← AJOUT
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