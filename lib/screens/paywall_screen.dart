import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool _isPurchasing = false;

  static const Color _teal       = Color(0xFF1A8A9A);
  static const Color _tealDark   = Color(0xFF0D6B78);
  static const Color _bg         = Color(0xFFF8F8F8);
  static const Color _surface    = Color(0xFFFFFFFF);
  static const Color _textPri    = Color(0xFF2C2C2C);
  static const Color _textMuted  = Color(0xFF888888);

  Future<void> _purchasePremium() async {
    setState(() => _isPurchasing = true);

    // TODO: Replace with real in-app purchase logic (e.g. in_app_purchase package)
    await Future.delayed(const Duration(seconds: 1));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_premium', true);

    if (!mounted) return;
    setState(() => _isPurchasing = false);
    Navigator.pop(context, true); // return true so callers can refresh
  }

  Future<void> _restorePurchase() async {
    setState(() => _isPurchasing = true);

    // TODO: Replace with real restore logic
    await Future.delayed(const Duration(milliseconds: 500));

    final prefs = await SharedPreferences.getInstance();
    final isPremium = prefs.getBool('is_premium') ?? false;

    if (!mounted) return;
    setState(() => _isPurchasing = false);

    if (isPremium) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No previous purchase found.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _featureRow(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _teal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _teal, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: _textPri,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 13, color: _textMuted),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: _teal, size: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: _textPri),
          onPressed: () => Navigator.pop(context, false),
        ),
        title: const Text(
          'StoneGuard Plus',
          style: TextStyle(
            color: _textPri,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── HERO BADGE ──
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A8A9A), Color(0xFF0D6B78)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: _teal.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.workspace_premium_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Unlock StoneGuard Plus',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _textPri,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Everything you need to manage kidney stone prevention like a pro.',
              style: TextStyle(fontSize: 14, color: _textMuted, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // ── FEATURES ──
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _featureRow(
                    Icons.medical_information_rounded,
                    'Doctor Reports',
                    'Generate and share PDF & text reports with your urologist.',
                  ),
                  const Divider(height: 1),
                  _featureRow(
                    Icons.history_rounded,
                    'Full History — Up to 2 Years',
                    'View 6-month and 12-month water & oxalate trends.',
                  ),
                  const Divider(height: 1),
                  _featureRow(
                    Icons.block,
                    'Ad-Free Experience',
                    'No ads, ever. Focus on your health.',
                  ),
                  const Divider(height: 1),
                  _featureRow(
                    Icons.star_rounded,
                    'Priority Support',
                    'Get help faster with dedicated support.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── PRICE + CTA ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEAF6F8), Color(0xFFD4EEF3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _teal.withValues(alpha: 0.25)),
              ),
              child: Column(
                children: [
                  const Text(
                    'Lifetime Access',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _tealDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '\$4.99',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: _tealDark,
                    ),
                  ),
                  const Text(
                    'one-time purchase, no subscription',
                    style: TextStyle(fontSize: 12, color: _textMuted),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isPurchasing ? null : _purchasePremium,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _teal,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: _teal.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: _isPurchasing
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Unlock Now — \$4.99',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── RESTORE ──
            TextButton(
              onPressed: _isPurchasing ? null : _restorePurchase,
              child: const Text(
                'Restore Purchase',
                style: TextStyle(color: _teal, fontSize: 14),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Payment will be charged to your account at confirmation.\nSubscription automatically renews unless cancelled.',
              style: TextStyle(fontSize: 11, color: _textMuted, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
