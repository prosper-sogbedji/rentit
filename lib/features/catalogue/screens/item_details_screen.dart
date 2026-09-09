import 'package:flutter/material.dart';

class ItemDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> item;

  const ItemDetailsScreen({super.key, required this.item});

  Widget _buildFeatureBadge({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF2563EB)),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 0.3,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String name = (item['name'] as String?) ?? 'Pro-Series 18V Cordless Combo Kit';
    final int price = (item['price'] as int?) ?? 45;
    final double rating = (item['rating'] as double?) ?? 4.9;
    final int reviews = (item['reviews'] as int?) ?? 14;
    final Color bgColor = (item['color'] as Color?) ?? const Color(0xFFFFF7ED);
    final IconData icon = (item['icon'] as IconData?) ?? Icons.construction;
    final Color iconColor = (item['iconColor'] as Color?) ?? const Color(0xFFF59E0B);
    final String? image = item['image'] as String?;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ──── Collapsible Hero Image ────
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: Colors.white,
                elevation: 0,
                leading: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF0F172A),
                      size: 20,
                    ),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.bookmark_border,
                        color: Color(0xFF0F172A),
                        size: 20,
                      ),
                      onPressed: () {},
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.share_outlined,
                        color: Color(0xFF0F172A),
                        size: 20,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    color: bgColor,
                    child: Stack(
                      children: [
                        Center(
                          child: image != null
                              ? Image.asset(
                                  image,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : Icon(icon, size: 100, color: iconColor),
                        ),
                        // Top Rated badge
                        Positioned(
                          top: 80,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Top Rated',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        // Pagination dots
                        Positioned(
                          bottom: 16,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              3,
                              (i) => Container(
                                width: i == 0 ? 20 : 6,
                                height: 6,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: i == 0
                                      ? const Color(0xFF2563EB)
                                      : Colors.white.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ──── Content ────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category + Rating row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              (item['category'] as String?) ?? 'POWER TOOLS',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2563EB),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: Color(0xFFF59E0B),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$rating ($reviews)',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Item Name
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          height: 1.2,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Location
                      const Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 15,
                            color: Color(0xFF64748B),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Downtown, San Francisco',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ──── Feature badges grid ────
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 3.0,
                        children: [
                          _buildFeatureBadge(
                            icon: Icons.electric_bolt_outlined,
                            label: 'Motor',
                            value: 'EC Brushless',
                          ),
                          _buildFeatureBadge(
                            icon: Icons.scale_outlined,
                            label: 'Weight',
                            value: '12.4 lbs Total',
                          ),
                          _buildFeatureBadge(
                            icon: Icons.battery_charging_full_outlined,
                            label: 'Battery',
                            value: '5.0Ah Li-Ion',
                          ),
                          _buildFeatureBadge(
                            icon: Icons.handyman_outlined,
                            label: 'Includes',
                            value: '7 Tools + Case',
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // ──── About ────
                      const Text(
                        'About this equipment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'This professional-grade 18V combo kit includes a high-torque hammer drill, impact driver, circular saw, and large-capacity batteries. Perfect for heavy-duty construction or serious DIY weekend projects. Maintained to professional standards and fully sanitized after every rental.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF475569),
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 22),

                      // ──── Owner Information ────
                      const Text(
                        'Owner Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 24,
                              backgroundColor: Color(0xFF2563EB),
                              child: Text(
                                'MV',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'Marcus V.',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      const Icon(
                                        Icons.verified,
                                        size: 14,
                                        color: Color(0xFF2563EB),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  const Text(
                                    'Response time: ~1 hour',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.chat_bubble_outline,
                                size: 14,
                                color: Color(0xFF2563EB),
                              ),
                              label: const Text(
                                'Chat',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFF2563EB),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ──── RentIt Guarantee ────
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
                              size: 20,
                              color: Color(0xFF2563EB),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'RentIt Guarantee Included',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  SizedBox(height: 3),
                                  Text(
                                    'This item is covered by our damage protection policy. Rent with peace of mind.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF3B82F6),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ──── Sticky Bottom Bar ────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
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
                              text: '\$$price',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const TextSpan(
                              text: ' /h',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF94A3B8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 13,
                            color: Color(0xFF10B981),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Available Tomorrow',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF10B981),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Book Now',
                        style: TextStyle(
                          fontSize: 16,
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
}
