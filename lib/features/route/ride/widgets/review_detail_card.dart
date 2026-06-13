import 'package:flutter/material.dart';

// ── Row wrapper ──────────────────────────────
class DetailRow extends StatelessWidget {
  final Widget child;
  const DetailRow({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: child,
      );
}

// ── Divider ──────────────────────────────────
class ReviewDivider extends StatelessWidget {
  const ReviewDivider({super.key});

  @override
  Widget build(BuildContext context) => Divider(
        height: 1,
        thickness: 1,
        color: Colors.grey.shade100,
        indent: 16,
        endIndent: 16,
      );
}

// ── Label ────────────────────────────────────
class ReviewLabel extends StatelessWidget {
  final String text;
  const ReviewLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Text(
          text,
          style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade400,
              letterSpacing: 0.8),
        ),
      );
}

// ── Edit button ──────────────────────────────
class EditButton extends StatelessWidget {
  final VoidCallback onTap;
  const EditButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: const Text(
          'Edit',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E5C2E),
            decoration: TextDecoration.underline,
            decorationColor: Color(0xFF1E5C2E),
          ),
        ),
      );
}

// ── Tag chip ─────────────────────────────────
class TagChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const TagChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.grey.shade600),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700)),
          ],
        ),
      );
}