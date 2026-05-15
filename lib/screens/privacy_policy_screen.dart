// ─── PRIVACY POLICY SCREEN ────────────────────────────────────────────────────
// Batch 5 — Fix 11: In-app privacy policy disclosure
//
// This screen is linked from SettingsScreen > Privacy Policy.
// It must match the actual data practices described in your Google Play
// store listing and external privacy policy URL.
//
// UPDATE THE PLACEHOLDERS before submitting to Play Store:
//   [YOUR EMAIL]  → your support/privacy contact email
//   [YOUR NAME / COMPANY]  → your legal name or business name

import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: const Color(0xFF01696F),
        foregroundColor: Colors.white,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: _PolicyBody(),
      ),
    );
  }
}

class _PolicyBody extends StatelessWidget {
  const _PolicyBody();

  @override
  Widget build(BuildContext context) {
    const h1 = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
    const h2 = TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
    const body = TextStyle(fontSize: 14, height: 1.6);
    const spacer = SizedBox(height: 16);
    const smallSpacer = SizedBox(height: 8);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('StoneGuard — Privacy Policy', style: h1),
        const Text(
            'Last updated: May 2026',
            style: TextStyle(fontSize: 12, color: Colors.grey)),
        spacer,

        // ── Overview ──
        const Text('Overview', style: h2),
        smallSpacer,
        const Text(
          'StoneGuard is a personal health-tracking app designed to help '
          'calcium oxalate kidney stone patients track hydration, dietary '
          'oxalate intake, pain levels, and stone history. '
          'Your health is private. We take that seriously.',
          style: body,
        ),
        spacer,

        // ── What we store ──
        const Text('What data is stored', style: h2),
        smallSpacer,
        const Text(
          'StoneGuard stores the following data ONLY on your device:\n'
          '• Daily water intake (fluid ounces)\n'
          '• Daily oxalate intake (mg) and food log\n'
          '• Daily hydration and oxalate goals\n'
          '• Journal entries (pain level, symptoms, side, notes, date)\n'
          '• Stone event history (type, size, date, treatment)\n'
          '• Up to 730 days of history for trend charts\n'
          '• Display name and optional avatar (used only within the app)\n'
          '• App preferences (dark mode, notification times)',
          style: body,
        ),
        spacer,

        // ── How we protect it ──
        const Text('How your data is protected', style: h2),
        smallSpacer,
        const Text(
          'All health data is encrypted at rest on your device:\n'
          '• Journal entries: AES-256-CBC encrypted SQLite database. '
          'Encryption key stored in Android Keystore / iOS Keychain.\n'
          '• History and current-day totals: AES-256-CBC encrypted with a '
          'random key stored in Android Keystore / iOS Keychain.\n'
          '• No data is transmitted to any StoneGuard server.\n'
          '• System backups are disabled so Android cannot copy your data '
          'to the cloud without your knowledge.',
          style: body,
        ),
        spacer,

        // ── What leaves your device ──
        const Text('What leaves your device', style: h2),
        smallSpacer,
        const Text(
          'StoneGuard itself never transmits health data off your device. '
          'However, if you consent to ads, Google AdMob may collect:\n'
          '• Your advertising ID (a resettable device identifier)\n'
          '• General device information (OS version, screen size)\n'
          '• Ad interaction events (clicks, impressions)\n\n'
          'No health data — no water logs, no pain scores, no journal text '
          '— is ever shared with Google or any advertiser.\n\n'
          'You can decline ads at first launch or revoke consent at any time '
          'in Settings → Privacy.',
          style: body,
        ),
        spacer,

        // ── Exports ──
        const Text('Report exports', style: h2),
        smallSpacer,
        const Text(
          'When you export a Doctor Report or health summary PDF, the file '
          'is saved temporarily to app-private storage on your device. '
          'When you tap Share, you choose where it goes (email, print, etc.). '
          'The temporary file is deleted immediately after sharing.',
          style: body,
        ),
        spacer,

        // ── Retention ──
        const Text('Data retention', style: h2),
        smallSpacer,
        const Text(
          'History data is automatically trimmed to the most recent 730 days '
          '(approximately 2 years). Older entries are deleted automatically. '
          'All data is deleted when you uninstall StoneGuard.',
          style: body,
        ),
        spacer,

        // ── Medical disclaimer ──
        const Text('Medical disclaimer', style: h2),
        smallSpacer,
        const Text(
          'StoneGuard is a personal tracking aid, NOT a medical device. '
          'It does not provide medical advice, diagnosis, or treatment. '
          'Always consult a qualified healthcare provider for medical decisions. '
          'In an emergency, call 911 or your local emergency number immediately.',
          style: TextStyle(fontSize: 14, height: 1.6, color: Colors.red),
        ),
        spacer,

        // ── Your rights ──
        const Text('Your rights', style: h2),
        smallSpacer,
        const Text(
          'Because all data is stored locally on your device, you are in '
          'full control:\n'
          '• Delete all data: uninstall the app.\n'
          '• Export your data: use the Doctor Report feature.\n'
          '• Revoke ad consent: Settings → Privacy → Ad Preferences.',
          style: body,
        ),
        spacer,

        // ── Contact ──
        const Text('Contact', style: h2),
        smallSpacer,
        const Text(
          'Questions about this policy? Contact us at:\n'
          '[YOUR EMAIL]\n\n'
          'Developer: [YOUR NAME / COMPANY]',
          style: body,
        ),
        spacer,
      ],
    );
  }
}
