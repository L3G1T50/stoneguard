// ─── CONSENT MANAGER ──────────────────────────────────────────────────────────
// Batch 5 — Fix 8: GDPR-aligned ad consent gate
//
// Flow:
//   1. On first launch, SplashScreen calls ConsentManager.showIfNeeded(context).
//   2. A dialog explains ads and asks the user to Accept or Decline.
//   3. The choice is stored in FlutterSecureStorage (not plain SharedPreferences).
//   4. AdMob is initialised ONLY if the user accepted.
//   5. BannerAdWidget checks hasConsented() before loading any ad.
//
// Fix 8 branding patch:
//   • All 'KidneyShield' references replaced with 'StoneGuard'.
//
// To comply with Google’s EU consent requirements you should also integrate
// the full Google User Messaging Platform (UMP) SDK for EEA users. This
// ConsentManager is a lightweight first-party gate that works for all regions
// and can be used alongside UMP.

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_config.dart';
import 'app_logger.dart';

class ConsentManager {
  static const _storage    = FlutterSecureStorage();
  static const _consentKey = 'ads_consent_granted';
  static const _shownKey   = 'ads_consent_shown';

  // ── Read helpers ───────────────────────────────────────────────

  /// Returns true if the user has explicitly accepted ad personalisation.
  static Future<bool> hasConsented() async {
    try {
      return await _storage.read(key: _consentKey) == 'true';
    } catch (e, st) {
      AppLogger.error('ConsentManager', 'hasConsented read error', e, st);
      return false; // Fail closed: no consent = no ads.
    }
  }

  /// Returns true if we have already shown the consent dialog.
  static Future<bool> wasShown() async {
    try {
      return await _storage.read(key: _shownKey) == 'true';
    } catch (e, st) {
      AppLogger.error('ConsentManager', 'wasShown read error', e, st);
      return false;
    }
  }

  // ── Show consent dialog if needed ──────────────────────────────────────

  /// Call once from SplashScreen (or first screen after onboarding).
  /// Shows the consent dialog only on first launch.
  /// Initialises MobileAds ONLY if the user accepts.
  static Future<void> showIfNeeded(BuildContext context) async {
    if (await wasShown()) return; // Already asked — respect previous choice.

    if (!context.mounted) return;

    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // User must make a choice.
      builder: (_) => const _ConsentDialog(),
    );

    await _saveChoice(accepted ?? false);

    if (accepted == true) {
      await _initAdMob();
    }
  }

  // ── Initialise AdMob (only called after consent) ──────────────────────

  static Future<void> _initAdMob() async {
    try {
      await MobileAds.instance.initialize();
      // Apply test-device configuration immediately after init so
      // debug/profile builds register the emulator and never track real
      // impressions. In release this is a no-op (see AdConfig).
      await AdConfig.applyRequestConfiguration();
      AppLogger.debug('ConsentManager', 'AdMob initialised after consent.');
    } catch (e, st) {
      AppLogger.error('ConsentManager', 'AdMob init failed', e, st);
    }
  }

  // ── Save choice ──────────────────────────────────────────────────

  static Future<void> _saveChoice(bool accepted) async {
    try {
      await _storage.write(key: _consentKey, value: accepted ? 'true' : 'false');
      await _storage.write(key: _shownKey,   value: 'true');
    } catch (e, st) {
      AppLogger.error('ConsentManager', '_saveChoice error', e, st);
    }
  }

  /// Allow the user to change their consent choice from Settings.
  static Future<void> revokeConsent() async {
    try {
      await _storage.write(key: _consentKey, value: 'false');
      AppLogger.debug('ConsentManager', 'Consent revoked by user.');
    } catch (e, st) {
      AppLogger.error('ConsentManager', 'revokeConsent error', e, st);
    }
  }
}

// ─── Consent Dialog Widget ─────────────────────────────────────────────────────

class _ConsentDialog extends StatelessWidget {
  const _ConsentDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Support StoneGuard with Ads'),
      content: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'StoneGuard is free to use. To keep it running, we show '
              'ads provided by Google AdMob.',
            ),
            SizedBox(height: 12),
            Text(
              'If you allow personalised ads, Google may use limited '
              'device information (such as your ad ID) to show you '
              'relevant ads. No health data from StoneGuard is ever '
              'shared with advertisers.',
            ),
            SizedBox(height: 12),
            Text(
              'You can change this choice at any time in Settings → '
              'Privacy.',
              style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Decline'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Accept Ads'),
        ),
      ],
    );
  }
}
