// ─── STONEGUARD DESIGN SYSTEM ────────────────────────────────────────────────
//
// Single source of truth for all colors, text styles, card styles,
// spacing, and the root ThemeData used in main.dart.
//
// DARK MODE:
//   Wrap your widget tree with ThemeNotifier (done in main.dart).
//   Read the current mode anywhere via:
//     ThemeNotifier.of(context).isDark
//     ThemeNotifier.of(context).toggle()
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── THEME NOTIFIER ─────────────────────────────────────────────────────────
/// Holds the current ThemeMode and notifies listeners on change.
/// Access anywhere: ThemeNotifier.of(context)
class ThemeNotifier extends ChangeNotifier {
  ThemeMode _mode;

  ThemeNotifier(this._mode);

  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  void toggle() {
    _mode = isDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void setMode(ThemeMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
  }

  /// Convenience accessor — call from any widget with a BuildContext.
  static ThemeNotifier of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_ThemeNotifierScope>()!
        .notifier;
  }
}

/// InheritedWidget wrapper so ThemeNotifier.of(context) works anywhere.
class ThemeNotifierProvider extends StatefulWidget {
  final ThemeNotifier notifier;
  final Widget child;

  const ThemeNotifierProvider({
    super.key,
    required this.notifier,
    required this.child,
  });

  @override
  State<ThemeNotifierProvider> createState() => _ThemeNotifierProviderState();
}

class _ThemeNotifierProviderState extends State<ThemeNotifierProvider> {
  @override
  void initState() {
    super.initState();
    widget.notifier.addListener(_onThemeChange);
  }

  @override
  void dispose() {
    widget.notifier.removeListener(_onThemeChange);
    super.dispose();
  }

  void _onThemeChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return _ThemeNotifierScope(
      notifier: widget.notifier,
      child: widget.child,
    );
  }
}

class _ThemeNotifierScope extends InheritedWidget {
  final ThemeNotifier notifier;

  const _ThemeNotifierScope({
    required this.notifier,
    required super.child,
  });

  @override
  bool updateShouldNotify(_ThemeNotifierScope old) => true;
}

// ─── COLOR PALETTE ────────────────────────────────────────────────────────────
abstract class AppColors {
  // Primary accent
  static const Color teal        = Color(0xFF00897B);
  static const Color tealLight   = Color(0xFFE0F2F1);
  static const Color tealDark    = Color(0xFF00695C);

  // Semantic roles
  static const Color warning     = Color(0xFFF57C00);
  static const Color warningBg   = Color(0xFFFFF3E0);
  static const Color danger      = Color(0xFFD32F2F);
  static const Color dangerBg    = Color(0xFFFFEBEE);
  static const Color success     = Color(0xFF2E7D32);
  static const Color successBg   = Color(0xFFE8F5E9);

  // Oxalate context
  static const Color oxalate     = Color(0xFF6A1B9A);
  static const Color oxalateBg   = Color(0xFFF3E5F5);

  // Surfaces & backgrounds (LIGHT)
  static const Color background  = Color(0xFFF4F6F8);
  static const Color surface     = Color(0xFFFFFFFF);
  static const Color divider     = Color(0xFFECEFF1);
  static const Color border      = Color(0xFFDDE3E7);

  // Text (LIGHT)
  static const Color textPrimary = Color(0xFF1A2530);
  static const Color textSecond  = Color(0xFF546E7A);
  static const Color textHint    = Color(0xFF90A4AE);

  // Nav bar (LIGHT)
  static const Color navBg       = Color(0xFFFFFFFF);
  static const Color navIndicator= Color(0xFFB2DFDB);

  // ── DARK MODE COLORS ──
  static const Color darkBackground  = Color(0xFF0F1419);
  static const Color darkSurface     = Color(0xFF1A2332);
  static const Color darkSurface2    = Color(0xFF243040);
  static const Color darkDivider     = Color(0xFF2A3A4A);
  static const Color darkBorder      = Color(0xFF2E4055);
  static const Color darkTextPrimary = Color(0xFFE8EDF2);
  static const Color darkTextSecond  = Color(0xFF8FA8BE);
  static const Color darkTextHint    = Color(0xFF4A6478);
  static const Color darkNavBg       = Color(0xFF1A2332);
  static const Color darkNavIndicator= Color(0xFF1A4A44);
  static const Color darkTealLight   = Color(0xFF0D2B28);

