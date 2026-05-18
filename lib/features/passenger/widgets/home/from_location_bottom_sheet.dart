import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:ride_link/features/passenger/providers/cities_provider.dart';
import 'package:ride_link/features/passenger/providers/search_ride_notifier.dart';
import 'package:ride_link/features/passenger/service/location_service.dart';

class FromLocationBottomSheet extends ConsumerStatefulWidget {
  const FromLocationBottomSheet({super.key});

  @override
  ConsumerState<FromLocationBottomSheet> createState() =>
      _FromLocationBottomSheetState();
}

class _FromLocationBottomSheetState
    extends ConsumerState<FromLocationBottomSheet> {
  final searchController = TextEditingController();

  String query = "";

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final citiesAsync = ref.watch(moroccoCitiesProvider);

    final filteredCities = citiesAsync.value
            ?.where(
              (city) => city.toLowerCase().contains(
                    query.toLowerCase(),
                  ),
            )
            .toList() ??
        [];

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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Center(
                  child: Text(
                    "Select departure city",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Divider(),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final city = await LocationService.getCurrentCity();

                    if (city != null) {
                      ref.read(searchRideProvider.notifier).setFrom(city);

                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(
                    Icons.my_location_rounded,
                  ),
                  label: const Text(
                    "Use my current location",
                  ),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextField(
                controller: searchController,
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
                  error: (err, _) => Center(
                        child: Text("Failed to load cities"),
                      ),
                  data: (cities) {
                    final filteredCities = cities
                        .where(
                          (city) => city.toLowerCase().contains(
                                query.toLowerCase(),
                              ),
                        )
                        .toList();

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: ListView.separated(
                        itemCount: filteredCities.length,
                        separatorBuilder: (_, __) {
                          return Divider(
                            height: 1,
                            color: colors.outlineVariant,
                          );
                        },
                        itemBuilder: (context, index) {
                          final city = filteredCities[index];

                          return ListTile(
                            leading: const Icon(
                              Icons.location_city,
                            ),
                            title: Text(city),
                            onTap: () {
                              ref
                                  .read(searchRideProvider.notifier)
                                  .setFrom(city);

                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    );
                  }),
            )
          ],
        ),
      ),
    );
  }
}
