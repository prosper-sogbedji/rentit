import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/providers/notification_provider.dart';
import '../../notifications/screens/notifications_modal.dart';
import '../../../models/rental_model.dart';
import '../providers/rental_provider.dart';
import '../widgets/rental_card.dart';
import '../widgets/rental_details_modal.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<RentalProvider>().loadRentals();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildRentalList(RentalProvider provider, int tabIndex, bool isFr) {
    if (provider.isLoading && provider.rentals.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    final rentals = provider.rentals.where((r) {
      if (tabIndex == 0) {
        // Tab Actives : uniquement les locations confirmées
        return r.status == RentalStatus.confirmed;
      } else if (tabIndex == 1) {
        // Tab En attente
        return r.status == RentalStatus.pending;
      } else {
        // Tab Terminées
        return r.status == RentalStatus.completed || r.status == RentalStatus.cancelled;
      }
    }).toList();

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
                isFr ? 'Aucune location dans cette catégorie' : 'No rentals in this category',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
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
        final itemName = item?.name ?? (isFr ? 'Location #${rental.id.substring(0, math.min(8, rental.id.length))}' : 'Rental #${rental.id.substring(0, math.min(8, rental.id.length))}');
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
          ownerName: isFr ? 'Partenaire Vérifié' : 'Verified Partner',
          itemImageUrl: itemImageUrl,
          onTap: () {
            RentalDetailsModal.show(
              context,
              rental: rental,
              item: item,
              isFr: isFr,
            );
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RentalProvider>();
    final lang = context.watch<LanguageProvider>();
    final notifProvider = context.watch<NotificationProvider>();
    final isFr = lang.isFrench;
    final currency = isFr ? '€' : '\$';

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
        title: Text(
          lang.t('rentals_title'),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none_outlined,
                  color: Color(0xFF0F172A),
                ),
                onPressed: () => NotificationsModal.show(context),
              ),
              if (notifProvider.unreadCount > 0)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
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
              tabs: [
                Tab(text: lang.t('tab_active')),
                Tab(text: lang.t('tab_pending')),
                Tab(text: lang.t('tab_completed')),
              ],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<RentalProvider>().loadRentals(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filtered Rentals List based on active tab
              AnimatedBuilder(
                animation: _tabController,
                builder: (context, child) {
                  return _buildRentalList(provider, _tabController.index, isFr);
                },
              ),

              const SizedBox(height: 16),

              // RENTAL INSIGHTS SECTION
              Text(
                isFr ? 'APERÇU DES DÉPENSES' : 'RENTAL INSIGHTS',
                style: const TextStyle(
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
                    label: isFr ? 'Total dépensé' : 'Total Spent',
                    value: '$currency${totalSpent.toStringAsFixed(2)}',
                  ),
                  const SizedBox(width: 12),
                  RentalInsightMetric(
                    label: isFr ? 'Articles loués' : 'Items Rented',
                    value: '$itemsRentedCount',
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
