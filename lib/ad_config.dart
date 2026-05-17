// ─── AD CONFIG ─────────────────────────────────────────────────────────────────
//
// Fix 9 — Test vs. Production Ad ID Guard
//
// kReleaseMode (package:flutter/foundation.dart) is true ONLY for
// --release builds. Debug/profile builds use Google's official test IDs
// automatically, so you never burn quota during development.
//
// Production IDs are now wired in.
// App ID goes in android/local.properties as admobAppId.
import 'package:flutter/foundation.dart';

// ── Production Ad Unit IDs ───────────────────────────────────────────────────
// App ID  : ca-app-pub-2298666914293591~4166424993  (set in local.properties)
// Ad unit : ca-app-pub-2298666914293591/4564423970
const String _kProdBannerHome    = 'ca-app-pub-2298666914293591/4564423970';
const String _kProdBannerFood    = 'ca-app-pub-2298666914293591/4564423970';
const String _kProdInterstitial  = 'ca-app-pub-2298666914293591/4564423970';

// ── Google's official test IDs (safe for debug/profile builds) ───────────────
const String _kTestBanner       = 'ca-app-pub-3940256099942544/6300978111';
const String _kTestInterstitial = 'ca-app-pub-3940256099942544/1033173712';

class AdConfig {
  AdConfig._();

  /// Banner ad unit for the Home / Shield screen.
  static String get bannerHome =>
      kReleaseMode ? _kProdBannerHome : _kTestBanner;

  /// Banner ad unit for the Food Guide screen.
  static String get bannerFood =>
      kReleaseMode ? _kProdBannerFood : _kTestBanner;

  /// Interstitial ad unit (e.g. shown after PDF export).
  static String get interstitial =>
      kReleaseMode ? _kProdInterstitial : _kTestInterstitial;

  /// All production IDs are now set — always returns false.
  static bool get hasUnreplacedPlaceholders => false;
}
