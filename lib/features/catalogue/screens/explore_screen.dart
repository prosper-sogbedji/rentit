import 'package:flutter/material.dart';
import '../../auth/screens/profile_screen.dart';
import '../../catalogue/screens/item_details_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  int _selectedCategoryIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortBy = 'recommended'; // 'recommended', 'price_asc', 'price_desc', 'rating'
  double _maxPrice = 150.0;
  String _currentLocation = 'San Francisco, CA';
  final Set<String> _savedItemIds = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleBookmark(String itemId, String itemName) {
    setState(() {
      if (_savedItemIds.contains(itemId)) {
        _savedItemIds.remove(itemId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$itemName retiré des favoris'),
            duration: const Duration(milliseconds: 1000),
          ),
        );
      } else {
        _savedItemIds.add(itemId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$itemName ajouté aux favoris ! ❤️'),
            duration: const Duration(milliseconds: 1000),
            backgroundColor: const Color(0xFF2563EB),
          ),
        );
      }
    });
  }

  bool get _isFilteringActive =>
      _selectedCategoryIndex != 0 ||
      _searchQuery.trim().isNotEmpty ||
      _sortBy != 'recommended' ||
      _maxPrice < 150.0;

  List<Map<String, dynamic>> get _filteredItems {
    final selectedCat = _categories[_selectedCategoryIndex]['label'] as String;
    final list = _allCatalogItems.where((item) {
      // Filtre catégorie
      if (selectedCat != 'All') {
        final itemCat = (item['category'] as String).toUpperCase();
        if (!itemCat.contains(selectedCat.toUpperCase())) {
          return false;
        }
      }
      // Filtre texte recherche
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.trim().toLowerCase();
        final name = (item['name'] as String).toLowerCase();
        final cat = (item['category'] as String).toLowerCase();
        if (!name.contains(q) && !cat.contains(q)) {
          return false;
        }
      }
      // Filtre prix max
      final price = (item['price'] is num) ? (item['price'] as num).toDouble() : 0.0;
      if (price > _maxPrice) {
        return false;
      }
      return true;
    }).toList();

    // Tri
    list.sort((a, b) {
      final pA = (a['price'] as num).toDouble();
      final pB = (b['price'] as num).toDouble();
      final rA = (a['rating'] as num).toDouble();
      final rB = (b['rating'] as num).toDouble();
      switch (_sortBy) {
        case 'price_asc':
          return pA.compareTo(pB);
        case 'price_desc':
          return pB.compareTo(pA);
        case 'rating':
          return rB.compareTo(rA);
        case 'recommended':
        default:
          return 0;
      }
    });

    return list;
  }

  final List<Map<String, dynamic>> _categories = [
    {'label': 'All', 'icon': Icons.apps},
    {'label': 'Tools', 'icon': Icons.construction},
    {'label': 'Photo', 'icon': Icons.camera_alt_outlined},
    {'label': 'Outdoor', 'icon': Icons.terrain_outlined},
    {'label': 'Audio', 'icon': Icons.headphones_outlined},
  ];

  late final List<Map<String, dynamic>> _allCatalogItems = [
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
      'status': 'popular',
      'timeAgo': '1 hour ago',
      'addedBy': 'Sarah J.',
    },
    {
      'id': 'item_2',
      'name': 'DSLR Master Kit 4K',
      'category': 'PHOTO',
      'price': 85,
      'rating': 4.8,
      'reviews': 32,
      'color': const Color(0xFFEFF6FF),
      'icon': Icons.camera_alt_outlined,
      'iconColor': const Color(0xFF2563EB),
      'image': 'assets/images/camera.jpg',
      'badge': 'Featured',
      'status': 'popular',
      'timeAgo': '3 hours ago',
      'addedBy': 'David L.',
    },
    {
      'id': 'item_3',
      'name': 'Alpine 4P Expedition Tent',
      'category': 'OUTDOOR',
      'price': 40,
      'rating': 4.7,
      'reviews': 20,
      'color': const Color(0xFFF0FDF4),
      'icon': Icons.terrain_outlined,
      'iconColor': const Color(0xFF059669),
      'image': 'assets/images/tent.jpg',
      'badge': 'Popular',
      'status': 'popular',
      'timeAgo': '4 hours ago',
      'addedBy': 'Alex T.',
    },
    {
      'id': 'item_4',
      'name': 'Heavy Duty Toolkit',
      'category': 'TOOLS',
      'price': 15,
      'rating': 4.9,
      'reviews': 48,
      'color': const Color(0xFFFFF7ED),
      'icon': Icons.build_outlined,
      'iconColor': const Color(0xFFF59E0B),
      'image': 'assets/images/toolkit.jpg',
      'badge': 'Top Rated',
      'status': 'new',
      'timeAgo': '2 hours ago',
      'addedBy': 'Mason Dec.',
    },
    {
      'id': 'item_5',
      'name': 'Specialized Road Bike',
      'category': 'OUTDOOR',
      'price': 25,
      'rating': 4.5,
      'reviews': 16,
      'color': const Color(0xFFEFF6FF),
      'icon': Icons.directions_bike_outlined,
      'iconColor': const Color(0xFF2563EB),
      'image': 'assets/images/bike.jpg',
      'badge': 'Eco',
      'status': 'popular',
      'timeAgo': '5 hours ago',
      'addedBy': 'SOMA',
    },
    {
      'id': 'item_6',
      'name': 'Industrial Demolition Jackhammer',
      'category': 'TOOLS',
      'price': 45,
      'rating': 4.9,
      'reviews': 64,
      'color': const Color(0xFFFEF2F2),
      'icon': Icons.construction,
      'iconColor': const Color(0xFFDC2626),
      'image': 'assets/images/jackhammer.jpg',
      'badge': 'Heavy Duty',
      'status': 'new',
      'timeAgo': '6 hours ago',
      'addedBy': 'Marc A.',
    },
    {
      'id': 'item_7',
      'name': 'Complete Socket Box Set',
      'category': 'TOOLS',
      'price': 20,
      'rating': 4.7,
      'reviews': 38,
      'color': const Color(0xFFFFFBEB),
      'icon': Icons.handyman_outlined,
      'iconColor': const Color(0xFFD97706),
      'image': 'assets/images/socket_set.jpg',
      'badge': 'Essential',
      'status': 'popular',
      'timeAgo': '1 day ago',
      'addedBy': 'Lucas B.',
    },
    {
      'id': 'item_8',
      'name': 'Cinema Prime Lens 50mm f/1.4',
      'category': 'PHOTO',
      'price': 45,
      'rating': 4.9,
      'reviews': 29,
      'color': const Color(0xFFF5F3FF),
      'icon': Icons.camera_outlined,
      'iconColor': const Color(0xFF7C3AED),
      'image': 'assets/images/lens.jpg',
      'badge': 'Pro Glass',
      'status': 'popular',
      'timeAgo': '1 day ago',
      'addedBy': 'Clara M.',
    },
    {
      'id': 'item_9',
      'name': 'Bosch Pro Impact Drill 18V',
      'category': 'TOOLS',
      'price': 30,
      'rating': 4.8,
      'reviews': 52,
      'color': const Color(0xFFECFDF5),
      'icon': Icons.construction,
      'iconColor': const Color(0xFF059669),
      'image': 'assets/images/bosch_drill.jpg',
      'badge': 'Pro',
      'status': 'popular',
      'timeAgo': '2 days ago',
      'addedBy': 'Robert K.',
    },
    {
      'id': 'item_10',
      'name': 'Wireless Stage Boombox 300W',
      'category': 'AUDIO',
      'price': 35,
      'rating': 4.8,
      'reviews': 41,
      'color': const Color(0xFFEFF6FF),
      'icon': Icons.speaker_group_outlined,
      'iconColor': const Color(0xFF2563EB),
      'badge': 'Hi-Fi',
      'status': 'new',
      'timeAgo': '3 hours ago',
      'addedBy': 'SoundWave Pro',
    },
    {
      'id': 'item_11',
      'name': 'Studio Monitor Headphones Pro',
      'category': 'AUDIO',
      'price': 20,
      'rating': 4.9,
      'reviews': 77,
      'color': const Color(0xFFF5F3FF),
      'icon': Icons.headphones_outlined,
      'iconColor': const Color(0xFF7C3AED),
      'badge': 'Studio',
      'status': 'popular',
      'timeAgo': '5 hours ago',
      'addedBy': 'AudioLab',
    },
    {
      'id': 'item_12',
      'name': 'Shure Wireless Mic Package',
      'category': 'AUDIO',
      'price': 40,
      'rating': 4.8,
      'reviews': 35,
      'color': const Color(0xFFFFF7ED),
      'icon': Icons.mic_external_on_outlined,
      'iconColor': const Color(0xFFF59E0B),
      'badge': 'Live Event',
      'status': 'new',
      'timeAgo': '8 hours ago',
      'addedBy': 'Event Masters',
    },
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

  void _showLocationSelector() {
    final cities = [
      'San Francisco, CA',
      'New York, NY',
      'Paris, France',
      'Cotonou, Bénin',
      'Porto-Novo, Bénin',
      'Dakar, Sénégal',
      'Abidjan, Côte d\'Ivoire',
    ];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select your location',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...cities.map((city) => ListTile(
                    leading: Icon(
                      Icons.location_on,
                      color: _currentLocation == city
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF94A3B8),
                    ),
                    title: Text(
                      city,
                      style: TextStyle(
                        fontWeight: _currentLocation == city
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: _currentLocation == city
                            ? const Color(0xFF2563EB)
                            : const Color(0xFF0F172A),
                      ),
                    ),
                    trailing: _currentLocation == city
                        ? const Icon(Icons.check, color: Color(0xFF2563EB))
                        : null,
                    onTap: () {
                      setState(() => _currentLocation = city);
                      Navigator.pop(ctx);
                    },
                  )),
            ],
          ),
        );
      },
    );
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        String tempSort = _sortBy;
        double tempMaxPrice = _maxPrice;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter & Sort',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Sort by',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _modalFilterChip(
                        'Recommended',
                        'recommended',
                        tempSort,
                        (v) => setModalState(() => tempSort = v),
                      ),
                      _modalFilterChip(
                        'Price: Low to High',
                        'price_asc',
                        tempSort,
                        (v) => setModalState(() => tempSort = v),
                      ),
                      _modalFilterChip(
                        'Price: High to Low',
                        'price_desc',
                        tempSort,
                        (v) => setModalState(() => tempSort = v),
                      ),
                      _modalFilterChip(
                        'Top Rated',
                        'rating',
                        tempSort,
                        (v) => setModalState(() => tempSort = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Max Price per hour',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF334155),
                        ),
                      ),
                      Text(
                        '\$${tempMaxPrice.toInt()}/h',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    min: 10,
                    max: 150,
                    divisions: 14,
                    value: tempMaxPrice,
                    activeColor: const Color(0xFF2563EB),
                    onChanged: (v) => setModalState(() => tempMaxPrice = v),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _sortBy = 'recommended';
                              _maxPrice = 150.0;
                            });
                            Navigator.pop(ctx);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _sortBy = tempSort;
                              _maxPrice = tempMaxPrice;
                            });
                            Navigator.pop(ctx);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Apply Filters',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _modalFilterChip(
    String label,
    String value,
    String current,
    ValueChanged<String> onSelected,
  ) {
    final bool active = current == value;
    return ChoiceChip(
      label: Text(label),
      selected: active,
      selectedColor: const Color(0xFF2563EB),
      labelStyle: TextStyle(
        color: active ? Colors.white : const Color(0xFF334155),
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      onSelected: (_) => onSelected(value),
    );
  }

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
                  child: GestureDetector(
                    onTap: () => _toggleBookmark(
                      item['id'] as String,
                      item['name'] as String,
                    ),
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
                      child: Icon(
                        _savedItemIds.contains(item['id'])
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        size: 16,
                        color: _savedItemIds.contains(item['id'])
                            ? const Color(0xFF2563EB)
                            : const Color(0xFF64748B),
                      ),
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
                  child: GestureDetector(
                    onTap: () => _toggleBookmark(
                      item['id'] as String,
                      item['name'] as String,
                    ),
                    child: Container(
                      width: 28,
                      height: 28,
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
                      child: Icon(
                        _savedItemIds.contains(item['id'])
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        size: 14,
                        color: _savedItemIds.contains(item['id'])
                            ? const Color(0xFF2563EB)
                            : const Color(0xFF64748B),
                      ),
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
                  GestureDetector(
                    onTap: _showLocationSelector,
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Color(0xFF2563EB),
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Location',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF94A3B8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  _currentLocation,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(width: 2),
                                const Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 16,
                                  color: Color(0xFF64748B),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: const CircleAvatar(
                        radius: 16,
                        backgroundColor: Color(0xFF2563EB),
                        child: Text(
                          'AJ',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
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
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (v) => setState(() => _searchQuery = v),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF0F172A),
                              ),
                              decoration: const InputDecoration(
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
                          if (_searchQuery.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear, size: 18, color: Color(0xFF94A3B8)),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            ),
                          GestureDetector(
                            onTap: _showFilterModal,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  margin: const EdgeInsets.all(6),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: (_sortBy != 'recommended' || _maxPrice < 150.0)
                                        ? const Color(0xFF1D4ED8)
                                        : const Color(0xFF2563EB),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.tune,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                                if (_sortBy != 'recommended' || _maxPrice < 150.0)
                                  Positioned(
                                    top: 2,
                                    right: 2,
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

                    // ──── Dynamic Content: Filtered Results vs Classic Sections ────
                    if (_isFilteringActive) ...[
                      // Active filter title and reset button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Results (${_filteredItems.length} found)',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _selectedCategoryIndex = 0;
                                _searchController.clear();
                                _searchQuery = '';
                                _sortBy = 'recommended';
                                _maxPrice = 150.0;
                              });
                            },
                            icon: const Icon(Icons.refresh, size: 14, color: Color(0xFF2563EB)),
                            label: const Text(
                              'Reset all',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (_filteredItems.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEFF6FF),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.search_off_rounded,
                                  color: Color(0xFF2563EB),
                                  size: 28,
                                ),
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                'No equipment found',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Try changing keywords, budget or category filter.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.72,
                          children: _filteredItems
                              .map((item) => _buildTrendingCard(item))
                              .toList(),
                        ),
                    ] else ...[
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
                            onPressed: () {
                              setState(() => _selectedCategoryIndex = 1); // Jump to Tools
                            },
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
                            onPressed: () {
                              setState(() => _selectedCategoryIndex = 2); // Jump to Photo
                            },
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
                            onPressed: () {
                              setState(() => _selectedCategoryIndex = 3); // Jump to Outdoor
                            },
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
                    ],

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