  // ── Aliases kept for backward compat ──
  static const Color primary      = teal;
  static const Color primaryLight = tealLight;
  static const Color primaryMuted = tealDark;
  static const Color textMuted    = textSecond;
  static const Color textFaint    = textHint;
  static const Color appBar       = surface;
}

// ─── CONTEXT-AWARE COLOR HELPER ──────────────────────────────────────────────
/// Use these anywhere you need a color that responds to dark/light mode.
/// Example:  color: AppDynamic.surface(context)
abstract class AppDynamic {
  static bool _dark(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark;

  static Color background(BuildContext ctx) =>
      _dark(ctx) ? AppColors.darkBackground  : AppColors.background;
  static Color surface(BuildContext ctx) =>
      _dark(ctx) ? AppColors.darkSurface      : AppColors.surface;
  static Color surface2(BuildContext ctx) =>
      _dark(ctx) ? AppColors.darkSurface2     : AppColors.surface;
  static Color border(BuildContext ctx) =>
      _dark(ctx) ? AppColors.darkBorder       : AppColors.border;
  static Color divider(BuildContext ctx) =>
      _dark(ctx) ? AppColors.darkDivider      : AppColors.divider;
  static Color textPrimary(BuildContext ctx) =>
      _dark(ctx) ? AppColors.darkTextPrimary  : AppColors.textPrimary;
  static Color textSecond(BuildContext ctx) =>
      _dark(ctx) ? AppColors.darkTextSecond   : AppColors.textSecond;
  static Color textHint(BuildContext ctx) =>
      _dark(ctx) ? AppColors.darkTextHint     : AppColors.textHint;
  static Color tealLight(BuildContext ctx) =>
      _dark(ctx) ? AppColors.darkTealLight    : AppColors.tealLight;
  static Color navBg(BuildContext ctx) =>
      _dark(ctx) ? AppColors.darkNavBg        : AppColors.navBg;
}

// ─── TEXT STYLES ─────────────────────────────────────────────────────────────
// NOTE: Static getters intentionally omit a hardcoded color (color: null /
// inherit: true) so they inherit from the DefaultTextStyle pushed by AppCard
// or any parent widget.  Use the ...Of(context) variants when you need an
// explicit color outside of a card context.
abstract class AppTextStyles {
  static TextStyle get screenTitle => GoogleFonts.inter(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
    // color intentionally omitted — inherits from DefaultTextStyle
  );

  static TextStyle get appBarTitle => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
  );

  static TextStyle get sectionLabel => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.4,
    // color intentionally omitted — inherits from DefaultTextStyle
  );

  static TextStyle get itemTitle => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.3,
    // color intentionally omitted — inherits from DefaultTextStyle
  );

  static TextStyle get body => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.45,
    // color intentionally omitted — inherits from DefaultTextStyle
  );

  static TextStyle get micro => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    // color intentionally omitted — inherits from DefaultTextStyle
  );

  static TextStyle get button => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.2,
  );

  // ── Context-aware versions — use outside of AppCard ──
  static TextStyle screenTitleOf(BuildContext ctx) {
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    return screenTitle.copyWith(
      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
    );
  }

  static TextStyle itemTitleOf(BuildContext ctx) {
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    return itemTitle.copyWith(
      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
    );
  }

  static TextStyle bodyOf(BuildContext ctx) {
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    return body.copyWith(
      color: isDark ? AppColors.darkTextSecond : AppColors.textSecond,
    );
  }

  static TextStyle microOf(BuildContext ctx) {
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    return micro.copyWith(
      color: isDark ? AppColors.darkTextHint : AppColors.textHint,
    );
  }

  static TextStyle sectionLabelOf(BuildContext ctx) {
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    return sectionLabel.copyWith(
      color: isDark ? AppColors.darkTextSecond : AppColors.textHint,
    );
  }

  // ── Aliases ──
  static TextStyle get sectionHeader => sectionLabel;
  static TextStyle get cardTitle     => itemTitle;
  static TextStyle get label         => GoogleFonts.inter(
    fontWeight: FontWeight.w600,
    fontSize: 13,
  );
  static TextStyle get meta  => micro;
  static TextStyle get title => screenTitle;
}

