import 'package:flutter/material.dart';
import '../../domain/entities/vehicle.dart';

/// Carte affichant un véhicule avec ses métadonnées et actions optionnelles.
/// Utilisée dans [VehiclesScreen] et le sélecteur de M4.
class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSetDefault;

  /// Mode compact : masque les boutons d'action (pour M4).
  final bool compact;

  const VehicleCard({
    super.key,
    required this.vehicle,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onSetDefault,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: vehicle.isDefault
                ? cs.primary.withValues(alpha: 0.5)
                : cs.outlineVariant,
            width: vehicle.isDefault ? 1.5 : 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- En-tête --------------------------------------------------
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_categoryIcon(vehicle.category),
                      color: cs.primary, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${vehicle.brand} ${vehicle.model}',
                          style: tt.labelLarge),
                      Text(vehicle.licensePlate,
                          style: tt.labelMedium
                              ?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
                if (vehicle.isDefault)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: cs.secondaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Par défaut',
                      style: tt.labelMedium?.copyWith(
                        color: cs.onSecondaryContainer,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // ---- Tags -----------------------------------------------------
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _Tag(
                  icon: Icons.airline_seat_recline_normal_outlined,
                  label: '${vehicle.availableSeats} places passagers',
                  highlight: true,
                  context: context,
                ),
                _Tag(
                  label: _categoryLabel(vehicle.category),
                  context: context,
                ),
                if (vehicle.color != null)
                  _Tag(label: vehicle.color!, context: context),
                if (vehicle.year != null)
                  _Tag(label: '${vehicle.year}', context: context),
              ],
            ),

            // ---- Actions --------------------------------------------------
            if (!compact && (onEdit != null || onDelete != null || onSetDefault != null)) ...[
              const SizedBox(height: 10),
              Divider(color: cs.outlineVariant, height: 1),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!vehicle.isDefault && onSetDefault != null)
                    _ActionButton(
                      label: 'Définir par défaut',
                      icon: Icons.star_border_rounded,
                      onTap: onSetDefault!,
                      context: context,
                    ),
                  if (onEdit != null) ...[
                    const SizedBox(width: 4),
                    _ActionButton(
                      label: 'Modifier',
                      icon: Icons.edit_outlined,
                      onTap: onEdit!,
                      context: context,
                    ),
                  ],
                  if (onDelete != null) ...[
                    const SizedBox(width: 4),
                    _ActionButton(
                      label: 'Supprimer',
                      icon: Icons.delete_outline_rounded,
                      onTap: onDelete!,
                      context: context,
                      danger: true,
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _categoryIcon(VehicleCategory cat) {
    return switch (cat) {
      VehicleCategory.suv => Icons.directions_car_filled_outlined,
      VehicleCategory.minivan => Icons.airport_shuttle_outlined,
      VehicleCategory.pickup => Icons.local_shipping_outlined,
      _ => Icons.directions_car_outlined,
    };
  }

  String _categoryLabel(VehicleCategory cat) {
    return switch (cat) {
      VehicleCategory.berline => 'Berline',
      VehicleCategory.suv => 'SUV',
      VehicleCategory.minivan => 'Minivan',
      VehicleCategory.pickup => 'Pick-up',
      VehicleCategory.autre => 'Autre',
    };
  }
}

// ---------------------------------------------------------------------------
// Widgets internes
// ---------------------------------------------------------------------------

class _Tag extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool highlight;
  final BuildContext context;

  const _Tag({
    required this.label,
    required this.context,
    this.icon,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext ctx) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: highlight
            ? cs.primaryContainer.withValues(alpha: 0.3)
            : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: highlight
              ? cs.primary.withValues(alpha: 0.3)
              : cs.outlineVariant,
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon,
                size: 13,
                color: highlight ? cs.primary : cs.onSurfaceVariant),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: tt.labelMedium?.copyWith(
              color: highlight ? cs.primary : cs.onSurfaceVariant,
              fontWeight: highlight ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final BuildContext context;
  final bool danger;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.context,
    this.danger = false,
  });

  @override
  Widget build(BuildContext ctx) {
    final cs = Theme.of(context).colorScheme;
    final color = danger ? cs.error : cs.primary;
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16, color: color),
      label: Text(label,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: color)),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}