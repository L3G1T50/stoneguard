// ─── FOOD GUIDE SCREEN ────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/food_item.dart';
import '../models/food_database.dart';
import '../theme/app_colors.dart';
import '../theme/app_dynamic.dart';
import '../theme/app_card.dart';

// ═══════════════════════════════════════════════════════════
// ENUMS & CONSTANTS
// ═══════════════════════════════════════════════════════════

enum OxalateLevel { low, medium, high, veryHigh }

// ═══════════════════════════════════════════════════════════
// FOOD GUIDE SCREEN
// ═══════════════════════════════════════════════════════════

class FoodGuideScreen extends StatefulWidget {
  const FoodGuideScreen({super.key});

  @override
  State<FoodGuideScreen> createState() => _FoodGuideScreenState();
}

class _FoodGuideScreenState extends State<FoodGuideScreen>
    with SingleTickerProviderStateMixin {
  // ── state ────────────────────────────────────────────────
  String        _searchQuery     = '';
  OxalateLevel? _filterLevel     = null;
  bool          _showFavoritesOnly = false;
  Set<String>   _favorites       = {};
  late TabController _tabController;

  static const String _favKey = 'food_favorites';

  // ── lifecycle ────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFavorites();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── persistence ──────────────────────────────────────────
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favorites = Set<String>.from(prefs.getStringList(_favKey) ?? []);
    });
  }

  Future<void> _toggleFavorite(String foodName) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favorites.contains(foodName)) {
        _favorites.remove(foodName);
      } else {
        _favorites.add(foodName);
      }
    });
    await prefs.setStringList(_favKey, _favorites.toList());
  }

  // ── helpers ───────────────────────────────────────────────
  List<FoodItem> get _filteredFoods {
    final allFoods = FoodDatabase.allFoods;
    return allFoods.where((food) {
      final matchesSearch = _searchQuery.isEmpty ||
          food.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          food.category.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesLevel =
          _filterLevel == null || food.oxalateLevel == _filterLevel;
      final matchesFavorite = !_showFavoritesOnly || _favorites.contains(food.name);
      return matchesSearch && matchesLevel && matchesFavorite;
    }).toList();
  }

  List<FoodItem> get _favoriteFoods {
    final allFoods = FoodDatabase.allFoods;
    return allFoods.where((food) => _favorites.contains(food.name)).toList();
  }

  Color _levelColor(OxalateLevel level) {
    switch (level) {
      case OxalateLevel.low:      return const Color(0xFF4CAF50);
      case OxalateLevel.medium:   return const Color(0xFFFFC107);
      case OxalateLevel.high:     return const Color(0xFFFF9800);
      case OxalateLevel.veryHigh: return const Color(0xFFF44336);
    }
  }

  String _levelLabel(OxalateLevel level) {
    switch (level) {
      case OxalateLevel.low:      return 'Low';
      case OxalateLevel.medium:   return 'Medium';
      case OxalateLevel.high:     return 'High';
      case OxalateLevel.veryHigh: return 'Very High';
    }
  }

  String _levelEmoji(OxalateLevel level) {
    switch (level) {
      case OxalateLevel.low:      return '✅';
      case OxalateLevel.medium:   return '⚠️';
      case OxalateLevel.high:     return '🚫';
      case OxalateLevel.veryHigh: return '❌';
    }
  }

  // ── build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final bg       = AppDynamic.background(context);
    final surface  = AppDynamic.surface(context);
    final textPrim = AppDynamic.textPrimary(context);
    final textSec  = AppDynamic.textSecond(context);
    final divCol   = AppDynamic.divider(context);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: Text(
          'Food Guide',
          style: TextStyle(
            color: textPrim,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: textPrim),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: textSec,
            tabs: const [
              Tab(text: 'All Foods'),
              Tab(text: '⭐ Favorites'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllFoodsTab(context, isDark, surface, textPrim, textSec, divCol),
          _buildFavoritesTab(context, surface, textPrim, textSec),
        ],
      ),
    );
  }

  // ── ALL FOODS TAB ─────────────────────────────────────────
  Widget _buildAllFoodsTab(
    BuildContext context,
    bool isDark,
    Color surface,
    Color textPrim,
    Color textSec,
    Color divCol,
  ) {
    final foods = _filteredFoods;

    return Column(
      children: [
        // Search + filter row
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            children: [
              // Search field
              Container(
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: divCol),
                ),
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: TextStyle(color: textPrim),
                  decoration: InputDecoration(
                    hintText: 'Search foods…',
                    hintStyle: TextStyle(color: textSec),
                    prefixIcon: Icon(Icons.search, color: textSec),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _filterChip(context, 'All',       null),
                    const SizedBox(width: 8),
                    _filterChip(context, '✅ Low',    OxalateLevel.low),
                    const SizedBox(width: 8),
                    _filterChip(context, '⚠️ Medium', OxalateLevel.medium),
                    const SizedBox(width: 8),
                    _filterChip(context, '🚫 High',   OxalateLevel.high),
                    const SizedBox(width: 8),
                    _filterChip(context, '❌ Very High', OxalateLevel.veryHigh),
                    const SizedBox(width: 8),
                    _favChip(context),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Results count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                '${foods.length} item${foods.length == 1 ? '' : 's'}',
                style: TextStyle(color: textSec, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // List
        Expanded(
          child: foods.isEmpty
              ? _emptyState(textSec)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: foods.length,
                  itemBuilder: (_, i) => _foodCard(context, foods[i]),
                ),
        ),
      ],
    );
  }

  // ── FAVORITES TAB ─────────────────────────────────────────
  Widget _buildFavoritesTab(
    BuildContext context,
    Color surface,
    Color textPrim,
    Color textSec,
  ) {
    final favs = _favoriteFoods;
    if (favs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star_border, size: 56, color: textSec),
            const SizedBox(height: 12),
            Text(
              'No favorites yet',
              style: TextStyle(
                  color: textSec, fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap ⭐ on any food to save it here.',
              style: TextStyle(color: textSec.withValues(alpha: 0.7), fontSize: 13),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: favs.length,
      itemBuilder: (_, i) => _foodCard(context, favs[i]),
    );
  }

  // ── FOOD CARD ─────────────────────────────────────────────
  Widget _foodCard(BuildContext context, FoodItem food) {
    final isFav    = _favorites.contains(food.name);
    final lvlColor = _levelColor(food.oxalateLevel);
    final lvlLabel = _levelLabel(food.oxalateLevel);
    final lvlEmoji = _levelEmoji(food.oxalateLevel);

    return AppCard(
      context: context,
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Oxalate level indicator dot
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Container(
              width: 12, height: 12,
              decoration: BoxDecoration(
                color: lvlColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Main content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + level badge row
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        food.name,
                        style: TextStyle(
                          color: AppDynamic.textPrimary(context),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: lvlColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$lvlEmoji $lvlLabel',
                        style: TextStyle(
                          color: lvlColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Category
                Text(
                  food.category,
                  style: TextStyle(
                    color: AppDynamic.textSecond(context),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                // Oxalate amount
                Row(
                  children: [
                    Icon(Icons.science_outlined,
                        size: 13, color: AppDynamic.textSecond(context)),
                    const SizedBox(width: 4),
                    Text(
                      '${food.oxalateMgPer100g} mg oxalate / 100g',
                      style: TextStyle(
                        color: AppDynamic.textSecond(context),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                if (food.notes != null && food.notes!.isNotEmpty) ...
                  [
                    const SizedBox(height: 6),
                    Text(
                      food.notes!,
                      style: TextStyle(
                        color: AppDynamic.textSecond(context)
                            .withValues(alpha: 0.8),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
              ],
            ),
          ),
          // Favorite button
          GestureDetector(
            onTap: () => _toggleFavorite(food.name),
            child: Padding(
              padding: const EdgeInsets.only(left: 8, top: 2),
              child: Icon(
                isFav ? Icons.star : Icons.star_border,
                color: isFav ? Colors.amber : AppDynamic.textSecond(context),
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── EMPTY STATE ───────────────────────────────────────────
  Widget _emptyState(Color textSec) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 52, color: textSec),
          const SizedBox(height: 12),
          Text(
            'No foods match your search',
            style: TextStyle(
                color: textSec, fontSize: 15, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          Text(
            'Try adjusting your search or filters.',
            style: TextStyle(
                color: textSec.withValues(alpha: 0.7), fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ── FILTER CHIPS ──────────────────────────────────────────
  Widget _favChip(BuildContext context) {
    final bg      = AppDynamic.background(context);
    final textSec = AppDynamic.textSecond(context);
    final divCol  = AppDynamic.divider(context);
    final selected = _showFavoritesOnly;
    return GestureDetector(
      onTap: () => setState(() {
        _showFavoritesOnly = !_showFavoritesOnly;
        _filterLevel = null;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.amber : bg,
          borderRadius: BorderRadius.circular(20),
          border: selected ? null : Border.all(color: divCol),
        ),
        child: Text(
          '⭐ Favorites',
          style: TextStyle(
            color: selected ? Colors.white : textSec,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _filterChip(BuildContext context, String label, OxalateLevel? level) {
    final bg     = AppDynamic.background(context);
    final textSec= AppDynamic.textSecond(context);
    final divCol = AppDynamic.divider(context);
    final selected = _filterLevel == level && !_showFavoritesOnly;
    return GestureDetector(
      onTap: () => setState(() {
        _filterLevel = level;
        _showFavoritesOnly = false;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.teal : bg,
          borderRadius: BorderRadius.circular(20),
          border: selected ? null : Border.all(color: divCol),
        ),
        child: Text(label,
            style: TextStyle(
              color: selected ? Colors.white : textSec,
              fontWeight:
                  selected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            )),
      ),
    );
  }
}
