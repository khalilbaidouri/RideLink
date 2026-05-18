import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ride_link/features/passenger/providers/popular_routes_provider.dart';
import 'package:ride_link/features/passenger/providers/search_ride_notifier.dart';

class PopularRoutesChips extends ConsumerWidget {
  const PopularRoutesChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routesAsync = ref.watch(popularRoutesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Popular Routes',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        routesAsync.when(
          data: (routes) {
            if (routes.isEmpty) {
              return const SizedBox(
                height: 32,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'No routes yet',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ),
              );
            }

            final colors = Theme.of(context).colorScheme;

            return SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: routes.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final route = routes[index];

                  return ActionChip(
                    onPressed: () {
                      ref.read(searchRideProvider.notifier).setFromTo(
                            from: route.fromName,
                            to: route.toName,
                          );
                      context.push('/passenger/search');
                    },
                    label: Text(
                      route.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
                    ),
                    backgroundColor: colors.surfaceContainerHighest,
                    side: BorderSide(
                      color: colors.outlineVariant,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                    ),
                    labelPadding: const EdgeInsets.symmetric(
                      horizontal: 6,
                    ),
                    visualDensity: VisualDensity.compact,
                  );
                },
              ),
            );
          },
          loading: () => const SizedBox(
            height: 32,
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            ),
          ),
          error: (_, __) => const SizedBox(
            height: 32,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Error loading routes',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
