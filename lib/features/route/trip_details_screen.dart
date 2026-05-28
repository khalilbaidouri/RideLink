import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'review_publish_screen.dart';

// ─────────────────────────────────────────────
//  Data model passed from Step 1
// ─────────────────────────────────────────────
class RouteData {
  final String departureCityName;
  final String destinationCityName;
  final int departureCityId;
  final int destinationCityId;
  final String meetingPoint;
  final String dropoffPoint;

  // ← Coordonnées ajoutées pour la carte Step 3
  final double departureLat;
  final double departureLng;
  final double destinationLat;
  final double destinationLng;

  const RouteData({
    required this.departureCityName,
    required this.destinationCityName,
    required this.departureCityId,
    required this.destinationCityId,
    this.meetingPoint = '',
    this.dropoffPoint = '',
    this.departureLat = 0.0,
    this.departureLng = 0.0,
    this.destinationLat = 0.0,
    this.destinationLng = 0.0,
  });
}

// ─────────────────────────────────────────────
//  Vehicle model
// ─────────────────────────────────────────────
class Vehicle {
  final int id;
  final String brand;
  final String model;
  final String color;
  final String plateNumber;
  final int seats;

  const Vehicle({
    required this.id,
    required this.brand,
    required this.model,
    required this.color,
    required this.plateNumber,
    required this.seats,
  });

  String get displayName => '$brand $model';
  String get subtitle => '$color • $plateNumber';
}

// ─────────────────────────────────────────────
//  TripDetailsScreen  (Step 2 of 3)
// ─────────────────────────────────────────────
class TripDetailsScreen extends StatefulWidget {
  final RouteData routeData;

  const TripDetailsScreen({super.key, required this.routeData});

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  static const Color _primary = Color(0xFF1E5C2E);
  static const Color _bg = Color(0xFFF4F5F0);

  DateTime _departureDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _departureTime = const TimeOfDay(hour: 8, minute: 30);
  int _seats = 3;
  final TextEditingController _priceController =
      TextEditingController(text: '150');

  List<Vehicle> _vehicles = [];
  Vehicle? _selectedVehicle;
  bool _loadingVehicles = true;

  @override
  void initState() {
    super.initState();
    _fetchVehicles();
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _fetchVehicles() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        if (mounted) setState(() => _loadingVehicles = false);
        return;
      }

      final response = await Supabase.instance.client
          .from('vehicles')
          .select()
          .eq('driver_id', user.id)
          .order('created_at', ascending: false);

      final list = (response as List)
          .map((v) => Vehicle(
                id: (v['id'] as num).toInt(),
                brand: v['brand'] as String? ?? '',
                model: v['model'] as String? ?? '',
                color: v['color'] as String? ?? '',
                plateNumber: v['plate_number'] as String? ?? '',
                seats: (v['seats'] as num?)?.toInt() ?? 4,
              ))
          .toList();

      if (mounted) {
        setState(() {
          _vehicles = list;
          if (list.isNotEmpty) _selectedVehicle = list.first;
          _loadingVehicles = false;
        });
      }
    } on PostgrestException catch (e) {
      if (mounted) {
        setState(() => _loadingVehicles = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur chargement véhicules: ${e.message}')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingVehicles = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _departureDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: _primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _departureDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _departureTime,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: _primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _departureTime = picked);
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

  void _onNext() {
    final price = double.tryParse(_priceController.text.trim());
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un prix valide.')),
      );
      return;
    }
    if (_selectedVehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un véhicule.')),
      );
      return;
    }

    final dt = DateTime(
      _departureDate.year,
      _departureDate.month,
      _departureDate.day,
      _departureTime.hour,
      _departureTime.minute,
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
            // ← Coordonnées transmises depuis Step 1
            departureLat: widget.routeData.departureLat,
            departureLng: widget.routeData.departureLng,
            destinationLat: widget.routeData.destinationLat,
            destinationLng: widget.routeData.destinationLng,
            departureDateTime: dt,
            seats: _seats,
            price: price,
            vehicleId: _selectedVehicle!.id,
            vehicleName: _selectedVehicle!.displayName,
            vehicleColor: _selectedVehicle!.color,
            vehiclePlate: _selectedVehicle!.plateNumber,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStepHeader(),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(child: _buildDateField()),
                        const SizedBox(width: 12),
                        Expanded(child: _buildTimeField()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSeatsCard(),
                    const SizedBox(height: 16),
                    _buildPriceField(),
                    const SizedBox(height: 20),
                    Text(
                      'Select Vehicle',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 10),
                    if (_loadingVehicles)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: CircularProgressIndicator(
                              color: Color(0xFF1E5C2E)),
                        ),
                      )
                    else if (_vehicles.isEmpty)
                      Container(
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
                                    color: Colors.grey.shade500, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ..._vehicles.map(_buildVehicleTile),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _buildNextButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: _primary, size: 24),
          ),
          const SizedBox(width: 12),
          const Text(
            'Ride Bookings',
            style: TextStyle(
              color: _primary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey.shade300,
            child: Icon(Icons.person, color: Colors.grey.shade600, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildStepHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step 2 of 3',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade800),
            ),
            const Text(
              'Trip Details',
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600, color: _primary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: 2 / 3,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(_primary),
            minHeight: 5,
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Departure Date',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_month_outlined,
                    color: Colors.grey.shade600, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _formatDate(_departureDate),
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Departure Time',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: _pickTime,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time,
                    color: Colors.grey.shade600, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _formatTime(_departureTime),
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSeatsCard() {
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
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _SeatsButton(
                icon: Icons.remove,
                onTap: () {
                  if (_seats > 1) setState(() => _seats--);
                },
                filled: false,
                primary: _primary,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '$_seats',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w800),
                ),
              ),
              _SeatsButton(
                icon: Icons.add,
                onTap: () {
                  if (_seats < 8) setState(() => _seats++);
                },
                filled: true,
                primary: _primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Price per Seat',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A)),
                  decoration: const InputDecoration(
                      border: InputBorder.none, isDense: true),
                ),
              ),
              const Text(
                'MAD',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _primary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleTile(Vehicle v) {
    final isSelected = _selectedVehicle?.id == v.id;
    return GestureDetector(
      onTap: () => setState(() => _selectedVehicle = v),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? _primary : Colors.grey.shade200,
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFD6EDDA)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.directions_car_filled_rounded,
                color: isSelected ? _primary : Colors.grey.shade500,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(v.displayName,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(v.subtitle,
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade500)),
                ],
              ),
            ),
            Radio<int>(
              value: v.id,
              groupValue: _selectedVehicle?.id,
              onChanged: (val) => setState(() => _selectedVehicle = v),
              activeColor: _primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: _onNext,
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
    );
  }
}

class _SeatsButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;
  final Color primary;

  const _SeatsButton({
    required this.icon,
    required this.onTap,
    required this.filled,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: filled ? primary : Colors.white,
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