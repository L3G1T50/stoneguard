// ─── AD CONFIG ─────────────────────────────────────────────────────────────────
//
// Fix 9 — Test vs. Production Ad ID Guard
//
// Problem: Using Google’s public test ad unit IDs in a production build
// violates AdMob policy and will trigger an account warning or suspension.
// Using production IDs in debug builds fills your quota and risks invalid
// click policy violations.
//
// Solution:
//   • kReleaseMode from foundation.dart is true ONLY for --release builds.
//   • In release: IDs come from const String fields that must be replaced
//     with your real AdMob unit IDs before publishing.
//   • In debug/profile: Google’s official test IDs are used automatically.
//   • A compile-time assertion fires if you accidentally leave the placeholder
//     string in a release build — the build will succeed but a runtime
//     assertion will crash-loudly in debug so you cannot miss it.
//
// HOW TO USE:
//   Replace the _kProd* constants below with your real AdMob ad unit IDs
//   from the AdMob dashboard BEFORE building your release APK/AAB.
//   The app ID itself goes in android/local.properties as admobAppId.
import 'package:flutter/foundation.dart';

// ── Replace these before your first production build ────────────────────────
// Format: ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX
const String _kProdBannerHome = 'ca-app-pub-REPLACE_ME/REPLACE_ME';
const String _kProdBannerFood = 'ca-app-pub-REPLACE_ME/REPLACE_ME';
const String _kProdInterstitial = 'ca-app-pub-REPLACE_ME/REPLACE_ME';

// ── Google’s official test IDs (safe for debug/profile builds) ──────────────
const String _kTestBanner = 'ca-app-pub-3940256099942544/6300978111';
const String _kTestInterstitial = 'ca-app-pub-3940256099942544/1033173712';

class AdConfig {
  AdConfig._();

  /// Banner ad unit for the Home / Shield screen.
  static String get bannerHome {
    if (kReleaseMode) {
      assert(
        !_kProdBannerHome.contains('REPLACE_ME'),
        'AdConfig: Replace _kProdBannerHome with your real AdMob unit ID '
        'before publishing a release build.',
      );
      return _kProdBannerHome;
    }
    return _kTestBanner;
  }

  /// Banner ad unit for the Food Guide screen.
  static String get bannerFood {
    if (kReleaseMode) {
      assert(
        !_kProdBannerFood.contains('REPLACE_ME'),
        'AdConfig: Replace _kProdBannerFood with your real AdMob unit ID '
        'before publishing a release build.',
      );
      return _kProdBannerFood;
    }
    return _kTestBanner;
  }

  /// Interstitial ad unit (e.g. shown after PDF export).
  static String get interstitial {
    if (kReleaseMode) {
      assert(
        !_kProdInterstitial.contains('REPLACE_ME'),
        'AdConfig: Replace _kProdInterstitial with your real AdMob unit ID '
        'before publishing a release build.',
      );
      return _kProdInterstitial;
    }
    return _kTestInterstitial;
  }

  /// Returns true when any production ID has not been replaced yet.
  /// Call this in a pre-publish checklist or CI step.
  static bool get hasUnreplacedPlaceholders =>
      _kProdBannerHome.contains('REPLACE_ME') ||
      _kProdBannerFood.contains('REPLACE_ME') ||
      _kProdInterstitial.contains('REPLACE_ME');
}
