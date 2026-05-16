import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ride_link/features/passenger/models/search_ride_state.dart';

class SearchRideNotifier extends StateNotifier<SearchRideState> {
  SearchRideNotifier()
      : super(
          SearchRideState(
            date: DateTime.now(),
          ),
        );

  void setFrom(String from) {
    state = state.copyWith(from: from);
  }

  void setTo(String to) {
    state = state.copyWith(to: to);
  }

  void setFromTo({required String from, required String to}) {
    state = state.copyWith(from: from, to: to);
  }

  void setDate(DateTime date) {
    state = state.copyWith(date: date);
  }

  void setSeats(int seats) {
    state = state.copyWith(seats: seats);
  }

  void reset() {
    state = const SearchRideState();
  }
}

final searchRideProvider =
    StateNotifierProvider<SearchRideNotifier, SearchRideState>(
  (ref) => SearchRideNotifier(),
);
