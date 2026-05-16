// ─── PRIVACY POLICY SCREEN ───────────────────────────────────────────────────
// Fix 11 — Upgraded: Full theme, structured sections, medical disclaimer card.
//
// Displayed from Settings → Privacy → Privacy Policy.
//
// Covers:
//   • What data is collected and stored locally
//   • How it is protected (AES-256, Flutter Secure Storage, no backup)
//   • What leaves the device (nothing auto — only user-initiated share)
//   • Third-party advertising (AdMob — consent-gated)
//   • Data retention and deletion
//   • Medical disclaimer
//   • Contact information
//
// Keep this screen in sync with your Google Play Store privacy policy URL.

import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// App palette constants (inline so this screen has no import dependencies
// that could differ between branches).
// ---------------------------------------------------------------------------
const _kTeal       = Color(0xFF01696F);
const _kWarning    = Color(0xFFB85C1A);
const _kTextPrimary   = Color(0xFF1A1A2E);
const _kTextSecondary = Color(0xFF4A4A6A);
const _kTextHint      = Color(0xFF9090A8);
const _kBgPage        = Color(0xFFF4F6FA);

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBgPage,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: _kTeal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Header card ────────────────────────────────────────────────
            _HeaderCard(
              icon: Icons.shield_outlined,
              title: 'Your Health Data Stays on Your Device',
              subtitle:
                  'StoneGuard is built on one principle: your personal health '
                  'information belongs to you. We do not collect it, sell it, '
                  'or send it to any server.',
            ),
            const SizedBox(height: 18),

            // Meta row
            _metaRow('Last updated', 'May 2026'),
            _metaRow('App version', '1.0.0'),
            _metaRow('Contact', 'stoneguardapp@gmail.com'),
            const SizedBox(height: 28),

            // ── 1. What we store ────────────────────────────────────────────
            const _SectionTitle('1. What StoneGuard Stores'),
            const _BodyText(
              'All data listed below is stored exclusively on your device. '
              'Nothing is transmitted to StoneGuard servers because '
              'StoneGuard has no servers.',
            ),
            const SizedBox(height: 10),
            const _BulletList(items: [
              'Daily water intake (fluid ounces)',
              'Daily oxalate intake (milligrams) and food log entries',
              'Hydration and oxalate goals',
              'Symptom journal entries: pain level, side, symptoms, notes, stone-passed flag',
              'Stone event history: type, size, date, treatment',
              'Up to 2 years (730 days) of daily history for trend charts',
              'Display name and optional avatar photo (used only within the app)',
              'App preferences: theme, notification settings, stone type, age',
              'Ad consent flag (yes/no only — no health data is linked to ads)',
            ]),
            const SizedBox(height: 24),

            // ── 2. How we protect it ──────────────────────────────────────
            const _SectionTitle('2. How Your Data Is Protected'),
            const _BodyText(
              'StoneGuard uses multiple layers of encryption to protect your '
              'health data at rest:',
            ),
            const SizedBox(height: 10),
            const _BulletList(items: [
              'Journal entries are stored in an AES-256 encrypted SQLite database '
                  '(SQLCipher). The database key is stored in the Android Keystore '
                  '/ iOS Keychain via Flutter Secure Storage, not in plain storage.',
              'Daily history and current-day health data (water, oxalate, food log, '
                  'goals) are encrypted with AES-256-CBC using random IVs per save. '
                  'Encryption keys are stored in the Android Keystore / iOS Keychain.',
              'System backups are disabled (android:allowBackup="false") so Android '
                  'cannot copy your health data to cloud backup without your consent.',
              'All network traffic is restricted to HTTPS only.',
            ]),
            const SizedBox(height: 24),

            // ── 3. What leaves your device ────────────────────────────────
            const _SectionTitle('3. What Leaves Your Device'),
            const _BodyText(
              'Nothing leaves your device automatically. Data only leaves '
              'when YOU initiate an explicit share action:',
            ),
            const SizedBox(height: 10),
            const _BulletList(items: [
              'Doctor Report export: tapping "Export" generates a PDF that is '
                  'offered via the OS share sheet. You choose the destination '
                  '(email, print, cloud drive, etc.). StoneGuard never sends '
                  'it anywhere automatically.',
              'Temporary export files are stored in app-private storage and '
                  'deleted as soon as the share sheet is dismissed.',
            ]),
            const SizedBox(height: 24),

            // ── 4. Advertising ─────────────────────────────────────────────
            const _SectionTitle('4. Advertising (Google AdMob)'),
            const _BodyText(
              'StoneGuard may display ads from Google AdMob to support free '
              'access to the app. Ads are ONLY loaded if you gave consent at '
              'first launch. If you declined, no ads load and no ad-related '
              'tracking occurs on your device.',
            ),
            const SizedBox(height: 10),
            const _BulletList(items: [
              'AdMob may use your advertising ID (a resettable device identifier) '
                  'to serve relevant ads.',
              'No health data from StoneGuard (water logs, pain scores, journal '
                  'text, oxalate data) is ever shared with Google or any advertiser.',
              'You can review or change your ad consent at any time: '
                  'Settings → Privacy → Ad Preferences.',
              'Google\'s privacy policy: https://policies.google.com/privacy',
            ]),
            const SizedBox(height: 24),

            // ── 5. Data retention ──────────────────────────────────────────
            const _SectionTitle('5. Data Retention & Deletion'),
            const _BodyText('You are in full control of your data:'),
            const SizedBox(height: 10),
            const _BulletList(items: [
              'Daily history is automatically trimmed to the most recent 730 days '
                  'to keep device storage usage low.',
              'Delete all data: Settings → Danger Zone → Clear All Data.',
              'Uninstalling the app removes all locally stored data.',
              'Because no data is stored on StoneGuard servers, there is nothing '
                  'to request deletion of from us.',
            ]),
            const SizedBox(height: 24),

            // ── 6. Children ────────────────────────────────────────────────
            const _SectionTitle('6. Children\'s Privacy'),
            const _BodyText(
              'StoneGuard is not directed at children under 13. We do not '
              'knowingly collect information from children. Because all data '
              'stays on-device, there is no server-side collection regardless '
              'of the user\'s age.',
            ),
            const SizedBox(height: 24),

            // ── 7. Policy changes ──────────────────────────────────────────
            const _SectionTitle('7. Changes to This Policy'),
            const _BodyText(
              'If this privacy policy changes materially, the updated policy '
              'will appear in the next app update and will be accessible from '
              'this screen. Continued use of the app after an update constitutes '
              'acceptance of the revised policy.',
            ),
            const SizedBox(height: 24),

            // ── 8. Contact ────────────────────────────────────────────────
            const _SectionTitle('8. Contact'),
            const _BodyText(
              'Privacy questions? Reach us at:\n'
              'stoneguardapp@gmail.com',
            ),
            const SizedBox(height: 32),

            // ── Medical disclaimer ──────────────────────────────────────────
            const _MedicalDisclaimerCard(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _metaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          Text('$label: ',
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _kTextHint)),
          Text(value,
              style: const TextStyle(fontSize: 12, color: _kTextHint)),
        ],
      ),
    );
  }
}

