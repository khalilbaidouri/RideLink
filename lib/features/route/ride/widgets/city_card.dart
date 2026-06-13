import 'package:flutter/material.dart';
import '../providers/route_providers.dart';

class CityCard extends StatelessWidget {
  static const Color _primary = Color(0xFF1E5C2E);
  static const Color _hint = Color(0xFF9E9E9E);

  final City? departureCity;
  final City? destinationCity;
  final VoidCallback onPickDeparture;
  final VoidCallback onPickDestination;
  final VoidCallback onSwap;

  const CityCard({
    super.key,
    required this.departureCity,
    required this.destinationCity,
    required this.onPickDeparture,
    required this.onPickDestination,
    required this.onSwap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('From',
                  style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              CityField(
                icon: Icons.location_on_outlined,
                iconColor: _primary,
                value: departureCity?.name,
                placeholder: 'Enter departure city',
                onTap: onPickDeparture,
              ),
              const SizedBox(height: 14),
              Text('To',
                  style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              CityField(
                icon: Icons.navigation_outlined,
                iconColor: Colors.grey.shade600,
                value: destinationCity?.name,
                placeholder: 'Enter destination city',
                onTap: onPickDestination,
              ),
            ],
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: GestureDetector(
                onTap: onSwap,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade200, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Icon(Icons.swap_vert_rounded, color: _primary, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CityField extends StatelessWidget {
  static const Color _hint = Color(0xFF9E9E9E);

  final IconData icon;
  final Color iconColor;
  final String? value;
  final String placeholder;
  final VoidCallback onTap;

  const CityField({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.placeholder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F7F3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value ?? placeholder,
                style: TextStyle(
                  color: value != null ? const Color(0xFF1A1A1A) : _hint,
                  fontSize: 15,
                  fontWeight:
                      value != null ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}