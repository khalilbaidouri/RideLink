import 'package:flutter/material.dart';
import 'package:ride_link/features/passenger/widgets/home/greeting.dart';
import 'package:ride_link/features/passenger/widgets/home/popular_routes_chips.dart';
import 'package:ride_link/features/passenger/widgets/home/prominent_search_card.dart';
import 'package:ride_link/features/passenger/widgets/home/recent_rides_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            const _HomeBannerImage(),
            SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 120),
                  Container(
                    padding: const EdgeInsets.only(
                      left: 14,
                      right: 14,
                      top: 20,
                      bottom: 20,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: const Column(
                      spacing: 20,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Greeting(),
                        ProminentSearchCard(),
                        PopularRoutesChips(),
                        RecentRidesList(),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeBannerImage extends StatelessWidget {
  const _HomeBannerImage();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
        ),
        child: Image.asset(
          'lib/assets/images/hero.jpg',
          height: 220,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
