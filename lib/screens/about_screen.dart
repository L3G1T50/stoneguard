// ─── ABOUT SCREEN ──────────────────────────────────────────────────
// Batch H: Migrated from isolated local colour constants to AppTheme
//   tokens (AppColors, AppTextStyles, AppSpacing, AppCard, AppDynamic).
//   Removed every hardcoded Color(0xFF...) literal; the screen now
//   adapts automatically to light / dark mode via the global theme.
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_scaffold.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const String _privacyUrl =
      'https://www.freeprivacypolicy.com/live/c256b9ff-8fd7-4252-ac3b-2cc80b29633f';

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      title: 'About StoneGuard',
      body: SingleChildScrollView(
        padding: AppSpacing.pagePadding.add(
            const EdgeInsets.only(bottom: 40)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Hero ──────────────────────────────────────────────────
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.teal.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.shield_rounded,
                        size: 44, color: AppColors.teal),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'StoneGuard',
                    style: AppTextStyles.heading,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Calcium Oxalate Stone Prevention',
                    style: TextStyle(
                        color: AppColors.teal,
                        fontWeight: FontWeight.w600,
                        fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Built by a survivor, for survivors.',
                    style: AppTextStyles.body.copyWith(
                        fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── My Story ─────────────────────────────────────────────
            _buildSection(
              icon: Icons.person_outline_rounded,
              title: 'My Story',
              content:
                  'My journey with kidney stones began at just 10 years old '
                  '-- a 10/10 pain emergency that landed me in the hospital '
                  'in the middle of the night. Over the years, I have faced '
                  'this battle 11 times and counting. Each stone has reinforced '
                  'how important it is to stay on top of hydration and diet '
                  'every single day. It is not just a health goal for me '
                  '-- it is a necessity.',
            ),
            const SizedBox(height: 16),

            // ── Why I Built This ─────────────────────────────────────
            _buildSection(
              icon: Icons.lightbulb_outline_rounded,
              title: 'Why I Built This App',
              content:
                  'I tried other apps, but could not find a single one built '
                  'specifically for calcium oxalate kidney stone sufferers. '
                  'It is hard to remember which foods to avoid every day '
                  'and to stay consistent with drinking enough water. '
                  'That gap inspired me to build something custom -- '
                  'a one-of-a-kind app that benefits not just myself, '
                  'but everyone who deals with stones.',
            ),
            const SizedBox(height: 16),

            // ── What It Does ─────────────────────────────────────────
            _buildSection(
              icon: Icons.favorite_outline_rounded,
              title: 'What StoneGuard Does',
              content:
                  'StoneGuard is designed to be simple enough to use every day, '
                  'while being powerful enough to show you the bigger picture. '
                  'It tracks your hydration, monitors your oxalate intake, '
                  'and helps you understand where you are doing well and '
                  'where you can improve.\n\n'
                  'That real data can help you have more informed conversations '
                  'with your doctor about your specific kidney stone situation. '
                  'Knowledge is prevention -- and StoneGuard puts that '
                  'knowledge in your hands.',
            ),
            const SizedBox(height: 24),

            // ── Quote ────────────────────────────────────────────────
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.format_quote_rounded,
                      color: AppColors.teal, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Wondering if you are on track? '
                          'With StoneGuard, you will know for sure.',
                      style: AppTextStyles.body.copyWith(
                          fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Disclaimer ───────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: AppDynamic.border(
                accentColor: AppColors.warning,
                borderRadius: 12,
                bgAlpha: 0.07,
                borderAlpha: 0.30,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: AppColors.warning, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'StoneGuard is a self-tracking and educational tool only. '
                          'It does not replace medical advice, clinical evaluation, '
                          'lab results, or imaging. Always consult your healthcare '
                          'provider for diagnosis and treatment.',
                      style: AppTextStyles.body,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Legal / info tiles ────────────────────────────────────
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildLinkTile(
                    context,
                    icon: Icons.privacy_tip_outlined,
                    label: 'Privacy Policy',
                    url: _privacyUrl,
                    isFirst: true,
                  ),
                  const Divider(height: 1),
                  _buildInfoTile(
                    icon: Icons.shield_outlined,
                    label: 'Data Storage',
                    value: 'On-device only',
                  ),
                  const Divider(height: 1),
                  _buildInfoTile(
                    icon: Icons.science_outlined,
                    label: 'Stone Type',
                    value: 'Calcium Oxalate (v1)',
                  ),
                  const Divider(height: 1),
                  _buildInfoTile(
                    icon: Icons.info_outline,
                    label: 'Version',
                    value: '1.0.0',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Center(
              child: Text(
                '\u00A9 2026 StoneGuard. Made with love for stone survivors.',
                style: AppTextStyles.micro,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.teal, size: 20),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.itemTitle),
            ],
          ),
          const SizedBox(height: 10),
          Text(content, style: AppTextStyles.body),
        ],
      ),
    );
  }

  Widget _buildLinkTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String url,
    bool isFirst = false,
  }) {
    return InkWell(
      borderRadius: isFirst
          ? const BorderRadius.vertical(top: Radius.circular(14))
          : BorderRadius.zero,
      onTap: () => _launchUrl(context, url),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.teal, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: AppTextStyles.itemTitle),
            ),
            const Icon(Icons.open_in_new_rounded,
                color: AppColors.teal, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textHint, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: AppTextStyles.itemTitle),
          ),
          Text(value, style: AppTextStyles.body),
        ],
      ),
    );
  }
}
