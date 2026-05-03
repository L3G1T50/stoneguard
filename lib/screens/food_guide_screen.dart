// ─── FOOD GUIDE SCREEN ────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/food_item.dart';
import '../widgets/banner_ad_widget.dart';

class FoodGuideScreen extends StatefulWidget {
  final void Function(double mg, String name) onLogFood;
  // onLogFood is optional — defaults to a no-op so the screen works
  // both as a standalone nav tab and when called from the Journal.
  const FoodGuideScreen({super.key, void Function(double mg, String name)? onLogFood})
      : onLogFood = onLogFood ?? _noOp;

  static void _noOp(double mg, String name) {}

  @override
  State<FoodGuideScreen> createState() => _FoodGuideScreenState();
}

class _FoodGuideScreenState extends State<FoodGuideScreen> {
  void _logFood(double mg, String name) => widget.onLogFood(mg, name);
  String _searchQuery = '';
  OxalateLevel? _filterLevel;
  bool _showFavoritesOnly = false;
  Set<String> _favorites = {};

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('favorites') ?? [];
    setState(() => _favorites = saved.toSet());
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
    await prefs.setStringList('favorites', _favorites.toList());
  }

  static const Map<OxalateLevel, Color> levelColor = {
    OxalateLevel.low: Color(0xFF43A047),
    OxalateLevel.moderate: Color(0xFFFB8C00),
    OxalateLevel.high: Color(0xFFE53935),
    OxalateLevel.veryHigh: Color(0xFF7B1FA2),
  };

  static const Map<OxalateLevel, String> levelLabel = {
    OxalateLevel.low: 'Low',
    OxalateLevel.moderate: 'Moderate',
    OxalateLevel.high: 'High',
    OxalateLevel.veryHigh: 'Very High',
  };

  static const Map<OxalateLevel, IconData> levelIcon = {
    OxalateLevel.low: Icons.check_circle,
    OxalateLevel.moderate: Icons.warning_amber_rounded,
    OxalateLevel.high: Icons.cancel,
    OxalateLevel.veryHigh: Icons.dangerous,
  };

  List<FoodItem> get _filteredFoods {
    return foodDatabase.where((food) {
      final matchesSearch = _searchQuery.isEmpty ||
          food.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          food.category.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFilter = _filterLevel == null || food.level == _filterLevel;
      final matchesFavorites = !_showFavoritesOnly || _favorites.contains(food.name);
      return matchesSearch && matchesFilter && matchesFavorites;
    }).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<void> _showTodaysLog() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final logKey = 'oxalate_log_${now.year}_${now.month}_${now.day}';
    final oxKey = 'oxalate_${now.year}_${now.month}_${now.day}';

    List<String> log = prefs.getStringList(logKey) ?? [];
    double total = prefs.getDouble(oxKey) ?? 0;

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.35,
          maxChildSize: 0.85,
          expand: false,
          builder: (_, scrollController) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Container(width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    )),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Today's Food Log",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.teal.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text('${total.toStringAsFixed(1)} mg total',
                          style: const TextStyle(
                              color: Colors.teal, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: log.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.restaurant_menu,
                          size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text('No foods logged yet today',
                          style: TextStyle(
                              color: Colors.grey.shade400, fontSize: 16)),
                      const SizedBox(height: 6),
                      Text('Tap "Log This Food" on any food item',
                          style: TextStyle(
                              color: Colors.grey.shade400, fontSize: 13)),
                    ],
                  ),
                )
                    : ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  itemCount: log.length,
                  separatorBuilder: (_, __) =>
                  const Divider(height: 1),
                  itemBuilder: (_, index) {
                    final parts = log[index].split('|');
                    final foodName = parts[0];
                    final foodMg = double.tryParse(parts[1]) ?? 0;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      leading: Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(
                          color: Colors.teal.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.restaurant,
                            color: Colors.teal, size: 20),
                      ),
                      title: Text(foodName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.teal.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${foodMg.toStringAsFixed(1)} mg',
                              style: const TextStyle(
                                  color: Colors.teal,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () async {
                              final updatedLog = List<String>.from(log)
                                ..removeAt(index);
                              final updatedTotal =
                              (total - foodMg).clamp(0.0, double.infinity);
                              await prefs.setStringList(logKey, updatedLog);
                              await prefs.setDouble(oxKey, updatedTotal);
                              setSheetState(() {
                                log = updatedLog;
                                total = updatedTotal;
                              });
                            },
                            child: Icon(Icons.delete_outline,
                                color: Colors.red.shade300, size: 22),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFoodDetail(FoodItem food) {
    final color = levelColor[food.level]!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: Text(food.name,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
                GestureDetector(
                  onTap: () {
                    _toggleFavorite(food.name);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _favorites.contains(food.name)
                              ? '💔 Removed from Favorites'
                              : '❤️ Added to Favorites',
                        ),
                        backgroundColor: Colors.teal,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.all(16),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      _favorites.contains(food.name)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: _favorites.contains(food.name)
                          ? Colors.redAccent
                          : Colors.grey.shade400,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(levelIcon[food.level], color: color, size: 16),
                    const SizedBox(width: 4),
                    Text(levelLabel[food.level]!,
                        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
                  ]),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(children: [
              _statCard('Oxalates', '${food.oxalateMg.toStringAsFixed(0)} mg', Icons.science_outlined, color),
              const SizedBox(width: 12),
              _statCard('Serving', food.serving, Icons.restaurant_outlined, Colors.teal),
              const SizedBox(width: 12),
              _statCard('Category', food.category, Icons.category_outlined, Colors.blueGrey),
            ]),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.teal.withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline, color: Colors.teal, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Text(food.tip,
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.5))),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _logFood(food.oxalateMg, food.name);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(children: [
                        const Icon(Icons.check_circle, color: Colors.white, size: 20),
                        const SizedBox(width: 10),
                        Expanded(child: Text(
                          '${food.name} logged — +${food.oxalateMg.toStringAsFixed(1)} mg',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        )),
                      ]),
                      backgroundColor: color,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.all(16),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                },
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Log This Food',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color),
              textAlign: TextAlign.center),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              textAlign: TextAlign.center),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final foods = _filteredFoods;

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: 'Search foods...',
                        prefixIcon: const Icon(Icons.search, color: Colors.teal),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _showTodaysLog(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.list_alt, color: Colors.grey.shade700, size: 16),
                          const SizedBox(width: 6),
                          Text('📋 Log',
                              style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _filterChip('All', null),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => setState(() {
                        _showFavoritesOnly = !_showFavoritesOnly;
                        if (_showFavoritesOnly) _filterLevel = null;
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: _showFavoritesOnly ? Colors.redAccent : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('❤️ Faves',
                            style: TextStyle(
                              color: _showFavoritesOnly ? Colors.white : Colors.grey.shade700,
                              fontWeight: _showFavoritesOnly ? FontWeight.bold : FontWeight.normal,
                              fontSize: 13,
                            )),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _filterChip('✅ Low', OxalateLevel.low),
                    const SizedBox(width: 8),
                    _filterChip('⚠️ Moderate', OxalateLevel.moderate),
                    const SizedBox(width: 8),
                    _filterChip('🚫 High', OxalateLevel.high),
                    const SizedBox(width: 8),
                    _filterChip('☠️ Very High', OxalateLevel.veryHigh),
                  ],
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),

        const BannerAdWidget(),
        const SizedBox(height: 4),

        Expanded(
          child: foods.isEmpty
              ? Center(child: Text('No foods found.',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 16)))
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: foods.length,
            itemBuilder: (context, index) {
              final food = foods[index];
              final color = levelColor[food.level]!;
              return GestureDetector(
                onTap: () => _showFoodDetail(food),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8, offset: const Offset(0, 2))
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(width: 12, height: 12,
                          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(food.name,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                            const SizedBox(height: 2),
                            Text('${food.category} • ${food.serving}',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('${food.oxalateMg.toStringAsFixed(0)} mg',
                            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _filterChip(String label, OxalateLevel? level) {
    final selected = _filterLevel == level;
    return GestureDetector(
      onTap: () => setState(() {
        _filterLevel = level;
        _showFavoritesOnly = false;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.teal : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.grey.shade700,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            )),
      ),
    );
  }
}
