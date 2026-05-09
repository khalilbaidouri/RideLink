import 'package:flutter/material.dart';
import '../../domain/entities/city.dart';

/// Tuile affichant une ville avec sa région et la distance GPS optionnelle.
/// Réutilisée dans [CityPickerScreen] et les champs Départ/Arrivée de M4.
class CityTile extends StatelessWidget {
  final City city;

  /// Distance en km depuis la position de l'utilisateur (null = non affichée).
  final double? distanceKm;

  /// Callback déclenché au tap.
  final VoidCallback? onTap;

  /// Affiche un indicateur "Position actuelle" si vrai.
  final bool isCurrentLocation;

  const CityTile({
    super.key,
    required this.city,
    this.distanceKm,
    this.onTap,
    this.isCurrentLocation = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant, width: 0.5),
        ),
        child: Row(
          children: [
            // Icône
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: cs.primaryContainer.withOpacity(0.25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.location_on_outlined,
                  color: cs.primary, size: 20),
            ),
            const SizedBox(width: 10),

            // Nom + région
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(city.name, style: tt.labelLarge),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          city.region,
                          style: tt.labelMedium
                              ?.copyWith(color: cs.onSurfaceVariant),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isCurrentLocation) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: cs.primaryContainer.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Position actuelle',
                            style: tt.labelMedium?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Distance
            if (distanceKm != null)
              Text(
                distanceKm! < 1
                    ? '0 km'
                    : '${distanceKm!.round()} km',
                style: tt.labelMedium?.copyWith(
                  color: isCurrentLocation ? cs.onSurfaceVariant : cs.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }
}