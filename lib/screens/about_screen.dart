// about_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const Color _teal   = Color(0xFF1A8A9A);
  static const Color _dark   = Color(0xFF1A2530);
  static const Color _muted  = Color(0xFF607D8B);
  static const Color _bgColor= Color(0xFFF4F8FA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: _dark,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'About KidneyShield',
          style: TextStyle(
            color: Color(0xFF1A2530),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App logo + version card
              _card(
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: _teal.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.shield_outlined,
                          color: _teal, size: 34),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'KidneyShield',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: _dark,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Version 1.0.0',
                            style: TextStyle(fontSize: 12, color: _muted),
                          ),
                          Text(
                            'Kidney stone prevention tracker',
                            style: TextStyle(fontSize: 12, color: _muted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Mission
              const Text(
                'Our Mission',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _dark,
                ),
              ),
              const SizedBox(height: 8),
              _card(
                child: const Text(
                  'KidneyShield helps calcium oxalate kidney stone formers '
                  'stay on top of their daily hydration and dietary oxalate '
                  'goals — the two most evidence-based lifestyle levers for '
                  'reducing recurrence risk.\n\n'
                  'Built by a kidney stone former, for kidney stone formers.',
                  style: TextStyle(fontSize: 13, color: _muted, height: 1.55),
                ),
              ),
              const SizedBox(height: 16),

              // Key features
              const Text(
                'Key Features',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _dark,
                ),
              ),
              const SizedBox(height: 8),
              _featureCard(Icons.water_drop_outlined,
                  'Hydration Tracker',
                  'Log water intake and stay above your daily fluid goal.'),
              const SizedBox(height: 8),
              _featureCard(Icons.restaurant_menu_outlined,
                  'Oxalate Logger',
                  'Search 400+ foods and track daily oxalate mg.'),
              const SizedBox(height: 8),
              _featureCard(Icons.trending_up_outlined,
                  'Progress Charts',
                  'Weekly and monthly trend visualisations.'),
              const SizedBox(height: 8),
              _featureCard(Icons.picture_as_pdf_outlined,
                  'Doctor Report',
                  'Export a PDF summary to share at your next appointment.'),
              const SizedBox(height: 16),

              // Disclaimer
              _disclaimerCard(),
              const SizedBox(height: 16),

              // Links
              const Text(
                'Links',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _dark,
                ),
              ),
              const SizedBox(height: 8),
              _linkTile(
                  Icons.privacy_tip_outlined,
                  'Privacy Policy',
                  'https://sites.google.com/view/kidneyshieldprivacy/home',
                  context),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _featureCard(IconData icon, String title, String desc) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _teal.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _teal, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _dark)),
                const SizedBox(height: 2),
                Text(desc,
                    style:
                        const TextStyle(fontSize: 11, color: _muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _disclaimerCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF57C00).withValues(alpha: 0.30)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded,
              color: Color(0xFFF57C00), size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'KidneyShield is a wellness tracking tool, not a medical device. '
              'It does not diagnose, treat, or prevent any condition. Always '
              'follow your doctor\'s advice regarding kidney stone management.',
              style:
                  TextStyle(fontSize: 11, color: Color(0xFF5D4037), height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _linkTile(
      IconData icon, String label, String url, BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) await launchUrl(uri);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: _teal, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _dark)),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: _muted, size: 20),
          ],
        ),
      ),
    );
  }
}
