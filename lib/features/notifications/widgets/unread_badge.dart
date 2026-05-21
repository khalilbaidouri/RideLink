import 'package:flutter/material.dart';

class UnreadBadge extends StatelessWidget {
  final int count;
  const UnreadBadge({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFDCEFE3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          fontFamily: 'PlusJakartaSans',
          color: Color(0xFF005127),
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}