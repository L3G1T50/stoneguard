// ─── SPLASH SCREEN ────────────────────────────────────────────
import 'package:flutter/material.dart';
import '../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
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
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeIn)),
    );
    _scaleAnim = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack)),
    );
    _controller.forward();
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (_, _, _) => const MyHomePage(),
          transitionsBuilder: (_, animation, _, child) =>
              FadeTransition(opacity: animation, child: child),
        ));
      }
    });
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

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
                const Text('StoneGuard',
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold,
                        color: Color(0xFF263238), letterSpacing: 1.2)),
                const SizedBox(height: 48),
                Container(
                  height: 200, width: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                      colors: [Color(0xFFF7F9FB), Color(0xFFE0E5EC)],
                    ),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 32, spreadRadius: 2, offset: const Offset(0, 16))],
                  ),
                  child: Stack(alignment: Alignment.center, children: [
                    Icon(Icons.shield, size: 130, color: Colors.grey.shade400),
                    Positioned(top: 48, child: Container(width: 75, height: 36,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                              colors: [Colors.white.withValues(alpha: 0.65), Colors.white.withValues(alpha: 0.0)]),
                        ))),
                    ShaderMask(
                      shaderCallback: (b) => const LinearGradient(
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        colors: [Color(0xFF00B8D4), Color(0xFF0097A7)],
                      ).createShader(b),
                      child: const Icon(Icons.water_drop, size: 54, color: Colors.white),
                    ),
                  ]),
                ),
                const SizedBox(height: 36),
                Text('Protect Your Health',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade500, letterSpacing: 0.8)),
                const SizedBox(height: 48),
                const SizedBox(height: 28, width: 28,
                    child: CircularProgressIndicator(strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.teal))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


