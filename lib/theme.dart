import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ShuttleTheme {
  // Glow Color Palette (Inspired by Slay or Sashay poster)
  static const Color neonPink = Color(0xFFFF1A75); // Neon Pink
  static const Color neonTeal = Color(0xFF00E5FF); // Neon Teal/Cyan
  static const Color neonYellow = Color(0xFFFFB700); // Neon Yellow/Orange
  
  // Theme Color System
  static const Color primary = neonPink;
  static const Color primaryContainer = neonTeal;
  static const Color secondary = Color(0xFF94A3B8); // Cool Slate Text
  static const Color secondaryContainer = Color(0xFF1E293B);
  static const Color tertiary = neonYellow;
  
  // Backgrounds (Translucent Glass / Deep Obsidian)
  static const Color background = Color(0xFF06070C); // Pitch Black/Obsidian
  static const Color surface = Color(0xFF0F111A); // Dark Card Base
  static const Color surfaceBright = Color(0xFF161926);
  static const Color surfaceDim = Color(0xFF08090E);
  static const Color surfaceContainerLowest = Color(0xFF121420); // Glass card fill
  static const Color surfaceContainerLow = Color(0xFF1B1E2E);
  static const Color surfaceContainer = Color(0xFF24293F);
  static const Color surfaceContainerHigh = Color(0xFF2D334F);
  static const Color surfaceContainerHighest = Color(0xFF3B4366);

  // On-Colors
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF06070C);
  static const Color onSecondary = Color(0xFF06070C);
  static const Color onSecondaryContainer = Color(0xFFF1F5F9);
  static const Color onTertiary = Color(0xFF06070C);
  static const Color onBackground = Color(0xFFF8FAFC); // Crisp off-white
  static const Color onSurface = Color(0xFFF8FAFC);
  static const Color onSurfaceVariant = Color(0xFF94A3B8);
  static const Color onSecondaryFixed = Color(0xFFF8FAFC);

  // Borders & Glow Accents
  static const Color outline = Color(0xFF334155); // Muted Dark Border
  static const Color outlineVariant = Color(0x3300E5FF); // Cyber Teal faint border

  // Spacing Units
  static const double baseSpacing = 4.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double gutter = 16.0;
  static const double marginMobile = 16.0;
  static const double marginDesktop = 48.0;

  // BorderRadius
  static const double radiusSmall = 6.0;
  static const double radiusDefault = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  static const double radiusFull = 9999.0;

  // Typography (Inter with bold, neon-ready contrast)
  static TextStyle get headlineLg => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w900,
        height: 40 / 32,
        letterSpacing: -0.02 * 32,
        color: onBackground,
      );

  static TextStyle get headlineLgMobile => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w900,
        height: 32 / 24,
        letterSpacing: -0.01 * 24,
        color: onBackground,
      );

  static TextStyle get headlineMd => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        height: 28 / 20,
        color: neonTeal,
      );

  static TextStyle get headlineSm => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 24 / 16,
        color: neonPink,
      );

  static TextStyle get bodyLg => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 24 / 16,
        color: onBackground,
      );

  static TextStyle get bodyMd => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
        color: onBackground,
      );

  static TextStyle get bodySm => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 16 / 12,
        color: onSurfaceVariant,
      );

  static TextStyle get labelCaps => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        height: 16 / 11,
        letterSpacing: 0.08 * 11,
        color: neonYellow,
      );

  // Theme definition
  static ThemeData get lightThemeData {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark, // Crucial for dark glassmorphism
      colorScheme: const ColorScheme.dark(
        primary: primary,
        primaryContainer: primaryContainer,
        secondary: secondary,
        secondaryContainer: secondaryContainer,
        tertiary: tertiary,
        background: background,
        surface: surface,
        onPrimary: onPrimary,
        onSecondary: onSecondary,
        onSurface: onSurface,
        onBackground: onBackground,
        outline: outline,
        outlineVariant: outlineVariant,
      ),
      scaffoldBackgroundColor: background,
      textTheme: TextTheme(
        headlineLarge: headlineLg,
        headlineMedium: headlineMd,
        headlineSmall: headlineSm,
        bodyLarge: bodyLg,
        bodyMedium: bodyMd,
        bodySmall: bodySm,
      ),
      fontFamily: 'Inter',
    );
  }
}
