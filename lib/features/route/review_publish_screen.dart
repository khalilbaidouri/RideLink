import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─────────────────────────────────────────────
//  Data passed from Step 1 + Step 2
// ─────────────────────────────────────────────
class RideReviewData {
  final String departureCityName;
  final String destinationCityName;
  final int departureCityId;
  final int destinationCityId;
  final String meetingPoint;
  final String dropoffPoint;
  final double departureLat;
  final double departureLng;
  final double destinationLat;
  final double destinationLng;
  final DateTime departureDateTime;
  final int seats;
  final double price;
  final int vehicleId;
  final String vehicleName;
  final String vehicleColor;
  final String vehiclePlate;

  const RideReviewData({
    required this.departureCityName,
    required this.destinationCityName,
    required this.departureCityId,
    required this.destinationCityId,
    required this.meetingPoint,
    required this.dropoffPoint,
    required this.departureLat,
    required this.departureLng,
    required this.destinationLat,
    required this.destinationLng,
    required this.departureDateTime,
    required this.seats,
    required this.price,
    required this.vehicleId,
    required this.vehicleName,
    required this.vehicleColor,
    required this.vehiclePlate,
  });
}

// ─────────────────────────────────────────────
//  ReviewPublishScreen  (Step 3 of 3)
// ─────────────────────────────────────────────
class ReviewPublishScreen extends StatefulWidget {
  final RideReviewData data;
  const ReviewPublishScreen({super.key, required this.data});

  @override
  State<ReviewPublishScreen> createState() => _ReviewPublishScreenState();
}

class _ReviewPublishScreenState extends State<ReviewPublishScreen> {
  static const Color _primary = Color(0xFF1E5C2E);
  static const Color _bg = Color(0xFFF4F5F0);

  bool _isPublishing = false;
  bool _isSavingDraft = false;

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final date = DateTime(dt.year, dt.month, dt.day);

