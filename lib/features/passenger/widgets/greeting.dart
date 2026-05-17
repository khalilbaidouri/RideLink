import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ride_link/features/passenger/providers/auth_user_provider.dart';

class Greeting extends StatelessWidget {
  const Greeting({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              "Good morning, ",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 24,
              ),
            ),
            const UserName(),
            const SizedBox(width: 6),
            Icon(
              Icons.waving_hand,
              color: primaryColor,
            )
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          "Where are you heading today?",
          style: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 16,
          ),
        )
      ],
    );
  }
}

class UserName extends ConsumerWidget {
  const UserName({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      data: (user) {
        return Text(
          user?.fullName ?? "User",
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
        );
      },
      error: (_, __) {
        return const Text(
          "User",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
        );
      },
      loading: () {
        return Container(
          width: 90,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      },
    );
  }
}
