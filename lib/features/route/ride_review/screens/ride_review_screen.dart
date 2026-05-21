import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/ride_review_provider.dart';
import '../widgets/star_rating_widget.dart';
import '../widgets/tag_chips_widget.dart';

class RideReviewScreen extends ConsumerWidget {
  final int rideId;
  final String reviewedUserId;
  final String reviewedUserName;
  final String? reviewedUserAvatarUrl;
  final String departureCity;
  final String destinationCity;
  final String rideDate; // e.g. "12 Apr"

  const RideReviewScreen({
    super.key,
    required this.rideId,
    required this.reviewedUserId,
    required this.reviewedUserName,
    this.reviewedUserAvatarUrl,
    required this.departureCity,
    required this.destinationCity,
    required this.rideDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(rideReviewProvider);
    final notifier = ref.read(rideReviewProvider.notifier);

    // Listen for submission success
    ref.listen<RideReviewState>(rideReviewProvider, (_, next) {
      if (next.submitted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted!')),
        );
        context.pop();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F0),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(Icons.close, size: 24),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Ride Bookings',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E35),
                        ),
                      ),
                    ),
                  ),
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: reviewedUserAvatarUrl != null
                        ? NetworkImage(reviewedUserAvatarUrl!)
                        : null,
                    child: reviewedUserAvatarUrl == null
                        ? const Icon(Icons.person, size: 18)
                        : null,
                  ),
                ],
              ),
            ),

            // ── Scrollable body ──────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),

                    // Title
                    const Text(
                      'How was your ride?',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$departureCity → $destinationCity · $rideDate',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Avatar
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFFFB800),
                              width: 3,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 48,
                            backgroundImage: reviewedUserAvatarUrl != null
                                ? NetworkImage(reviewedUserAvatarUrl!)
                                : null,
                            backgroundColor: Colors.grey.shade200,
                            child: reviewedUserAvatarUrl == null
                                ? const Icon(Icons.person, size: 40)
                                : null,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.verified,
                            color: Color(0xFF1B5E35),
                            size: 20,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    Text(
                      reviewedUserName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Rating + Tags card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const StarRatingWidget(),
                          if (state.error != null &&
                              state.selectedRating == 0) ...[
                            const SizedBox(height: 8),
                            Text(
                              state.error!,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 12),
                            ),
                          ],
                          const SizedBox(height: 20),
                          const TagChipsWidget(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Comment
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Write your experience (Optional)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextField(
                        maxLines: 4,
                        onChanged: notifier.setComment,
                        decoration: InputDecoration(
                          hintText:
                              '${reviewedUserName.split(' ').first} was very polite and the car was spotless...',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: state.isSubmitting
                            ? null
                            : () => notifier.submitReview(
                                  rideId: rideId,
                                  reviewedUserId: reviewedUserId,
                                ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B5E35),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: state.isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Submit Review',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ── Bottom NavBar (passenger style, matching Image 2) ────
      bottomNavigationBar: _PassengerBottomNav(),
    );
  }
}

class _PassengerBottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // "My Rides" is active since we come from rides
    const activeIndex = 1;
    final items = [
      (Icons.search, 'Home'),
      (Icons.directions_car, 'Rides'),
      (Icons.chat_bubble_outline, 'Messages'),
      (Icons.person_outline, 'Profile'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final isActive = i == activeIndex;
              return GestureDetector(
                onTap: () {
                  if (i == 0) context.go('/passenger/home');
                  if (i == 1) context.go('/passenger/rides');
                  if (i == 2) context.go('/passenger/messages');
                  if (i == 3) context.go('/passenger/profile');
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFFFFB800)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        items[i].$1,
                        color: isActive
                            ? Colors.white
                            : const Color(0xFF6B6B6B),
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      items[i].$2,
                      style: TextStyle(
                        fontSize: 11,
                        color: isActive
                            ? const Color(0xFF1A1A1A)
                            : const Color(0xFF6B6B6B),
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}