import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../domain/entities/vehicle.dart';

// ---------------------------------------------------------------------------
// État
// ---------------------------------------------------------------------------

class VehiclesState {
  final List<Vehicle> vehicles;
  final bool isLoading;
  final String? error;

  const VehiclesState({
    this.vehicles = const [],
    this.isLoading = false,
    this.error,
  });

  VehiclesState copyWith({
    List<Vehicle>? vehicles,
    bool? isLoading,
    String? error,
  }) {
    return VehiclesState(
      vehicles: vehicles ?? this.vehicles,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier — Riverpod 3 : Notifier remplace StateNotifier
// ---------------------------------------------------------------------------

class VehiclesNotifier extends Notifier<VehiclesState> {
  final _uuid = const Uuid();

  @override
  VehiclesState build() {
    // Lance le chargement initial au premier appel
    _loadInitialData();
    return const VehiclesState(isLoading: true);
  }

  /// Charge les vehicules du conducteur depuis Supabase.
  Future<void> _loadInitialData() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) {
      state = state.copyWith(
        isLoading: false,
        error: 'No authenticated user found.',
      );
      return;
    }

    try {
      final response = await client
          .from('vehicles')
          .select(
            'id, driver_id, brand, model, plate_number, seats, color, created_at',
          )
          .eq('driver_id', user.id)
          .order('created_at', ascending: false);

      final vehicles = response
          .map<Vehicle>(
            (row) => Vehicle(
              id: row['id'].toString(),
              ownerId: row['driver_id'] as String? ?? user.id,
              brand: row['brand'] as String? ?? '',
              model: row['model'] as String? ?? '',
              licensePlate: row['plate_number'] as String? ?? '',
              totalSeats: row['seats'] as int? ?? 5,
              category: VehicleCategory.berline,
              color: row['color'] as String?,
              year: null,
              isDefault: false,
            ),
          )
          .toList();

      state = state.copyWith(
        isLoading: false,
        vehicles: vehicles,
        error: null,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    }
  }

  /// Ajoute un nouveau véhicule.
  Future<void> addVehicle({
    required String ownerId,
    required String brand,
    required String model,
    required String licensePlate,
    required int totalSeats,
    required VehicleCategory category,
    String? color,
    int? year,
  }) async {
    final isFirst = state.vehicles.isEmpty;
    final newVehicle = Vehicle(
      id: _uuid.v4(),
      ownerId: ownerId,
      brand: brand,
      model: model,
      licensePlate: licensePlate,
      totalSeats: totalSeats,
      category: category,
      color: color,
      year: year,
      isDefault: isFirst,
    );
    state = state.copyWith(vehicles: [...state.vehicles, newVehicle]);
  }

  /// Met à jour un véhicule existant.
  Future<void> updateVehicle(Vehicle updated) async {
    state = state.copyWith(
      vehicles:
          state.vehicles.map((v) => v.id == updated.id ? updated : v).toList(),
    );
  }

  /// Supprime un véhicule.
  Future<void> deleteVehicle(String vehicleId) async {
    final remaining =
        state.vehicles.where((v) => v.id != vehicleId).toList();
    // Si on supprime le défaut, le premier restant devient défaut
    if (remaining.isNotEmpty && !remaining.any((v) => v.isDefault)) {
      remaining[0] = remaining[0].copyWith(isDefault: true);
    }
    state = state.copyWith(vehicles: remaining);
  }

  /// Définit un véhicule comme véhicule par défaut.
  void setDefault(String vehicleId) {
    state = state.copyWith(
      vehicles: state.vehicles
          .map((v) => v.copyWith(isDefault: v.id == vehicleId))
          .toList(),
    );
  }

}

// ---------------------------------------------------------------------------
// Providers exposés
// ---------------------------------------------------------------------------

/// Riverpod 3 : NotifierProvider remplace StateNotifierProvider
final vehiclesProvider =
    NotifierProvider<VehiclesNotifier, VehiclesState>(
  VehiclesNotifier.new,
);

/// Véhicule par défaut (pré-sélectionné dans M4).
final defaultVehicleProvider = Provider<Vehicle?>((ref) {
  final vehicles = ref.watch(vehiclesProvider).vehicles;
  try {
    return vehicles.firstWhere((v) => v.isDefault);
  } catch (_) {
    return vehicles.isNotEmpty ? vehicles.first : null;
  }
});

/// Véhicules triés : défaut en premier, puis alphabétique par marque.
final sortedVehiclesProvider = Provider<List<Vehicle>>((ref) {
  final vehicles = ref.watch(vehiclesProvider).vehicles;
  return [...vehicles]..sort((a, b) {
      if (a.isDefault) return -1;
      if (b.isDefault) return 1;
      return a.brand.compareTo(b.brand);
    });
});