// lib/services/revenue_cat_service.dart
//
// RevenueCat core service layer for KidneyShield.
// Handles SDK initialisation, entitlement checks, and purchase flows.
// Uses the Singleton pattern so a single instance is shared app-wide.
//
// SETUP INSTRUCTIONS (before building):
//   1. Create a RevenueCat project at https://app.revenuecat.com
//   2. Replace the placeholder API keys below with your real keys.
//   3. Create an Entitlement named 'premium' in the RevenueCat dashboard
//      and attach your subscription product(s) to it.
//   4. Run `flutter pub get` after Stage 1 is pushed.

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

// ---------------------------------------------------------------------------
// API key placeholders – replace before first build
// ---------------------------------------------------------------------------
const String _kAndroidApiKey = 'YOUR_REVENUECAT_ANDROID_API_KEY';
const String _kIosApiKey     = 'YOUR_REVENUECAT_IOS_API_KEY';

// The entitlement identifier configured in the RevenueCat dashboard.
const String kPremiumEntitlement = 'premium';

// ---------------------------------------------------------------------------
// SubscriptionStatus – a clean data class surfaced to the UI layer
// ---------------------------------------------------------------------------
class SubscriptionStatus {
  final bool isSubscribed;
  final String? activeProductIdentifier;
  final DateTime? expirationDate;

  const SubscriptionStatus({
    required this.isSubscribed,
    this.activeProductIdentifier,
    this.expirationDate,
  });

  /// Convenient unsubscribed sentinel value.
  static const SubscriptionStatus free = SubscriptionStatus(isSubscribed: false);

  @override
  String toString() =>
      'SubscriptionStatus(isSubscribed: $isSubscribed, '
      'product: $activeProductIdentifier, expires: $expirationDate)';
}

// ---------------------------------------------------------------------------
// RevenueCatService – Singleton
// ---------------------------------------------------------------------------
class RevenueCatService {
  // ---- Singleton boilerplate ----
  RevenueCatService._internal();
  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;

  // Whether the SDK has been initialised at least once this session.
  bool _initialised = false;

  // ---------------------------------------------------------------------------
  // Initialisation
  // ---------------------------------------------------------------------------

  /// Call once from `main()` or the root widget's `initState`.
  ///
  /// [userId] – pass your app's authenticated user ID (or null for anonymous).
  Future<void> initialise({String? userId}) async {
    if (_initialised) return; // Guard: do not re-initialise.

    // Choose the correct API key for the platform at runtime.
    final String apiKey = Platform.isIOS ? _kIosApiKey : _kAndroidApiKey;

    final PurchasesConfiguration config = userId != null
        ? PurchasesConfiguration(apiKey)..appUserID = userId
        : PurchasesConfiguration(apiKey);

    // Enable verbose logging in debug builds only.
    if (kDebugMode) {
      await Purchases.setLogLevel(LogLevel.verbose);
    }

    await Purchases.configure(config);
    _initialised = true;

    if (kDebugMode) {
      debugPrint('[RevenueCatService] SDK initialised (userId: $userId)');
    }
  }

  // ---------------------------------------------------------------------------
  // Subscriber status
  // ---------------------------------------------------------------------------

  /// Returns the current [SubscriptionStatus] by fetching the latest
  /// CustomerInfo from RevenueCat.
  ///
  /// Throws [RevenueCatServiceException] on network / billing errors.
  Future<SubscriptionStatus> getSubscriptionStatus() async {
    _assertInitialised();
    try {
      final CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      return _mapCustomerInfo(customerInfo);
    } on PurchasesErrorCode catch (e) {
      throw RevenueCatServiceException(
        'Failed to fetch subscription status: ${e.name}',
        code: e,
      );
    } catch (e) {
      throw RevenueCatServiceException('Unexpected error: $e');
    }
  }

  /// Convenience bool helper used by the state management layer.
  Future<bool> isSubscribed() async {
    final status = await getSubscriptionStatus();
    return status.isSubscribed;
  }

  // ---------------------------------------------------------------------------
  // Available products / offerings
  // ---------------------------------------------------------------------------

