import 'package:flutter/material.dart';
import 'package:ride_link/features/auth/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'features/auth/signup.dart';
import 'features/home/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Supabase.initialize(
    url: dotenv.env['YOUR_SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['YOUR_ANON_KEY'] ?? '',
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RideLink',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          primary: const Color(0xFF2E7D32),
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F7F2),
        useMaterial3: true,
      ),
      routes: {
        '/': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const Login(),
      },
      initialRoute: '/login',
      // home: const SignupScreen(),
    );
  }
}