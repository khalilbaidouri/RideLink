import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/trip_providers.dart';
import '../widgets/map_preview.dart';
import '../widgets/review_detail_card.dart';

class ReviewPublishScreen extends ConsumerStatefulWidget {
  final RideReviewData data;
  const ReviewPublishScreen({super.key, required this.data});

  @override
  ConsumerState<ReviewPublishScreen> createState() =>
      _ReviewPublishScreenState();
}

class _ReviewPublishScreenState extends ConsumerState<ReviewPublishScreen> {
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
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
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
      await publishRide(widget.data);
      if (!mounted) return;
      _showSuccessDialog();
    } on PostgrestException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erreur Supabase: ${e.message}'),
            backgroundColor: Colors.red.shade700),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red.shade700),
      );
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  Future<void> _saveDraft() async {
    setState(() => _isSavingDraft = true);
    try {
      await saveDraft(widget.data);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Trajet sauvegardé comme brouillon.'),
            backgroundColor: Color(0xFF1E5C2E)),
      );
      Navigator.of(context).popUntil((r) => r.isFirst);
    } on PostgrestException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erreur Supabase: ${e.message}'),
            backgroundColor: Colors.red.shade700),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red.shade700),
      );
    } finally {
      if (mounted) setState(() => _isSavingDraft = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
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
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('Your ride is now visible to passengers.',
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(dialogCtx).pop();
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
    final busy = _isPublishing || _isSavingDraft;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // AppBar
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                            Text('Step 3 of 3',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey.shade800)),
                            const Text('Review & Publish',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _primary)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: const LinearProgressIndicator(
                            value: 1.0,
                            backgroundColor: Color(0xFFE0E0E0),
                            valueColor:
                                AlwaysStoppedAnimation<Color>(_primary),
                            minHeight: 5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    const Text('Final Review',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A1A))),
                    const SizedBox(height: 4),
                    Text(
                      'Check your ride details before making it\npublic for other travelers.',
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          height: 1.4),
                    ),
                    const SizedBox(height: 14),

                    // Map
                    MapPreview(
                      departureName: d.departureCityName,
                      destinationName: d.destinationCityName,
                      departureLat: d.departureLat,
                      departureLng: d.departureLng,
                      destinationLat: d.destinationLat,
                      destinationLng: d.destinationLng,
                      height: 160,
                      primary: _primary,
                      showBadge: true,
                    ),
                    const SizedBox(height: 14),

                    // Details card
                    Container(
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
                          // Pickup / Dropoff
                          DetailRow(
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
                                        border: Border.all(
                                            color: Colors.grey.shade400,
                                            width: 2),
                                      ),
                                    ),
                                    Container(
                                        width: 2,
                                        height: 36,
                                        color: Colors.grey.shade300),
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _primary),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const ReviewLabel('PICKUP'),
                                      Text(
                                        d.meetingPoint.isNotEmpty
                                            ? d.meetingPoint
                                            : d.departureCityName,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 18),
                                      const ReviewLabel('DROP-OFF'),
                                      Text(
                                        d.dropoffPoint.isNotEmpty
                                            ? d.dropoffPoint
                                            : d.destinationCityName,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                                EditButton(
                                    onTap: () => Navigator.pop(context)),
                              ],
                            ),
                          ),
                          const ReviewDivider(),

                          // Date & Time
                          DetailRow(
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEF4ED),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                      Icons.calendar_month_outlined,
                                      color: _primary,
                                      size: 20),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const ReviewLabel('DATE & TIME'),
                                      Text(
                                        _formatDateTime(d.departureDateTime),
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                ),
                                EditButton(
                                    onTap: () => Navigator.pop(context)),
                              ],
                            ),
                          ),
                          const ReviewDivider(),

                          // Meeting point
                          DetailRow(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const ReviewLabel('MEETING POINT'),
                                      Text(
                                        d.meetingPoint.isNotEmpty
                                            ? d.meetingPoint
                                            : '—',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                                EditButton(
                                    onTap: () => Navigator.pop(context)),
                              ],
                            ),
                          ),
                          const ReviewDivider(),

                          // Seats + Price
                          DetailRow(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const ReviewLabel('SEATS'),
                                      Row(children: [
                                        const Icon(Icons.people_outline,
                                            color: _primary, size: 18),
                                        const SizedBox(width: 4),
                                        Text('${d.seats} Availab.',
                                            style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700)),
                                      ]),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const ReviewLabel('PRICE'),
                                      Row(children: [
                                        const Icon(
                                            Icons.monetization_on_outlined,
                                            color: _primary,
                                            size: 18),
                                        const SizedBox(width: 4),
                                        Text(
                                            '${d.price.toStringAsFixed(0)} MAD',
                                            style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700)),
                                      ]),
                                    ],
                                  ),
                                ),
                                EditButton(
                                    onTap: () => Navigator.pop(context)),
                              ],
                            ),
                          ),
                          const ReviewDivider(),

                          // Vehicle
                          DetailRow(
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEF4ED),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                      Icons.directions_car_filled_rounded,
                                      color: _primary,
                                      size: 20),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const ReviewLabel('VEHICLE'),
                                      Text(
                                        '${d.vehicleName} • ${d.vehicleColor}',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                ),
                                EditButton(
                                    onTap: () => Navigator.pop(context)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Tags
                    const Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        TagChip(
                            icon: Icons.bolt, label: 'Instant Booking'),
                        TagChip(
                            icon: Icons.eco_outlined, label: 'Eco-Friendly'),
                        TagChip(
                            icon: Icons.people_outline,
                            label: 'Max 2 in back'),
                      ],
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),

            // Bottom buttons
            Padding(
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
                          : const Text('Publish Ride',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700)),
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
                        : Text('Save as Draft',
                            style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 15,
                                fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}