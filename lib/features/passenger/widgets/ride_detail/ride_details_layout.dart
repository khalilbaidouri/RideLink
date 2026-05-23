import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ride_link/features/passenger/models/ride_details.dart';
import 'package:ride_link/features/passenger/widgets/ride_detail/ride_details_map.dart';
import 'package:ride_link/features/passenger/widgets/ride_detail/ride_details_widgets.dart';

class RideDetailsLayout extends StatelessWidget {
  const RideDetailsLayout({
    super.key,
    required this.details,
    required this.showSheet,
    required this.onMapInteractionStart,
    required this.onMapInteractionEnd,
  });

  final RideDetails details;
  final bool showSheet;
  final VoidCallback onMapInteractionStart;
  final VoidCallback onMapInteractionEnd;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return Stack(
      children: [
        Positioned.fill(
          child: RideDetailsMap(
            details: details,
            disableGestures: showSheet,
            onInteractionStart: onMapInteractionStart,
            onInteractionEnd: onMapInteractionEnd,
          ),
        ),
        Positioned(
          left: 16,
          top: media.padding.top + 12,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: showSheet ? 1.0 : 0.0,
            child: IgnorePointer(
              ignoring: !showSheet,
              child: FloatingIconButton(
                icon: Icons.arrow_back,
                onPressed: () => context.pop(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
