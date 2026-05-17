// lib/widgets/premium_gate.dart
//
// PremiumGate — gatekeeper widget that checks isSubscribed and either
// renders the premium child or a locked overlay prompting the paywall.
//
// Usage:
//   PremiumGate(
//     featureName: 'Doctor Report',
//     child: DoctorViewScreen(),
//   )
//
// The widget is transparent to subscribers — zero overhead when unlocked.

import 'package:flutter/material.dart';
import '../services/subscription_notifier.dart';
import '../screens/paywall_screen.dart';

class PremiumGate extends StatelessWidget {
  /// The premium feature widget to show when the user is subscribed.
  final Widget child;

  /// Short display name shown in the lock overlay, e.g. 'Doctor Report'.
  final String featureName;

  /// Optional: override the lock overlay subtitle.
  final String? lockedSubtitle;

  const PremiumGate({
    super.key,
    required this.child,
    required this.featureName,
    this.lockedSubtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SubscriptionNotifier.of(context),
      builder: (context, _) {
        final notifier = SubscriptionNotifier.of(context);

        // Show a neutral loading spinner while the first status check runs.
        if (notifier.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Subscriber — render the real feature immediately.
        if (notifier.isSubscribed) return child;

        // Free user — show the lock overlay.
        return _LockedScreen(
          featureName: featureName,
          subtitle: lockedSubtitle ??
              'Upgrade to StoneGuard Plus to access $featureName.',
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// _LockedScreen — shown to free users in place of the gated feature
// ---------------------------------------------------------------------------
class _LockedScreen extends StatelessWidget {
  final String featureName;
  final String subtitle;

  static const Color _teal     = Color(0xFF1A8A9A);
  static const Color _tealDark = Color(0xFF0D6B78);
  static const Color _textPri  = Color(0xFF2C2C2C);
  static const Color _textMuted= Color(0xFF888888);

  const _LockedScreen({
    required this.featureName,
    required this.subtitle,
  });

  Future<void> _openPaywall(BuildContext context) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const PaywallScreen()),
    );
    // SubscriptionNotifier is refreshed inside PaywallScreen on success,
    // so this widget will rebuild automatically once the user subscribes.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: Text(featureName),
        backgroundColor: Colors.white,
        foregroundColor: _textPri,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(36),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lock icon
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A8A9A), Color(0xFF0D6B78)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: _teal.withValues(alpha: 0.30),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  color: Colors.white,
                  size: 42,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                '$featureName is a Plus Feature',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _textPri,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: _textMuted,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => _openPaywall(context),
                  icon: const Icon(Icons.workspace_premium_rounded),
                  label: const Text(
                    'Upgrade to Plus',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Maybe Later',
                  style: TextStyle(color: _textMuted, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