    String dayStr;
    if (date == today) {
      dayStr = 'Today';
    } else if (date == tomorrow) {
      dayStr = 'Tomorrow';
    } else {
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      dayStr = '${months[dt.month - 1]} ${dt.day}';
    }

    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '$dayStr, $h:$m $period';
  }

  Future<void> _publishRide() async {
    setState(() => _isPublishing = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('Utilisateur non connecté.');

      await Supabase.instance.client.from('rides').insert({
        'driver_id': user.id,
        'vehicle_id': widget.data.vehicleId,
        'departure_city_id': widget.data.departureCityId,
        'destination_city_id': widget.data.destinationCityId,
        'departure_address': widget.data.meetingPoint.isNotEmpty
            ? widget.data.meetingPoint
            : null,
        'destination_address': widget.data.dropoffPoint.isNotEmpty
            ? widget.data.dropoffPoint
            : null,
        'departure_time':
            widget.data.departureDateTime.toUtc().toIso8601String(),
        'price': widget.data.price,
        'available_seats': widget.data.seats,
        'status': 'active',
      });

      if (!mounted) return;
      _showSuccessDialog();
    } on PostgrestException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur Supabase: ${e.message}'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  Future<void> _saveDraft() async {
    setState(() => _isSavingDraft = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('Utilisateur non connecté.');

      await Supabase.instance.client.from('rides').insert({
        'driver_id': user.id,
        'vehicle_id': widget.data.vehicleId,
        'departure_city_id': widget.data.departureCityId,
        'destination_city_id': widget.data.destinationCityId,
        'departure_address': widget.data.meetingPoint.isNotEmpty
            ? widget.data.meetingPoint
            : null,
        'destination_address': widget.data.dropoffPoint.isNotEmpty
            ? widget.data.dropoffPoint
            : null,
        'departure_time':
            widget.data.departureDateTime.toUtc().toIso8601String(),
        'price': widget.data.price,
        'available_seats': widget.data.seats,
        'status': 'draft',
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Trajet sauvegardé comme brouillon.'),
          backgroundColor: Color(0xFF1E5C2E),
        ),
      );
      Navigator.of(context).popUntil((r) => r.isFirst);
    } on PostgrestException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur Supabase: ${e.message}'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSavingDraft = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                  color: Color(0xFFD6EDDA), shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, color: _primary, size: 36),
            ),
            const SizedBox(height: 16),
            const Text('Ride Published!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
              'Your ride is now visible to passengers.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((r) => r.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Go to My Rides',
                  style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
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
                    const SizedBox(height: 16),
                    const Text(
                      'Final Review',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A1A)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Check your ride details before making it\npublic for other travelers.',
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          height: 1.4),
                    ),
                    const SizedBox(height: 14),
                    _ReviewMapPreview(
                      departureCityName: d.departureCityName,
                      destinationCityName: d.destinationCityName,
                      departureLat: d.departureLat,
                      departureLng: d.departureLng,
                      destinationLat: d.destinationLat,
                      destinationLng: d.destinationLng,
                      primary: _primary,
                    ),
                    const SizedBox(height: 14),
                    _buildDetailsCard(d),
                    const SizedBox(height: 14),
                    _buildTagsRow(),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
            _buildBottomButtons(),
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
              'Step 3 of 3',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade800),
            ),
            const Text(
              'Review & Publish',
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600, color: _primary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: const LinearProgressIndicator(
            value: 1.0,
            backgroundColor: Color(0xFFE0E0E0),
            valueColor: AlwaysStoppedAnimation<Color>(_primary),
            minHeight: 5,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsCard(RideReviewData d) {
    return Container(
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
      child: Column(
        children: [
          _DetailRow(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: Colors.grey.shade400, width: 2),
                      ),
                    ),
                    Container(
                        width: 2, height: 36, color: Colors.grey.shade300),
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF1E5C2E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _ReviewLabel('PICKUP'),
                      Text(
                        d.meetingPoint.isNotEmpty
                            ? d.meetingPoint
                            : d.departureCityName,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 18),
                      const _ReviewLabel('DROP-OFF'),
                      Text(
                        d.dropoffPoint.isNotEmpty
                            ? d.dropoffPoint
                            : d.destinationCityName,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                _EditButton(onTap: () => Navigator.pop(context)),
              ],
            ),
          ),
          _Divider(),
          _DetailRow(
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF4ED),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.calendar_month_outlined,
                      color: _primary, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _ReviewLabel('DATE & TIME'),
                      Text(
                        _formatDateTime(d.departureDateTime),
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                _EditButton(onTap: () => Navigator.pop(context)),
              ],
            ),
          ),
          _Divider(),
          _DetailRow(
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF4ED),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.location_on_outlined,
                      color: _primary, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _ReviewLabel('MEETING POINT'),
                      Text(
                        d.meetingPoint.isNotEmpty ? d.meetingPoint : '—',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                _EditButton(onTap: () => Navigator.pop(context)),
              ],
            ),
          ),
          _Divider(),
          _DetailRow(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _ReviewLabel('SEATS'),
                      Row(children: [
                        const Icon(Icons.people_outline,
                            color: _primary, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '${d.seats} Availab.',
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                      ]),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _ReviewLabel('PRICE'),
                      Row(children: [
                        const Icon(Icons.monetization_on_outlined,
                            color: _primary, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '${d.price.toStringAsFixed(0)} MAD',
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                      ]),
                    ],
                  ),
                ),
                _EditButton(onTap: () => Navigator.pop(context)),
              ],
            ),
          ),
          _Divider(),
          _DetailRow(
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF4ED),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.directions_car_filled_rounded,
                      color: _primary, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _ReviewLabel('VEHICLE'),
                      Text(
                        '${d.vehicleName} • ${d.vehicleColor}',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                _EditButton(onTap: () => Navigator.pop(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsRow() {
    return const Wrap(
      spacing: 10,
      runSpacing: 8,
      children: [
        _TagChip(icon: Icons.bolt, label: 'Instant Booking'),
        _TagChip(icon: Icons.eco_outlined, label: 'Eco-Friendly'),
        _TagChip(icon: Icons.people_outline, label: 'Max 2 in back'),
      ],
    );
  }

  Widget _buildBottomButtons() {
    final bool busy = _isPublishing || _isSavingDraft;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: busy ? null : _publishRide,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: _isPublishing
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Text(
                      'Publish Ride',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: busy ? null : _saveDraft,
            child: _isSavingDraft
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        color: Color(0xFF1E5C2E), strokeWidth: 2),
                  )
                : Text(
                    'Save as Draft',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Map Preview — ligne droite (zéro CORS)
// ─────────────────────────────────────────────

class _ReviewMapPreview extends StatefulWidget {
  final String departureCityName;
  final String destinationCityName;
  final double departureLat;
  final double departureLng;
  final double destinationLat;
  final double destinationLng;
  final Color primary;

  const _ReviewMapPreview({
    required this.departureCityName,
    required this.destinationCityName,
    required this.departureLat,
    required this.departureLng,
    required this.destinationLat,
    required this.destinationLng,
    required this.primary,
  });

  @override
  State<_ReviewMapPreview> createState() => _ReviewMapPreviewState();
}

class _ReviewMapPreviewState extends State<_ReviewMapPreview> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(31.7917, -7.0926),
    zoom: 5,
  );

  // ── FIX CORS : ligne droite, aucun appel HTTP ──
  Future<void> _drawRoute() async {
    final startLatLng = LatLng(widget.departureLat, widget.departureLng);
    final endLatLng = LatLng(widget.destinationLat, widget.destinationLng);

    final controller = await _controller.future;

    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(
            startLatLng.latitude < endLatLng.latitude
                ? startLatLng.latitude
                : endLatLng.latitude,
            startLatLng.longitude < endLatLng.longitude
                ? startLatLng.longitude
                : endLatLng.longitude,
          ),
          northeast: LatLng(
            startLatLng.latitude > endLatLng.latitude
                ? startLatLng.latitude
                : endLatLng.latitude,
            startLatLng.longitude > endLatLng.longitude
                ? startLatLng.longitude
                : endLatLng.longitude,
          ),
        ),
        60,
      ),
    );

    setState(() {
      _markers.clear();
      _polylines.clear();

      _markers.add(Marker(
        markerId: const MarkerId('start'),
        position: startLatLng,
        infoWindow: InfoWindow(title: widget.departureCityName),
      ));

      _markers.add(Marker(
        markerId: const MarkerId('end'),
        position: endLatLng,
        infoWindow: InfoWindow(title: widget.destinationCityName),
      ));

      _polylines.add(Polyline(
        polylineId: const PolylineId('route'),
        points: [startLatLng, endLatLng],
        color: widget.primary,
        width: 4,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: _initialPosition,
              markers: _markers,
              polylines: _polylines,
              mapType: MapType.normal,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              compassEnabled: false,
              rotateGesturesEnabled: false,
              scrollGesturesEnabled: false,
              zoomGesturesEnabled: false,
              tiltGesturesEnabled: false,
              onMapCreated: (GoogleMapController c) {
                if (!_controller.isCompleted) {
                  _controller.complete(c);
                }
                _drawRoute();
              },
            ),
            Positioned(
              bottom: 14,
              left: 14,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 2)),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.map_outlined, size: 16, color: widget.primary),
                    const SizedBox(width: 6),
                    const Text(
                      'Preview on Map',
                      style: TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontWeight: FontWeight.w600,
                          fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Small reusable widgets
// ─────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final Widget child;
  const _DetailRow({required this.child});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: child,
      );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Divider(
        height: 1,
        thickness: 1,
        color: Colors.grey.shade100,
        indent: 16,
        endIndent: 16,
      );
}

class _ReviewLabel extends StatelessWidget {
  final String text;
  const _ReviewLabel(this.text);

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

class _EditButton extends StatelessWidget {
  final VoidCallback onTap;
  const _EditButton({required this.onTap});

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

class _TagChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _TagChip({required this.icon, required this.label});

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
