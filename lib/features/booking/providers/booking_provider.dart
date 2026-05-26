import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';

class BookingRequestsNotifier
    extends AsyncNotifier<List<BookingModel>> {
  @override
  Future<List<BookingModel>> build() async {
    return ref.read(bookingServiceProvider).fetchBookingRequests();
  }

  Future<void> accept(String id) async {
  await ref.read(bookingServiceProvider).acceptBooking(id);
  final current = state.valueOrNull ?? [];
  state = AsyncData(
    current.map((b) => b.id == id
        ? b.copyWith(status: BookingStatus.confirmed)
        : b).toList(),
  );
}

Future<void> reject(String id) async {
  await ref.read(bookingServiceProvider).rejectBooking(id);
  final current = state.valueOrNull ?? [];
  state = AsyncData(
    current.map((b) => b.id == id
        ? b.copyWith(status: BookingStatus.cancelled)
        : b).toList(),
  );
}
}

final bookingRequestsProvider =
    AsyncNotifierProvider<BookingRequestsNotifier, List<BookingModel>>(
  BookingRequestsNotifier.new,
);

// Providers filtrés par statut — utiles pour afficher des tabs
final pendingBookingsProvider = Provider<List<BookingModel>>((ref) {
  final list = ref.watch(bookingRequestsProvider).valueOrNull ?? [];
  return list.where((b) => b.status == BookingStatus.pending).toList();
});

final confirmedBookingsProvider = Provider<List<BookingModel>>((ref) {
  final list = ref.watch(bookingRequestsProvider).valueOrNull ?? [];
  return list.where((b) => b.status == BookingStatus.confirmed).toList();
});

final cancelledBookingsProvider = Provider<List<BookingModel>>((ref) {
  final list = ref.watch(bookingRequestsProvider).valueOrNull ?? [];
  return list.where((b) => b.status == BookingStatus.cancelled).toList();
});