// ─── Reusable sub-widgets ───────────────────────────────────────────────────────

class _HeaderCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _HeaderCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kTeal.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kTeal.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _kTeal, size: 30),
          const SizedBox(height: 10),
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _kTextPrimary)),
          const SizedBox(height: 8),
          Text(subtitle,
              style: const TextStyle(
                  fontSize: 13,
                  color: _kTextSecondary,
                  height: 1.55)),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(text,
          style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _kTextPrimary)),
    );
  }
}

class _BodyText extends StatelessWidget {
  final String text;
  const _BodyText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
            fontSize: 13, color: _kTextSecondary, height: 1.6));
  }
}

class _BulletList extends StatelessWidget {
  final List<String> items;
  const _BulletList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6, right: 9),
                      child: CircleAvatar(
                          radius: 3,
                          backgroundColor:
                              _kTeal.withValues(alpha: 0.7)),
                    ),
                    Expanded(
                      child: Text(item,
                          style: const TextStyle(
                              fontSize: 13,
                              color: _kTextSecondary,
                              height: 1.55)),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

class _MedicalDisclaimerCard extends StatelessWidget {
  const _MedicalDisclaimerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _kWarning.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: _kWarning.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.medical_information_outlined,
                  color: _kWarning, size: 20),
              const SizedBox(width: 8),
              const Text('Medical Disclaimer',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _kWarning)),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'StoneGuard is a personal health tracking tool for '
            'informational and self-monitoring purposes only. '
            'It is NOT a medical device. Information provided by '
            'this app is NOT a substitute for professional medical '
            'advice, diagnosis, or treatment.',
            style: TextStyle(
                fontSize: 12, color: _kTextSecondary, height: 1.6),
          ),
          const SizedBox(height: 8),
          const Text(
            'Always consult your physician, urologist, or a qualified '
            'healthcare provider before making dietary or lifestyle changes '
            'related to kidney stone management. In an emergency, call 911 '
            'or go to your nearest emergency room immediately.',
            style: TextStyle(
                fontSize: 12, color: _kTextSecondary, height: 1.6),
          ),
        ],
      ),
    );
  }
}
