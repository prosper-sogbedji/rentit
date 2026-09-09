import 'package:flutter/material.dart';
import 'booking_confirmation_screen.dart';

class ReservationScreen extends StatefulWidget {
  final Map<String, dynamic> item;

  const ReservationScreen({super.key, required this.item});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  // ── State ──────────────────────────────────────────────
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  int _startHour = 9; // 09:00
  int _durationHours = 4;

  final int _minDuration = 1;
  final int _maxDuration = 24;

  // ── Computed values ────────────────────────────────────
  int get _endHour => (_startHour + _durationHours).clamp(0, 48);

  double get _pricePerHour {
    return ((widget.item['price'] as int?) ?? 35).toDouble();
  }

  double get _rentalSubtotal => _pricePerHour * _durationHours;
  double get _serviceFee => double.parse((_rentalSubtotal * 0.12).toStringAsFixed(2));
  double get _total => _rentalSubtotal + _serviceFee;

  String _formatHour(int hour) {
    final h = hour % 24;
    final period = h < 12 ? 'AM' : 'PM';
    final display = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$display:00 $period';
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final weekday = days[d.weekday - 1];
    return '$weekday, ${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  // ── Build helpers ──────────────────────────────────────
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: Color(0xFF0F172A),
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    final now = DateTime.now();
    final firstDay = now;
    final lastDay = now.add(const Duration(days: 60));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: CalendarDatePicker(
        initialDate: _selectedDate,
        firstDate: firstDay,
        lastDate: lastDay,
        onDateChanged: (date) => setState(() => _selectedDate = date),
        selectableDayPredicate: (day) => !day.isBefore(
          DateTime(now.year, now.month, now.day),
        ),
      ),
    );
  }

  Widget _buildTimeControl({
    required String label,
    required String value,
    required VoidCallback onDecrease,
    required VoidCallback onIncrease,
    bool readOnly = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
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
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: onDecrease,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.remove,
                      size: 16,
                      color: Color(0xFF374151),
                    ),
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                GestureDetector(
                  onTap: readOnly ? null : onIncrease,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: readOnly
                          ? const Color(0xFFF1F5F9)
                          : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.add,
                      size: 16,
                      color: readOnly
                          ? const Color(0xFFCBD5E1)
                          : const Color(0xFF2563EB),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationSlider() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Rental Duration',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$_durationHours ${_durationHours == 1 ? "hour" : "hours"}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2563EB),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF2563EB),
            inactiveTrackColor: const Color(0xFFE2E8F0),
            thumbColor: const Color(0xFF2563EB),
            overlayColor: const Color(0xFF2563EB).withValues(alpha: 0.12),
            trackHeight: 5,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
          ),
          child: Slider(
            min: _minDuration.toDouble(),
            max: _maxDuration.toDouble(),
            divisions: _maxDuration - _minDuration,
            value: _durationHours.toDouble(),
            onChanged: (v) => setState(() => _durationHours = v.round()),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$_minDuration h',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$_maxDuration h',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickDurationChip(int h) {
    final selected = _durationHours == h;
    return GestureDetector(
      onTap: () => setState(() => _durationHours = h),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2563EB) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? const Color(0xFF2563EB)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          '${h}h',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : const Color(0xFF374151),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPriceLine(
            label:
                '\$${_pricePerHour.toStringAsFixed(0)} × $_durationHours ${_durationHours == 1 ? "hour" : "hours"}',
            value: '\$${_rentalSubtotal.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 10),
          _buildPriceLine(
            label: 'Service fee (12%)',
            value: '\$${_serviceFee.toStringAsFixed(2)}',
            light: true,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Color(0xFFE2E8F0), height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                '\$${_total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2563EB),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceLine({
    required String label,
    required String value,
    bool light = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: light ? const Color(0xFF94A3B8) : const Color(0xFF374151),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: light ? const Color(0xFF94A3B8) : const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemName =
        (widget.item['name'] as String?) ?? 'Pro Cordless Drill';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Book Equipment',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              itemName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Item summary strip ──
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: (widget.item['color'] as Color?) ??
                              const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: widget.item['image'] != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: widget.item['image'].startsWith('assets/')
                                    ? Image.asset(
                                        widget.item['image'],
                                        fit: BoxFit.cover,
                                      )
                                    : Image.network(
                                        widget.item['image'],
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            const Icon(Icons.error, color: Colors.grey),
                                      ),
                              )
                            : Icon(
                                (widget.item['icon'] as IconData?) ??
                                    Icons.construction,
                                color: (widget.item['iconColor'] as Color?) ??
                                    const Color(0xFFF59E0B),
                                size: 26,
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              itemName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '\$${_pricePerHour.toStringAsFixed(0)} / hour',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF2563EB),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 13,
                            color: Color(0xFFF59E0B),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${(widget.item['rating'] as double?) ?? 4.8}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF374151),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Select Date ──
                _buildSectionTitle('Select Date'),
                _buildCalendar(),

                const SizedBox(height: 24),

                // ── Start Time + End Time ──
                _buildSectionTitle('Rental Window'),
                Row(
                  children: [
                    _buildTimeControl(
                      label: 'START TIME',
                      value: _formatHour(_startHour),
                      onDecrease: () {
                        if (_startHour > 0) {
                          setState(() => _startHour--);
                        }
                      },
                      onIncrease: () {
                        if (_startHour < 22) {
                          setState(() => _startHour++);
                        }
                      },
                    ),
                    const SizedBox(width: 12),
                    _buildTimeControl(
                      label: 'END TIME',
                      value: _formatHour(_endHour),
                      onDecrease: () {},
                      onIncrease: () {},
                      readOnly: true,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ── Duration Quick chips ──
                Row(
                  children: [2, 4, 6, 8]
                      .map((h) => _buildQuickDurationChip(h))
                      .toList(),
                ),

                const SizedBox(height: 16),

                // ── Slider ──
                _buildDurationSlider(),

                const SizedBox(height: 24),

                // ── Booking Summary ──
                _buildSectionTitle('Booking Summary'),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Column(
                    children: [
                      _buildSummaryRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Date',
                        value: _formatDate(_selectedDate),
                      ),
                      const SizedBox(height: 10),
                      _buildSummaryRow(
                        icon: Icons.schedule_outlined,
                        label: 'Time',
                        value:
                            '${_formatHour(_startHour)} → ${_formatHour(_endHour)}',
                      ),
                      const SizedBox(height: 10),
                      _buildSummaryRow(
                        icon: Icons.timer_outlined,
                        label: 'Duration',
                        value:
                            '$_durationHours ${_durationHours == 1 ? "hour" : "hours"}',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Price breakdown ──
                _buildSectionTitle('Price Breakdown'),
                _buildPriceSummary(),
              ],
            ),
          ),

          // ── Sticky bottom CTA ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
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
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '\$${_total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '$_durationHours ${_durationHours == 1 ? "hour" : "hours"} · incl. fees',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BookingConfirmationScreen(
                              item: widget.item,
                              selectedDate: _selectedDate,
                              startHour: _startHour,
                              durationHours: _durationHours,
                              totalPrice: _total,
                              subtotal: _rentalSubtotal,
                              serviceFee: _serviceFee,
                            ),
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
                      child: const Text(
                        'Confirm & Book',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF2563EB)),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF3B82F6),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }
}
