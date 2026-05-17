import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ride_review_provider.dart';

const _allTags = ['Punctual', 'Safe Driving', 'Great Music', 'Clean Car', 'Friendly', 'Comfortable'];

class TagChipsWidget extends ConsumerWidget {
  const TagChipsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTags = ref.watch(rideReviewProvider).selectedTags;
    final notifier = ref.read(rideReviewProvider.notifier);

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: _allTags.map((tag) {
        final isSelected = selectedTags.contains(tag);
        return GestureDetector(
          onTap: () => notifier.toggleTag(tag),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF1B5E35)
                  : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF1B5E35)
                    : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            child: Text(
              tag,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}