// ─── BANNER AD WIDGET ────────────────────────────────────────────────────────
// Fix 9 (follow-up): Uses AdConfig.bannerAdUnitId instead of a hardcoded
// production string so debug builds serve test ads and release builds serve
// real ads. Also gates ad loading behind ConsentManager so ads are never
// loaded before the user has explicitly accepted.

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../ad_config.dart';
import '../consent_manager.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadIfConsented();
  }

  /// Only loads an ad when the user has explicitly accepted ads.
  /// If they declined or haven't been asked yet, renders nothing.
  Future<void> _loadIfConsented() async {
    final consented = await ConsentManager.hasConsented();
    if (!consented) return; // No consent → no ad, no tracking.
    if (!mounted) return;

    BannerAd(
      // AdConfig.bannerAdUnitId returns:
      //   debug   → Google's official test banner unit (safe to click)
      //   release → your real production unit ID
      adUnitId: AdConfig.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    ).load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoaded && _bannerAd != null) {
      return SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }
    // Returns nothing if consent was declined or ad hasn't loaded yet.
    return const SizedBox.shrink();
  }
}
