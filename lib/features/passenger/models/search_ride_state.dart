class SearchRideState {
  final String from;
  final String to;
  final DateTime? date;
  final int seats;

  const SearchRideState({
    this.from = "",
    this.to = "",
    this.date,
    this.seats = 1,
  });

  SearchRideState copyWith({
    String? from,
    String? to,
    DateTime? date,
    int? seats,
  }) {
    return SearchRideState(
      from: from ?? this.from,
      to: to ?? this.to,
      date: date ?? this.date,
      seats: seats ?? this.seats,
    );
  }
}