// ─── SPACING ─────────────────────────────────────────────────────────────────
abstract class AppSpacing {
  static const double xs  = 4;
  static const double sm  = 8;
  static const double md  = 16;
  static const double lg  = 24;
  static const double xl  = 32;
  static const double xxl = 48;

  static const EdgeInsets pagePadding =
      EdgeInsets.symmetric(horizontal: 18);
  static const double sectionGap = 28;
  static const EdgeInsets cardPadding = EdgeInsets.all(18);
}

// ─── CARD DECORATION (legacy helper) ─────────────────────────────────────────
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
        color: Color(0x08000000),
        blurRadius: 12,
        spreadRadius: 0,
        offset: Offset(0, 4),
      ),
    ],
  );
}

// ─── APP CARD WIDGET ─────────────────────────────────────────────────────────
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = color ??
        (isDark ? AppColors.darkSurface : AppColors.surface);
    final borderColor =
        isDark ? AppColors.darkBorder : AppColors.border;
    final shadowColor =
        isDark ? const Color(0x40000000) : const Color(0x08000000);

    // ── Push context-aware text colors so every Text inside
    //    this card automatically uses the right dark/light color
    //    without needing ...Of(context) calls in every screen. ──
    final primaryTextColor =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final secondaryTextColor =
        isDark ? AppColors.darkTextSecond : AppColors.textSecond;
    final hintTextColor =
        isDark ? AppColors.darkTextHint : AppColors.textHint;

    return Semantics(
      container: true,
      child: DefaultTextStyle(
        // Primary text color as the baseline for all Text widgets in the card.
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: primaryTextColor,
        ),
        child: IconTheme(
          // Icons inside the card also inherit dark-aware color
          data: IconThemeData(
            color: isDark ? AppColors.darkTextHint : AppColors.textHint,
          ),
          child: Material(
            color: cardColor,
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
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: padding ?? AppSpacing.cardPadding,
                // Provide secondary & hint colors via an InheritedTheme
                // so that AppTextStyles.body / .micro also resolve correctly
                // when used with .copyWith(color: null).
                child: _CardTextTheme(
                  primaryColor: primaryTextColor,
                  secondaryColor: secondaryTextColor,
                  hintColor: hintTextColor,
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Provides the three card-level text colors down the widget tree.
/// AppTextStyles static getters now omit their hardcoded color so
/// they inherit from DefaultTextStyle (primary).  Callers that want
/// the secondary or hint shade should still use ...Of(context).
class _CardTextTheme extends StatelessWidget {
  final Color primaryColor;
  final Color secondaryColor;
  final Color hintColor;
  final Widget child;

  const _CardTextTheme({
    required this.primaryColor,
    required this.secondaryColor,
    required this.hintColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Re-apply primary as DefaultTextStyle so Text() with no explicit style picks it up.
    return DefaultTextStyle.merge(
      style: TextStyle(color: primaryColor),
      child: child,
    );
  }
}

// ─── SECTION HEADER WIDGET ───────────────────────────────────────────────────
class AppSectionHeader extends StatelessWidget {
  final String title;
  final EdgeInsetsGeometry? padding;

  const AppSectionHeader(this.title, {super.key, this.padding});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(top: 28, bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.sectionLabelOf(context),
      ),
    );
  }
}

// ─── SCREEN TITLE WIDGET ─────────────────────────────────────────────────────
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
          Text(title, style: AppTextStyles.screenTitleOf(context)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: AppTextStyles.bodyOf(context)),
          ],
        ],
      ),
    );
  }
}

// ─── PRIMARY BUTTON ──────────────────────────────────────────────────────────
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

// ─── ICON BADGE ──────────────────────────────────────────────────────────────
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // In dark mode use a slightly more opaque tint so the badge is visible
    final bgOpacity = isDark ? 0.18 : 0.10;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: bgOpacity),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: size),
    );
  }
}

// ─── STANDARD APP BAR ────────────────────────────────────────────────────────
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppBar(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
      foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: centerTitle,
      leading: leading,
      actions: actions,
      title: Text(title, style: AppTextStyles.appBarTitle.copyWith(
        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
      )),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(
          height: 1,
          thickness: 1,
          color: isDark ? AppColors.darkDivider : AppColors.divider,
        ),
      ),
    );
  }
}

