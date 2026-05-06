// ─── SHOP SCREEN ──────────────────────────────────────────────────────────────
// Displays kidney stone prevention supplements and hydration products.
// All surface/text colors resolved dynamically via isDark ternaries.
// ──────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_scaffold.dart';

class ShopProduct {
  final String id;
  final String name;
  final String brand;
  final String category;
  final String description;
  final String benefit;
  final String dosage;
  final String price;
  final String rating;
  final String reviewCount;
  final String emoji;
  final String affiliateUrl;
  final bool isFeatured;
  final List<String> tags;

  const ShopProduct({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.description,
    required this.benefit,
    required this.dosage,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.emoji,
    required this.affiliateUrl,
    this.isFeatured = false,
    this.tags = const [],
  });
}

const List<ShopProduct> _products = [
  ShopProduct(
    id: 'potassium_citrate',
    name: 'Potassium Citrate',
    brand: 'Now Foods',
    category: 'Supplements',
    description: 'Helps alkalinize urine and prevent calcium oxalate and uric acid stones.',
    benefit: 'Raises urine pH and binds oxalate',
    dosage: '99 mg, 1–3x daily with meals',
    price: '\$12–\$18',
    rating: '4.6',
    reviewCount: '2.4k',
    emoji: '🧪',
    affiliateUrl: 'https://www.amazon.com/s?k=potassium+citrate+supplement',
    isFeatured: true,
    tags: ['oxalate', 'uric acid', 'alkaline'],
  ),
  ShopProduct(
    id: 'magnesium_citrate',
    name: 'Magnesium Citrate',
    brand: 'Doctor\'s Best',
    category: 'Supplements',
    description: 'Binds oxalate in the gut, reducing absorption and urinary oxalate levels.',
    benefit: 'Reduces oxalate absorption',
    dosage: '200–400 mg daily with meals',
    price: '\$10–\$20',
    rating: '4.5',
    reviewCount: '5.1k',
    emoji: '💊',
    affiliateUrl: 'https://www.amazon.com/s?k=magnesium+citrate+supplement',
    isFeatured: true,
    tags: ['oxalate', 'magnesium'],
  ),
  ShopProduct(
    id: 'vitamin_b6',
    name: 'Vitamin B6 (P-5-P)',
    brand: 'Solgar',
    category: 'Supplements',
    description: 'Reduces endogenous oxalate production in the liver.',
    benefit: 'Lowers internal oxalate production',
    dosage: '25–50 mg daily',
    price: '\$8–\$16',
    rating: '4.4',
    reviewCount: '890',
    emoji: '🌿',
    affiliateUrl: 'https://www.amazon.com/s?k=vitamin+b6+p5p+supplement',
    tags: ['oxalate', 'liver'],
  ),
  ShopProduct(
    id: 'chanca_piedra',
    name: 'Chanca Piedra Extract',
    brand: 'Stone Breaker',
    category: 'Herbal',
    description: 'Traditional herb shown to help break down and prevent kidney stones.',
    benefit: 'May reduce stone formation',
    dosage: '500 mg, 2x daily',
    price: '\$15–\$25',
    rating: '4.3',
    reviewCount: '3.2k',
    emoji: '🌱',
    affiliateUrl: 'https://www.amazon.com/s?k=chanca+piedra+kidney+stone',
    isFeatured: false,
    tags: ['herbal', 'traditional'],
  ),
  ShopProduct(
    id: 'water_bottle_large',
    name: '64oz Motivational Water Bottle',
    brand: 'HydroJug',
    category: 'Hydration',
    description: 'Time-marked bottle to hit your daily 2.5L hydration target easily.',
    benefit: 'Tracks daily water intake',
    dosage: 'Aim for 2–3 full bottles per day',
    price: '\$20–\$35',
    rating: '4.7',
    reviewCount: '12k',
    emoji: '💧',
    affiliateUrl: 'https://www.amazon.com/s?k=64oz+motivational+water+bottle',
    isFeatured: true,
    tags: ['hydration', 'daily use'],
  ),
  ShopProduct(
    id: 'electrolyte_powder',
    name: 'Sugar-Free Electrolyte Powder',
    brand: 'LMNT',
    category: 'Hydration',
    description: 'Sodium, potassium, and magnesium blend — no sugar, no oxalate concerns.',
    benefit: 'Supports hydration without citric acid',
    dosage: '1 packet per 16 oz water',
    price: '\$25–\$40',
    rating: '4.8',
    reviewCount: '28k',
    emoji: '⚡',
    affiliateUrl: 'https://www.amazon.com/s?k=LMNT+electrolyte+powder',
    isFeatured: false,
    tags: ['hydration', 'electrolytes'],
  ),
  ShopProduct(
    id: 'kidney_stone_strainer',
    name: 'Kidney Stone Urine Strainer',
    brand: 'QCP',
    category: 'Monitoring',
    description: 'Catch passed stones for lab analysis to identify stone type.',
    benefit: 'Identifies stone composition',
    dosage: 'Use during active stone passage',
    price: '\$8–\$15',
    rating: '4.2',
    reviewCount: '1.8k',
    emoji: '🔬',
    affiliateUrl: 'https://www.amazon.com/s?k=kidney+stone+urine+strainer',
    tags: ['monitoring', 'analysis'],
  ),
  ShopProduct(
    id: 'ph_test_strips',
    name: 'Urine pH Test Strips',
    brand: 'HealthyWiser',
    category: 'Monitoring',
    description: 'Monitor urine pH daily — optimal range for stone prevention is 6.5–7.5.',
    benefit: 'Track urine alkalinity',
    dosage: 'Test first morning urine daily',
    price: '\$8–\$12',
    rating: '4.4',
    reviewCount: '4.6k',
    emoji: '📊',
    affiliateUrl: 'https://www.amazon.com/s?k=urine+pH+test+strips',
    isFeatured: false,
    tags: ['monitoring', 'pH'],
  ),
  ShopProduct(
    id: 'lemon_juice',
    name: 'Organic Lemon Juice Concentrate',
    brand: 'Santa Cruz',
    category: 'Food & Drink',
    description: 'High citrate content helps prevent calcium stone formation in the kidneys.',
    benefit: 'Raises urinary citrate naturally',
    dosage: '4 oz daily diluted in water',
    price: '\$6–\$10',
    rating: '4.5',
    reviewCount: '7.2k',
    emoji: '🍋',
    affiliateUrl: 'https://www.amazon.com/s?k=organic+lemon+juice+concentrate',
    isFeatured: true,
    tags: ['citrate', 'natural', 'food'],
  ),
  ShopProduct(
    id: 'oxalate_food_guide',
    name: 'The Kidney Stone Diet Book',
    brand: 'Jill Harris RN',
    category: 'Education',
    description: 'Comprehensive guide to low-oxalate eating, meal planning, and stone prevention.',
    benefit: 'Complete diet & lifestyle guide',
    dosage: 'Read and apply daily',
    price: '\$15–\$25',
    rating: '4.9',
    reviewCount: '890',
    emoji: '📚',
    affiliateUrl: 'https://www.amazon.com/s?k=kidney+stone+diet+book',
    tags: ['education', 'diet'],
  ),
];

