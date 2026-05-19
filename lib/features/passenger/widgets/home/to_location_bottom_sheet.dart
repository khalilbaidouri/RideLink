import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ride_link/features/passenger/providers/cities_provider.dart';
import 'package:ride_link/features/passenger/providers/search_ride_notifier.dart';

class ToLocationBottomSheet extends ConsumerStatefulWidget {
  const ToLocationBottomSheet({super.key});

  @override
  ConsumerState<ToLocationBottomSheet> createState() =>
      _ToLocationBottomSheetState();
}

class _ToLocationBottomSheetState extends ConsumerState<ToLocationBottomSheet> {
  String query = "";

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final search = ref.watch(searchRideProvider);
    final citiesAsync = ref.watch(moroccoCitiesProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
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
            const Text(
              "Select destination city",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    query = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Search city",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: colors.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: citiesAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (e, _) => const Center(
                  child: Text("Error loading cities"),
                ),
                data: (cities) {
                  final filteredCities = cities.where((city) {
                    final matchQuery =
                        city.toLowerCase().contains(query.toLowerCase());

                    final notSameAsFrom = city != search.from; // 👈 important

                    return matchQuery && notSameAsFrom;
                  }).toList();

                  return ListView.separated(
                    itemCount: filteredCities.length,
                    separatorBuilder: (_, __) => Divider(
                      color: colors.outlineVariant,
                    ),
                    itemBuilder: (context, index) {
                      final city = filteredCities[index];

                      return ListTile(
                        leading: const Icon(Icons.location_city),
                        title: Text(city),
                        onTap: () {
                          ref.read(searchRideProvider.notifier).setTo(city);

                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
