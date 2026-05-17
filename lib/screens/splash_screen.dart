// splash_screen.dart
import 'package:flutter/material.dart';
import '../consent_manager.dart';
import '../secure_prefs.dart';
import '../app_logger.dart';

class SplashScreen extends StatefulWidget {
  final bool integrityOk;
  const SplashScreen({super.key, required this.integrityOk});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _scale;

  static const Color _teal = Color(0xFF1A8A9A);
  static const Color _dark = Color(0xFF0D1F2D);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _scale = Tween<double>(begin: 0.85, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _ctrl.forward();
    _init();
  }

  Future<void> _init() async {
    // Minimum splash display time
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    try {
      // Request consent & init AdMob (Fix 8)
      await ConsentManager.instance.requestConsentAndInitAdMob(context);
    } catch (e, st) {
      AppLogger.error('SplashScreen', 'consent init failed', e, st);
    }

    if (!mounted) return;
    _navigate();
  }

  Future<void> _navigate() async {
    try {
      final onboarded = await SecurePrefs.instance
          .getBool('onboarding_complete', defaultValue: false);
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        onboarded ? '/home' : '/onboarding',
      );
    } catch (e, st) {
      AppLogger.error('SplashScreen', 'navigation failed', e, st);
      if (mounted) Navigator.pushReplacementNamed(context, '/onboarding');
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _dark,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: _teal.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: _teal.withValues(alpha: 0.4), width: 2),
                  ),
                  child: const Icon(Icons.shield_outlined,
                      color: _teal, size: 52),
                ),
                const SizedBox(height: 24),
                const Text(
                  'StoneGuard',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Kidney stone prevention, simplified.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.55),
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
