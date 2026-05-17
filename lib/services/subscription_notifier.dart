// lib/services/subscription_notifier.dart
//
// Reactive subscription state for KidneyShield.
//
// Architecture choice: plain ChangeNotifier — consistent with the existing
// codebase which uses StatefulWidget + direct service calls (no Riverpod/Bloc).
//
// Usage (anywhere in the widget tree beneath MyApp):
//
//   // Read once:
//   final notifier = SubscriptionNotifier.of(context);
//   if (notifier.isSubscribed) { ... }
//
//   // Rebuild on change:
//   ListenableBuilder(
//     listenable: SubscriptionNotifier.of(context),
//     builder: (context, _) {
//       return notifier.isSubscribed ? PremiumWidget() : FreeWidget();
//     },
//   );

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'revenue_cat_service.dart';

// ---------------------------------------------------------------------------
// SubscriptionNotifier
// ---------------------------------------------------------------------------
class SubscriptionNotifier extends ChangeNotifier {
  // ---- Internal state ----
  bool _isSubscribed = false;
  bool _isLoading = true;   // true while the first status check is in-flight
  String? _errorMessage;   // non-null when the last refresh failed

  // ---- Public getters (read-only surface) ----
  bool get isSubscribed  => _isSubscribed;
  bool get isLoading     => _isLoading;
  String? get errorMessage => _errorMessage;

  final RevenueCatService _service = RevenueCatService();

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  /// Call once after [RevenueCatService.initialise()] has completed.
  /// Performs the first status fetch and begins listening for SDK updates.
  Future<void> init() async {
    await _refresh();
  }

  // ---------------------------------------------------------------------------
  // Public API used by UI widgets
  // ---------------------------------------------------------------------------

  /// Re-fetches subscriber status from RevenueCat and notifies listeners.
  /// Call after a successful purchase or restore to update the UI immediately.
  Future<void> refresh() async {
    await _refresh();
  }

  /// Convenience: is the user currently on the free tier?
  bool get isFree => !_isSubscribed;

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  Future<void> _refresh() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final status = await _service.getSubscriptionStatus();
      _isSubscribed = status.isSubscribed;
      _errorMessage = null;
    } on RevenueCatServiceException catch (e) {
      // Keep the previous subscription state on error so the user
      // does not get locked out due to a transient network hiccup.
      _errorMessage = e.message;
      if (kDebugMode) {
        debugPrint('[SubscriptionNotifier] Refresh error: ${e.message}');
      }
    } catch (e) {
      _errorMessage = 'Could not verify subscription status.';
      if (kDebugMode) {
        debugPrint('[SubscriptionNotifier] Unexpected error: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

// ---------------------------------------------------------------------------
// SubscriptionProvider — InheritedNotifier wrapper
// ---------------------------------------------------------------------------
// Wraps SubscriptionNotifier in Flutter's built-in InheritedNotifier so any
// widget can call SubscriptionNotifier.of(context) without adding dependencies.

class SubscriptionProvider extends InheritedNotifier<SubscriptionNotifier> {
  const SubscriptionProvider({
    super.key,
    required SubscriptionNotifier notifier,
    required super.child,
  }) : super(notifier: notifier);

  /// Access the nearest [SubscriptionNotifier] in the widget tree.
  /// Widgets that call this will rebuild whenever [isSubscribed] changes.
  static SubscriptionNotifier of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<SubscriptionProvider>();
    assert(
      provider != null,
      'SubscriptionNotifier.of() called outside of a SubscriptionProvider. '
      'Make sure SubscriptionProvider wraps your MaterialApp.',
    );
    return provider!.notifier!;
  }
}