  /// Fetches all configured RevenueCat Offerings for display on the paywall.
  ///
  /// Returns null if no offerings are configured on the dashboard.
  Future<Offerings?> getOfferings() async {
    _assertInitialised();
    try {
      return await Purchases.getOfferings();
    } on PurchasesErrorCode catch (e) {
      throw RevenueCatServiceException(
        'Failed to fetch offerings: ${e.name}',
        code: e,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Purchase flow
  // ---------------------------------------------------------------------------

  /// Initiates a purchase for the given [package].
  ///
  /// Returns the resulting [SubscriptionStatus] on success.
  /// Throws [RevenueCatServiceException] with a user-friendly message on
  /// any billing error (declined, cancelled, network loss, etc.).
  Future<SubscriptionStatus> purchasePackage(Package package) async {
    _assertInitialised();
    try {
      final CustomerInfo customerInfo =
          await Purchases.purchasePackage(package);
      return _mapCustomerInfo(customerInfo);
    } on PurchasesErrorCode catch (e) {
      // User-cancelled is NOT a real error – handle silently.
      if (e == PurchasesErrorCode.purchaseCancelledError) {
        throw RevenueCatServiceException(
          'Purchase was cancelled.',
          code: e,
          isCancellation: true,
        );
      }
      throw RevenueCatServiceException(
        _friendlyMessage(e),
        code: e,
      );
    } catch (e) {
      throw RevenueCatServiceException('Unexpected purchase error: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Restore purchases
  // ---------------------------------------------------------------------------

  /// Restores previous purchases and returns the updated [SubscriptionStatus].
  Future<SubscriptionStatus> restorePurchases() async {
    _assertInitialised();
    try {
      final CustomerInfo customerInfo = await Purchases.restorePurchases();
      return _mapCustomerInfo(customerInfo);
    } on PurchasesErrorCode catch (e) {
      throw RevenueCatServiceException(
        'Could not restore purchases: ${e.name}',
        code: e,
      );
    } catch (e) {
      throw RevenueCatServiceException('Unexpected restore error: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // User identity (login / logout)
  // ---------------------------------------------------------------------------

  /// Log in with a known user ID (call after your app's own auth completes).
  Future<void> logIn(String userId) async {
    _assertInitialised();
    await Purchases.logIn(userId);
  }

  /// Log out and revert to an anonymous RevenueCat identity.
  Future<void> logOut() async {
    _assertInitialised();
    await Purchases.logOut();
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Maps RevenueCat's [CustomerInfo] to our clean [SubscriptionStatus] model.
  SubscriptionStatus _mapCustomerInfo(CustomerInfo info) {
    final EntitlementInfo? entitlement =
        info.entitlements.active[kPremiumEntitlement];

    if (entitlement == null || !entitlement.isActive) {
      return SubscriptionStatus.free;
    }

    return SubscriptionStatus(
      isSubscribed: true,
      activeProductIdentifier: entitlement.productIdentifier,
      expirationDate: entitlement.expirationDate != null
          ? DateTime.tryParse(entitlement.expirationDate!)
          : null,
    );
  }

  /// Converts a [PurchasesErrorCode] into a short, user-readable string.
  String _friendlyMessage(PurchasesErrorCode code) {
    switch (code) {
      case PurchasesErrorCode.networkError:
        return 'No internet connection. Please check your network and try again.';
      case PurchasesErrorCode.paymentPendingError:
        return 'Your payment is pending. We will notify you once it is confirmed.';
      case PurchasesErrorCode.productAlreadyPurchasedError:
        return 'You already own this subscription. Try Restore Purchases.';
      case PurchasesErrorCode.purchaseNotAllowedError:
        return 'Purchases are not allowed on this device.';
      case PurchasesErrorCode.receiptAlreadyInUseError:
        return 'This receipt is linked to another account. Please restore from that account.';
      case PurchasesErrorCode.storeProblemError:
        return 'There was a problem with the App Store / Play Store. Please try again later.';
      default:
        return 'Something went wrong with the purchase (${code.name}). Please try again.';
    }
  }

  void _assertInitialised() {
    if (!_initialised) {
      throw StateError(
        '[RevenueCatService] SDK not initialised. '
        'Call RevenueCatService().initialise() before using this service.',
      );
    }
  }
}

// ---------------------------------------------------------------------------
// RevenueCatServiceException – typed error for catch blocks
// ---------------------------------------------------------------------------
class RevenueCatServiceException implements Exception {
  final String message;
  final PurchasesErrorCode? code;

  /// True when the user explicitly cancelled the purchase flow.
  final bool isCancellation;

  const RevenueCatServiceException(
    this.message, {
    this.code,
    this.isCancellation = false,
  });

  @override
  String toString() => 'RevenueCatServiceException: $message';
}
