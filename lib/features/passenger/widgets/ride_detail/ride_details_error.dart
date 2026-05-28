import 'package:flutter/material.dart';

class RideDetailsError extends StatelessWidget {
  const RideDetailsError({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Text(
        'Unable to load ride details right now.',
        style: TextStyle(
          fontSize: 12,
          color: colors.onSurfaceVariant,
        ),
      ),
    );
  }
}
