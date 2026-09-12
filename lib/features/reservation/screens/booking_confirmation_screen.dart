import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../main.dart';
import '../../../models/item_model.dart';
import '../../../models/rental_model.dart';
import '../../rentals/providers/rental_provider.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final ItemModel item;
  final DateTime selectedDate;
  final int startHour;
  final int durationHours;
  final double totalPrice;
  final double subtotal;
  final double serviceFee;

  const BookingConfirmationScreen({
    super.key,
    required this.item,
    required this.selectedDate,
    required this.startHour,
    required this.durationHours,
    required this.totalPrice,
    required this.subtotal,
    required this.serviceFee,
  });

  // ── Helpers ────────────────────────────────────────────
  String _formatHour(int hour) {
    return DateFormat('h:mm a').format(DateTime(2000, 1, 1, hour % 24));
  }

  String _formatDate(DateTime d) {
    return DateFormat('EEEE, MMMM d').format(d);
  }

  int get _endHour => (startHour + durationHours).clamp(0, 48);

  RentalModel _buildRentalModel() {
    final now = DateTime.now();
    final start = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      startHour % 24,
    );
    final end = start.add(Duration(hours: durationHours));
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? 'user_active';
    return RentalModel(
      id: 'booking_${now.millisecondsSinceEpoch}',
      userId: currentUid,
      itemId: item.id,
      startDate: start,
      endDate: end,
      duration: durationHours,
      totalPrice: totalPrice,
      status: RentalStatus.pending,
      createdAt: now,
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color iconColor = const Color(0xFF2563EB),
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  double get _pricePerHour => item.pricePerDay / 24;

  Color get _itemColor => const Color(0xFFFFF7ED);
  IconData get _itemIcon => switch (item.categoryId) {
    'tools' => Icons.build_rounded,
    'electronics' => Icons.devices_rounded,
    'vehicles' => Icons.directions_car_rounded,
    _ => Icons.inventory_2_rounded,
  };
  Color get _itemIconColor => const Color(0xFFF59E0B);

  Widget _buildPriceLine({
    required String label,
    required String value,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
            color: isTotal ? const Color(0xFF0F172A) : const Color(0xFF475569),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 20 : 14,
            fontWeight: FontWeight.w700,
            color: isTotal ? const Color(0xFF2563EB) : const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildStepHeader() {
    return Row(
      children: [
        _buildStep(number: '1', label: 'Schedule'),
        Expanded(child: Container(height: 1, color: const Color(0xFF2563EB))),
        _buildStep(number: '2', label: 'Confirm', active: true),
      ],
    );
  }

  Widget _buildStep({
    required String number,
    required String label,
    bool active = false,
  }) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? const Color(0xFF2563EB) : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: active ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1),
            ),
          ),
          child: Text(
            number,
            style: TextStyle(
              color: active ? Colors.white : const Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 7),
        Text(
          label,
          style: TextStyle(
            color: active ? const Color(0xFF2563EB) : const Color(0xFF64748B),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Build (but don't yet persist) the rental
    final rental = _buildRentalModel();
    final itemName = item.name;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Review your booking',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 128),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStepHeader(),
                const SizedBox(height: 22),

                // ── Booking status banner ──
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.hourglass_top_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Review Your Booking',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Please confirm the details below before proceeding.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // ── Item Card ──
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          color: _itemColor,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: item.imageUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: item.imageUrl.startsWith('assets/')
                                    ? Image.asset(
                                        item.imageUrl,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.network(
                                        item.imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            const Icon(Icons.error, color: Colors.grey),
                                      ),
                              )
                            : Icon(_itemIcon, color: _itemIconColor, size: 30),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              itemName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD1FAE5),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Available',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF059669),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${_pricePerHour.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                          const Text(
                            'per hour',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // ── Booking Details ──
                const Text(
                  'Booking Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'DATE',
                        value: _formatDate(selectedDate),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(color: Color(0xFFE2E8F0), height: 1),
                      ),
                      _buildDetailRow(
                        icon: Icons.schedule_outlined,
                        label: 'PICKUP TIME',
                        value: _formatHour(startHour),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(color: Color(0xFFE2E8F0), height: 1),
                      ),
                      _buildDetailRow(
                        icon: Icons.flag_outlined,
                        label: 'RETURN TIME',
                        value: _formatHour(_endHour),
                        iconColor: const Color(0xFF10B981),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(color: Color(0xFFE2E8F0), height: 1),
                      ),
                      _buildDetailRow(
                        icon: Icons.timer_outlined,
                        label: 'DURATION',
                        value:
                            '$durationHours ${durationHours == 1 ? "hour" : "hours"}',
                        iconColor: const Color(0xFF7C3AED),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // ── Price Breakdown ──
                const Text(
                  'Price Breakdown',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      _buildPriceLine(
                        label:
                            '\$${_pricePerHour.toStringAsFixed(0)} × $durationHours ${durationHours == 1 ? "hour" : "hours"}',
                        value: '\$${subtotal.toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 12),
                      _buildPriceLine(
                        label: 'Service fee (12%)',
                        value: '\$${serviceFee.toStringAsFixed(2)}',
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(color: Color(0xFFE2E8F0), height: 1),
                      ),
                      _buildPriceLine(
                        label: 'Total',
                        value: '\$${rental.totalPrice.toStringAsFixed(2)}',
                        isTotal: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Guarantee note ──
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        size: 18,
                        color: Color(0xFF2563EB),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Free cancellation up to 24 hours before pickup. RentIt Guarantee covers damage up to \$500.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF3B82F6),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Sticky CTA ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () async {
                  // Enregistrer la réservation dans le RentalProvider (gestion d'état réactive)
                  await context.read<RentalProvider>().bookRental(rental, item: item);

                  if (!context.mounted) return;

                  // Show success dialog
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => _SuccessDialog(
                      itemName: itemName,
                      date: _formatDate(selectedDate),
                      startTime: _formatHour(startHour),
                      endTime: _formatHour(_endHour),
                      total: rental.totalPrice,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_outline, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Pay \$${rental.totalPrice.toStringAsFixed(2)} — Confirm Booking',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Success dialog ──────────────────────────────────────────────
class _SuccessDialog extends StatelessWidget {
  final String itemName;
  final String date;
  final String startTime;
  final String endTime;
  final double total;

  const _SuccessDialog({
    required this.itemName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ Icon
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFD1FAE5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Color(0xFF059669),
                size: 40,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Booking Confirmed!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              itemName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _row('Date', date),
                  const SizedBox(height: 8),
                  _row('Time', '$startTime → $endTime'),
                  const SizedBox(height: 8),
                  _row(
                    'Total',
                    '\$${total.toStringAsFixed(2)}',
                    bold: true,
                    highlight: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Naviguer directement vers le shell principal sur l'onglet Mes Locations (index 2)
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const MainShell(initialIndex: 2),
                    ),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'View My Rentals',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(
    String label,
    String value, {
    bool bold = false,
    bool highlight = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            color: highlight
                ? const Color(0xFF2563EB)
                : const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
