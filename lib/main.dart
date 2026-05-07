import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'features/auth/login.dart';
import 'features/auth/signup.dart';
import 'features/home/home_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'theme/ride_link_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );
  runApp(const RideLinkApp());
}

class RideLinkApp extends StatelessWidget {
  const RideLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    final lightTheme = RideLinkTheme.light;
    final darkTheme = RideLinkTheme.dark;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RideLink',
      supportedLocales: FLocalizations.supportedLocales,
      localizationsDelegates: const [...FLocalizations.localizationsDelegates],
      theme: lightTheme.toApproximateMaterialTheme(),
      darkTheme: darkTheme.toApproximateMaterialTheme(),
      themeMode: ThemeMode.system,
      builder: (context, child) {
        final fTheme = Theme.of(context).brightness == Brightness.dark
            ? darkTheme
            : lightTheme;
        return FTheme(
          data: fTheme,
          child: FToaster(child: FTooltipGroup(child: child!)),
        );
      },
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/': (context) => const SignupScreen(),
        '/login': (context) => const Login(),
        '/home': (context) => const HomeScreen(),
      },
      initialRoute: '/onboarding',
    );
  }
}
