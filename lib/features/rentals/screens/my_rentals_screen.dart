import 'package:flutter/material.dart';
import '../../../models/rental_model.dart';
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

  // Mock data matching the design before Firebase integration
  final List<RentalModel> _allRentals = [
    RentalModel(
      id: 'rent_1',
      userId: 'user_1',
      itemId: 'item_1',
      startDate: DateTime(2026, 10, 12),
      endDate: DateTime(2026, 10, 15),
      duration: 3,
      totalPrice: 45.00,
      status: 'active',
      createdAt: DateTime.now(),
    ),
    RentalModel(
      id: 'rent_2',
      userId: 'user_1',
      itemId: 'item_2',
      startDate: DateTime(2026, 10, 20),
      endDate: DateTime(2026, 10, 22),
      duration: 2,
      totalPrice: 70.00,
      status: 'pending',
      createdAt: DateTime.now(),
    ),
    RentalModel(
      id: 'rent_3',
      userId: 'user_1',
      itemId: 'item_3',
      startDate: DateTime(2026, 9, 1),
      endDate: DateTime(2026, 9, 4),
      duration: 3,
      totalPrice: 120.00,
      status: 'completed',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

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

  List<RentalModel> _filterRentals(String status) {
    return _allRentals
        .where((r) => r.status.toLowerCase() == status.toLowerCase())
        .toList();
  }

  Widget _buildRentalList(String status) {
    final rentals = _filterRentals(status);

    if (rentals.isEmpty) {
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
                'No $status rentals found',
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
        return RentalCard(
          rental: rental,
          itemName: rental.status == 'active'
              ? 'Professional Cordless Drill'
              : (rental.status == 'pending'
                  ? 'DSLR Camera 4K Master'
                  : 'Heavy Duty Jackhammer'),
          ownerName: rental.status == 'active'
              ? 'Sarah J.'
              : (rental.status == 'pending' ? 'David L.' : 'Marc A.'),
          itemImageUrl: rental.status == 'active'
              ? 'assets/images/drill.jpg'
              : (rental.status == 'pending'
                  ? 'assets/images/camera.jpg'
                  : 'assets/images/jackhammer.jpg'),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Details for rental #${rental.id}'),
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
                    ? 'active'
                    : (_tabController.index == 1 ? 'pending' : 'completed');
                return _buildRentalList(currentStatus);
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

            const Row(
              children: [
                RentalInsightMetric(
                  label: 'Total Spent',
                  value: '\$315.00',
                ),
                SizedBox(width: 12),
                RentalInsightMetric(
                  label: 'Items Rented',
                  value: '12',
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
