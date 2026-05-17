// lib/screens/paywall_screen.dart
//
// KidneyShieldPaywall — conversion-optimised paywall with full error handling.

import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../services/billing_error_handler.dart';
import '../services/revenue_cat_service.dart';
import '../services/subscription_notifier.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  static const Color _teal      = Color(0xFF1A8A9A);
  static const Color _tealDark  = Color(0xFF0D6B78);
  static const Color _bg        = Color(0xFFF8F8F8);
  static const Color _surface   = Color(0xFFFFFFFF);
  static const Color _textPri   = Color(0xFF2C2C2C);
  static const Color _textMuted = Color(0xFF888888);

  bool _isLoading    = true;
  bool _isPurchasing = false;
  Offerings? _offerings;
  Package? _selectedPackage;
  String? _fetchError;

  final RevenueCatService _service = RevenueCatService();

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    if (!mounted) return;
    setState(() { _isLoading = true; _fetchError = null; });
    try {
      final offerings = await _service.getOfferings();
      if (!mounted) return;
      setState(() {
        _offerings = offerings;
        _selectedPackage =
            offerings?.current?.availablePackages.firstOrNull;
        _isLoading = false;
      });
    } on RevenueCatServiceException catch (e) {
      if (!mounted) return;
      setState(() { _fetchError = e.message; _isLoading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _fetchError = 'Could not load pricing. Please check your connection.';
        _isLoading = false;
      });
    }
  }

  Future<void> _purchaseSelected() async {
    if (_selectedPackage == null || !mounted) return;
    setState(() => _isPurchasing = true);
    try {
      final status = await _service.purchasePackage(_selectedPackage!);
      if (!mounted) return;
      await SubscriptionNotifier.of(context).refresh();
      if (!mounted) return;
      if (status.isSubscribed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Welcome to KidneyShield Plus! 🎉'),
            backgroundColor: Color(0xFF0D6B78),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      }
    } on RevenueCatServiceException catch (e) {
      if (!mounted) return;
      BillingErrorHandler.handle(context, e, onRetry: _purchaseSelected);
    } catch (e) {
      if (!mounted) return;
      BillingErrorHandler.handleGeneric(context, e);
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  Future<void> _restorePurchases() async {
    if (!mounted) return;
    setState(() => _isPurchasing = true);
    try {
      final status = await _service.restorePurchases();
      if (!mounted) return;
      await SubscriptionNotifier.of(context).refresh();
      if (!mounted) return;
      if (status.isSubscribed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Purchase restored successfully!'),
            backgroundColor: Color(0xFF0D6B78),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No previous purchase found for this account.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on RevenueCatServiceException catch (e) {
      if (!mounted) return;
      BillingErrorHandler.handle(context, e, onRetry: _restorePurchases);
    } catch (e) {
      if (!mounted) return;
      BillingErrorHandler.handleGeneric(
        context, e,
        fallbackMessage: 'Restore failed. Please try again.',
      );
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  String _priceLabel(Package package) {
    final price = package.storeProduct.priceString;
    switch (package.packageType) {
      case PackageType.monthly:  return '$price / month';
      case PackageType.annual:   return '$price / year';
      case PackageType.lifetime: return '$price one-time';
      default: return price;
    }
  }

  String _packageTitle(Package package) {
    switch (package.packageType) {
      case PackageType.monthly:  return 'Monthly';
      case PackageType.annual:   return 'Annual';
      case PackageType.lifetime: return 'Lifetime Access';
      default: return package.identifier;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: _bg,
          appBar: AppBar(
            backgroundColor: _surface,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: _textPri),
              tooltip: 'Close',
              onPressed:
                  _isPurchasing ? null : () => Navigator.pop(context, false),
            ),
            title: const Text(
              'KidneyShield Plus',
              style: TextStyle(
                color: _textPri,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            centerTitle: true,
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _fetchError != null
                  ? _buildErrorState()
                  : _buildPaywall(),
        ),
        if (_isPurchasing)
          Container(
            color: Colors.black45,
            child: const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Processing…',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPaywall() {
    final packages =
        _offerings?.current?.availablePackages ?? <Package>[];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildHeroBadge(),
          const SizedBox(height: 20),
          const Text('Unlock KidneyShield Plus',
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: _textPri),
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          const Text(
            'Everything you need to manage kidney stone prevention like a pro.',
            style: TextStyle(fontSize: 14, color: _textMuted, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildFeatureList(),
          const SizedBox(height: 28),
          if (packages.isEmpty)
            _buildFallbackPriceCard()
          else
            _buildPackageSelector(packages),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed:
                  (_isPurchasing || _selectedPackage == null)
                      ? null
                      : _purchaseSelected,
              style: ElevatedButton.styleFrom(
                backgroundColor: _teal,
                foregroundColor: Colors.white,
                disabledBackgroundColor: _teal.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text(
                _selectedPackage != null
                    ? 'Unlock Now — ${_priceLabel(_selectedPackage!)}'
                    : 'Unlock Now',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _isPurchasing ? null : _restorePurchases,
            child: const Text('Restore Purchase',
                style: TextStyle(color: _teal, fontSize: 14)),
          ),
          const SizedBox(height: 8),
          const Text(
            'Payment will be charged to your Google Play account at\nconfirmation of purchase.',
            style: TextStyle(fontSize: 11, color: _textMuted, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeroBadge() {
    return Container(
      width: 80, height: 80,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A8A9A), Color(0xFF0D6B78)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: _teal.withValues(alpha: 0.35),
              blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: const Icon(Icons.workspace_premium_rounded,
          color: Colors.white, size: 40),
    );
  }

  Widget _buildFeatureList() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          _featureRow(Icons.medical_information_rounded,
              'Doctor Reports',
              'Generate and share PDF reports with your urologist.'),
          const Divider(height: 1),
          _featureRow(Icons.history_rounded,
              'Full History — Up to 2 Years',
              'View 6-month and 12-month water & oxalate trends.'),
          const Divider(height: 1),
          _featureRow(Icons.file_download_rounded,
              'Export Reports',
              'Download and share your health data as PDF.'),
          const Divider(height: 1),
          _featureRow(Icons.block,
              'Ad-Free Experience',
              'No ads, ever. Focus entirely on your health.'),
          const Divider(height: 1),
          _featureRow(Icons.star_rounded,
              'Priority Support',
              'Get help faster with dedicated support.'),
        ],
      ),
    );
  }

  Widget _buildPackageSelector(List<Package> packages) {
    return Column(
      children: packages.map((pkg) {
        final isSelected = pkg.identifier == _selectedPackage?.identifier;
        return GestureDetector(
          onTap: () => setState(() => _selectedPackage = pkg),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? _teal.withValues(alpha: 0.08) : _surface,
              border: Border.all(
                  color: isSelected ? _teal : Colors.grey.shade300,
                  width: isSelected ? 2 : 1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: isSelected ? _teal : Colors.grey, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_packageTitle(pkg),
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15,
                              color: isSelected ? _tealDark : _textPri)),
                      Text(
                        pkg.storeProduct.description.isNotEmpty
                            ? pkg.storeProduct.description
                            : _priceLabel(pkg),
                        style: const TextStyle(
                            fontSize: 12, color: _textMuted)),
                    ],
                  ),
                ),
                Text(pkg.storeProduct.priceString,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16,
                        color: isSelected ? _tealDark : _textPri)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFallbackPriceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEAF6F8), Color(0xFFD4EEF3)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _teal.withValues(alpha: 0.25)),
      ),
      child: const Column(
        children: [
          Text('KidneyShield Plus',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: _tealDark)),
          SizedBox(height: 4),
          Text('Pricing loading…',
              style: TextStyle(fontSize: 14, color: _textMuted)),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, size: 56,
                color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text('Could not load pricing',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold,
                    color: _textPri)),
            const SizedBox(height: 8),
            Text(
              _fetchError ?? 'Please check your connection and try again.',
              style: const TextStyle(fontSize: 14, color: _textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadOfferings,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _teal, foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
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
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15,
                        color: _textPri)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 13, color: _textMuted)),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: _teal, size: 20),
        ],
      ),
    );
  }
}