const List<String> _categories = [
  'All', 'Supplements', 'Hydration', 'Monitoring', 'Food & Drink', 'Herbal', 'Education'
];

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});
  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  String _selectedCategory = 'All';
  final Set<String> _wishlist = {};
  bool _showFeaturedOnly = false;

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('shop_wishlist') ?? [];
    setState(() => _wishlist.addAll(saved));
  }

  Future<void> _toggleWishlist(String id) async {
    setState(() {
      if (_wishlist.contains(id)) {
        _wishlist.remove(id);
      } else {
        _wishlist.add(id);
      }
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('shop_wishlist', _wishlist.toList());
  }

  List<ShopProduct> get _filtered {
    return _products.where((p) {
      final catMatch = _selectedCategory == 'All' || p.category == _selectedCategory;
      final featMatch = !_showFeaturedOnly || p.isFeatured;
      return catMatch && featMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final cardBg  = isDark ? const Color(0xFF1A2332) : Colors.white;
    final borderC = isDark ? const Color(0xFF2E4055) : const Color(0xFFD0D0D8);
    final mutedC  = isDark ? const Color(0xFF8FA8BE) : const Color(0xFF888888);
    return GradientScaffold(
      title: 'Stone Prevention Shop',
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'These are affiliate links. Always consult your doctor before starting supplements.',
                    style: TextStyle(fontSize: 11.5, color: mutedC),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 34,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final cat = _categories[i];
                        final selected = cat == _selectedCategory;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedCategory = cat),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: selected ? AppColors.primary : cardBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: selected ? AppColors.primary : borderC),
                            ),
                            child: Text(
                              cat,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                                color: selected ? Colors.white : mutedC,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() => _showFeaturedOnly = !_showFeaturedOnly),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _showFeaturedOnly ? AppColors.primary.withValues(alpha: 0.12) : cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _showFeaturedOnly ? AppColors.primary : borderC),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.star_rounded, size: 14,
                            color: _showFeaturedOnly ? AppColors.primary : mutedC),
                        const SizedBox(width: 4),
                        Text('Top Picks',
                            style: TextStyle(fontSize: 12,
                                color: _showFeaturedOnly ? AppColors.primary : mutedC)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _filtered.isEmpty
                ? Center(child: Text('No products in this category',
                    style: TextStyle(color: mutedC)))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    itemCount: _filtered.length,
                    itemBuilder: (context, index) {
                      final product = _filtered[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ProductCard(
                          product: product,
                          isWishlisted: _wishlist.contains(product.id),
                          onWishlist: () => _toggleWishlist(product.id),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ShopProduct product;
  final bool isWishlisted;
  final VoidCallback onWishlist;

  const _ProductCard({
    required this.product,
    required this.isWishlisted,
    required this.onWishlist,
  });

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final cardBg  = isDark ? const Color(0xFF1A2332) : Colors.white;
    final borderC = isDark ? const Color(0xFF2E4055) : const Color(0xFFD0D0D8);
    final bgC     = isDark ? const Color(0xFF0F1419) : const Color(0xFFF4F6F8);
    final textC   = isDark ? const Color(0xFFE8EDF2) : const Color(0xFF2C2C2C);
    final mutedC  = isDark ? const Color(0xFF8FA8BE) : const Color(0xFF888888);
    return GestureDetector(
      onTap: () => _launch(product.affiliateUrl),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderC),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: bgC,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderC),
                  ),
                  child: Center(
                    child: Text(product.emoji, style: const TextStyle(fontSize: 24)),
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
                            child: Text(product.name,
                                style: TextStyle(fontSize: 14,
                                    fontWeight: FontWeight.w600, color: textC)),
                          ),
                          if (product.isFeatured)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('Top Pick',
                                  style: TextStyle(fontSize: 10,
                                      color: AppColors.primary, fontWeight: FontWeight.w600)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(product.brand, style: TextStyle(fontSize: 12, color: mutedC)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 13, color: Color(0xFFFFB300)),
                          const SizedBox(width: 3),
                          Text(product.rating,
                              style: TextStyle(fontSize: 12,
                                  fontWeight: FontWeight.w600, color: textC)),
                          const SizedBox(width: 4),
                          Text('(${product.reviewCount})',
                              style: TextStyle(fontSize: 11, color: mutedC)),
                          const Spacer(),
                          Text(product.price,
                              style: const TextStyle(fontSize: 13,
                                  fontWeight: FontWeight.w600, color: AppColors.primary)),
                        ],
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onWishlist,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(
                      isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      size: 22,
                      color: isWishlisted ? const Color(0xFFE07070) : mutedC,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(product.description, style: TextStyle(fontSize: 13, color: textC, height: 1.4)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: bgC,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: borderC),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Benefit', style: TextStyle(fontSize: 10, color: mutedC,
                            fontWeight: FontWeight.w500)),
                        const SizedBox(height: 2),
                        Text(product.benefit, style: TextStyle(fontSize: 11, color: textC,
                            fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: bgC,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: borderC),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dosage', style: TextStyle(fontSize: 10, color: mutedC,
                            fontWeight: FontWeight.w500)),
                        const SizedBox(height: 2),
                        Text(product.dosage, style: TextStyle(fontSize: 11, color: textC,
                            fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _launch(product.affiliateUrl),
                icon: const Icon(Icons.open_in_new_rounded, size: 15),
                label: const Text('View on Amazon'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
