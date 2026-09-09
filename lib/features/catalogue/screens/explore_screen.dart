import 'package:flutter/material.dart';
import '../../catalogue/screens/item_details_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  int _selectedCategoryIndex = 0;

  final List<Map<String, dynamic>> _categories = [
    {'label': 'All', 'icon': Icons.apps},
    {'label': 'Tools', 'icon': Icons.construction},
    {'label': 'Photo', 'icon': Icons.camera_alt_outlined},
    {'label': 'Outdoor', 'icon': Icons.terrain_outlined},
    {'label': 'Audio', 'icon': Icons.headphones_outlined},
  ];

  final List<Map<String, dynamic>> _featuredItems = [
    {
      'id': 'item_1',
      'name': 'Pro Cordless Drill',
      'category': 'TOOLS',
      'price': 35,
      'rating': 4.8,
      'reviews': 93,
      'color': const Color(0xFFFFF7ED),
      'icon': Icons.construction,
      'iconColor': const Color(0xFFF59E0B),
      'image': 'assets/images/drill.jpg',
      'badge': 'Featured',
    },
    {
      'id': 'item_2',
      'name': 'DSLR Master Kit',
      'category': 'PHOTOGRAPHY',
      'price': 85,
      'rating': 4.8,
      'reviews': 32,
      'color': const Color(0xFFEFF6FF),
      'icon': Icons.camera_alt_outlined,
      'iconColor': const Color(0xFF2563EB),
      'image': 'assets/images/camera.jpg',
      'badge': 'Featured',
    },
  ];

  final List<Map<String, dynamic>> _trendingItems = [
    {
      'id': 'item_3',
      'name': 'DSLR Master Kit',
      'category': 'PHOTOGRAPHY',
      'price': 85,
      'rating': 4.8,
      'reviews': 32,
      'color': const Color(0xFFEFF6FF),
      'icon': Icons.camera_alt_outlined,
      'iconColor': const Color(0xFF2563EB),
      'image': 'assets/images/camera.jpg',
      'badge': 'Featured',
    },
    {
      'id': 'item_4',
      'name': 'Alpine 4P Tent',
      'category': 'OUTDOORS',
      'price': 40,
      'rating': 4.7,
      'reviews': 20,
      'color': const Color(0xFFF0FDF4),
      'icon': Icons.terrain_outlined,
      'iconColor': const Color(0xFF059669),
      'image': 'assets/images/tent.jpg',
      'badge': 'Featured',
    },
  ];

  final List<Map<String, dynamic>> _recentItems = [
    {
      'id': 'item_5',
      'name': 'Heavy Duty Toolkit',
      'timeAgo': '2 hours ago',
      'addedBy': 'Mason Dec.',
      'price': 15,
      'rating': 4.9,
      'status': 'new',
      'icon': Icons.build_outlined,
      'color': const Color(0xFFFFF7ED),
      'iconColor': const Color(0xFFF59E0B),
      'image': 'assets/images/toolkit.jpg',
    },
    {
      'id': 'item_6',
      'name': 'Specialized Road Bike',
      'timeAgo': '5 hours ago',
      'addedBy': 'SOMA',
      'price': 25,
      'rating': 4.5,
      'status': 'popular',
      'icon': Icons.directions_bike_outlined,
      'color': const Color(0xFFEFF6FF),
      'iconColor': const Color(0xFF2563EB),
      'image': 'assets/images/bike.jpg',
    },
  ];

  Widget _buildCategoryChip(int index, Map<String, dynamic> cat) {
    final bool selected = _selectedCategoryIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategoryIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2563EB) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected
                ? const Color(0xFF2563EB)
                : const Color(0xFFE2E8F0),
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(
              cat['icon'] as IconData,
              size: 16,
              color: selected ? Colors.white : const Color(0xFF64748B),
            ),
            const SizedBox(width: 6),
            Text(
              cat['label'] as String,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : const Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedCard(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ItemDetailsScreen(item: item),
          ),
        );
      },
      child: Container(
        width: 190,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            Stack(
              children: [
                Container(
                  height: 130,
                  decoration: BoxDecoration(
                    color: item['color'] as Color,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                  ),
                  child: Center(
                    child: item['image'] != null
                        ? ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(18),
                            ),
                            child: Image.asset(
                              item['image'] as String,
                              width: double.infinity,
                              height: 130,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            item['icon'] as IconData,
                            size: 56,
                            color: item['iconColor'] as Color,
                          ),
                  ),
                ),
                // Badge
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item['badge'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                // Favourite icon
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.bookmark_border,
                      size: 16,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['category'] as String,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['name'] as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '\$${item['price']}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                            const TextSpan(
                              text: ' /h',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF94A3B8),
                                fontWeight: FontWeight.w500,
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
                            '${item['rating']}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF374151),
                            ),
                          ),
                          Text(
                            ' (${item['reviews']})',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingCard(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ItemDetailsScreen(item: item),
          ),
        );
      },
      child: Container(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 110,
                  decoration: BoxDecoration(
                    color: item['color'] as Color,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Center(
                    child: item['image'] != null
                        ? ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            child: Image.asset(
                              item['image'] as String,
                              width: double.infinity,
                              height: 110,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            item['icon'] as IconData,
                            size: 44,
                            color: item['iconColor'] as Color,
                          ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item['badge'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.bookmark_border,
                      size: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['category'] as String,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item['name'] as String,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '\$${item['price']}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                        const TextSpan(
                          text: ' /h',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 12,
                        color: Color(0xFFF59E0B),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${item['rating']} (${item['reviews']})',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentItem(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ItemDetailsScreen(item: item),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: item['color'] as Color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: item['image'] != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        item['image'] as String,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(
                      item['icon'] as IconData,
                      color: item['iconColor'] as Color,
                      size: 28,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${item['timeAgo']} · ${item['addedBy']}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '\$${item['price']}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                            const TextSpan(
                              text: ' /h',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.star,
                        size: 12,
                        color: Color(0xFFF59E0B),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${item['rating']}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: item['status'] == 'new'
                    ? const Color(0xFFD1FAE5)
                    : const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                item['status'] == 'new' ? 'New' : 'Popular',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: item['status'] == 'new'
                      ? const Color(0xFF059669)
                      : const Color(0xFFF59E0B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ──── AppBar ────
            SliverAppBar(
              floating: true,
              backgroundColor: Colors.white,
              elevation: 0,
              scrolledUnderElevation: 0,
              title: Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Color(0xFF2563EB),
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Location',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'San Francisco, CA',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFF2563EB),
                    child: const Text(
                      'AJ',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ──── Search Bar ────
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14),
                            child: Icon(
                              Icons.search,
                              color: Color(0xFF94A3B8),
                              size: 22,
                            ),
                          ),
                          const Expanded(
                            child: TextField(
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF0F172A),
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search equipment, tools...',
                                hintStyle: TextStyle(
                                  color: Color(0xFFCBD5E1),
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.all(6),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.tune,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ──── Category Chips ────
                    SizedBox(
                      height: 44,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        itemBuilder: (ctx, i) =>
                            _buildCategoryChip(i, _categories[i]),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ──── Featured Gear ────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '⚡ Featured Gear',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Row(
                            children: [
                              Text(
                                'See All',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                              SizedBox(width: 2),
                              Icon(
                                Icons.arrow_forward,
                                size: 14,
                                color: Color(0xFF2563EB),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 260,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _featuredItems.length,
                        itemBuilder: (ctx, i) =>
                            _buildFeaturedCard(_featuredItems[i]),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ──── Trending Near You ────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '🔥 Trending Near You',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Row(
                            children: [
                              Text(
                                'See All',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                              SizedBox(width: 2),
                              Icon(
                                Icons.arrow_forward,
                                size: 14,
                                color: Color(0xFF2563EB),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.72,
                      children: _trendingItems
                          .map((item) => _buildTrendingCard(item))
                          .toList(),
                    ),

                    const SizedBox(height: 24),

                    // ──── Recently Added ────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '🕐 Recently Added',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Row(
                            children: [
                              Text(
                                'See All',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                              SizedBox(width: 2),
                              Icon(
                                Icons.arrow_forward,
                                size: 14,
                                color: Color(0xFF2563EB),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._recentItems
                        .map((item) => _buildRecentItem(item)),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // BottomNavigationBar managed by MainShell
    );
  }
}
