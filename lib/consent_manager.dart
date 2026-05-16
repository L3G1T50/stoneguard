// ─── CONSENT MANAGER ──────────────────────────────────────────────────────────
// Fix 8: GDPR-aligned ad consent gate
//
// Flow:
//   1. SplashScreen calls ConsentManager.showIfNeeded(context) on first launch.
//   2. Dialog explains ads, user accepts or declines.
//   3. Choice stored in FlutterSecureStorage.
//   4. AdMob initialised ONLY if user accepted.
//   5. BannerAdWidget checks hasConsented() before loading any ad.

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_config.dart';
import 'app_logger.dart';

class ConsentManager {
  static const _storage    = FlutterSecureStorage();
  static const _consentKey = 'ads_consent_granted';
  static const _shownKey   = 'ads_consent_shown';

  static Future<bool> hasConsented() async {
    try {
      return await _storage.read(key: _consentKey) == 'true';
    } catch (e, st) {
      AppLogger.error('ConsentManager', 'hasConsented read error', e, st);
      return false;
    }
  }

  static Future<bool> wasShown() async {
    try {
      return await _storage.read(key: _shownKey) == 'true';
    } catch (e, st) {
      AppLogger.error('ConsentManager', 'wasShown read error', e, st);
      return false;
    }
  }

  static Future<void> showIfNeeded(BuildContext context) async {
    if (await wasShown()) return;
    if (!context.mounted) return;

    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _ConsentDialog(),
    );

    await _saveChoice(accepted ?? false);
    if (accepted == true) await _initAdMob();
  }

  static Future<void> _initAdMob() async {
    try {
      await MobileAds.instance.initialize();
      await AdConfig.applyRequestConfiguration();
      AppLogger.debug('ConsentManager', 'AdMob initialised after consent.');
    } catch (e, st) {
      AppLogger.error('ConsentManager', 'AdMob init failed', e, st);
    }
  }

  static Future<void> _saveChoice(bool accepted) async {
    try {
      await _storage.write(key: _consentKey, value: accepted ? 'true' : 'false');
      await _storage.write(key: _shownKey,   value: 'true');
    } catch (e, st) {
      AppLogger.error('ConsentManager', '_saveChoice error', e, st);
    }
  }

  static Future<void> revokeConsent() async {
    try {
      await _storage.write(key: _consentKey, value: 'false');
      AppLogger.debug('ConsentManager', 'Consent revoked by user.');
    } catch (e, st) {
      AppLogger.error('ConsentManager', 'revokeConsent error', e, st);
    }
  }
}

class _ConsentDialog extends StatelessWidget {
  const _ConsentDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Support KidneyShield with Ads'),
      content: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'KidneyShield is free to use. To keep it running, we show '
              'ads provided by Google AdMob.',
            ),
            SizedBox(height: 12),
            Text(
              'If you allow personalised ads, Google may use limited '
              'device information (such as your ad ID) to show you '
              'relevant ads. No health data from KidneyShield is ever '
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
