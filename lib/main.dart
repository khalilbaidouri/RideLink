import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://oljabqexykgoudggajsm.supabase.co',
    anonKey: 'sb_publishable_dHQil9sz0JIq35pJ9-Hbzw_noCOhHO_',
  );
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Demo'),
        ),
        body: const Center(
          child: Text('Hello, World!'),
        ),
      ),  
    );
  }
}