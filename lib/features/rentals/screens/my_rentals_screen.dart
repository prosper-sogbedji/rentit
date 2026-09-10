import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/rental_model.dart';
import '../providers/rental_provider.dart';
import '../widgets/rental_card.dart';
import '../widgets/rental_insight_metric.dart';

class MyRentalsScreen extends StatefulWidget {
  const MyRentalsScreen({super.key});

  @override
  State<MyRentalsScreen> createState() => _MyRentalsScreenState();
}

class _MyRentalsScreenState extends State<MyRentalsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildRentalList(RentalProvider provider, String statusName) {
    if (provider.isLoading && provider.rentals.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    final rentals = provider.rentals
        .where((r) => r.status.name.toLowerCase() == statusName.toLowerCase())
        .toList();

    if (rentals.isEmpty) {
      final displayStatus = statusName == 'confirmed' ? 'active' : statusName;
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 12),
              Text(
                'No $displayStatus rentals found',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: rentals.map((rental) {
        final item = provider.getItemForRental(rental.itemId);
        final itemName = item?.name ?? 'Rental #${rental.id.substring(0, math.min(8, rental.id.length))}';
        final itemImageUrl = (item?.imageUrl != null && item!.imageUrl.isNotEmpty)
            ? item.imageUrl
            : (rental.status == RentalStatus.confirmed
                ? 'assets/images/drill.jpg'
                : (rental.status == RentalStatus.pending
                    ? 'assets/images/camera.jpg'
                    : 'assets/images/jackhammer.jpg'));

        return RentalCard(
          rental: rental,
          itemName: itemName,
          ownerName: 'Verified Partner',
          itemImageUrl: itemImageUrl,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$itemName (${rental.status.name.toUpperCase()})'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RentalProvider>();
    final totalSpent = provider.rentals.fold<double>(
      0.0,
      (sum, r) => sum + r.totalPrice,
    );
    final itemsRentedCount = provider.rentals.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'My Rentals',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none_outlined,
              color: Color(0xFF0F172A),
            ),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF2563EB),
              unselectedLabelColor: const Color(0xFF64748B),
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              indicatorColor: const Color(0xFF2563EB),
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: const [
                Tab(text: 'Active'),
                Tab(text: 'Pending'),
                Tab(text: 'Completed'),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filtered Rentals List based on active tab
            AnimatedBuilder(
              animation: _tabController,
              builder: (context, child) {
                final currentStatus = _tabController.index == 0
                    ? 'confirmed'
                    : (_tabController.index == 1 ? 'pending' : 'completed');
                return _buildRentalList(provider, currentStatus);
              },
            ),

            const SizedBox(height: 12),

            // RENTAL INSIGHTS SECTION
            const Text(
              'RENTAL INSIGHTS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF64748B),
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                RentalInsightMetric(
                  label: 'Total Spent',
                  value: '\$${totalSpent.toStringAsFixed(2)}',
                ),
                const SizedBox(width: 12),
                RentalInsightMetric(
                  label: 'Items Rented',
                  value: '$itemsRentedCount',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Help Banner Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withValues(alpha: 0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      color: Color(0xFF2563EB),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Need help with a rental?',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Contact support or resolution center',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: Color(0xFF2563EB),
                    size: 20,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
      // BottomNavigationBar managed by MainShell
    );
  }
}
