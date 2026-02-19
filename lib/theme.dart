import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Qatar Airways Brand Colors - Refined
  static const Color burgundy = Color(0xFF8A1538); // Oryx Burgundy
  static const Color burgundyLight = Color(0xFFAA1B45);
  static const Color burgundyDark = Color(0xFF630F28);

  static const Color gold = Color(0xFFC5A059); // Premium Gold
  static const Color goldLight = Color(0xFFD4AF37);
  static const Color goldDark = Color(0xFFA68545);

  static const Color offWhite = Color(0xFFFAFAF9);
  static const Color darkGrey = Color(0xFF1C1C1E);
  static const Color silver = Color(0xFFE5E5EA);

  // Luxury Accent Colors
  static const Color glassWhite = Color(0xB3FFFFFF);
  static const Color glassBurgundy = Color(0x1A8A1538);

  // Functional colors
  static const Color success = Color(0xFF15803D);
  static const Color error = Color(0xFFB91C1C);
  static const Color warning = Color(0xFFB45309);
}

class AppTheme {
  static TextTheme get _textTheme =>
      GoogleFonts.plusJakartaSansTextTheme().copyWith(
        headlineLarge: GoogleFonts.plusJakartaSans(
          color: AppColors.burgundy,
          fontWeight: FontWeight.w900,
          letterSpacing: -1.0,
          fontSize: 32,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          color: AppColors.burgundy,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          color: AppColors.burgundy,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          color: AppColors.darkGrey,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          color: AppColors.darkGrey,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          color: AppColors.darkGrey,
          fontWeight: FontWeight.w400,
          fontSize: 14,
        ),
        labelLarge: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          fontSize: 12,
        ),
        labelSmall: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          fontSize: 10,
        ),
      );

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.burgundy,
        primary: AppColors.burgundy,
        secondary: AppColors.gold,
        surface: AppColors.offWhite,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
      ),
      textTheme: _textTheme,
      scaffoldBackgroundColor: AppColors.offWhite,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.burgundy,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 16,
          letterSpacing: 1.0,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: AppColors.silver.withOpacity(0.5)),
        ),
        color: Colors.white,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 10,
        shadowColor: Colors.black.withOpacity(0.1),
        indicatorColor: AppColors.burgundy.withOpacity(0.1),
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return GoogleFonts.plusJakartaSans(
              color: AppColors.burgundy,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            );
          }
          return GoogleFonts.plusJakartaSans(
            color: Colors.grey[500],
            fontSize: 11,
            fontWeight: FontWeight.w500,
          );
        }),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(color: AppColors.burgundy, size: 24);
          }
          return IconThemeData(color: Colors.grey[400], size: 24);
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.silver),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.silver.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.burgundy, width: 2),
        ),
        labelStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600, color: Colors.grey[600]),
        hintStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w400, color: Colors.grey[400]),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.burgundy,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800, letterSpacing: 0.5, fontSize: 16),
        ),
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.burgundy,
        brightness: Brightness.dark,
        primary: AppColors.burgundyLight,
        secondary: AppColors.gold,
        surface: const Color(0xFF0F0F0F),
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        ThemeData(brightness: Brightness.dark).textTheme,
      ),
      scaffoldBackgroundColor: const Color(0xFF0F0F0F),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.burgundyDark,
        elevation: 0,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 16,
          letterSpacing: 1.0,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
        color: const Color(0xFF1A1A1A),
      ),
    );
  }
}
