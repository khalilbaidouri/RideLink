import 'package:flutter/material.dart';

class SeatsCard extends StatelessWidget {
  static const Color _primary = Color(0xFF1E5C2E);

  final int seats;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const SeatsCard({
    super.key,
    required this.seats,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF4ED),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Seats available',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A)),
                ),
                const SizedBox(height: 4),
                Text(
                  'How many passengers can\nyou take?',
                  style:
                      TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Row(
            children: [
              SeatsButton(
                icon: Icons.remove,
                onTap: onDecrement,
                filled: false,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '$seats',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w800),
                ),
              ),
              SeatsButton(
                icon: Icons.add,
                onTap: onIncrement,
                filled: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SeatsButton extends StatelessWidget {
  static const Color _primary = Color(0xFF1E5C2E);

  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  const SeatsButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.filled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: filled ? _primary : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 4,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Icon(icon,
            color: filled ? Colors.white : Colors.grey.shade700, size: 20),
      ),
    );
  }
}