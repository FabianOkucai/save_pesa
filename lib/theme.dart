import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Qatar Airways Brand Colors
  static const Color burgundy = Color(0xFF8A1538); // Oryx Burgundy
  static const Color burgundyLight = Color(0xFFAA1B45);
  static const Color burgundyDark = Color(0xFF630F28);

  static const Color gold = Color(0xFFC5A059); // Premium Gold
  static const Color goldLight = Color(0xFFD4AF37);

  static const Color offWhite = Color(0xFFF8F4F1);
  static const Color darkGrey = Color(0xFF1F1F1F);
  static const Color silver = Color(0xFFE5E4E2);

  // Functional colors
  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFFFA000);
}

class AppTheme {
  // Plus Jakarta Sans — premium, geometric, modern
  static TextTheme get _textTheme =>
      GoogleFonts.plusJakartaSansTextTheme().copyWith(
        headlineLarge: GoogleFonts.plusJakartaSans(
          color: AppColors.burgundy,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          color: AppColors.burgundy,
          fontWeight: FontWeight.w800,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          color: AppColors.burgundy,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          color: AppColors.darkGrey,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          color: AppColors.darkGrey,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          color: AppColors.darkGrey,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        labelSmall: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
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
          fontWeight: FontWeight.w900,
          fontSize: 16,
          letterSpacing: 1.5,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.white,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: AppColors.burgundy.withOpacity(0.1),
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return GoogleFonts.plusJakartaSans(
              color: AppColors.burgundy,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            );
          }
          return GoogleFonts.plusJakartaSans(
            color: Colors.grey,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          );
        }),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(color: AppColors.burgundy, size: 24);
          }
          return const IconThemeData(color: Colors.grey, size: 24);
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        hintStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w400),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800, letterSpacing: 1),
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
        surface: const Color(0xFF121212),
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        ThemeData(brightness: Brightness.dark).textTheme,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.burgundyDark,
        elevation: 0,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 16,
          letterSpacing: 1.5,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: const Color(0xFF1E1E1E),
      ),
    );
  }
}