// ─── LIGHT THEME DATA ────────────────────────────────────────────────────────
ThemeData buildAppTheme() {
  const seed = AppColors.teal;
  final interTextTheme = GoogleFonts.interTextTheme();

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: seed,
      primary: AppColors.teal,
      secondary: AppColors.tealDark,
      surface: AppColors.surface,
      error: AppColors.danger,
      brightness: Brightness.light,
    ),
    textTheme: interTextTheme,
    primaryTextTheme: interTextTheme,
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: false,
      titleTextStyle: AppTextStyles.appBarTitle.copyWith(color: AppColors.textPrimary),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.navBg,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.navBg,
      indicatorColor: AppColors.navIndicator,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.tealDark);
        }
        return GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textHint);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.tealDark, size: 24);
        }
        return const IconThemeData(color: AppColors.textHint, size: 22);
      }),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        textStyle: AppTextStyles.button,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: const Size(double.infinity, 48),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.teal,
        side: const BorderSide(color: AppColors.teal),
        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: const Size(double.infinity, 48),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.teal,
        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.background,
      hintStyle: GoogleFonts.inter(color: AppColors.textHint, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.teal, width: 1.5)),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.teal,
      thumbColor: AppColors.teal,
      inactiveTrackColor: AppColors.tealLight,
      overlayColor: AppColors.teal.withValues(alpha: 0.12),
      trackHeight: 3,
    ),
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
    dividerTheme: const DividerThemeData(color: AppColors.divider, thickness: 1, space: 1),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      contentTextStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecond, height: 1.5),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.textPrimary,
      contentTextStyle: GoogleFonts.inter(color: Colors.white, fontSize: 13),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.background,
      labelStyle: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecond),
      side: const BorderSide(color: AppColors.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
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

// ─── DARK THEME DATA ─────────────────────────────────────────────────────────
ThemeData buildDarkTheme() {
  const seed = AppColors.teal;
  final interTextTheme = GoogleFonts.interTextTheme(
    ThemeData(brightness: Brightness.dark).textTheme,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: seed,
      primary: AppColors.teal,
      secondary: AppColors.tealDark,
      surface: AppColors.darkSurface,
      error: const Color(0xFFEF5350),
      brightness: Brightness.dark,
    ),
    textTheme: interTextTheme,
    primaryTextTheme: interTextTheme,
    scaffoldBackgroundColor: AppColors.darkBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      foregroundColor: AppColors.darkTextPrimary,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.darkTextPrimary,
        letterSpacing: -0.3,
      ),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.darkNavBg,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.darkNavBg,
      indicatorColor: AppColors.darkNavIndicator,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.teal);
        }
        return GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.darkTextHint);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.teal, size: 24);
        }
        return const IconThemeData(color: AppColors.darkTextHint, size: 22);
      }),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        textStyle: AppTextStyles.button,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: const Size(double.infinity, 48),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.teal,
        side: const BorderSide(color: AppColors.teal),
        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: const Size(double.infinity, 48),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.teal,
        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface2,
      hintStyle: GoogleFonts.inter(color: AppColors.darkTextHint, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.teal, width: 1.5)),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.teal,
      thumbColor: AppColors.teal,
      inactiveTrackColor: AppColors.darkTealLight,
      overlayColor: AppColors.teal.withValues(alpha: 0.16),
      trackHeight: 3,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.teal;
        return AppColors.darkTextSecond;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.darkTealLight;
        return AppColors.darkSurface2;
      }),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.darkDivider, thickness: 1, space: 1),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.darkTextPrimary),
      contentTextStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.darkTextSecond, height: 1.5),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.darkSurface2,
      contentTextStyle: GoogleFonts.inter(color: AppColors.darkTextPrimary, fontSize: 13),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.darkSurface2,
      labelStyle: GoogleFonts.inter(fontSize: 12, color: AppColors.darkTextSecond),
      side: BorderSide(color: AppColors.darkBorder),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.darkBorder),
      ),
      margin: EdgeInsets.zero,
    ),
  );
}
