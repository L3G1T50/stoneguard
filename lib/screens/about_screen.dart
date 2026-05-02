import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const Color _bg        = Color(0xFFF8F8F8);
  static const Color _surface   = Color(0xFFFFFFFF);
  static const Color _border    = Color(0xFFD0D0D8);
  static const Color _textPri   = Color(0xFF2C2C2C);
  static const Color _textMuted = Color(0xFF888888);
  static const Color _appBar    = Color(0xFFE8E8EC);
  static const Color _teal      = Color(0xFF1A8A9A);

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
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _appBar,
        elevation: 0,
        iconTheme: const IconThemeData(color: _textPri),
        centerTitle: true,
        title: const Text(
          'About StoneGuard',
          style: TextStyle(
              color: _textPri, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _teal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.shield_rounded,
                        size: 44, color: _teal),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'StoneGuard',
                    style: TextStyle(
                        color: _textPri,
                        fontWeight: FontWeight.bold,
                        fontSize: 26),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Calcium Oxalate Stone Prevention',
                    style: TextStyle(
                        color: _teal,
                        fontWeight: FontWeight.w600,
                        fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Built by a survivor, for survivors.',
                    style: TextStyle(
                        color: _textMuted,
                        fontStyle: FontStyle.italic,
                        fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // My Story
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
            const SizedBox(height: 20),

            // Why I Built This
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
            const SizedBox(height: 20),

            // What it does
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
            const SizedBox(height: 28),

            // Quote
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _teal.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _teal.withValues(alpha: 0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.format_quote_rounded, color: _teal, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Wondering if you are on track? '
                          'With StoneGuard, you will know for sure.',
                      style: TextStyle(
                          color: _textPri,
                          fontStyle: FontStyle.italic,
                          fontSize: 13,
                          height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Disclaimer
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFE082)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: Color(0xFFF9A825), size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'StoneGuard is a self-tracking and educational tool only. '
                          'It does not replace medical advice, clinical evaluation, '
                          'lab results, or imaging. Always consult your healthcare '
                          'provider for diagnosis and treatment.',
                      style: TextStyle(
                          color: Color(0xFF5D4037),
                          fontSize: 12,
                          height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Legal / Info tiles
            Container(
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _border),
              ),
              child: Column(
                children: [
                  _buildLinkTile(
                    context,
                    icon: Icons.privacy_tip_outlined,
                    label: 'Privacy Policy',
                    url: _privacyUrl,
                    isFirst: true,
                  ),
                  Divider(height: 1, color: _border),
                  _buildInfoTile(
                    icon: Icons.shield_outlined,
                    label: 'Data Storage',
                    value: 'On-device only',
                  ),
                  Divider(height: 1, color: _border),
                  _buildInfoTile(
                    icon: Icons.science_outlined,
                    label: 'Stone Type',
                    value: 'Calcium Oxalate (v1)',
                  ),
                  Divider(height: 1, color: _border),
                  _buildInfoTile(
                    icon: Icons.info_outline,
                    label: 'Version',
                    value: '1.0.0',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                '2026 StoneGuard. Made with love for stone survivors.',
                style: TextStyle(color: _textMuted, fontSize: 11),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _teal, size: 20),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      color: _textPri,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
                color: _textMuted, fontSize: 13, height: 1.6),
          ),
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
            Icon(icon, color: _teal, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      color: _textPri,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
            ),
            const Icon(Icons.open_in_new_rounded, color: _teal, size: 16),
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
          Icon(icon, color: _textMuted, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: const TextStyle(color: _textPri, fontSize: 14)),
          ),
          Text(value,
              style: const TextStyle(color: _textMuted, fontSize: 13)),
        ],
      ),
    );
  }
}