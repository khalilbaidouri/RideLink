import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ride_link/features/passenger/models/search_ride_result.dart';

class RideDetailsScreen extends StatelessWidget {
  const RideDetailsScreen({
    super.key,
    required this.rideId,
    this.result,
  });

  final String rideId;
  final SearchRideResult? result;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final date = result == null
        ? null
        : DateFormat('EEE, MMM d').format(result!.departureTime);
    final time = result == null
        ? null
        : DateFormat('HH:mm').format(result!.departureTime);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride details'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _DetailsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result?.driver.name ?? 'Driver details unavailable',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                if (result != null)
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: colors.tertiary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${result!.driver.rating.toStringAsFixed(1)} '
                        '(${result!.driver.totalReviews})',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    'Rating information will appear here.',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _DetailsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Route',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _RouteRow(
                  label: 'From',
                  value: result?.fromName ?? '—',
                ),
                const SizedBox(height: 8),
                _RouteRow(
                  label: 'To',
                  value: result?.toName ?? '—',
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _InfoPill(
                      label: 'Date',
                      value: date ?? '—',
                    ),
                    const SizedBox(width: 8),
                    _InfoPill(
                      label: 'Time',
                      value: time ?? '—',
                    ),
                    const SizedBox(width: 8),
                    _InfoPill(
                      label: 'Seats',
                      value: result == null ? '—' : '${result!.seatsLeft} left',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _DetailsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Price',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  result == null
                      ? 'Price to be confirmed'
                      : '${result!.price.toStringAsFixed(0)} MAD',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: colors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () {},
            child: const Text('Book this ride'),
          ),
          const SizedBox(height: 12),
          Text(
            'Ride ID: $rideId',
            style: TextStyle(
              fontSize: 11,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _RouteRow extends StatelessWidget {
  const _RouteRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        SizedBox(
          width: 48,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
