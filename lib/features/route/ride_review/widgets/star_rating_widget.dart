import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ride_review_provider.dart';

const _labels = ['Terrible', 'Bad', 'Okay', 'Good', 'Excellent'];

class StarRatingWidget extends ConsumerWidget {
  const StarRatingWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rating = ref.watch(rideReviewProvider).selectedRating;
    final notifier = ref.read(rideReviewProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        final isSelected = starIndex <= rating;
        return GestureDetector(
          onTap: () => notifier.setRating(starIndex),
          child: Column(
            children: [
              Icon(
                isSelected ? Icons.star : Icons.star_border,
                color: isSelected ? const Color(0xFFFFB800) : Colors.grey.shade400,
                size: 36,
              ),
              const SizedBox(height: 4),
              Text(
                _labels[index],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? const Color(0xFF1A1A1A)
                      : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}