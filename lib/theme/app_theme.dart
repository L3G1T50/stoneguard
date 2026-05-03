// ─── STONEGUARD DESIGN SYSTEM ────────────────────────────────────────────────
//
// Single source of truth for all colors, text styles, card styles,
// spacing, and the root ThemeData used in main.dart.
//
// HOW TO USE IN ANY SCREEN:
//   import '../theme/app_theme.dart';
//
//   Color primary = AppColors.teal;          // accent color
//   TextStyle t   = AppTextStyles.title;     // screen title
//   Widget card   = AppCard(child: ...);     // consistent card
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─── COLOR PALETTE ────────────────────────────────────────────────────────────
abstract class AppColors {
  // Primary accent – teal used for all positive/interactive elements
  static const Color teal        = Color(0xFF00897B);
  static const Color tealLight   = Color(0xFFE0F2F1);
  static const Color tealDark    = Color(0xFF00695C);

  // Semantic roles
  static const Color warning     = Color(0xFFF57C00);  // amber – "pay attention"
  static const Color warningBg   = Color(0xFFFFF3E0);
  static const Color danger      = Color(0xFFD32F2F);  // red – destructive only
  static const Color dangerBg    = Color(0xFFFFEBEE);
  static const Color success     = Color(0xFF2E7D32);  // green – "all good"
  static const Color successBg   = Color(0xFFE8F5E9);

  // Oxalate context – used ONLY on oxalate-related widgets
  static const Color oxalate     = Color(0xFF6A1B9A);
  static const Color oxalateBg   = Color(0xFFF3E5F5);

  // Surfaces & backgrounds
  static const Color background  = Color(0xFFF4F6F8);  // app scaffold bg
  static const Color surface     = Color(0xFFFFFFFF);  // card / sheet bg
  static const Color divider     = Color(0xFFECEFF1);

  // Text
  static const Color textPrimary = Color(0xFF1A2530);  // near-black, warmer
  static const Color textSecond  = Color(0xFF546E7A);  // medium gray
  static const Color textHint    = Color(0xFF90A4AE);  // light placeholder

  // Nav bar
  static const Color navBg       = Color(0xFFFFFFFF);
  static const Color navIndicator= Color(0xFFB2DFDB);  // teal 100
}

// ─── TEXT STYLES ──────────────────────────────────────────────────────────────
abstract class AppTextStyles {
  // Screen / tab title  (e.g. "Settings", "Shield")
  static const TextStyle screenTitle = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
    height: 1.2,
  );

  // Section header label  (e.g. "DAILY GOALS", "NOTIFICATIONS")
  static const TextStyle sectionLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.textHint,
    letterSpacing: 1.4,
  );

  // Card / list item title
  static const TextStyle itemTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // Body copy and subtitles inside cards
  static const TextStyle body = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecond,
    height: 1.45,
  );

  // Small metadata / badges
  static const TextStyle micro = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textHint,
    letterSpacing: 0.3,
  );

  // Primary button label
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.2,
  );
}

// ─── SPACING ──────────────────────────────────────────────────────────────────
abstract class AppSpacing {
  static const double xs  = 4;
  static const double sm  = 8;
  static const double md  = 16;
  static const double lg  = 24;
  static const double xl  = 32;
  static const double xxl = 48;

  /// Standard horizontal page padding
  static const EdgeInsets pagePadding =
      EdgeInsets.symmetric(horizontal: 18);

  /// Padding between sections on a scrollable screen
  static const double sectionGap = 28;

  /// Inner padding for cards
  static const EdgeInsets cardPadding = EdgeInsets.all(18);
}

// ─── CARD DECORATION ─────────────────────────────────────────────────────────
BoxDecoration appCardDecoration({
  Color color = AppColors.surface,
  double radius = 16,
}) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: const [
      BoxShadow(
        color: Color(0x0A000000),  // 4 % black – barely visible, just depth
        blurRadius: 10,
        spreadRadius: 0,
        offset: Offset(0, 3),
      ),
    ],
  );
}

