import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ride_link/features/passenger/providers/search_ride_notifier.dart';

class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SearchAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AppBar(
      elevation: 0,
      shadowColor: colors.shadow,
      shape: Border(
        bottom: BorderSide(
          color: colors.outlineVariant,
          width: 1,
        ),
      ),
      title: const SearchAppBarTitle(),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(65);
}

class SearchAppBarTitle extends ConsumerWidget {
  const SearchAppBarTitle({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final search = ref.watch(searchRideProvider);
    final date =
        search.date == null ? '' : DateFormat('d MMM').format(search.date!);
    final seatLabel = search.seats == 1 ? '1 seat' : '${search.seats} seats';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${search.from} -> ${search.to}",
          style: TextStyle(color: primaryColor),
        ),
        Text(
          date.isEmpty ? seatLabel : '$date | $seatLabel',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
