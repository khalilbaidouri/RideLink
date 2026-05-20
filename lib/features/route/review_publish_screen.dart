import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─────────────────────────────────────────────
//  Data passed from Step 1 + Step 2
// ─────────────────────────────────────────────
class RideReviewData {
  // Route (Step 1)
  final String departureCityName;
  final String destinationCityName;
  final int departureCityId;
  final int destinationCityId;
  final String meetingPoint;
  final String dropoffPoint;

  // Trip (Step 2)
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

  // ── Format helpers ────────────────────────
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

  // ── Publish ride to Supabase ──────────────
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

  // ── Save as Draft ─────────────────────────
  // Note: Pour sauvegarder comme brouillon, vous devez ajouter
  // 'draft' dans le check constraint de la colonne status :
  // ALTER TABLE rides DROP CONSTRAINT rides_status_check;
  // ALTER TABLE rides ADD CONSTRAINT rides_status_check
  //   CHECK (status IN ('active', 'completed', 'cancelled', 'draft'));
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
        'status': 'draft', // nécessite la migration SQL ci-dessus
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
                    _buildMapPreview(),
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

  // ── App Bar ───────────────────────────────
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

  // ── Step header ───────────────────────────
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
          child: LinearProgressIndicator(
            value: 1.0,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(_primary),
            minHeight: 5,
          ),
        ),
      ],
    );
  }

  // ── Map preview ───────────────────────────
  Widget _buildMapPreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 160,
        width: double.infinity,
        child: Stack(
          children: [
            CustomPaint(painter: _MapPainter(), size: Size.infinite),
            const CustomPaint(
                painter: _RouteLinePainter(_primary), size: Size.infinite),
          ],
        ),
      ),
    );
  }

  // ── Details card ──────────────────────────
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
          // Pickup / Drop-off
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
                _EditButton(onTap: () => _goToStep(1)),
              ],
            ),
          ),
          _Divider(),

          // Date & Time
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
                _EditButton(onTap: () => _goToStep(2)),
              ],
            ),
          ),
          _Divider(),

          // Meeting Point
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
                _EditButton(onTap: () => _goToStep(1)),
              ],
            ),
          ),
          _Divider(),

          // Seats & Price
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
                _EditButton(onTap: () => _goToStep(2)),
              ],
            ),
          ),
          _Divider(),

          // Vehicle
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
                _EditButton(onTap: () => _goToStep(2)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Tags row ──────────────────────────────
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

  // ── Bottom buttons ────────────────────────
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

  void _goToStep(int step) {
    Navigator.pop(context);
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

// ─────────────────────────────────────────────
//  Painters
// ─────────────────────────────────────────────

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    const gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF6EA8A0), Color(0xFF4A8A80)],
    );
    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));

    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 18) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    for (double x = 0; x < size.width; x += 18) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    final blockPaint = Paint()..color = Colors.white.withOpacity(0.08);
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 20; col++) {
        if ((row + col) % 3 == 0) {
          canvas.drawRect(
            Rect.fromLTWH(col * 18 + 1, row * 18 + 1, 16, 16),
            blockPaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _RouteLinePainter extends CustomPainter {
  final Color color;
  const _RouteLinePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(size.width * 0.5, size.height * 0.12);
    path.cubicTo(
      size.width * 0.42,
      size.height * 0.35,
      size.width * 0.58,
      size.height * 0.55,
      size.width * 0.5,
      size.height * 0.88,
    );
    canvas.drawPath(path, linePaint);

    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.12), 7,
        Paint()..color = Colors.white);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.12), 4,
        Paint()..color = color);

    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.88), 7,
        Paint()..color = color);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.88), 3,
        Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_) => false;
}
