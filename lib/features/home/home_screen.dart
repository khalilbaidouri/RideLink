import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RideLink'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            context.push(
              '/passenger/review',
              extra: {
                'rideId': 1,
                'reviewedUserId': 'test-uuid',
                'reviewedUserName': 'khaliiiiiil',
                'reviewedUserAvatarUrl':
                    'https://www.baidouri.site/assets/profile-BAKGZndA.jpg',
                'departureCity': 'Casa',
                'destinationCity': 'Rabat',
                'rideDate': '12 Apr',
              },
            );
          },
          child: const Text('Test Review Screen'),
        ),
      ),
    );
  }
}
