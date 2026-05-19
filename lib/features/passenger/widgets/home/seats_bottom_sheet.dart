import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ride_link/features/passenger/providers/search_ride_notifier.dart';

class SeatsBottomSheet extends ConsumerWidget {
  const SeatsBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;

    final search = ref.watch(searchRideProvider);

    final seatsOptions = [1, 2, 3, 4, 5, 6];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: colors.outlineVariant,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Select seats",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const SizedBox(height: 12),
            Divider(),
            const SizedBox(height: 12),
            ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 8),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: seatsOptions.length,
              separatorBuilder: (_, __) {
                return Divider(
                  height: 1,
                  color: colors.outlineVariant,
                );
              },
              itemBuilder: (context, index) {
                final seats = seatsOptions[index];

                final isSelected = search.seats == seats;

                return ListTile(
                  leading: const Icon(
                    Icons.people_alt_outlined,
                  ),
                  title: Text("$seats Seats"),
                  trailing: isSelected
                      ? Icon(
                          Icons.check,
                          color: colors.primary,
                        )
                      : null,
                  onTap: () {
                    ref.read(searchRideProvider.notifier).setSeats(seats);

                    Navigator.pop(context);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
