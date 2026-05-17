// lib/services/billing_error_handler.dart
//
// BillingErrorHandler — centralised billing error surface layer.
//
// Converts RevenueCatServiceException into user-facing UI responses.
// All billing try-catch blocks across the app should route through here
// so messaging is consistent and maintained in one place.
//
// Usage:
//   try {
//     await RevenueCatService().purchasePackage(pkg);
//   } on RevenueCatServiceException catch (e) {
//     BillingErrorHandler.handle(context, e);
//   }

import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'revenue_cat_service.dart';

class BillingErrorHandler {
  BillingErrorHandler._(); // static-only class

  // ---------------------------------------------------------------------------
  // Primary entry point
  // ---------------------------------------------------------------------------

  /// Surfaces a [RevenueCatServiceException] to the user.
  ///
  /// • Cancellations are silently ignored (no UI noise).
  /// • Network errors show a retry-able snackbar.
  /// • Billing errors show a dismissible dialog with a clear action.
  /// • Unknown errors show a short snackbar.
  static void handle(
    BuildContext context,
    RevenueCatServiceException exception, {
    VoidCallback? onRetry,
  }) {
    // User tapped “Cancel” in the OS billing sheet — do nothing.
    if (exception.isCancellation) return;

    final code = exception.code;

    // Network / connectivity errors — offer a retry action.
    if (code == PurchasesErrorCode.networkError) {
      _showSnackBar(
        context,
        message: exception.message,
        action: onRetry != null
            ? SnackBarAction(label: 'Retry', onPressed: onRetry)
            : null,
        isError: true,
      );
      return;
    }

    // Pending payment — informational, not an error.
    if (code == PurchasesErrorCode.paymentPendingError) {
      _showSnackBar(
        context,
        message: exception.message,
        isError: false,
        duration: const Duration(seconds: 6),
      );
      return;
    }

    // Already purchased — prompt restore.
    if (code == PurchasesErrorCode.productAlreadyPurchasedError ||
        code == PurchasesErrorCode.receiptAlreadyInUseError) {
      _showDialog(
        context,
        title: 'Already Purchased',
        body: exception.message,
        primaryLabel: 'Restore Purchases',
        onPrimary: () {
          Navigator.pop(context);
          // Caller should handle the restore flow; fire a generic restore hint.
          _showSnackBar(
            context,
            message: 'Use the “Restore Purchase” button on the paywall.',
            isError: false,
          );
        },
      );
      return;
    }

    // Purchase not allowed (e.g. parental controls, sandbox restriction).
    if (code == PurchasesErrorCode.purchaseNotAllowedError) {
      _showDialog(
        context,
        title: 'Purchase Not Allowed',
        body: exception.message,
        primaryLabel: 'OK',
        onPrimary: () => Navigator.pop(context),
      );
      return;
    }

    // Store problem (Play Store outage, invalid product config).
    if (code == PurchasesErrorCode.storeProblemError) {
      _showDialog(
        context,
        title: 'Store Problem',
        body: exception.message,
        primaryLabel: 'OK',
        onPrimary: () => Navigator.pop(context),
        secondaryLabel: onRetry != null ? 'Try Again' : null,
        onSecondary: onRetry != null
            ? () {
                Navigator.pop(context);
                onRetry();
              }
            : null,
      );
      return;
    }

    // Fallback — generic snackbar for anything else.
    _showSnackBar(
      context,
      message: exception.message,
      isError: true,
    );
  }

  // ---------------------------------------------------------------------------
  // Handle raw exceptions that escaped RevenueCat typing
  // ---------------------------------------------------------------------------

  /// Convenience wrapper for catch blocks that catch generic [Exception].
  /// Checks if it is a [RevenueCatServiceException] first; otherwise shows
  /// a generic error message.
  static void handleGeneric(
    BuildContext context,
    Object error, {
    VoidCallback? onRetry,
    String fallbackMessage =
        'Something went wrong. Please try again.',
  }) {
    if (error is RevenueCatServiceException) {
      handle(context, error, onRetry: onRetry);
    } else {
      _showSnackBar(context, message: fallbackMessage, isError: true);
    }
  }

  // ---------------------------------------------------------------------------
  // Private UI helpers
  // ---------------------------------------------------------------------------

  static void _showSnackBar(
    BuildContext context, {
    required String message,
    required bool isError,
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 4),
  }) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor:
              isError ? Colors.red.shade700 : const Color(0xFF0D6B78),
          duration: duration,
          action: action,
        ),
      );
  }

  static void _showDialog(
    BuildContext context, {
    required String title,
    required String body,
    required String primaryLabel,
    required VoidCallback onPrimary,
    String? secondaryLabel,
    VoidCallback? onSecondary,
  }) {
    if (!context.mounted) return;
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          if (secondaryLabel != null && onSecondary != null)
            TextButton(
              onPressed: onSecondary,
              child: Text(secondaryLabel),
            ),
          FilledButton(
            onPressed: onPrimary,
            child: Text(primaryLabel),
          ),
        ],
      ),
    );
  }
}
