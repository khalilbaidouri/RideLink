import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/route_providers.dart';
import '../providers/trip_providers.dart';
import '../widgets/seats_card.dart';
import '../widgets/vehicle_tile.dart';
import 'review_publish_screen.dart';

class TripDetailsScreen extends ConsumerStatefulWidget {
  final RouteData routeData;

  const TripDetailsScreen({super.key, required this.routeData});

  @override
  ConsumerState<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends ConsumerState<TripDetailsScreen> {
  static const Color _primary = Color(0xFF1E5C2E);
  static const Color _bg = Color(0xFFF4F5F0);

  late final TextEditingController _priceCtrl;

  @override
  void initState() {
    super.initState();
    _priceCtrl =
        TextEditingController(text: ref.read(tripFormProvider).price);
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  void _onNext(TripFormState form) {
    final price = double.tryParse(_priceCtrl.text.trim());
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un prix valide.')),
      );
      return;
    }
    if (form.selectedVehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un véhicule.')),
      );
      return;
    }

    final dt = DateTime(
      form.departureDate.year,
      form.departureDate.month,
      form.departureDate.day,
      form.departureTime.hour,
      form.departureTime.minute,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewPublishScreen(
          data: RideReviewData(
            departureCityName: widget.routeData.departureCityName,
            destinationCityName: widget.routeData.destinationCityName,
            departureCityId: widget.routeData.departureCityId,
            destinationCityId: widget.routeData.destinationCityId,
            meetingPoint: widget.routeData.meetingPoint,
            dropoffPoint: widget.routeData.dropoffPoint,
            departureLat: widget.routeData.departureLat,
            departureLng: widget.routeData.departureLng,
            destinationLat: widget.routeData.destinationLat,
            destinationLng: widget.routeData.destinationLng,
            departureDateTime: dt,
            seats: form.seats,
            price: price,
            vehicleId: form.selectedVehicle!.id,
            vehicleName: form.selectedVehicle!.displayName,
            vehicleColor: form.selectedVehicle!.color,
            vehiclePlate: form.selectedVehicle!.plateNumber,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(tripFormProvider);
    final notifier = ref.read(tripFormProvider.notifier);
    final vehiclesAsync = ref.watch(vehiclesProvider);

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // AppBar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back,
                        color: _primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Text('Ride Bookings',
                      style: TextStyle(
                          color: _primary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3)),
                  const Spacer(),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey.shade300,
                    child: Icon(Icons.person,
                        color: Colors.grey.shade600, size: 22),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Step header
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Step 2 of 3',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey.shade800)),
                            const Text('Trip Details',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _primary)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: 2 / 3,
                            backgroundColor: Colors.grey.shade200,
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(_primary),
                            minHeight: 5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Date + Time
                    Row(
                      children: [
                        Expanded(
                          child: _PickerField(
                            label: 'Departure Date',
                            icon: Icons.calendar_month_outlined,
                            value: _formatDate(form.departureDate),
                            onTap: () async {
                              final d = await showDatePicker(
                                context: context,
                                initialDate: form.departureDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 365)),
                                builder: (ctx, child) => Theme(
                                  data: Theme.of(ctx).copyWith(
                                    colorScheme: const ColorScheme.light(
                                        primary: _primary),
                                  ),
                                  child: child!,
                                ),
                              );
                              if (d != null) notifier.setDate(d);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _PickerField(
                            label: 'Departure Time',
                            icon: Icons.access_time,
                            value: _formatTime(form.departureTime),
                            onTap: () async {
                              final t = await showTimePicker(
                                context: context,
                                initialTime: form.departureTime,
                                builder: (ctx, child) => Theme(
                                  data: Theme.of(ctx).copyWith(
                                    colorScheme: const ColorScheme.light(
                                        primary: _primary),
                                  ),
                                  child: child!,
                                ),
                              );
                              if (t != null) notifier.setTime(t);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    SeatsCard(
                      seats: form.seats,
                      onDecrement: () {
                        if (form.seats > 1) notifier.setSeats(form.seats - 1);
                      },
                      onIncrement: () {
                        if (form.seats < 8) notifier.setSeats(form.seats + 1);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Price per Seat',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _priceCtrl,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  onChanged: notifier.setPrice,
                                  style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1A1A1A)),
                                  decoration: const InputDecoration(
                                      border: InputBorder.none, isDense: true),
                                ),
                              ),
                              const Text('MAD',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: _primary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Vehicles
                    Text('Select Vehicle',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700)),
                    const SizedBox(height: 10),

                    vehiclesAsync.when(
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: CircularProgressIndicator(
                              color: Color(0xFF1E5C2E)),
                        ),
                      ),
                      error: (e, _) => Text('Erreur: $e'),
                      data: (vehicles) {
                        if (vehicles.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.directions_car_outlined,
                                    color: Colors.grey.shade400, size: 28),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Aucun véhicule trouvé.\nAjoutez-en un dans votre profil.',
                                    style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        // Auto-select first if none selected
                        if (form.selectedVehicle == null &&
                            vehicles.isNotEmpty) {
                          Future.microtask(
                              () => notifier.setVehicle(vehicles.first));
                        }

                        return Column(
                          children: vehicles
                              .map((v) => VehicleTile(
                                    vehicle: v,
                                    isSelected:
                                        form.selectedVehicle?.id == v.id,
                                    onTap: () => notifier.setVehicle(v),
                                  ))
                              .toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Next button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => _onNext(form),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Next',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Picker field (date / time) ────────────────
class _PickerField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final VoidCallback onTap;

  const _PickerField({
    required this.label,
    required this.icon,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.grey.shade600, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(value,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}