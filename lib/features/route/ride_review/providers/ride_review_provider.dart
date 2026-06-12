import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/ride_review_provider.dart';
import '../widgets/star_rating_widget.dart';
import '../widgets/tag_chips_widget.dart';

class RideReviewState {
  final int selectedRating; // 1-5
  final List<String> selectedTags;
  final String comment;
  final bool isSubmitting;
  final String? error;
  final bool submitted;

  const RideReviewState({
    this.selectedRating = 0,
    this.selectedTags = const [],
    this.comment = '',
    this.isSubmitting = false,
    this.error,
    this.submitted = false,
  });

  RideReviewState copyWith({
    int? selectedRating,
    List<String>? selectedTags,
    String? comment,
    bool? isSubmitting,
    String? error,
    bool? submitted,
  }) {
    return RideReviewState(
      selectedRating: selectedRating ?? this.selectedRating,
      selectedTags: selectedTags ?? this.selectedTags,
      comment: comment ?? this.comment,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      submitted: submitted ?? this.submitted,
    );
  }
}

class RideReviewNotifier extends StateNotifier<RideReviewState> {
  RideReviewNotifier() : super(const RideReviewState());

  void setRating(int rating) {
    state = state.copyWith(selectedRating: rating);
  }

  void toggleTag(String tag) {
    final tags = List<String>.from(state.selectedTags);
    if (tags.contains(tag)) {
      tags.remove(tag);
    } else {
      tags.add(tag);
    }
    state = state.copyWith(selectedTags: tags);
  }

  void setComment(String comment) {
    state = state.copyWith(comment: comment);
  }

  Future<void> submitReview({
    required int rideId,
    required String reviewedUserId,
  }) async {
    if (state.selectedRating == 0) {
      state = state.copyWith(error: 'Please select a rating.');
      return;
    }

    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final client = Supabase.instance.client;
      final currentUser = client.auth.currentUser;
      if (currentUser == null) throw Exception('Not authenticated');

      await client.from('reviews').insert({
        'ride_id': rideId,
        'reviewer_id': currentUser.id,
        'reviewed_user_id': reviewedUserId,
        'rating': state.selectedRating.toDouble(),
        'comment': state.comment.isEmpty ? null : state.comment,
      });

      // Update the reviewed user's rating & total_reviews
      final existing = await client
          .from('reviews')
          .select('rating')
          .eq('reviewed_user_id', reviewedUserId);

      final ratings =
          (existing as List).map((e) => (e['rating'] as num).toDouble()).toList();
      final avg = ratings.reduce((a, b) => a + b) / ratings.length;

      await client.from('users').update({
        'rating': avg,
        'total_reviews': ratings.length,
      }).eq('id', reviewedUserId);

      state = state.copyWith(isSubmitting: false, submitted: true);
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'Failed to submit review. Please try again.',
      );
    }
  }
}

final rideReviewProvider =
    StateNotifierProvider.autoDispose<RideReviewNotifier, RideReviewState>(
  (ref) => RideReviewNotifier(),
);