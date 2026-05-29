import 'package:flutter/material.dart';

class BookingEmptyState extends StatelessWidget {
  final String message;
  const BookingEmptyState({
    super.key,
    this.message = 'No booking requests yet.',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFDCEFE3),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.inbox_outlined,
                size: 44,
                color: Color(0xFF005127),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No requests here',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF181D18),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}