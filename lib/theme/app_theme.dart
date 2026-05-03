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
import 'package:google_fonts/google_fonts.dart';

// ─── COLOR PALETTE ────────────────────────────────────────────────────────────
abstract class AppColors {
  // Primary accent – teal used for all positive/interactive elements
  static const Color teal        = Color(0xFF00897B);
  static const Color tealLight   = Color(0xFFE0F2F1);
  static const Color tealDark    = Color(0xFF00695C);

  // Semantic roles  (each color used ONLY for its stated role)
  static const Color warning     = Color(0xFFF57C00);  // amber  – "pay attention"
  static const Color warningBg   = Color(0xFFFFF3E0);
  static const Color danger      = Color(0xFFD32F2F);  // red    – destructive only
  static const Color dangerBg    = Color(0xFFFFEBEE);
  static const Color success     = Color(0xFF2E7D32);  // green  – "all good"
  static const Color successBg   = Color(0xFFE8F5E9);

  // Oxalate context – used ONLY on oxalate-related widgets
  static const Color oxalate     = Color(0xFF6A1B9A);
  static const Color oxalateBg   = Color(0xFFF3E5F5);

  // Surfaces & backgrounds
  static const Color background  = Color(0xFFF4F6F8);  // scaffold bg
  static const Color surface     = Color(0xFFFFFFFF);  // card / sheet bg
  static const Color divider     = Color(0xFFECEFF1);
  static const Color border      = Color(0xFFDDE3E7);  // subtle card border

  // Text
  static const Color textPrimary = Color(0xFF1A2530);  // near-black, warmer
  static const Color textSecond  = Color(0xFF546E7A);  // medium gray
  static const Color textHint    = Color(0xFF90A4AE);  // light placeholder

  // Nav bar
  static const Color navBg       = Color(0xFFFFFFFF);
  static const Color navIndicator= Color(0xFFB2DFDB);  // teal 100

  // ── Aliases kept for backward compat with older screen imports ──
  static const Color primary      = teal;
  static const Color primaryLight = tealLight;
  static const Color primaryMuted = tealDark;
  static const Color textMuted    = textSecond;
  static const Color textFaint    = textHint;
  static const Color appBar       = surface;
}

// ─── TEXT STYLES ──────────────────────────────────────────────────────────────
// NOTE: These are base styles. GoogleFonts.interTextTheme() applied in
// buildAppTheme() means ALL Text widgets automatically use Inter.
// These constants are used where an explicit TextStyle is needed.
abstract class AppTextStyles {
  // Screen / tab title  (e.g. "Settings", "Shield")
  static TextStyle get screenTitle => GoogleFonts.inter(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  // AppBar title – used in appBarTheme titleTextStyle
  static TextStyle get appBarTitle => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  // Section header label  (e.g. "DAILY GOALS", "NOTIFICATIONS")
  static TextStyle get sectionLabel => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.textHint,
    letterSpacing: 1.4,
  );

  // Card / list item title
  static TextStyle get itemTitle => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // Body copy and subtitles inside cards
  static TextStyle get body => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecond,
    height: 1.45,
  );

  // Small metadata / badges
  static TextStyle get micro => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textHint,
    letterSpacing: 0.3,
  );

  // Primary button label
  static TextStyle get button => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.2,
  );

  // ── Aliases kept for backward compat ──
  static TextStyle get sectionHeader => sectionLabel;
  static TextStyle get cardTitle     => itemTitle;
  static TextStyle get label         => GoogleFonts.inter(
    color: AppColors.textSecond,
    fontWeight: FontWeight.w600,
    fontSize: 13,
  );
  static TextStyle get meta          => micro;
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
    border: Border.all(color: AppColors.border),
    boxShadow: const [
      BoxShadow(
        color: Color(0x08000000),  // 3% black – barely visible, just depth
        blurRadius: 12,
        spreadRadius: 0,
        offset: Offset(0, 4),
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
              border: Border.all(color: AppColors.border),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
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
/// Rounded square icon with a tinted background. Used in list rows & cards.
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

// ─── STANDARD APP BAR ─────────────────────────────────────────────────────────
/// Use this instead of a raw AppBar in every screen for consistency.
/// White background, dark title, subtle bottom divider – matches Settings style.
/// Usage:  StoneGuardAppBar(title: 'Pain Journal')
class StoneGuardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;

  const StoneGuardAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: centerTitle,
      leading: leading,
      actions: actions,
      title: Text(title, style: AppTextStyles.appBarTitle),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(
          height: 1,
          thickness: 1,
          color: AppColors.divider,
        ),
      ),
    );
  }
}

// ─── ROOT THEME DATA ─────────────────────────────────────────────────────────
/// Pass this to MaterialApp's `theme:` parameter in main.dart.
ThemeData buildAppTheme() {
  const seed = AppColors.teal;

  // Inter applied as the base text theme for the entire app.
  // Every Text widget will use Inter automatically – no per-widget font needed.
  final interTextTheme = GoogleFonts.interTextTheme();

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

    // Inter as the app-wide font
    textTheme: interTextTheme,
    primaryTextTheme: interTextTheme,

    // Scaffold background
    scaffoldBackgroundColor: AppColors.background,

    // AppBar – flat white, dark title, subtle bottom divider
    // All screens should use StoneGuardAppBar for full consistency.
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: false,
      titleTextStyle: AppTextStyles.appBarTitle,
      systemOverlayStyle: const SystemUiOverlayStyle(
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
          return GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.tealDark,
          );
        }
        return GoogleFonts.inter(
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

    // OutlinedButton defaults
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.teal,
        side: const BorderSide(color: AppColors.teal),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
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
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Input decoration (text fields, search bars)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.background,
      hintStyle: GoogleFonts.inter(color: AppColors.textHint, fontSize: 14),
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
      titleTextStyle: GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      contentTextStyle: GoogleFonts.inter(
        fontSize: 14,
        color: AppColors.textSecond,
        height: 1.5,
      ),
    ),

    // SnackBar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.textPrimary,
      contentTextStyle:
          GoogleFonts.inter(color: Colors.white, fontSize: 13),
      behavior: SnackBarBehavior.floating,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    // Chip
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.background,
      labelStyle:
          GoogleFonts.inter(fontSize: 12, color: AppColors.textSecond),
      side: const BorderSide(color: AppColors.border),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),

    // Card
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      margin: EdgeInsets.zero,
    ),
  );
}
