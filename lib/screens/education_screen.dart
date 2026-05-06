// ─── EDUCATION / LEARN SCREEN ────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_scaffold.dart';

// ─── Data model ───────────────────────────────────────────────────────────────────────────
class _Article {
  final String category;
  final String title;
  final String summary;
  final IconData icon;
  final Color color;
  final List<_Bullet> bullets;

  const _Article({
    required this.category,
    required this.title,
    required this.summary,
    required this.icon,
    required this.color,
    required this.bullets,
  });
}

class _Bullet {
  final String heading;
  final String body;
  const _Bullet(this.heading, this.body);
}

// ─── Article content ───────────────────────────────────────────────────────────────────
const List<_Article> _articles = [

  _Article(
    category: 'Hydration',
    title: 'Why Water Is Your #1 Defense',
    summary: 'Drinking enough fluid is the single most effective way to prevent calcium oxalate stones. Here\'s how much, what kind, and when.',
    icon: Icons.water_drop_outlined,
    color: Color(0xFF00BCD4),
    bullets: [
      _Bullet('Daily goal', 'Aim for 2.5–3 liters (84–100 oz) of fluid per day. Your urine should look pale yellow — not clear, not dark.'),
      _Bullet('Lemon water', 'Lemon juice adds urinary citrate, which directly inhibits stone crystal formation. Squeeze half a lemon into 8 oz of water twice daily.'),
      _Bullet('Spread it out', 'Sip throughout the day rather than drinking large amounts at once. Kidneys can only process ~1 liter per hour.'),
      _Bullet('Night matters', 'Drink a glass of water before bed. Urine concentrates overnight — when most stones begin to form.'),
      _Bullet('What counts', 'Water, herbal tea, broth, and diluted juice all count. Coffee and alcohol are mild diuretics — compensate with extra water.'),
    ],
  ),

  _Article(
    category: 'Diet',
    title: 'The Low-Oxalate Diet Explained',
    summary: 'Calcium oxalate stones are made from oxalate — a compound found in many healthy foods. Learning which foods to limit (and which to keep) makes a huge difference.',
    icon: Icons.restaurant_menu_outlined,
    color: Color(0xFF4CAF50),
    bullets: [
      _Bullet('High-oxalate foods to limit', 'Spinach, almonds, beets, Swiss chard, rhubarb, sweet potatoes, and dark chocolate contain 50–600 mg of oxalate per serving.'),
      _Bullet('Safe swaps', 'Replace spinach with kale or romaine. Swap almonds for macadamia nuts or sunflower seeds. Choose white or brown rice over quinoa.'),
      _Bullet('Don\'t cut calcium', 'Dietary calcium binds oxalate in your gut — preventing it from reaching your kidneys. Eat dairy or calcium-rich foods with meals.'),
      _Bullet('Sodium raises risk', 'High sodium causes more calcium to spill into urine. Limit sodium to under 2,300 mg/day. Read labels — processed food is the hidden culprit.'),
      _Bullet('Protein in moderation', 'Excess animal protein raises uric acid and calcium in urine. Aim for 0.8–1.0 g/kg body weight per day.'),
    ],
  ),

  _Article(
    category: 'Supplements',
    title: 'Supplements That Actually Help',
    summary: 'Some supplements are evidence-backed for stone prevention. Others are overhyped or can make things worse. Know the difference.',
    icon: Icons.medication_outlined,
    color: Color(0xFF9C27B0),
    bullets: [
      _Bullet('Magnesium citrate', 'Binds oxalate in the gut before it\'s absorbed. 200–400 mg/day of magnesium citrate (not oxide) is well-supported in studies.'),
      _Bullet('Potassium citrate', 'Raises urinary citrate and pH — both reduce stone risk. Often prescribed by urologists. Available OTC as supplements.'),
      _Bullet('Vitamin B6', 'Helps the body convert glyoxylate to glycine instead of oxalate. 25–50 mg/day of P-5-P form is most bioavailable.'),
      _Bullet('Vitamin C caution', 'High-dose vitamin C (>1,000 mg/day) is metabolized to oxalate. Keep supplemental C under 500 mg/day.'),
      _Bullet('Vitamin D balance', 'Deficiency is linked to stone risk, but excess D raises urinary calcium. Keep levels in the 40–60 ng/mL range.'),
    ],
  ),

  _Article(
    category: 'Understanding Stones',
    title: 'Types of Kidney Stones',
    summary: 'Not all kidney stones are the same. Knowing your stone type is the first step toward the right prevention strategy.',
    icon: Icons.science_outlined,
    color: Color(0xFFFF9800),
    bullets: [
      _Bullet('Calcium oxalate (most common)', '80% of stones. Caused by high oxalate, low citrate, or low fluid intake. Prevented by diet, hydration, and magnesium.'),
      _Bullet('Calcium phosphate', 'Form in alkaline urine. May be linked to hyperparathyroidism or renal tubular acidosis. Needs medical evaluation.'),
      _Bullet('Uric acid', '10% of stones. Caused by high animal protein, low fluid intake, or gout. Prevented by alkalizing urine and reducing meat.'),
      _Bullet('Struvite', 'Linked to urinary tract infections (UTIs). More common in women. Require treating the underlying infection.'),
      _Bullet('Cystine', 'Rare genetic condition. Requires high fluid intake (3+ liters/day) and specific medications prescribed by a urologist.'),
    ],
  ),

  _Article(
    category: 'Symptoms & First Aid',
    title: 'What To Do During a Stone Episode',
    summary: 'Passing a kidney stone is one of the most painful experiences possible. Here\'s how to manage an active episode and when to go to the ER.',
    icon: Icons.emergency_outlined,
    color: Color(0xFFF44336),
    bullets: [
      _Bullet('Pain location', 'Kidney stone pain (renal colic) starts in the flank — the back just below the ribs — and radiates to the groin and inner thigh.'),
      _Bullet('Heat therapy', 'Apply a heating pad to the flank for 20-minute intervals. Heat relaxes the ureter and significantly reduces pain.'),
      _Bullet('Stay hydrated', 'Drink water continuously during an episode. Fluids help push the stone toward the bladder and out.'),
      _Bullet('Strain your urine', 'Use a kidney stone strainer over the toilet to catch the stone. If caught, bring it to your doctor for analysis — it confirms your stone type.'),
      _Bullet('Go to the ER if…', 'You have fever or chills (sign of infection), uncontrollable vomiting, or pain so severe you cannot stand. These are medical emergencies.'),
    ],
  ),

  _Article(
    category: 'Lab & Testing',
    title: 'Understanding Your Urine Tests',
    summary: 'A 24-hour urine collection is the gold standard test for understanding why you form stones. Here\'s how to read your results.',
    icon: Icons.biotech_outlined,
    color: Color(0xFF2196F3),
    bullets: [
      _Bullet('Urine volume', 'Goal: >2.0 liters/day. Below this, minerals concentrate and crystallize. This is the single most fixable risk factor.'),
      _Bullet('Urine oxalate', 'Goal: <40 mg/day. High oxalate usually means either too many high-oxalate foods or too little dietary calcium with meals.'),
      _Bullet('Urine citrate', 'Goal: >320 mg/day (women), >450 mg/day (men). Citrate is your body\'s natural stone inhibitor. Low citrate = higher risk.'),
      _Bullet('Urine calcium', 'Goal: <250 mg/day (women), <300 mg/day (men). High calcium can be from diet, genetics, or a parathyroid issue.'),
      _Bullet('Urine pH', 'Ideal range: 6.0–7.0. Too acidic (under 5.5) promotes uric acid stones. Too alkaline (over 7.5) promotes calcium phosphate stones.'),
    ],
  ),
];

