import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/catalog_data.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/providers/user_provider.dart';
import 'item_details_screen.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;
  const SearchScreen({super.key, this.initialQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _query = '';
  String _selectedCategoryKey = 'ALL';
  String _sortBy = 'recommended'; // recommended, price_asc, price_desc, rating
  double _maxPrice = 100.0;

  final List<String> _popularKeywordsFr = [
    'Perceuse',
    'Caméra 4K',
    'Objectif',
    'Brise-béton',
    'Sono Bluetooth',
    'Tente camping',
    'Vélo VTT',
    'Boîte à outils',
  ];

  final List<String> _popularKeywordsEn = [
    'Drill',
    'Cinema Camera',
    'Prime Lens',
    'Jackhammer',
    'Sound System',
    'Camping Tent',
    'Mountain Bike',
    'Toolbox',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchController.text = widget.initialQuery!;
      _query = widget.initialQuery!;
    }
    // Auto-focus clavier à l'arrivée sur l'onglet recherche
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filterItems(bool isFr, String userCity) {
    final list = kCatalogItems.where((item) {
      // Filtre catégorie
      if (_selectedCategoryKey != 'ALL') {
        final cat = (item['category'] as String).toUpperCase();
        if (!cat.contains(_selectedCategoryKey)) {
          return false;
        }
      }

      // Filtre texte
      if (_query.trim().isNotEmpty) {
        final q = _query.trim().toLowerCase();
        final nameFr = ((item['nameFr'] as String?) ?? (item['name'] as String)).toLowerCase();
        final nameEn = ((item['nameEn'] as String?) ?? (item['name'] as String)).toLowerCase();
        final catFr = ((item['categoryFr'] as String?) ?? '').toLowerCase();
        final catEn = ((item['categoryEn'] as String?) ?? '').toLowerCase();
        final city = ((item['city'] as String?) ?? '').toLowerCase();
        final descFr = ((item['descFr'] as String?) ?? '').toLowerCase();
        final descEn = ((item['descEn'] as String?) ?? '').toLowerCase();

        final match = nameFr.contains(q) ||
            nameEn.contains(q) ||
            catFr.contains(q) ||
            catEn.contains(q) ||
            city.contains(q) ||
            descFr.contains(q) ||
            descEn.contains(q);

        if (!match) return false;
      }

      // Filtre prix
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
          final aCityMatch = (a['city'] == userCity) ? 1 : 0;
          final bCityMatch = (b['city'] == userCity) ? 1 : 0;
          if (aCityMatch != bCityMatch) {
            return bCityMatch.compareTo(aCityMatch);
          }
          return rB.compareTo(rA);
      }
    });

    return list;
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _query = '';
      _selectedCategoryKey = 'ALL';
      _maxPrice = 100.0;
      _sortBy = 'recommended';
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final isFr = lang.isFrench;
    final userProv = context.watch<UserProvider>();
    final userCity = userProv.location.isNotEmpty ? userProv.location : 'Paris, France';

    final filteredItems = _filterItems(isFr, userCity);
    final popularKeywords = isFr ? _popularKeywordsFr : _popularKeywordsEn;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Barre de recherche supérieure
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: const Color(0xFFE2E8F0)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _focusNode.hasFocus
                                  ? const Color(0xFF2563EB)
                                  : const Color(0xFFE2E8F0),
                              width: _focusNode.hasFocus ? 1.5 : 1,
                            ),
                          ),
                          child: TextField(
                            controller: _searchController,
                            focusNode: _focusNode,
                            textInputAction: TextInputAction.search,
                            onChanged: (val) => setState(() => _query = val),
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF0F172A),
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              hintText: isFr
                                  ? 'Rechercher un outil, matériel, sono...'
                                  : 'Search equipment, tools, audio...',
                              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                              prefixIcon: const Icon(Icons.search, color: Color(0xFF2563EB), size: 22),
                              suffixIcon: _query.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 20),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() => _query = '');
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Bouton Filtres / Tri
                      PopupMenuButton<String>(
                        icon: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: _sortBy != 'recommended'
                                ? const Color(0xFFEFF6FF)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _sortBy != 'recommended'
                                  ? const Color(0xFFBFDBFE)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Icon(
                            Icons.tune_rounded,
                            color: _sortBy != 'recommended'
                                ? const Color(0xFF2563EB)
                                : const Color(0xFF475569),
                            size: 20,
                          ),
                        ),
                        onSelected: (val) => setState(() => _sortBy = val),
                        itemBuilder: (ctx) => [
                          PopupMenuItem(
                            value: 'recommended',
                            child: Row(
                              children: [
                                Icon(Icons.star_outline, size: 18, color: _sortBy == 'recommended' ? const Color(0xFF2563EB) : const Color(0xFF64748B)),
                                const SizedBox(width: 8),
                                Text(isFr ? 'Recommandés' : 'Recommended'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'price_asc',
                            child: Row(
                              children: [
                                Icon(Icons.arrow_upward, size: 18, color: _sortBy == 'price_asc' ? const Color(0xFF2563EB) : const Color(0xFF64748B)),
                                const SizedBox(width: 8),
                                Text(isFr ? 'Prix croissant' : 'Price: Low to High'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'price_desc',
                            child: Row(
                              children: [
                                Icon(Icons.arrow_downward, size: 18, color: _sortBy == 'price_desc' ? const Color(0xFF2563EB) : const Color(0xFF64748B)),
                                const SizedBox(width: 8),
                                Text(isFr ? 'Prix décroissant' : 'Price: High to Low'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'rating',
                            child: Row(
                              children: [
                                Icon(Icons.thumb_up_alt_outlined, size: 18, color: _sortBy == 'rating' ? const Color(0xFF2563EB) : const Color(0xFF64748B)),
                                const SizedBox(width: 8),
                                Text(isFr ? 'Mieux notés' : 'Highest Rated'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Chips Catégories horizontales
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: kCatalogCategories.map((cat) {
                        final key = cat['key'] as String;
                        final label = isFr ? cat['labelFr'] as String : cat['labelEn'] as String;
                        final isSelected = _selectedCategoryKey == key;
                        final icon = cat['icon'] as IconData;

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            selected: isSelected,
                            showCheckmark: false,
                            avatar: Icon(
                              icon,
                              size: 16,
                              color: isSelected ? Colors.white : const Color(0xFF64748B),
                            ),
                            label: Text(label),
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? Colors.white : const Color(0xFF334155),
                            ),
                            backgroundColor: const Color(0xFFF1F5F9),
                            selectedColor: const Color(0xFF2563EB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                              ),
                            ),
                            onSelected: (_) {
                              setState(() => _selectedCategoryKey = key);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // Corps : Suggestions ou Résultats
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  // Si recherche vide et aucune catégorie spécifique, afficher les recherches populaires
                  if (_query.isEmpty && _selectedCategoryKey == 'ALL') ...[
                    Text(
                      isFr ? 'Recherches populaires' : 'Popular Searches',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: popularKeywords.map((kw) {
                        return ActionChip(
                          avatar: const Icon(Icons.trending_up, size: 16, color: Color(0xFF2563EB)),
                          label: Text(kw),
                          labelStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          onPressed: () {
                            _searchController.text = kw;
                            setState(() => _query = kw);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // En-tête des résultats avec compteur
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isFr
                            ? '${filteredItems.length} équipement${filteredItems.length > 1 ? 's' : ''} trouvé${filteredItems.length > 1 ? 's' : ''}'
                            : '${filteredItems.length} item${filteredItems.length > 1 ? 's' : ''} found',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      if (_query.isNotEmpty || _selectedCategoryKey != 'ALL')
                        GestureDetector(
                          onTap: _clearSearch,
                          child: Text(
                            isFr ? 'Effacer filtres' : 'Clear filters',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Si 0 résultat
                  if (filteredItems.isEmpty) ...[
                    const SizedBox(height: 40),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.search_off_rounded,
                              size: 40,
                              color: Color(0xFF93C5FD),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            isFr ? 'Aucun résultat trouvé' : 'No items found',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isFr
                                ? 'Essayez un autre mot-clé ou modifiez vos filtres de catégorie.'
                                : 'Try searching for something else or change category filters.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _clearSearch,
                            icon: const Icon(Icons.refresh, size: 18),
                            label: Text(isFr ? 'Réinitialiser' : 'Reset'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Grille de résultats 2 colonnes
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredItems.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.72,
                      ),
                      itemBuilder: (ctx, idx) {
                        final item = filteredItems[idx];
                        final name = isFr
                            ? ((item['nameFr'] as String?) ?? item['name'] as String)
                            : ((item['nameEn'] as String?) ?? item['name'] as String);
                        final price = item['price'];
                        final rating = item['rating'];
                        final city = item['city'] as String? ?? '';
                        final image = item['image'] as String? ?? '';

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
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Image avec badges
                                Expanded(
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                        child: Container(
                                          width: double.infinity,
                                          color: const Color(0xFFF1F5F9),
                                          child: Image.asset(
                                            image,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => const Center(
                                              child: Icon(Icons.handyman_outlined, color: Color(0xFF94A3B8), size: 36),
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Note badge
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(alpha: 0.65),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.star, color: Color(0xFFFBBF24), size: 12),
                                              const SizedBox(width: 3),
                                              Text(
                                                '$rating',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Détails
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Ville
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF94A3B8)),
                                          const SizedBox(width: 2),
                                          Expanded(
                                            child: Text(
                                              city,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Color(0xFF64748B),
                                                fontWeight: FontWeight.w500,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),

                                      // Nom équipement
                                      Text(
                                        name,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF0F172A),
                                          height: 1.25,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),

                                      // Prix par jour
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: [
                                          Text(
                                            '$price €',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF2563EB),
                                            ),
                                          ),
                                          Text(
                                            isFr ? ' /jour' : ' /day',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF94A3B8),
                                              fontWeight: FontWeight.w500,
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
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
