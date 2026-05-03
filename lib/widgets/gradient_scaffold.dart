// ─── SHARED GRADIENT SCAFFOLD ────────────────────────────────────────────────────────
// All tabs use this widget so the teal-to-white gradient stays consistent
// across the whole app. To update the theme, change it here once.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _kGradientColors = [
  Color(0xFF01696F),
  Color(0xFF2A9DA5),
  Color(0xFFE0F4F5),
  Colors.white,
];
const _kGradientStops = [0.0, 0.18, 0.42, 0.62];
// ignore: unused_element
const _kHeaderHeight = 112.0; // how tall the teal band is before it fades

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
    // Keep status-bar icons white while the teal header is showing
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        floatingActionButton: floatingActionButton,
        bottomSheet: bottomSheet,
        body: Stack(
          children: [
            // ── Gradient background (full screen) ──
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment(0, 0.55),
                    colors: _kGradientColors,
                    stops: _kGradientStops,
                  ),
                ),
              ),
            ),

            // ── Actual content + custom header ──
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

// ── Slim custom header — white title centered, icons on edges ─────────────────
class _GradientAppBar extends StatelessWidget {
  const _GradientAppBar({required this.title, this.actions});
  final String title;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final bool canPop = Navigator.of(context).canPop();

    // Use a Stack so the title is always pixel-perfect centered,
    // regardless of how many icons sit on the left or right.
    return SizedBox(
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Centered title ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 56),
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          // ── Left: back button or spacer ──
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

          // ── Right: action icons ──
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
