import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/providers/notification_provider.dart';
import '../../auth/screens/profile_screen.dart';
import '../../notifications/screens/notifications_modal.dart';
import 'item_details_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  int _selectedCategoryIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortBy = 'recommended';
  double _maxPrice = 150.0;
  String _currentLocation = 'Paris, France';
  final Set<String> _savedItemIds = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleBookmark(String itemId, String itemName, bool isFr) {
    setState(() {
      if (_savedItemIds.contains(itemId)) {
        _savedItemIds.remove(itemId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isFr ? '$itemName retiré des favoris' : '$itemName removed from favorites'),
            duration: const Duration(milliseconds: 900),
          ),
        );
      } else {
        _savedItemIds.add(itemId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isFr ? '$itemName ajouté aux favoris ❤️' : '$itemName added to favorites ❤️'),
            duration: const Duration(milliseconds: 900),
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

  List<Map<String, dynamic>> _getFilteredItems(List<Map<String, dynamic>> categories) {
    final selectedCatKey = categories[_selectedCategoryIndex]['key'] as String;
    final list = _allCatalogItems.where((item) {
      if (selectedCatKey != 'ALL') {
        final itemCat = (item['category'] as String).toUpperCase();
        if (!itemCat.contains(selectedCatKey)) {
          return false;
        }
      }
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.trim().toLowerCase();
        final name = (item['name'] as String).toLowerCase();
        final cat = (item['category'] as String).toLowerCase();
        if (!name.contains(q) && !cat.contains(q)) {
          return false;
        }
      }
      final price = (item['price'] is num) ? (item['price'] as num).toDouble() : 0.0;
      if (price > _maxPrice) {
        return false;
      }
      return true;
    }).toList();

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

  // Catalogue réaliste d'équipements réels
  final List<Map<String, dynamic>> _allCatalogItems = [
    {
      'id': 'item_1',
      'name': 'Perceuse à percussion sans fil 18V',
      'category': 'TOOLS',
      'price': 25,
      'rating': 4.8,
      'reviews': 34,
      'color': const Color(0xFFEFF6FF),
      'icon': Icons.construction,
      'iconColor': const Color(0xFF2563EB),
      'image': 'assets/images/drill.jpg',
      'isAvailable': true,
    },
    {
      'id': 'item_2',
      'name': 'Appareil photo Cinema 4K Pro',
      'category': 'PHOTO',
      'price': 45,
      'rating': 4.9,
      'reviews': 28,
      'color': const Color(0xFFF5F3FF),
      'icon': Icons.camera_alt_outlined,
      'iconColor': const Color(0xFF7C3AED),
      'image': 'assets/images/camera.jpg',
      'isAvailable': true,
    },
    {
      'id': 'item_3',
      'name': 'Brise-béton professionnel 1600W',
      'category': 'TOOLS',
      'price': 40,
      'rating': 4.7,
      'reviews': 19,
      'color': const Color(0xFFFEF2F2),
      'icon': Icons.hardware_outlined,
      'iconColor': const Color(0xFFEF4444),
      'image': 'assets/images/jackhammer.jpg',
      'isAvailable': true,
    },
    {
      'id': 'item_4',
      'name': 'Boîte à outils complète 120 pièces',
      'category': 'TOOLS',
      'price': 15,
      'rating': 4.8,
      'reviews': 42,
      'color': const Color(0xFFFFFBEB),
      'icon': Icons.handyman_outlined,
      'iconColor': const Color(0xFFF59E0B),
      'image': 'assets/images/toolkit.jpg',
      'isAvailable': true,
    },
    {
      'id': 'item_5',
      'name': 'Tente de camping 4 personnes',
      'category': 'OUTDOOR',
      'price': 30,
      'rating': 4.6,
      'reviews': 15,
      'color': const Color(0xFFECFDF5),
      'icon': Icons.terrain_outlined,
      'iconColor': const Color(0xFF059669),
      'image': 'assets/images/tent.jpg',
      'isAvailable': true,
    },
    {
      'id': 'item_6',
      'name': 'Vélo tout-terrain aluminium',
      'category': 'OUTDOOR',
      'price': 20,
      'rating': 4.7,
      'reviews': 22,
      'color': const Color(0xFFEFF6FF),
      'icon': Icons.directions_bike_outlined,
      'iconColor': const Color(0xFF2563EB),
      'image': 'assets/images/bike.jpg',
      'isAvailable': true,
    },
    {
      'id': 'item_7',
      'name': 'Objectif 50mm f/1.4 Portrait',
      'category': 'PHOTO',
      'price': 35,
      'rating': 4.9,
      'reviews': 31,
      'color': const Color(0xFFF5F3FF),
      'icon': Icons.camera_outlined,
      'iconColor': const Color(0xFF7C3AED),
      'image': 'assets/images/lens.jpg',
      'isAvailable': true,
    },
    {
      'id': 'item_8',
      'name': 'Enceinte sono portable 500W Bluetooth',
      'category': 'AUDIO',
      'price': 35,
      'rating': 4.8,
      'reviews': 20,
      'color': const Color(0xFFFDF2F8),
      'icon': Icons.speaker_outlined,
      'iconColor': const Color(0xFFDB2777),
      'image': null,
      'isAvailable': true,
    },
  ];

  void _showLocationSelector() {
    final isFr = context.read<LanguageProvider>().isFrench;
    final cities = [
      'Paris, France',
      'Lomé, Togo',
      'Cotonou, Bénin',
      'Dakar, Sénégal',
      'Abidjan, Côte d\'Ivoire',
      'Lyon, France',
      'San Francisco, CA',
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
              Text(
                isFr ? 'Sélectionner votre ville' : 'Select your location',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 12),
              ...cities.map((city) => ListTile(
                    leading: Icon(
                      Icons.location_on,
                      color: _currentLocation == city ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
                    ),
                    title: Text(
                      city,
                      style: TextStyle(
                        fontWeight: _currentLocation == city ? FontWeight.w700 : FontWeight.w500,
                        color: _currentLocation == city ? const Color(0xFF2563EB) : const Color(0xFF0F172A),
                      ),
                    ),
                    trailing: _currentLocation == city ? const Icon(Icons.check, color: Color(0xFF2563EB)) : null,
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
    final isFr = context.read<LanguageProvider>().isFrench;
    String tempSort = _sortBy;
    double tempMaxPrice = _maxPrice;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isFr ? 'Filtrer et trier' : 'Filter and Sort',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isFr ? 'Trier par :' : 'Sort by:',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _modalFilterChip(isFr ? 'Recommandé' : 'Recommended', 'recommended', tempSort, (v) => setModalState(() => tempSort = v)),
                      _modalFilterChip(isFr ? 'Prix croissant' : 'Price: Low to High', 'price_asc', tempSort, (v) => setModalState(() => tempSort = v)),
                      _modalFilterChip(isFr ? 'Prix décroissant' : 'Price: High to Low', 'price_desc', tempSort, (v) => setModalState(() => tempSort = v)),
                      _modalFilterChip(isFr ? 'Meilleures notes' : 'Top Rated', 'rating', tempSort, (v) => setModalState(() => tempSort = v)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isFr ? 'Budget max / jour :' : 'Max price / day:',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF64748B)),
                      ),
                      Text(
                        '${tempMaxPrice.toInt()} €',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF2563EB)),
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
                          child: Text(isFr ? 'Réinitialiser' : 'Reset'),
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
                          ),
                          child: Text(isFr ? 'Appliquer' : 'Apply'),
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

  Widget _modalFilterChip(String label, String value, String current, ValueChanged<String> onSelected) {
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

  Widget _buildItemCard(Map<String, dynamic> item, bool isFr) {
    final currency = isFr ? '€' : '\$';
    final perDay = isFr ? '/jour' : '/day';

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ItemDetailsScreen(item: item)),
        );
      },
      child: Container(
        width: 185,
        margin: const EdgeInsets.only(right: 14),
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
                  height: 120,
                  decoration: BoxDecoration(
                    color: item['color'] as Color,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Center(
                    child: item['image'] != null
                        ? ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: Image.asset(
                              item['image'] as String,
                              width: double.infinity,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            item['icon'] as IconData,
                            size: 48,
                            color: item['iconColor'] as Color,
                          ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _toggleBookmark(item['id'] as String, item['name'] as String, isFr),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _savedItemIds.contains(item['id']) ? Icons.favorite : Icons.favorite_border,
                        size: 16,
                        color: _savedItemIds.contains(item['id']) ? const Color(0xFFEF4444) : const Color(0xFF64748B),
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
                    item['name'] as String,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${item['price']} $currency $perDay',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 13, color: Color(0xFFF59E0B)),
                          const SizedBox(width: 2),
                          Text(
                            '${item['rating']}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
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

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final notifProvider = context.watch<NotificationProvider>();
    final isFr = lang.isFrench;

    final categories = [
      {'key': 'ALL', 'label': isFr ? 'Tout' : 'All', 'icon': Icons.apps},
      {'key': 'TOOLS', 'label': isFr ? 'Outillage' : 'Tools', 'icon': Icons.construction},
      {'key': 'PHOTO', 'label': isFr ? 'Photo & Vidéo' : 'Photography', 'icon': Icons.camera_alt_outlined},
      {'key': 'OUTDOOR', 'label': isFr ? 'Plein air' : 'Outdoors', 'icon': Icons.terrain_outlined},
      {'key': 'AUDIO', 'label': 'Audio', 'icon': Icons.speaker_outlined},
    ];

    final filteredList = _getFilteredItems(categories);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ──── AppBar Épurée ────
            SliverAppBar(
              floating: true,
              backgroundColor: Colors.white,
              elevation: 0,
              scrolledUnderElevation: 0,
              title: Row(
                children: [
                  GestureDetector(
                    onTap: _showLocationSelector,
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: Color(0xFF2563EB), size: 18),
                        const SizedBox(width: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isFr ? 'Localisation' : 'Location',
                              style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                            ),
                            Row(
                              children: [
                                Text(
                                  _currentLocation,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                                ),
                                const Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF64748B)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // Switch Langue rapide
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: InkWell(
                      onTap: lang.toggleLanguage,
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(isFr ? '🇫🇷' : '🇬🇧', style: const TextStyle(fontSize: 13)),
                            const SizedBox(width: 4),
                            Text(
                              isFr ? 'FR' : 'EN',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF2563EB)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),

                  // Notifications Bell
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_none_outlined, color: Color(0xFF0F172A), size: 22),
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

                  // Avatar profil
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ProfileScreen()),
                      );
                    },
                    child: const CircleAvatar(
                      radius: 16,
                      backgroundColor: Color(0xFF2563EB),
                      child: Text('AJ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),

            // ──── Search & Categories ────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Barre de recherche
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14),
                            child: Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (val) => setState(() => _searchQuery = val),
                              style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                              decoration: InputDecoration(
                                hintText: lang.t('search_hint'),
                                hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(vertical: 13),
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
                          Container(
                            height: 24,
                            width: 1,
                            color: const Color(0xFFE2E8F0),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.tune,
                              size: 20,
                              color: _isFilteringActive ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                            ),
                            onPressed: _showFilterModal,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Catégories
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 8),
                        itemBuilder: (ctx, idx) {
                          final selected = _selectedCategoryIndex == idx;
                          final cat = categories[idx];
                          return GestureDetector(
                            onTap: () => setState(() => _selectedCategoryIndex = idx),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: selected ? const Color(0xFF2563EB) : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: selected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    cat['icon'] as IconData,
                                    size: 15,
                                    color: selected ? Colors.white : const Color(0xFF64748B),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    cat['label'] as String,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: selected ? Colors.white : const Color(0xFF334155),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ──── Résultats Filtrés OU Sections Catalogue ────
            if (_isFilteringActive) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${filteredList.length} ${lang.t('results_found')}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                      ),
                      TextButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                            _selectedCategoryIndex = 0;
                            _sortBy = 'recommended';
                            _maxPrice = 150.0;
                          });
                        },
                        child: Text(
                          lang.t('reset_filters'),
                          style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (filteredList.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.search_off_outlined, size: 50, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            lang.t('no_results'),
                            style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.74,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (ctx, idx) => _buildItemCard(filteredList[idx], isFr),
                      childCount: filteredList.length,
                    ),
                  ),
                ),
            ] else ...[
              // Section Équipements Recommandés
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 22, 16, 12),
                  child: Text(
                    lang.t('featured_title'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 215,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _allCatalogItems.length,
                    itemBuilder: (ctx, idx) => _buildItemCard(_allCatalogItems[idx], isFr),
                  ),
                ),
              ),

              // Section Récents
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 22, 16, 12),
                  child: Text(
                    lang.t('recent_title'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, idx) {
                      final item = _allCatalogItems.reversed.toList()[idx];
                      final currency = isFr ? '€' : '\$';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: item['color'] as Color,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: item['image'] != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.asset(item['image'] as String, fit: BoxFit.cover),
                                    )
                                  : Icon(item['icon'] as IconData, color: item['iconColor'] as Color, size: 26),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'] as String,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${item['price']} $currency ${isFr ? '/jour' : '/day'}',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF2563EB)),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => ItemDetailsScreen(item: item)),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text(
                                lang.t('rent_now'),
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: 4,
                  ),
                ),
              ),
            ],

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}
