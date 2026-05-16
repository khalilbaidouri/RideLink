import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ride_link/features/passenger/providers/search_ride_notifier.dart';
import 'package:ride_link/features/passenger/widgets/date_bottom_sheet.dart';
import 'package:ride_link/features/passenger/widgets/from_location_bottom_sheet.dart';
import 'package:ride_link/features/passenger/widgets/search_field_card.dart';
import 'package:ride_link/features/passenger/widgets/seats_bottom_sheet.dart';
import 'package:ride_link/features/passenger/widgets/to_location_bottom_sheet.dart';

class ProminentSearchCard extends ConsumerWidget {
  const ProminentSearchCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;

    final search = ref.watch(searchRideProvider);

    final formattedDate = search.date == null
        ? "Today"
        : DateFormat('dd MMM').format(search.date!);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Builder(
            builder: (context) {
              return SearchFieldCard(
                icon: Icons.my_location_rounded,
                label: "From",
                value: search.from.isEmpty ? "Current Location" : search.from,
                iconColor: colors.primary,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    builder: (_) {
                      return const FromLocationBottomSheet();
                    },
                  );
                },
              );
            },
          ),
          Container(
            margin: const EdgeInsets.only(left: 12),
            child: SizedBox(
              height: 16,
              child: VerticalDivider(
                thickness: 3,
                width: 32,
                color: colors.outlineVariant,
              ),
            ),
          ),
          SearchFieldCard(
            icon: Icons.location_on_outlined,
            label: "To",
            value: search.to.isEmpty ? "Enter destination" : search.to,
            iconColor: colors.secondary,
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                builder: (_) {
                  return const ToLocationBottomSheet();
                },
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SearchFieldCard(
                  icon: Icons.calendar_month_sharp,
                  label: "Date",
                  value: formattedDate,
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      builder: (_) {
                        return const DateBottomSheet();
                      },
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SearchFieldCard(
                  icon: Icons.people_alt_outlined,
                  label: "Seats",
                  value: search.seats.toString(),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      builder: (_) {
                        return const SeatsBottomSheet();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                final search = ref.watch(searchRideProvider);

                final isValid = search.from.isNotEmpty &&
                    search.to.isNotEmpty &&
                    search.date != null;

                if (!isValid) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please fill From, To and Date"),
                    ),
                  );
                  return;
                }

                context.push('/passenger/search');
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Find Rides"),
            ),
          ),
        ],
      ),
    );
  }
}
