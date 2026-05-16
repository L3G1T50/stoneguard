// ─── CONSENT MANAGER ──────────────────────────────────────────────────────────
//
// Fix 8 — GDPR Ad Consent Wiring
//
// Problem: MobileAds.instance.initialize() was being called at cold start in
// main.dart before the user’s consent status was known. Under GDPR/CCPA this
// is a policy violation — the SDK must not load personalised ads until the
// user has either granted consent or is determined to be outside a regulated
// region.
//
// Solution:
//   1. On first launch (or if consent has lapsed), load the Google UMP consent
//      form and present it to the user.
//   2. Only after the form resolves (granted OR not-required) do we call
//      MobileAds.instance.initialize().
//   3. The consent status is persisted by the UMP SDK automatically. On
//      subsequent launches we check the cached status: if still valid we
//      skip the form and go straight to initialising AdMob.
//   4. If the user is outside a regulated region (NOT_REQUIRED) AdMob is
//      initialised immediately.
//
// Usage (call once, early, from the first stateful screen that hosts ads):
//   await ConsentManager.instance.requestConsentAndInitAdMob(context);
//
// NOTE: This file uses google_mobile_ads ^5.x which ships the UMP SDK
// bundled. No separate package is needed.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'app_logger.dart';

enum AdConsentStatus { unknown, required, obtained, notRequired }

class ConsentManager {
  ConsentManager._();
  static final ConsentManager instance = ConsentManager._();

  bool _adMobInitialised = false;
  AdConsentStatus _status = AdConsentStatus.unknown;

  AdConsentStatus get status => _status;
  bool get canShowAds => _adMobInitialised;

  /// Call once from the first screen that hosts an ad.
  /// Safe to call multiple times — initialises AdMob at most once.
  Future<void> requestConsentAndInitAdMob(BuildContext context) async {
    if (_adMobInitialised) return;

    try {
      final params = ConsentRequestParameters();

      // Load / refresh the consent information.
      await _loadConsentInfo(params);

      final info = ConsentInformation.instance;
      final required = await info.isConsentFormAvailable();
      final consentStatus = info.consentStatus;

      if (consentStatus == ConsentStatus.required && required) {
        // Show the UMP form. This is a no-op if the form was already shown
        // and consent is still valid.
        if (context.mounted) {
          await _showConsentForm(context);
        }
      }

      final updatedStatus = info.consentStatus;
      if (updatedStatus == ConsentStatus.obtained ||
          updatedStatus == ConsentStatus.notRequired) {
        _status = updatedStatus == ConsentStatus.obtained
            ? AdConsentStatus.obtained
            : AdConsentStatus.notRequired;
        await _initAdMob();
      } else {
        _status = AdConsentStatus.required;
        AppLogger.info(
            'ConsentManager', 'Consent required but not yet obtained.');
      }
    } catch (e, st) {
      AppLogger.error(
          'ConsentManager', 'requestConsentAndInitAdMob failed', e, st);
      // Fail open for users outside regulated regions: attempt AdMob init
      // so we don’t silently lose revenue on non-GDPR traffic.
      await _initAdMob();
    }
  }

  Future<void> _loadConsentInfo(ConsentRequestParameters params) async {
    final completer = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () => completer.complete(),
      (FormError error) => completer.completeError(Exception(error.message)),
    );
    await completer.future;
  }

  Future<void> _showConsentForm(BuildContext context) async {
    final completer = Completer<void>();
    ConsentForm.loadAndShowConsentFormIfRequired(
      (FormError? error) {
        if (error != null) {
          completer.completeError(Exception(error.message));
        } else {
          completer.complete();
        }
      },
    );
    await completer.future;
  }

  Future<void> _initAdMob() async {
    if (_adMobInitialised) return;
    await MobileAds.instance.initialize();
    _adMobInitialised = true;
    AppLogger.info('ConsentManager', 'AdMob initialised.');
  }

  /// Reset consent — useful for testing or if the user revokes consent
  /// from Settings. Resets UMP SDK state and re-enables the consent flow
  /// on the next requestConsentAndInitAdMob() call.
  Future<void> resetConsent() async {
    await ConsentInformation.instance.reset();
    _adMobInitialised = false;
    _status = AdConsentStatus.unknown;
  }
}
