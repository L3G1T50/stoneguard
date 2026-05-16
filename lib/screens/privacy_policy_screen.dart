// ─── PRIVACY POLICY SCREEN ───────────────────────────────────────────────────
// Fix 11: In-app privacy policy disclosure
// Branding: StoneGuard → KidneyShield.

import 'package:flutter/material.dart';
import '../widgets/gradient_scaffold.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      title: 'Privacy Policy',
      body: const _PolicyBody(),
    );
  }
}

class _PolicyBody extends StatelessWidget {
  const _PolicyBody();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'KidneyShield Privacy Policy',
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Last updated: May 2026',
            style: textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          _Section(
            title: '1. Overview',
            body:
                'KidneyShield is a kidney stone prevention app designed to help '
                'you track dietary oxalate intake, hydration, and wellness '
                'journal entries. Your health is personal — we take data '
                'privacy seriously.',
          ),
          _Section(
            title: '2. What Data We Collect',
            body:
                'KidneyShield collects only the data you choose to enter:\n\n'
                '• Oxalate food log entries (food name, mg of oxalate, timestamp)\n'
                '• Daily hydration intake\n'
                '• Wellness journal entries\n'
                '• App settings (theme preference, notification times)\n\n'
                'We do NOT collect your name, email address, location, or any '
                'other personally identifiable information.',
          ),
          _Section(
            title: '3. Where Your Data Is Stored',
            body:
                'All data is stored exclusively on your device using an AES-256 '
                'encrypted SQLite database. Your data never leaves your device '
                'and is never uploaded to any server. KidneyShield has no '
                'backend, no cloud sync, and no account system.',
          ),
          _Section(
            title: '4. Advertising (Google AdMob)',
            body:
                'KidneyShield shows ads provided by Google AdMob to support '
                'free access to the app. If you accept personalised ads, Google '
                'may use your device\'s advertising ID to show relevant ads.\n\n'
                'IMPORTANT: No health data from KidneyShield (oxalate logs, '
                'hydration records, journal entries) is ever shared with Google '
                'or any advertiser.\n\n'
                'You can decline personalised ads during the consent prompt on '
                'first launch, or change your choice at any time in '
                'Settings → Privacy.',
          ),
          _Section(
            title: '5. Third-Party SDKs',
            body:
                'KidneyShield uses the following third-party libraries:\n\n'
                '• Google AdMob (advertising)\n'
                '• Flutter Secure Storage (AES-256 key management via Android Keystore)\n'
                '• Flutter Local Notifications (reminder alerts, on-device only)\n\n'
                'None of these SDKs receive your health data.',
          ),
          _Section(
            title: '6. Data Retention & Deletion',
            body:
                'Your data is kept until you delete it. You can:\n\n'
                '• Delete individual log entries from the History screen\n'
                '• Delete all data by uninstalling the app\n\n'
                'Because data is stored only on your device, uninstalling '
                'KidneyShield permanently removes all records.',
          ),
          _Section(
            title: '7. Children\'s Privacy',
            body:
                'KidneyShield is not directed at children under 13. We do not '
                'knowingly collect data from children.',
          ),
          _Section(
            title: '8. Changes to This Policy',
            body:
                'We may update this policy as the app evolves. Significant '
                'changes will be noted in the app update release notes on the '
                'Play Store.',
          ),
          _Section(
            title: '9. Contact',
            body:
                'Questions about this policy? Contact us at:\n\n'
                'kidneyshield.app@gmail.com',
          ),

          const SizedBox(height: 32),
          Center(
            child: Text(
              '© 2026 KidneyShield. All rights reserved.',
              style: textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String body;
  const _Section({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(body, style: textTheme.bodyMedium?.copyWith(height: 1.55)),
        ],
      ),
    );
  }
}
