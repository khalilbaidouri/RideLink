import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/vehicle.dart';
import '../../providers/vehicles_provider.dart';
import '../widgets/vehicle_card.dart';   // ← déplacé ici

/// Bottom sheet de création / modification d'un véhicule (M3).
///
/// Usage :
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   isScrollControlled: true,
///   builder: (_) => VehicleFormSheet(vehicle: existingVehicle),
/// );
/// ```
class VehicleFormSheet extends ConsumerStatefulWidget {
  /// Null = création, non-null = modification.
  final Vehicle? vehicle;

  const VehicleFormSheet({super.key, this.vehicle});

  @override
  ConsumerState<VehicleFormSheet> createState() => _VehicleFormSheetState();
}

class _VehicleFormSheetState extends ConsumerState<VehicleFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _brand;
  late final TextEditingController _model;
  late final TextEditingController _plate;
  late final TextEditingController _color;
  late final TextEditingController _year;

  int _totalSeats = 5;
  VehicleCategory _category = VehicleCategory.berline;
  bool _saving = false;

  bool get _isEditing => widget.vehicle != null;

  @override
  void initState() {
    super.initState();
    final v = widget.vehicle;
    _brand = TextEditingController(text: v?.brand ?? '');
    _model = TextEditingController(text: v?.model ?? '');
    _plate = TextEditingController(text: v?.licensePlate ?? '');
    _color = TextEditingController(text: v?.color ?? '');
    _year  = TextEditingController(text: v?.year?.toString() ?? '');
    _totalSeats = v?.totalSeats ?? 5;
    _category   = v?.category ?? VehicleCategory.berline;
  }

  @override
  void dispose() {
    _brand.dispose(); _model.dispose(); _plate.dispose();
    _color.dispose(); _year.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Soumission
  // -------------------------------------------------------------------------

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final notifier = ref.read(vehiclesProvider.notifier);

    if (_isEditing) {
      await notifier.updateVehicle(
        widget.vehicle!.copyWith(
          brand: _brand.text.trim(),
          model: _model.text.trim(),
          licensePlate: _plate.text.trim().toUpperCase(),
          totalSeats: _totalSeats,
          category: _category,
          color: _color.text.trim().isEmpty ? null : _color.text.trim(),
          year: int.tryParse(_year.text.trim()),
        ),
      );
    } else {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: User not authenticated')),
          );
        }
        return;
      }

      await notifier.addVehicle(
        ownerId: userId,
        brand: _brand.text.trim(),
        model: _model.text.trim(),
        licensePlate: _plate.text.trim().toUpperCase(),
        totalSeats: _totalSeats,
        category: _category,
        color: _color.text.trim().isEmpty ? null : _color.text.trim(),
        year: int.tryParse(_year.text.trim()),
      );
    }

    if (mounted) Navigator.pop(context);
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag handle
              const SizedBox(height: 10),
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  )),
              const SizedBox(height: 12),
              // Titre
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      _isEditing ? 'Modifier le véhicule' : 'Ajouter un véhicule',
                      style: tt.headlineMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Divider(color: cs.outlineVariant, height: 1),
              // Formulaire
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ---- Marque + Modèle ------------------------------
                        Row(
                          children: [
                            Expanded(
                              child: _Field(
                                label: 'Marque',
                                hint: 'Ex : Dacia',
                                controller: _brand,
                                validator: _required,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _Field(
                                label: 'Modèle',
                                hint: 'Ex : Logan',
                                controller: _model,
                                validator: _required,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // ---- Immatriculation ------------------------------
                        _Field(
                          label: 'Immatriculation',
                          hint: 'Ex : 123456-A-1',
                          controller: _plate,
                          validator: _required,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9A-Za-z\-]')),
                            UpperCaseTextFormatter(),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // ---- Couleur + Année ------------------------------
                        Row(
                          children: [
                            Expanded(
                              child: _Field(
                                label: 'Couleur',
                                hint: 'Ex : Blanc',
                                controller: _color,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _Field(
                                label: 'Année',
                                hint: '2020',
                                controller: _year,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(4),
                                ],
                                validator: (v) {
                                  if (v == null || v.isEmpty) return null;
                                  final y = int.tryParse(v);
                                  if (y == null || y < 1990 || y > 2026) {
                                    return 'Année invalide';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // ---- Catégorie ------------------------------------
                        const _SectionLabel('Catégorie'),
                        const SizedBox(height: 8),
                        _CategorySelector(
                          selected: _category,
                          onChanged: (c) => setState(() => _category = c),
                        ),
                        const SizedBox(height: 16),

                        // ---- Nombre de places ----------------------------
                        const _SectionLabel('Nombre de places (conducteur inclus)'),
                        const SizedBox(height: 8),
                        _SeatsSelector(
                          value: _totalSeats,
                          onChanged: (v) => setState(() => _totalSeats = v),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: cs.primaryContainer.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline,
                                  size: 16, color: cs.primary),
                              const SizedBox(width: 8),
                              Text(
                                '${_totalSeats - 1} place(s) disponible(s) pour les passagers',
                                style: tt.labelMedium
                                    ?.copyWith(color: cs.primary),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // ---- Boutons -------------------------------------
                        ElevatedButton(
                          onPressed: _saving ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                          ),
                          child: _saving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : Text(_isEditing
                                  ? 'Enregistrer les modifications'
                                  : 'Ajouter le véhicule'),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                          ),
                          child: const Text('Annuler'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Ce champ est requis' : null;
}

// ---------------------------------------------------------------------------
// Écran principal M3 — liste des véhicules
// ---------------------------------------------------------------------------

/// Écran listant les véhicules du conducteur avec ajout/modification/suppression.
class VehiclesScreen extends ConsumerWidget {
  const VehiclesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final state = ref.watch(vehiclesProvider);
    final sorted = ref.watch(sortedVehiclesProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        elevation: 0,
        title: Text('Mes véhicules',
            style: tt.headlineSmall?.copyWith(color: cs.onPrimary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Ajouter un véhicule',
            onPressed: () => _openForm(context),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : sorted.isEmpty
              ? _EmptyState(onAdd: () => _openForm(context))
              : ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  children: [
                    Text(
                      '${sorted.length} véhicule(s) enregistré(s)',
                      style: tt.labelMedium
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    const SizedBox(height: 12),
                    ...sorted.map(
                      (v) => _buildVehicleCard(context, ref, v),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => _openForm(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Ajouter un véhicule'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildVehicleCard(
      BuildContext context, WidgetRef ref, Vehicle v) {
    return VehicleCard(
      vehicle: v,
      onEdit: () => _openForm(context, vehicle: v),
      onDelete: () => _confirmDelete(context, ref, v),
      onSetDefault: () =>
          ref.read(vehiclesProvider.notifier).setDefault(v.id),
    );
  }

  void _openForm(BuildContext context, {Vehicle? vehicle}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => VehicleFormSheet(vehicle: vehicle),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, Vehicle v) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le véhicule ?'),
        content: Text(
            'Voulez-vous supprimer "${v.brand} ${v.model}" (${v.licensePlate}) ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error),
              child: const Text('Supprimer')),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(vehiclesProvider.notifier).deleteVehicle(v.id);
    }
  }
}

// ---------------------------------------------------------------------------
// Widgets internes
// ---------------------------------------------------------------------------

class _Field extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const _Field({
    required this.label,
    required this.hint,
    required this.controller,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                )),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      text,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: cs.onSurfaceVariant,
          ),
    );
  }
}

class _CategorySelector extends StatelessWidget {
  final VehicleCategory selected;
  final ValueChanged<VehicleCategory> onChanged;

  const _CategorySelector(
      {required this.selected, required this.onChanged});

  static const _items = [
    (VehicleCategory.berline, 'Berline', Icons.directions_car_outlined),
    (VehicleCategory.suv, 'SUV', Icons.directions_car_filled_outlined),
    (VehicleCategory.minivan, 'Minivan', Icons.airport_shuttle_outlined),
    (VehicleCategory.pickup, 'Pick-up', Icons.local_shipping_outlined),
    (VehicleCategory.autre, 'Autre', Icons.commute_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _items.map((item) {
        final isSelected = selected == item.$1;
        return GestureDetector(
          onTap: () => onChanged(item.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? cs.primary
                  : cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? cs.primary : cs.outlineVariant,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(item.$3,
                    size: 16,
                    color: isSelected ? cs.onPrimary : cs.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(
                  item.$2,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SeatsSelector extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _SeatsSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        IconButton(
          onPressed: value > 2 ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove_circle_outline),
          color: cs.primary,
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$value places',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: value < 9 ? () => onChanged(value + 1) : null,
          icon: const Icon(Icons.add_circle_outline),
          color: cs.primary,
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.directions_car_outlined,
                size: 64, color: cs.onSurfaceVariant),
            const SizedBox(height: 16),
            Text('Aucun véhicule enregistré', style: tt.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Ajoutez votre véhicule pour commencer à proposer des trajets.',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un véhicule'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Formatters
// ---------------------------------------------------------------------------

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue newVal) {
    return newVal.copyWith(text: newVal.text.toUpperCase());
  }
}

