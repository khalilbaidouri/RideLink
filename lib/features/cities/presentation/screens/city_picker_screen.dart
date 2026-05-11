import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../providers/cities_provider.dart';
import '../widgets/city_tile.dart';

/// Écran de sélection d'une ville (M2).
///
/// Usage depuis M4 :
/// ```dart
/// final city = await Navigator.push<City>(
///   context,
///   MaterialPageRoute(builder: (_) => const CityPickerScreen()),
/// );
/// ```
class CityPickerScreen extends ConsumerStatefulWidget {
  /// Label affiché dans l'AppBar ('Ville de départ', 'Ville d'arrivée'…).
  final String title;

  const CityPickerScreen({
    super.key,
    this.title = 'Choisir une ville',
  });

  @override
  ConsumerState<CityPickerScreen> createState() => _CityPickerScreenState();
}

class _CityPickerScreenState extends ConsumerState<CityPickerScreen> {
  final _searchController = TextEditingController();
  bool _locationLoading = false;

  @override
  void initState() {
    super.initState();
    // Réinitialise la recherche à l'ouverture de l'écran
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(citySearchQueryProvider.notifier).clear();
      _fetchLocation();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // GPS
  // -------------------------------------------------------------------------

  Future<void> _fetchLocation() async {
    setState(() => _locationLoading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );
      ref.read(userLocationProvider.notifier).setLocation(
            pos.latitude, pos.longitude);
    } catch (_) {
      // GPS indisponible — la section "Villes proches" sera masquée
    } finally {
      if (mounted) setState(() => _locationLoading = false);
    }
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final filtered = ref.watch(filteredCitiesProvider);
    final nearby = ref.watch(nearbyCitiesProvider);
    final query = ref.watch(citySearchQueryProvider);

    final bool showNearby = nearby != null && query.isEmpty;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        elevation: 0,
        title: Text(widget.title,
            style: tt.headlineSmall?.copyWith(color: cs.onPrimary)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: _SearchBar(
              controller: _searchController,
              onChanged: (v) =>
                  ref.read(citySearchQueryProvider.notifier).update(v),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // ---- Section villes proches (GPS) --------------------------------
          if (showNearby) ...[
            _SectionLabel(
              label: 'Villes proches de vous',
              trailing: _locationLoading
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
            ),
            const SizedBox(height: 8),
            ...nearby.take(4).map(
                  (e) => CityTile(
                    city: e.city,
                    distanceKm: e.distanceKm,
                    isCurrentLocation: e.distanceKm < 10,
                    onTap: () => Navigator.pop(context, e.city),
                  ),
                ),
            const SizedBox(height: 20),
            _SectionLabel(
              label: '${filtered.length} villes disponibles',
            ),
            const SizedBox(height: 8),
          ],

          // ---- Résultats de recherche / liste complète ----------------------
          if (filtered.isEmpty)
            _EmptyState(query: query)
          else
            ...filtered.map(
              (city) => CityTile(
                city: city,
                distanceKm: nearby
                    ?.firstWhere(
                      (e) => e.city.id == city.id,
                      orElse: () => (city: city, distanceKm: -1),
                    )
                    .distanceKm
                    .let((d) => d >= 0 ? d : null),
                onTap: () => Navigator.pop(context, city),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Widgets internes
// ---------------------------------------------------------------------------

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        hintText: 'Rechercher une ville…',
        hintStyle: TextStyle(color: cs.onPrimary.withOpacity(0.6)),
        prefixIcon: Icon(Icons.search, color: cs.onPrimary.withOpacity(0.8)),
        suffixIcon: controller.text.isNotEmpty
            ? GestureDetector(
                onTap: () {
                  controller.clear();
                  onChanged('');
                },
                child: Icon(Icons.close, color: cs.onPrimary.withOpacity(0.8)),
              )
            : null,
        filled: true,
        fillColor: cs.primaryContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final Widget? trailing;

  const _SectionLabel({required this.label, this.trailing});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text(
          label.toUpperCase(),
          style: tt.labelMedium?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            fontSize: 11,
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          trailing!,
        ],
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String query;
  const _EmptyState({required this.query});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(Icons.location_off_outlined,
              size: 48, color: cs.onSurfaceVariant),
          const SizedBox(height: 12),
          Text('Aucune ville trouvée', style: tt.headlineSmall),
          const SizedBox(height: 4),
          Text('Essayez un autre nom pour "$query"',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Extension utilitaire locale
// ---------------------------------------------------------------------------
extension _Let<T> on T {
  R let<R>(R Function(T) f) => f(this);
}