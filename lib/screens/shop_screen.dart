// ─── SHOP SCREEN ─────────────────────────────────────────────────────────────
// Amazon Associates affiliate tag: stoneguard-20
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_theme.dart';
import '../widgets/gradient_scaffold.dart';

// ─── Product Model ────────────────────────────────────────────────────────────
class _Product {
  final String title;
  final String subtitle;
  final String why;
  final String asin;        // Amazon product ID
  final IconData icon;
  final Color color;
  final String category;

  const _Product({
    required this.title,
    required this.subtitle,
    required this.why,
    required this.asin,
    required this.icon,
    required this.color,
    required this.category,
  });

  String get affiliateUrl =>
      'https://www.amazon.com/dp/$asin?tag=stoneguard-20';
}

// ─── Product Catalog ──────────────────────────────────────────────────────────
const List<_Product> _products = [

  // ── pH Test Strips ────────────────────────────────────────────────────────
  _Product(
    category: 'Urine pH',
    title: 'pH Test Strips (200ct)',
    subtitle: 'Urine & Saliva — 4.5 to 9.0',
    why: 'Track urine pH daily. Ideal range for stone prevention is 6.0–7.0.',
    asin: 'B00OBZPDCA',
    icon: Icons.science_outlined,
    color: Color(0xFF2196F3),
  ),
  _Product(
    category: 'Urine pH',
    title: 'Hydrion pH Strips',
    subtitle: 'Clinical-grade accuracy',
    why: 'Used by urologists. Color-coded for quick, accurate pH readings.',
    asin: 'B00XVGN3EG',
    icon: Icons.science_outlined,
    color: Color(0xFF2196F3),
  ),

  // ── Hydration ─────────────────────────────────────────────────────────────
  _Product(
    category: 'Hydration',
    title: 'Half Gallon Water Bottle',
    subtitle: '64 oz with time marker',
    why: 'Drinking 2–3L/day is the #1 way to prevent calcium oxalate stones.',
    asin: 'B08QS5G7MP',
    icon: Icons.water_drop_outlined,
    color: Color(0xFF00BCD4),
  ),
  _Product(
    category: 'Hydration',
    title: 'Hydration Tracker Bottle',
    subtitle: 'Smart LED reminder cap',
    why: 'Glows to remind you to drink every hour. Perfect for stone prevention.',
    asin: 'B09BNZ7VWP',
    icon: Icons.water_drop_outlined,
    color: Color(0xFF00BCD4),
  ),

  // ── Supplements ───────────────────────────────────────────────────────────
  _Product(
    category: 'Supplements',
    title: 'Magnesium Citrate 400mg',
    subtitle: 'Reduces oxalate absorption',
    why: 'Magnesium binds to oxalate in the gut, reducing kidney stone risk.',
    asin: 'B000BD0RT0',
    icon: Icons.medication_outlined,
    color: Color(0xFF9C27B0),
  ),
  _Product(
    category: 'Supplements',
    title: 'Potassium Citrate',
    subtitle: 'Urine alkalizer',
    why: 'Raises urine pH and citrate levels — a key stone prevention strategy.',
    asin: 'B00CAZAU62',
    icon: Icons.medication_outlined,
    color: Color(0xFF9C27B0),
  ),
  _Product(
    category: 'Supplements',
    title: 'Vitamin B6 (P-5-P)',
    subtitle: 'Reduces oxalate production',
    why: 'B6 helps the body convert oxalate before it reaches the kidneys.',
    asin: 'B0019GW3G8',
    icon: Icons.medication_outlined,
    color: Color(0xFF9C27B0),
  ),

  // ── Diet & Kitchen ────────────────────────────────────────────────────────
  _Product(
    category: 'Diet & Kitchen',
    title: 'The Kidney Stone Diet Book',
    subtitle: 'By Jill Harris RN',
    why: 'The go-to guide by the nation\'s top kidney stone dietitian.',
    asin: '1736242504',
    icon: Icons.menu_book_outlined,
    color: Color(0xFF4CAF50),
  ),
  _Product(
    category: 'Diet & Kitchen',
    title: 'Lemon Juice Concentrate',
    subtitle: '32 oz — daily citrate boost',
    why: 'Lemon juice raises urinary citrate, which inhibits stone formation.',
    asin: 'B00LIFCKCK',
    icon: Icons.lunch_dining_outlined,
    color: Color(0xFF4CAF50),
  ),

  // ── Strainers ─────────────────────────────────────────────────────────────
  _Product(
    category: 'Stone Strainers',
    title: 'Kidney Stone Strainer Kit',
    subtitle: '3-pack urine strainers',
    why: 'Catch passed stones for lab analysis — critical for identifying stone type.',
    asin: 'B01N4G2CXX',
    icon: Icons.filter_alt_outlined,
    color: Color(0xFFFF9800),
  ),

  // ── Heating Pads ──────────────────────────────────────────────────────────
  _Product(
    category: 'Pain Relief',
    title: 'Electric Heating Pad',
    subtitle: 'XL fast-heating, auto shutoff',
    why: 'Heat applied to the flank reduces kidney stone pain during an episode.',
    asin: 'B077GPPFXT',
    icon: Icons.thermostat_outlined,
    color: Color(0xFFF44336),
  ),
];

// ─── Screen ───────────────────────────────────────────────────────────────────
class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  String _selectedCategory = 'All';

  List<String> get _categories {
    final cats = _products.map((p) => p.category).toSet().toList();
    cats.sort();
    return ['All', ...cats];
  }

  List<_Product> get _filtered => _selectedCategory == 'All'
      ? _products
      : _products.where((p) => p.category == _selectedCategory).toList();

  Future<void> _openProduct(_Product product) async {
    final uri = Uri.parse(product.affiliateUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Amazon. Check your connection.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return GradientScaffold(
      title: 'Stone Guard Shop',
      body: CustomScrollView(
        slivers: [

          // ── Disclaimer banner ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: AppColors.primary, size: 18),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'StoneGuard recommends these kidney stone tools based on urological best practices. '
                      'As an Amazon Associate we earn from qualifying purchases.',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Category filter chips ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories.map((cat) {
                    final active = _selectedCategory == cat;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.primary.withValues(alpha: 0.12)
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: active ? AppColors.primary : AppColors.border,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: active
                                ? AppColors.primary
                                : AppColors.textMuted,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          // ── Product count ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
              child: Text(
                '${filtered.length} product${filtered.length == 1 ? '' : 's'}',
                style: const TextStyle(
                  color: AppColors.textFaint,
                  fontSize: 12,
                ),
              ),
            ),
          ),

          // ── Product grid ────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => _ProductCard(
                  product: filtered[i],
                  onTap: () => _openProduct(filtered[i]),
                ),
                childCount: filtered.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Product Card ─────────────────────────────────────────────────────────────
class _ProductCard extends StatelessWidget {
  final _Product product;
  final VoidCallback onTap;

  const _ProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Icon box
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: product.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(product.icon, color: product.color, size: 26),
            ),
            const SizedBox(width: 14),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: product.color.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      product.category.toUpperCase(),
                      style: TextStyle(
                        color: product.color,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Title
                  Text(
                    product.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),

                  // Subtitle
                  Text(
                    product.subtitle,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Why it helps
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.shield_outlined,
                            color: AppColors.primary, size: 14),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            product.why,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // View on Amazon button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onTap,
                      icon: const Icon(Icons.open_in_new, size: 15),
                      label: const Text(
                        'View on Amazon',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9900), // Amazon orange
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
