// ─── SHARED GRADIENT SCAFFOLD ─────────────────────────────────────────────────
// All tabs use this widget so the teal-to-theme gradient stays consistent
// across the whole app. Supports both light and dark mode automatically.
//
// Batch G:
//   • AppBar title uses AppTextStyles.appBarTitle (18px w700 Inter) in white,
//     consistent with StoneGuardAppBar typography. Was fontSize:22/bold.
//   • Gradient top stops replaced with AppColors.teal / AppColors.tealDark
//     so any future brand-colour change flows through automatically.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class GradientScaffold extends StatelessWidget {
  const GradientScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.bottomSheet,
    this.resizeToAvoidBottomInset = true,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomSheet;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Color> gradientColors = isDark
        ? [
            AppColors.teal,
            AppColors.tealDark,
            AppColors.darkBackground,
            AppColors.darkBackground,
          ]
        : [
            AppColors.teal,
            AppColors.tealDark,
            const Color(0xFFE0F4F5),
            Colors.white,
          ];

    const gradientStops = [0.0, 0.18, 0.42, 0.62];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        floatingActionButton: floatingActionButton,
        bottomSheet: bottomSheet,
        body: Stack(
          children: [
            // Gradient background (full screen)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: const Alignment(0, 0.55),
                    colors: gradientColors,
                    stops: gradientStops,
                  ),
                ),
              ),
            ),

            // Content + custom header
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _GradientAppBar(title: title, actions: actions),
                  Expanded(child: body),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Slim custom header ────────────────────────────────────────────────────────
class _GradientAppBar extends StatelessWidget {
  const _GradientAppBar({required this.title, this.actions});
  final String title;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final bool canPop = Navigator.of(context).canPop();

    return SizedBox(
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Centered title — Batch G: use AppTextStyles.appBarTitle in white
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 56),
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.appBarTitle.copyWith(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),

          // Left: back button or spacer
          Positioned(
            left: 0,
            child: canPop
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                : const SizedBox(width: 48),
          ),

          // Right: action icons
          if (actions != null)
            Positioned(
              right: 0,
              child: Row(mainAxisSize: MainAxisSize.min, children: actions!),
            ),
        ],
      ),
    );
  }
}
