import 'package:flutter/material.dart';
import 'package:stoneguard/widgets/banner_ad_widget.dart';
import '../theme/app_theme.dart';
import 'emergency_care_screen.dart';
import 'settings_screen.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  final Map<String, bool> _expanded = {};

  void _toggle(String title) {
    setState(() {
      _expanded[title] = !(_expanded[title] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: StoneGuardAppBar(
        title: 'Learn',
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.textPrimary),
            tooltip: 'Settings',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ── EMERGENCY CARE BANNER ──
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const EmergencyCareScreen()),
            ),
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFE53935), Color(0xFFC62828)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: Color(0xFFE53935).withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.emergency,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Emergency Care Guide',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                        SizedBox(height: 2),
                        Text('Know when to call 911 or go to the ER',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: Colors.white70, size: 22),
                ],
              ),
            ),
          ),

          // ── EXPANDABLE CARDS ──
          _expandableCard(
            icon: Icons.info_outline,
            color: AppColors.teal,
            title: 'What Are Calcium Oxalate Stones?',
            body:
            'Calcium oxalate stones are the most common type of kidney stone. '
                'They form when oxalate — a natural compound found in many foods — '
                'binds with calcium in the urine and crystallizes.',
          ),
          _expandableCard(
            icon: Icons.water_drop,
            color: Colors.blue,
            title: 'Hydration Is #1',
            body:
            'Drinking enough water is the single most effective way to prevent kidney stones. '
                'Aim for at least 2.5–3 liters (84–100 oz) of water per day. '
                'Your urine should be pale yellow.',
          ),
          _expandableCard(
            icon: Icons.no_meals,
            color: AppColors.warning,
            title: 'High-Oxalate Foods to Limit',
            body:
            'Spinach, almonds, rhubarb, beets, Swiss chard, and dark chocolate are very high in oxalate. '
                'You don\'t have to eliminate them, but portion control matters. '
                'Pair them with calcium-rich foods to reduce absorption.',
          ),
          _expandableCard(
            icon: Icons.check_circle_outline,
            color: AppColors.success,
            title: 'Safe Foods to Enjoy',
            body:
            'Rice, pasta, white bread, eggs, meat, fish, most fruits (apples, bananas, grapes), '
                'and dairy products are low in oxalate. Calcium from food (not supplements) actually helps — '
                'it binds oxalate in the gut before it reaches your kidneys.',
          ),
          _expandableCard(
            icon: Icons.science_outlined,
            color: AppColors.oxalate,
            title: 'What About Calcium?',
            body:
            'Counterintuitively, eating MORE dietary calcium can help prevent stones — '
                'it binds oxalate in the gut so less reaches the kidneys. '
                'However, calcium supplements (pills) may increase risk. '
                'Get calcium from food like dairy instead.',
          ),
          _expandableCard(
            icon: Icons.local_cafe,
            color: const Color(0xFF6D4C41),
            title: 'Sodium & Protein',
            body:
            'High sodium increases calcium in the urine, raising stone risk. '
                'High animal protein lowers urine pH and citrate levels. '
                'Limit processed foods, fast food, and excessive red meat.',
          ),
          _expandableCard(
            icon: Icons.medical_services_outlined,
            color: AppColors.danger,
            title: 'When to See a Doctor',
            body:
            'See a doctor immediately if you have severe flank pain, blood in urine, '
                'fever with stone symptoms, or repeated stones. '
                'A urologist can order a 24-hour urine test to find your personal risk factors.',
          ),
          _expandableCard(
            icon: Icons.emoji_nature,
            color: const Color(0xFFF9A825),
            title: 'The Power of Citrate',
            body:
            'Citrate is one of the most powerful natural defenses against kidney stones. '
                'It binds calcium in the urine and prevents crystals from forming.\n\n'
                '• Squeeze fresh lemon or lime into your water daily\n'
                '• Orange juice and lemonade are good natural sources\n'
                '• Your doctor may prescribe potassium citrate if dietary sources aren\'t enough\n\n'
                'Even half a lemon squeezed into water each morning can make a meaningful difference over time.',
          ),
          _expandableCard(
            icon: Icons.quiz_outlined,
            color: const Color(0xFF3949AB),
            title: 'FAQ — Common Questions',
            body:
            'Q: Why do I keep getting kidney stones?\n'
                'A: Recurring stones are usually due to a combination of genetics, diet, and not drinking enough fluids. '
                'A 24-hour urine test from your urologist can pinpoint your exact risk factors.\n\n'
                'Q: Is oxalate the only thing I need to worry about?\n'
                'A: No. Sodium, animal protein, hydration, and low citrate levels all play a role. '
                'StoneGuard tracks the most important daily factors.\n\n'
                'Q: Can I ever eat high-oxalate foods again?\n'
                'A: Yes — moderation and pairing them with calcium-rich foods (like cheese or milk) '
                'significantly reduces how much oxalate your body absorbs.\n\n'
                'Q: Does drinking more water really work?\n'
                'A: Yes — it\'s the single most proven prevention method. '
                'More fluid = more diluted urine = less chance of crystals forming.\n\n'
                'Q: What\'s the fastest sign I\'m improving?\n'
                'A: Pale yellow urine throughout the day means you\'re well hydrated. '
                'That\'s your daily goal.',
          ),
          _expandableCard(
            icon: Icons.favorite_outline,
            color: Colors.pinkAccent,
            title: 'Mental Support — You\'re Not Alone',
            body:
            'Kidney stones are one of the most painful experiences a person can go through — '
                'and dealing with them repeatedly takes a real mental toll.\n\n'
                'It\'s okay to feel frustrated. It\'s okay to have hard days. '
                'What matters is that you keep showing up for yourself.\n\n'
                '💧 Every glass of water is an act of self-care.\n'
                '🥗 Every smart food choice is a win — even small ones.\n'
                '📓 Tracking your patterns gives you power over your condition.\n'
                '🏥 Your data can help your doctor help you better.\n\n'
                'Prevention isn\'t perfect — but consistency over time makes a real difference. '
                'StoneGuard is here to help you stay consistent, one day at a time.\n\n'
                'You\'ve survived every stone so far. Keep going. 💪',
          ),

          const SizedBox(height: 12),

          // ── DISCLAIMER ──
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.warningBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: AppColors.warning, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'This app is for tracking and educational purposes only. '
                        'It is not a medical device and does not offer medical advice. '
                        'Always consult a doctor.',
                    style: AppTextStyles.body.copyWith(color: AppColors.warning),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const BannerAdWidget(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _expandableCard({
    required IconData icon,
    required Color color,
    required String title,
    required String body,
  }) {
    final isOpen = _expanded[title] ?? false;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          splashColor: color.withValues(alpha: 0.06),
          highlightColor: color.withValues(alpha: 0.04),
          onTap: () => _toggle(title),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.itemTitle,
                      ),
                    ),
                    Icon(
                      isOpen ? Icons.expand_less : Icons.expand_more,
                      color: AppColors.textHint,
                      size: 22,
                    ),
                  ],
                ),
                if (isOpen) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppColors.divider),
                  const SizedBox(height: 12),
                  Text(
                    body,
                    style: AppTextStyles.body.copyWith(height: 1.6),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
