import 'package:flutter/material.dart';
import 'package:stoneguard/widgets/banner_ad_widget.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_scaffold.dart';
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
    return GradientScaffold(
      title: 'Learn',
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 22),
          tooltip: 'Settings',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          ),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
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
            icon: Icons.science,
            color: AppColors.teal,
            title: 'Magnesium & B6',
            body:
            'Magnesium helps prevent oxalate absorption in the intestines. '
                'Vitamin B6 reduces the production of oxalate in the body. '
                'Good sources: pumpkin seeds, sunflower seeds, bananas, and avocados. '
                'Talk to your doctor before starting supplements.',
          ),
          _expandableCard(
            icon: Icons.nightlight_round,
            color: const Color(0xFF3949AB),
            title: 'Sleep & Stress',
            body:
            'Chronic stress raises cortisol, which can increase urinary calcium. '
                'Poor sleep is linked to higher inflammation. '
                'Prioritize 7–9 hours of sleep and stress-reduction habits like walking, '
                'meditation, or journaling.',
          ),
          _expandableCard(
            icon: Icons.directions_walk,
            color: AppColors.success,
            title: 'Exercise & Weight',
            body:
            'Obesity is a significant risk factor for kidney stones. '
                'Regular moderate exercise — even 30 minutes of walking daily — '
                'can meaningfully reduce your risk over time. '
                'Avoid extreme low-carb diets, which can raise urinary oxalate.',
          ),
          const BannerAdWidget(),
          const SizedBox(height: 16),
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
    return GestureDetector(
      onTap: () => _toggle(title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: isOpen
                  ? color.withValues(alpha: 0.4)
                  : AppColors.border),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(title,
                        style: AppTextStyles.itemTitle),
                  ),
                  AnimatedRotation(
                    turns: isOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textHint, size: 22),
                  ),
                ],
              ),
            ),
            if (isOpen)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
                child: Text(body,
                    style: AppTextStyles.body.copyWith(
                        height: 1.6, fontSize: 13.5)),
              ),
          ],
        ),
      ),
    );
  }
}