// ─── Screen ─────────────────────────────────────────────────────────────────────────────
class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  String _selectedCategory = 'All';

  List<String> get _categories {
    final cats = _articles.map((a) => a.category).toSet().toList();
    cats.sort();
    return ['All', ...cats];
  }

  List<_Article> get _filtered => _selectedCategory == 'All'
      ? _articles
      : _articles.where((a) => a.category == _selectedCategory).toList();

  void _openArticle(_Article article, bool isDark) {
    final surfaceCol = isDark ? AppColors.darkSurface    : AppColors.surface;
    final borderCol  = isDark ? AppColors.darkBorder     : AppColors.border;
    final bgCol      = isDark ? AppColors.darkBackground : AppColors.background;
    final textPri    = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textMut    = isDark ? AppColors.darkTextSecond  : AppColors.textSecond;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: surfaceCol,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (_, controller) => Column(
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: borderCol,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: article.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(article.icon, color: article.color, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article.category.toUpperCase(),
                          style: TextStyle(
                            color: article.color,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Text(
                          article.title,
                          style: TextStyle(
                            color: textPri,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: borderCol, height: 1),
            // Scrollable body
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: [
                  // Summary
                  Text(
                    article.summary,
                    style: TextStyle(
                      color: textMut,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Bullet points
                  ...article.bullets.map((b) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: bgCol,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderCol),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 3),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: article.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                b.heading,
                                style: TextStyle(
                                  color: textPri,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                b.body,
                                style: TextStyle(
                                  color: textMut,
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
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
    final isDark     = Theme.of(context).brightness == Brightness.dark;
    final surfaceCol = isDark ? AppColors.darkSurface    : AppColors.surface;
    final borderCol  = isDark ? AppColors.darkBorder     : AppColors.border;
    final textPri    = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textMut    = isDark ? AppColors.darkTextSecond  : AppColors.textSecond;
    final textFaint  = isDark ? AppColors.darkTextHint    : AppColors.textHint;
    final filtered   = _filtered;

    return GradientScaffold(
      title: 'Learn',
      body: CustomScrollView(
        slivers: [

          // ── Hero banner ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: isDark ? 0.25 : 0.10),
                    AppColors.primary.withValues(alpha: isDark ? 0.10 : 0.04),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.school_outlined,
                      color: AppColors.primary, size: 36),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Stone Prevention Guide',
                          style: TextStyle(
                            color: textPri,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_articles.length} evidence-based articles to help you stop stones before they start.',
                          style: TextStyle(
                              color: textMut, fontSize: 12, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Category chips ──────────────────────────────────────────────
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
                              : surfaceCol,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                active ? AppColors.primary : borderCol,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color:
                                active ? AppColors.primary : textMut,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          // ── Article count ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
              child: Text(
                '${filtered.length} article${filtered.length == 1 ? '' : 's'}',
                style: TextStyle(color: textFaint, fontSize: 12),
              ),
            ),
          ),

          // ── Article cards ───────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final article = filtered[i];
                  return GestureDetector(
                    onTap: () => _openArticle(article, isDark),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: surfaceCol,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderCol),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(alpha: isDark ? 0.25 : 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: article.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Icon(article.icon,
                                color: article.color, size: 24),
                          ),
                          const SizedBox(width: 14),
                          // Text
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Category badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: article.color
                                        .withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    article.category.toUpperCase(),
                                    style: TextStyle(
                                      color: article.color,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  article.title,
                                  style: TextStyle(
                                    color: textPri,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  article.summary,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: textMut,
                                      fontSize: 12,
                                      height: 1.4),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Text(
                                      '${article.bullets.length} key points',
                                      style: TextStyle(
                                          color: article.color,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(Icons.arrow_forward_ios,
                                        size: 10, color: article.color),
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
                childCount: filtered.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
