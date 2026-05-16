// ─── SPLASH SCREEN ────────────────────────────────────────────────────
//
// Fix 2: Wire ConsentManager.showIfNeeded() into the splash-to-home transition.
//   • When the user is a returning user going to MainShell, we show the
//     consent dialog exactly once (ConsentManager gates repeat showings).
//   • New users see onboarding/setup first; consent is shown on their
//     first arrival at MainShell instead, so it doesn’t interrupt the
//     onboarding flow.
//   • If consent was already given/declined in a prior session, the call
//     is a no-op (returns immediately without showing a dialog).
//
// Batch C: Key-loss warning
//   • main.dart passes showKeyLossWarning: true when checkIntegrity()
//     returns false.  The dialog is shown HERE instead of via a
//     postFrameCallback in main(), because context is guaranteed to
//     exist once _SplashScreenState is mounted.
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../consent_manager.dart';
import 'setup_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  /// When true, a one-time dialog is shown after the splash animation
  /// explaining that encrypted health data was reset (key-loss recovery).
  final bool showKeyLossWarning;

  const SplashScreen({super.key, this.showKeyLossWarning = false});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnim = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();
    _goNext();
  }

  Future<void> _goNext() async {
    await Future.delayed(const Duration(milliseconds: 2800));
    if (!mounted) return;

    // Batch C: show key-loss dialog before navigating away, so context
    // is guaranteed and the user sees it before any data screen loads.
    if (widget.showKeyLossWarning) {
      await _showKeyLossDialog();
      if (!mounted) return;
    }

    final prefs = await SharedPreferences.getInstance();

    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
    final hasCompletedSetup = prefs.getBool('has_completed_setup') ?? false;

    if (!mounted) return;

    Widget nextScreen;

    if (!hasSeenOnboarding) {
      nextScreen = const OnboardingScreen();
    } else if (!hasCompletedSetup) {
      nextScreen = const SetupScreen();
    } else {
      await ConsentManager.showIfNeeded(context);
      if (!mounted) return;
      nextScreen = const MainShell();
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  /// One-time dialog shown when the AES key was wiped (app-data clear,
  /// OS Keystore rotation, device restore). Blocks navigation until
  /// the user acknowledges so they aren’t confused by missing data.
  Future<void> _showKeyLossDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Data Reset Detected'),
        content: const Text(
          'KidneyShield could not read your saved data — this usually '
          'happens after clearing app storage or restoring a backup.\n\n'
          'Your daily entries and goals have been reset to defaults. '
          'Your history (if exported) can be re-imported from the '
          'History screen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK, Got It'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'KidneyShield',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF263238),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 48),
                Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFF7F9FB), Color(0xFFE0E5EC)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 32,
                        spreadRadius: 2,
                        offset: const Offset(0, 16),
                      )
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.shield,
                        size: 130,
                        color: Colors.grey.shade400,
                      ),
                      Positioned(
                        top: 48,
                        child: Container(
                          width: 75,
                          height: 36,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withValues(alpha: 0.65),
                                Colors.white.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                      ShaderMask(
                        shaderCallback: (b) => const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF00B8D4), Color(0xFF0097A7)],
                        ).createShader(b),
                        child: const Icon(
                          Icons.water_drop,
                          size: 54,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),
                Text(
                  'Protect Your Health',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade500,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 48),
                const SizedBox(
                  height: 28,
                  width: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
