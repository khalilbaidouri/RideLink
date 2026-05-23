import 'package:flutter/material.dart';
import 'package:ride_link/features/passenger/models/ride_details.dart';
import 'package:ride_link/features/passenger/providers/ride_booking_status_provider.dart';

class RideDetailsBottomBar extends StatelessWidget {
  const RideDetailsBottomBar({
    super.key,
    required this.details,
    required this.isBooking,
    required this.isChecking,
    required this.bookingStatus,
    required this.onBook,
  });

  final RideDetails details;
  final bool isBooking;
  final bool isChecking;
  final BookingStatus bookingStatus;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final isPending = bookingStatus == BookingStatus.pending;
    final isConfirmed = bookingStatus == BookingStatus.confirmed;
    final canBook = !isBooking && !isChecking && !isPending && !isConfirmed;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(
            top: BorderSide(color: colors.outlineVariant),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total Price',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${details.price.toStringAsFixed(0)} MAD',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
            ),
            if (isPending)
              OutlinedButton(
                onPressed: null,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                ),
                child: const Text('Request Pending'),
              )
            else if (isConfirmed)
              OutlinedButton(
                onPressed: null,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                ),
                child: const Text('Booked'),
              )
            else
              ElevatedButton(
                onPressed: canBook ? onBook : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.secondary,
                  foregroundColor: colors.onSecondary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                ),
                child: isBooking
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.onSecondary,
                        ),
                      )
                    : Text(isChecking ? 'Checking...' : 'Book This Ride'),
              ),
          ],
        ),
      ),
    );
  }
}
