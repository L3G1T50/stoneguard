// ─── FOOD GUIDE SCREEN ────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../food_database.dart';
import '../theme/app_theme.dart';

// ══════════════════════════════════════════════════════════════════════════
// FOOD GUIDE SCREEN
// ══════════════════════════════════════════════════════════════════════════

class FoodGuideScreen extends StatefulWidget {
  final void Function(double mg, String name)? onLogFood;
  const FoodGuideScreen({super.key, this.onLogFood});

  @override
  State<FoodGuideScreen> createState() => _FoodGuideScreenState();
}

class _FoodGuideScreenState extends State<FoodGuideScreen>
    with SingleTickerProviderStateMixin {
  // ── state ────────────────────────────────────────────────────────────────
  String         _searchQuery      = '';
  OxalateLevel?  _filterLevel;
  bool           _showFavoritesOnly = false;
  Set<String>    _favorites         = {};
  late TabController _tabController;

  static const String _favKey = 'food_favorites';

  // ── lifecycle ────────────────────────────────────────────────────────────
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

  // ── persistence ──────────────────────────────────────────────────────────
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

  // ── log food + show snackbar ─────────────────────────────────────────────
  void _logFood(BuildContext context, double mg, String name) {
    if (widget.onLogFood == null) return;
    widget.onLogFood!(mg, name);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Text('✅ ', style: TextStyle(fontSize: 16)),
            Expanded(
              child: Text(
                'Logged: $name  (+${mg.toStringAsFixed(0)} mg oxalate)',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF01696F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ── quick-add bottom sheet ─────────────────────────────────────────────
  void _showQuickAdd(BuildContext context) {
    final nameCtrl = TextEditingController();
    final mgCtrl   = TextEditingController();
    final formKey  = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppDynamic.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.add_circle_outline,
                      color: Color(0xFF01696F), size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Quick Add Food',
                    style: TextStyle(
                      color: AppDynamic.textPrimary(ctx),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameCtrl,
                style: TextStyle(color: AppDynamic.textPrimary(ctx)),
                decoration: InputDecoration(
                  labelText: 'Food name',
                  labelStyle: TextStyle(color: AppDynamic.textSecond(ctx)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter a food name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: mgCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(color: AppDynamic.textPrimary(ctx)),
                decoration: InputDecoration(
                  labelText: 'Oxalate amount (mg)',
                  labelStyle: TextStyle(color: AppDynamic.textSecond(ctx)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter mg amount';
                  if (double.tryParse(v.trim()) == null) return 'Enter a number';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF01696F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final mg = double.parse(mgCtrl.text.trim());
                      final name = nameCtrl.text.trim();
                      Navigator.pop(ctx);
                      _logFood(context, mg, name);
                    }
                  },
                  child: const Text('Log Food',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── helpers ───────────────────────────────────────────────────────────────
  List<FoodItem> get _filteredFoods {
    return foodItems.where((food) {
      final matchesSearch = _searchQuery.isEmpty ||
          food.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          food.category.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesLevel =
          _filterLevel == null || food.level == _filterLevel;
      final matchesFavorite =
          !_showFavoritesOnly || _favorites.contains(food.name);
      return matchesSearch && matchesLevel && matchesFavorite;
    }).toList();
  }

  List<FoodItem> get _favoriteFoods {
    return foodItems.where((food) => _favorites.contains(food.name)).toList();
  }

  Color _levelColor(OxalateLevel level) {
    switch (level) {
      case OxalateLevel.low:      return const Color(0xFF4CAF50);
      case OxalateLevel.moderate: return const Color(0xFFFFC107);
      case OxalateLevel.high:     return const Color(0xFFFF9800);
      case OxalateLevel.veryHigh: return const Color(0xFFF44336);
    }
  }

  String _levelLabel(OxalateLevel level) {
    switch (level) {
      case OxalateLevel.low:      return 'Low';
      case OxalateLevel.moderate: return 'Moderate';
      case OxalateLevel.high:     return 'High';
      case OxalateLevel.veryHigh: return 'Very High';
    }
  }

  String _levelEmoji(OxalateLevel level) {
    switch (level) {
      case OxalateLevel.low:      return '✅';
      case OxalateLevel.moderate: return '⚠️';
      case OxalateLevel.high:     return '🚫';
      case OxalateLevel.veryHigh: return '❌';
    }
  }

  // ── build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bg       = AppDynamic.background(context);
    final surface  = AppDynamic.surface(context);
    final textPrim = AppDynamic.textPrimary(context);
    final textSec  = AppDynamic.textSecond(context);
    final divCol   = AppDynamic.divider(context);

    return Scaffold(
      backgroundColor: bg,
      floatingActionButton: widget.onLogFood != null
          ? FloatingActionButton.extended(
              onPressed: () => _showQuickAdd(context),
              backgroundColor: const Color(0xFF01696F),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Quick Add',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            )
          : null,
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
          _buildAllFoodsTab(context, surface, textPrim, textSec, divCol),
          _buildFavoritesTab(context, textSec),
        ],
      ),
    );
  }

  // ── ALL FOODS TAB ─────────────────────────────────────────────────────────
  Widget _buildAllFoodsTab(
    BuildContext context,
    Color surface,
    Color textPrim,
    Color textSec,
    Color divCol,
  ) {
    final foods = _filteredFoods;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            children: [
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
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _filterChip(context, 'All',           null),
                    const SizedBox(width: 8),
                    _filterChip(context, '✅ Low',        OxalateLevel.low),
                    const SizedBox(width: 8),
                    _filterChip(context, '⚠️ Moderate',  OxalateLevel.moderate),
                    const SizedBox(width: 8),
                    _filterChip(context, '🚫 High',       OxalateLevel.high),
                    const SizedBox(width: 8),
                    _filterChip(context, '❌ Very High',  OxalateLevel.veryHigh),
                    const SizedBox(width: 8),
                    _favChip(context),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
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
        Expanded(
          child: foods.isEmpty
              ? _emptyState(textSec)
              : ListView.builder(
                  padding: const EdgeInsets.only(
                      left: 12, right: 12, top: 8, bottom: 88),
                  itemCount: foods.length,
                  itemBuilder: (_, i) => _foodCard(context, foods[i]),
                ),
        ),
      ],
    );
  }

  // ── FAVORITES TAB ─────────────────────────────────────────────────────────
  Widget _buildFavoritesTab(BuildContext context, Color textSec) {
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
                  color: textSec,
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap ⭐ on any food to save it here.',
              style: TextStyle(
                  color: textSec.withValues(alpha: 0.7), fontSize: 13),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(
          left: 12, right: 12, top: 8, bottom: 88),
      itemCount: favs.length,
      itemBuilder: (_, i) => _foodCard(context, favs[i]),
    );
  }

  // ── FOOD CARD ─────────────────────────────────────────────────────────────
  Widget _foodCard(BuildContext context, FoodItem food) {
    final isFav    = _favorites.contains(food.name);
    final lvlColor = _levelColor(food.level);
    final lvlLabel = _levelLabel(food.level);
    final lvlEmoji = _levelEmoji(food.level);

    return AppCard(
      onTap: widget.onLogFood != null
          ? () => _logFood(context, food.oxalateMg, food.name)
          : null,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: lvlColor,
                shape: BoxShape.circle,
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
                Text(
                  food.category,
                  style: TextStyle(
                    color: AppDynamic.textSecond(context),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.science_outlined,
                        size: 13, color: AppDynamic.textSecond(context)),
                    const SizedBox(width: 4),
                    Text(
                      '${food.oxalateMg} mg oxalate  •  ${food.serving}',
                      style: TextStyle(
                        color: AppDynamic.textSecond(context),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                if (food.tip.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    food.tip,
                    style: TextStyle(
                      color: AppDynamic.textSecond(context)
                          .withValues(alpha: 0.8),
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                if (widget.onLogFood != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.touch_app_outlined,
                          size: 11,
                          color: const Color(0xFF01696F).withValues(alpha: 0.7)),
                      const SizedBox(width: 4),
                      Text(
                        'Tap to log',
                        style: TextStyle(
                          color:
                              const Color(0xFF01696F).withValues(alpha: 0.7),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
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

  // ── EMPTY STATE ───────────────────────────────────────────────────────────
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

  // ── FILTER CHIPS ──────────────────────────────────────────────────────────
  Widget _favChip(BuildContext context) {
    final bg       = AppDynamic.background(context);
    final textSec  = AppDynamic.textSecond(context);
    final divCol   = AppDynamic.divider(context);
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

  Widget _filterChip(
      BuildContext context, String label, OxalateLevel? level) {
    final bg      = AppDynamic.background(context);
    final textSec = AppDynamic.textSecond(context);
    final divCol  = AppDynamic.divider(context);
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
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : textSec,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
