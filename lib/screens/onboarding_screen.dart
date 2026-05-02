import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'setup_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // AnimationController drives the icon cross-fade between pages
  late AnimationController _iconController;
  late Animation<double> _iconFade;

  final List<_OnboardingPageData> _pages = const [
    _OnboardingPageData(
      title: 'Welcome to StoneGuard',
      description:
      'A simple way to track habits that may help lower your kidney stone risk.',
      accent: Color(0xFF0097A7),
      icon: Icons.shield_rounded,
      overlayIcon: Icons.water_drop_rounded,
    ),
    _OnboardingPageData(
      title: 'Hydration is your first shield',
      description:
      'Log water quickly and stay closer to your daily goal with simple reminders and progress tracking.',
      accent: Color(0xFF00ACC1),
      icon: Icons.shield_rounded,
      overlayIcon: Icons.local_drink_rounded,
    ),
    _OnboardingPageData(
      title: 'Watch oxalate before it adds up',
      description:
      'Search foods, learn their oxalate level, and keep a closer eye on your daily intake.',
      accent: Color(0xFF2A9D8F),
      icon: Icons.shield_rounded,
      overlayIcon: Icons.restaurant_menu_rounded,
    ),
    _OnboardingPageData(
      title: 'Spot patterns and share progress',
      description:
      'See what is working over time and bring cleaner information to doctor visits and follow-ups.',
      accent: Color(0xFF3A86FF),
      icon: Icons.shield_rounded,
      overlayIcon: Icons.show_chart_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1.0, // start fully visible
    );
    _iconFade = CurvedAnimation(parent: _iconController, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  // NOTE: uses 'seen_onboarding' to match the key preserved in _clearAllData()
  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_onboarding', true);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SetupScreen()),
    );
  }

  void _nextPage() {
    if (_currentPage == _pages.length - 1) {
      _finishOnboarding();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onPageChanged(int index) {
    // Fade out → update page → fade back in for a smooth icon swap
    _iconController.reverse().then((_) {
      if (!mounted) return;
      setState(() => _currentPage = index);
      _iconController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [

            // ── TOP BAR: page counter + Skip ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_currentPage + 1} of ${_pages.length}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // Skip button — hidden on the last page
                  if (!isLastPage)
                    TextButton(
                      onPressed: _finishOnboarding,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey.shade500,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    )
                  else
                  // Invisible placeholder so the counter stays left-aligned
                    const SizedBox(width: 56),
                ],
              ),
            ),

            // ── PAGE CONTENT ──
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Hero badge with animated icon fade
                        FadeTransition(
                          opacity: _iconFade,
                          child: _StoneGuardHeroBadge(page: page),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF263238),
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF6B7280),
                            height: 1.55,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ── BOTTOM: dots + button + hint ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
              child: Column(
                children: [
                  // Animated dot indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                          (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 10,
                        width: _currentPage == index ? 26 : 10,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? const Color(0xFF0097A7)
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Next / Continue button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0097A7),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          isLastPage ? 'Continue to setup' : 'Next',
                          key: ValueKey(isLastPage),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'You can change goals and settings later anytime.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}

// ── Hero badge widget ──────────────────────────────────────────
class _StoneGuardHeroBadge extends StatelessWidget {
  final _OnboardingPageData page;

  const _StoneGuardHeroBadge({required this.page});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 215,
      width: 215,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF7F9FB),
            Color(0xFFE0E5EC),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 32,
            spreadRadius: 2,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            page.icon,
            size: 138,
            color: Colors.grey.shade400,
          ),
          Positioned(
            top: 48,
            child: Container(
              width: 78,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.68),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                page.accent.withValues(alpha: 0.95),
                page.accent,
              ],
            ).createShader(bounds),
            child: Icon(
              page.overlayIcon,
              size: 58,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Page data model ────────────────────────────────────────────
class _OnboardingPageData {
  final String title;
  final String description;
  final Color accent;
  final IconData icon;
  final IconData overlayIcon;

  const _OnboardingPageData({
    required this.title,
    required this.description,
    required this.accent,
    required this.icon,
    required this.overlayIcon,
  });
}