// consent_manager.dart  (Fix 8 — GDPR Ad Consent Wiring)
//
// google_mobile_ads ^5.x: ConsentInformation.instance.consentStatus
// returns a `Future<ConsentStatus>`, NOT a synchronous getter.
// All status reads are now awaited via _getConsentStatus().
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

  Future<void> requestConsentAndInitAdMob(BuildContext context) async {
    if (_adMobInitialised) return;
    try {
      final params = ConsentRequestParameters();
      await _loadConsentInfo(params);

      final formAvailable =
          await ConsentInformation.instance.isConsentFormAvailable();
      final consentStatus = await _getConsentStatus();

      if (consentStatus == ConsentStatus.required && formAvailable) {
        if (context.mounted) await _showConsentForm();
      }

      final updated = await _getConsentStatus();
      if (updated == ConsentStatus.obtained ||
          updated == ConsentStatus.notRequired) {
        _status = updated == ConsentStatus.obtained
            ? AdConsentStatus.obtained
            : AdConsentStatus.notRequired;
        await _initAdMob();
      } else {
        _status = AdConsentStatus.required;
        AppLogger.debug(
            'ConsentManager', 'Consent required but not yet obtained.');
      }
    } catch (e, st) {
      AppLogger.error(
          'ConsentManager', 'requestConsentAndInitAdMob failed', e, st);
      // Fail open: initialise AdMob for non-GDPR traffic.
      await _initAdMob();
    }
  }

  Future<void> _loadConsentInfo(ConsentRequestParameters params) {
    final c = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () => c.complete(),
      (FormError e) => c.completeError(Exception(e.message)),
    );
    return c.future;
  }

  Future<void> _showConsentForm() {
    final c = Completer<void>();
    ConsentForm.loadAndShowConsentFormIfRequired(
      (FormError? e) {
        if (e != null) {
          c.completeError(Exception(e.message));
        } else {
          c.complete();
        }
      },
    );
    return c.future;
  }

  Future<void> _initAdMob() async {
    if (_adMobInitialised) return;
    await MobileAds.instance.initialize();
    _adMobInitialised = true;
    AppLogger.debug('ConsentManager', 'AdMob initialised.');
  }

  /// In google_mobile_ads ^5.x `consentStatus` is a `Future<ConsentStatus>`.
  Future<ConsentStatus> _getConsentStatus() async {
    try {
      // The property is async in v5 — await it.
      return await ConsentInformation.instance.getConsentStatus();
    } catch (_) {
      return ConsentStatus.unknown;
    }
  }

  Future<void> resetConsent() async {
    await ConsentInformation.instance.reset();
    _adMobInitialised = false;
    _status = AdConsentStatus.unknown;
  }
}
