import 'package:flutter/material.dart';

// ─── StoneGuard Brand Colors ───────────────────────────────────
// ONE place to change any color in the whole app.

class AppColors {
  AppColors._();

  // Primary accent — teal (trust, health, calm)
  static const Color primary        = Color(0xFF1A8A9A);
  static const Color primaryLight   = Color(0xFFE4F4F6); // teal tint for backgrounds
  static const Color primaryMuted   = Color(0xFF0E6B78); // darker teal for pressed states

  // Semantic status colors (used ONLY for their specific meaning)
  static const Color success        = Color(0xFF2E7D32); // green  → safe / good / stone passed
  static const Color warning        = Color(0xFFE65100); // orange → caution / symptoms
  static const Color danger         = Color(0xFFC62828); // red    → severe pain / danger zone ONLY

  // Neutral surfaces
  static const Color background     = Color(0xFFF8F8F8);
  static const Color surface        = Color(0xFFFFFFFF); // cards
  static const Color border         = Color(0xFFD0D0D8);
  static const Color appBar         = Color(0xFFE8E8EC);

  // Text
  static const Color textPrimary    = Color(0xFF2C2C2C);
  static const Color textMuted      = Color(0xFF888888);
  static const Color textFaint      = Color(0xFFBBBBBB);
}

// ─── StoneGuard Text Styles ────────────────────────────────────
// Use these instead of raw TextStyle() everywhere.

class AppTextStyles {
  AppTextStyles._();

  // Screen titles (top of each tab/screen)
  static const TextStyle screenTitle = TextStyle(
    color: AppColors.textPrimary,
    fontWeight: FontWeight.bold,
    fontSize: 20,
    letterSpacing: -0.3,
  );

  // Section header labels (e.g. "DAILY GOALS", "ABOUT")
  static const TextStyle sectionHeader = TextStyle(
    color: AppColors.textMuted,
    fontWeight: FontWeight.w600,
    fontSize: 11,
    letterSpacing: 0.9,
  );

  // Card title / form label
  static const TextStyle cardTitle = TextStyle(
    color: AppColors.textPrimary,
    fontWeight: FontWeight.bold,
    fontSize: 15,
  );

  // Body text inside cards
  static const TextStyle body = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 14,
    height: 1.6,
  );

  // Muted label (e.g. "Pain Level", "Side")
  static const TextStyle label = TextStyle(
    color: AppColors.textMuted,
    fontWeight: FontWeight.w600,
    fontSize: 13,
  );

  // Tiny metadata (dates, counts)
  static const TextStyle meta = TextStyle(
    color: AppColors.textMuted,
    fontSize: 11,
  );
}

// ─── Shared Card Decoration ────────────────────────────────────
// Use AppStyles.card() on any Container that should look like a card.

class AppStyles {
  AppStyles._();

  static BoxDecoration card({double radius = 16}) => BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: AppColors.border),
    boxShadow: const [
      BoxShadow(
        color: Color(0x0A000000), // ~4% black
        blurRadius: 10,
        offset: Offset(0, 3),
      ),
    ],
  );

  // Primary teal button style
  static ButtonStyle primaryButton({double radius = 12}) =>
      ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      );
}