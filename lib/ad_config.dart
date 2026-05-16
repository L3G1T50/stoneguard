// ─── AD CONFIG ─────────────────────────────────────────────────────────────────
// Batch 5 — Fix 9: Test ads in debug / production ads in release
//
// Problem being fixed:
//   The previous code hardcoded the production ad unit ID directly in
//   BannerAdWidget. This means:
//     1. Test builds served real ads, which violates AdMob policy.
//     2. Clicking your own ads during testing risks account suspension.
//
// Solution:
//   AdConfig.bannerAdUnitId returns:
//     - Debug/Profile: Google's official test banner ID (safe to click freely)
//     - Release:       Your real production ID (ca-app-pub-...)
//
//   AdConfig.applyRequestConfiguration() also sets testDeviceIds in
//   debug + profile so even if a real ID slipped through, AdMob would
//   still serve test ads.
//
// Batch F:
//   • Extended non-production gate from kDebugMode to
//     (kDebugMode || kProfileMode) so Flutter profile builds also get
//     test ad IDs and test-device registration. Release = !debug && !profile.

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

abstract final class AdConfig {
  // ── Production IDs (release builds only) ─────────────────────────────────
  static const _prodBannerAdUnitId =
      'ca-app-pub-2298666914293591/4564423970';

  // ── Google official test IDs (debug + profile builds) ─────────────────
  // Source: https://developers.google.com/admob/android/test-ads
  static const _testBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111'; // Google's official test banner

  // ── Non-production flag ────────────────────────────────────────────────
  // true for debug and profile; false only for release.
  static bool get _isNonProduction => kDebugMode || kProfileMode;

  // ── Public accessor ────────────────────────────────────────────────────

  /// Returns the correct banner ad unit ID for the current build mode.
  /// Always use this instead of a hardcoded string.
  static String get bannerAdUnitId =>
      _isNonProduction ? _testBannerAdUnitId : _prodBannerAdUnitId;

  // ── Request configuration ──────────────────────────────────────────────

  /// Called inside ConsentManager._initAdMob() immediately after
  /// MobileAds.instance.initialize().
  /// In debug/profile: registers the emulator/device as a test device so AdMob
  ///           serves test ads even if a real ad unit ID is accidentally used.
  /// In release: no-op (test device list stays empty).
  static Future<void> applyRequestConfiguration() async {
    if (_isNonProduction) {
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          // 'TEST_EMULATOR' covers Android emulators automatically.
          // Add your physical device's hashed ID here if needed
          // (printed in logcat on first ad load as:
          //  "Use RequestConfiguration.Builder.setTestDeviceIds(...)").
          testDeviceIds: ['TEST_EMULATOR'],
          tagForChildDirectedTreatment:
              TagForChildDirectedTreatment.unspecified,
          tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.unspecified,
        ),
      );
    }
  }
}