// ─── APP CARD WIDGET ─────────────────────────────────────────────────────────
/// Drop-in replacement for the ad-hoc Container cards scattered across screens.
/// Usage:
///   AppCard(child: Column(...))
///   AppCard(onTap: () {}, child: ListTile(...))
class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double radius;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.color,
    this.radius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      child: Material(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(radius),
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: onTap,
          splashColor: AppColors.teal.withValues(alpha: 0.06),
          highlightColor: AppColors.teal.withValues(alpha: 0.04),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            padding: padding ?? AppSpacing.cardPadding,
            child: child,
          ),
        ),
      ),
    );
  }
}

// ─── SECTION HEADER WIDGET ───────────────────────────────────────────────────
/// Standardised section header used in every scrollable screen.
/// Usage:  AppSectionHeader('DAILY GOALS')
class AppSectionHeader extends StatelessWidget {
  final String title;
  final EdgeInsetsGeometry? padding;

  const AppSectionHeader(this.title, {super.key, this.padding});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(top: 28, bottom: 10),
      child: Text(title.toUpperCase(), style: AppTextStyles.sectionLabel),
    );
  }
}

// ─── SCREEN TITLE WIDGET ─────────────────────────────────────────────────────
/// Large title shown at the top of each tab screen.
/// Usage:  AppScreenTitle('Settings')
class AppScreenTitle extends StatelessWidget {
  final String title;
  final String? subtitle;

  const AppScreenTitle(this.title, {super.key, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.screenTitle),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: AppTextStyles.body),
          ],
        ],
      ),
    );
  }
}

// ─── PRIMARY BUTTON ───────────────────────────────────────────────────────────
/// Consistent teal primary button.
/// Usage:  AppButton(label: 'Save', onPressed: () {})
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? color;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppColors.teal,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(label, style: AppTextStyles.button),
                ],
              ),
      ),
    );
  }
}

// ─── ICON BADGE ───────────────────────────────────────────────────────────────
/// Circular icon with a tinted background. Used in list rows & cards.
/// Usage:  AppIconBadge(icon: Icons.water_drop, color: AppColors.teal)
class AppIconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const AppIconBadge({
    super.key,
    required this.icon,
    required this.color,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: size),
    );
  }
}

// ─── ROOT THEME DATA ─────────────────────────────────────────────────────────
/// Pass this to MaterialApp's `theme:` parameter in main.dart.
ThemeData buildAppTheme() {
  const seed = AppColors.teal;

  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: seed,
      primary: AppColors.teal,
      secondary: AppColors.tealDark,
      surface: AppColors.surface,
      error: AppColors.danger,
      brightness: Brightness.light,
    ),

    // Scaffold background
    scaffoldBackgroundColor: AppColors.background,

    // AppBar – flat, white, dark title text
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.2,
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.navBg,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    ),

    // Bottom NavigationBar
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.navBg,
      indicatorColor: AppColors.navIndicator,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.tealDark,
          );
        }
        return const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.textHint,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.tealDark, size: 24);
        }
        return const IconThemeData(color: AppColors.textHint, size: 22);
      }),
    ),

    // ElevatedButton defaults
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        textStyle: AppTextStyles.button,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        minimumSize: const Size(double.infinity, 48),
      ),
    ),

    // TextButton defaults
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.teal,
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Input decoration (text fields, search bars)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.background,
      hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
      ),
    ),

    // Slider
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.teal,
      thumbColor: AppColors.teal,
      inactiveTrackColor: AppColors.tealLight,
      overlayColor: AppColors.teal.withValues(alpha: 0.12),
      trackHeight: 3,
    ),

    // Switch
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.teal;
        return Colors.white;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.tealLight;
        return const Color(0xFFCFD8DC);
      }),
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 1,
    ),

    // Dialog
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      contentTextStyle: const TextStyle(
        fontSize: 14,
        color: AppColors.textSecond,
        height: 1.5,
      ),
    ),

    // SnackBar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.textPrimary,
      contentTextStyle:
          const TextStyle(color: Colors.white, fontSize: 13),
      behavior: SnackBarBehavior.floating,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    // Chip
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.background,
      labelStyle:
          const TextStyle(fontSize: 12, color: AppColors.textSecond),
      side: BorderSide.none,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}
