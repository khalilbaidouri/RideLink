import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ride_link/features/passenger/models/ride_details.dart';
import 'package:ride_link/features/passenger/providers/ride_booking_status_provider.dart';
import 'package:ride_link/features/passenger/providers/ride_details_provider.dart';
import 'package:ride_link/features/passenger/widgets/ride_detail/ride_details_bottom_bar.dart';
import 'package:ride_link/features/passenger/widgets/ride_detail/ride_details_error.dart';
import 'package:ride_link/features/passenger/widgets/ride_detail/ride_details_layout.dart';
import 'package:ride_link/features/passenger/widgets/ride_detail/ride_details_sheet.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RideDetailsScreen extends ConsumerStatefulWidget {
  const RideDetailsScreen({
    super.key,
    required this.rideId,
  });

  final String rideId;

  @override
  ConsumerState<RideDetailsScreen> createState() => _RideDetailsScreenState();
}

class _RideDetailsScreenState extends ConsumerState<RideDetailsScreen> {
  static const _ignoreMoveAfterOpen = Duration(milliseconds: 500);
  bool _showSheet = false;
  bool _mapInteracting = false;
  bool _isBooking = false;
  DateTime _lastSheetOpen = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    _showSheet = true;
    _lastSheetOpen = DateTime.now();
  }

  void _handleMapInteractionStart() {
    final now = DateTime.now();
    if (now.difference(_lastSheetOpen) < _ignoreMoveAfterOpen) {
      return;
    }

    _mapInteracting = true;
    if (_showSheet) {
      setState(() => _showSheet = false);
    }
  }

  void _handleMapInteractionEnd() {
    if (!_mapInteracting) return;
    _mapInteracting = false;
    setState(() {
      _showSheet = true;
      _lastSheetOpen = DateTime.now();
    });
  }

  Future<void> _bookRide(RideDetails details) async {
    if (_isBooking) return;

    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to book a ride.')),
        );
      }
      return;
    }

    setState(() => _isBooking = true);
    try {
      await client.from('bookings').insert({
        'ride_id': int.tryParse(details.id) ?? details.id,
        'passenger_id': user.id,
        'seats_reserved': 1,
        'total_price': details.price,
        'status': 'pending',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking requested.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking failed: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isBooking = false);
        ref.invalidate(rideBookingStatusProvider(details.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailsAsync = ref.watch(rideDetailsProvider(widget.rideId));
    final bookingStatusAsync =
        ref.watch(rideBookingStatusProvider(widget.rideId));

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: detailsAsync.when(
        data: (details) => RideDetailsLayout(
          details: details,
          showSheet: _showSheet,
          onMapInteractionStart: _handleMapInteractionStart,
          onMapInteractionEnd: _handleMapInteractionEnd,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const RideDetailsError(),
      ),
      // Sheet + bottom bar both live here — fully outside the map Stack,
      // so zero gesture leakage is possible by design.
      bottomNavigationBar: detailsAsync.maybeWhen(
        data: (details) => _showSheet
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RideDetailsSheet(details: details),
                  RideDetailsBottomBar(
                    details: details,
                    isBooking: _isBooking,
                    isChecking: bookingStatusAsync.isLoading,
                    bookingStatus:
                        bookingStatusAsync.value ?? BookingStatus.none,
                    onBook: () => _bookRide(details),
                  ),
                ],
              )
            : null,
        orElse: () => null,
      ),
    );
  }
}
