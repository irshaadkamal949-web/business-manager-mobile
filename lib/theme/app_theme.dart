import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'design_tokens.dart';

class AppTheme {
  AppTheme._();

  static const Color goldAccent = Tok.gold;

  // ─── DARK THEME ─────────────────────────────────────────
  static ThemeData get darkTheme {
    final base = ThemeData.dark();
    return base.copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Tok.bg,
      primaryColor: Tok.gold,
      cardColor: Tok.card,
      dividerColor: Tok.border,
      colorScheme: const ColorScheme.dark(
        primary: Tok.gold,
        secondary: Tok.teal,
        surface: Tok.card,
        error: Tok.red,
        onPrimary: Color(0xFF0B1520),
        onSecondary: Colors.white,
        onSurface: Tok.text,
        onError: Colors.white,
      ),
      textTheme: _buildTextTheme(base.textTheme, Tok.text, Tok.text2),
      iconTheme: const IconThemeData(color: Tok.text2),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Tok.bg,
        selectedItemColor: Tok.gold,
        unselectedItemColor: Tok.text3,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.2),
        unselectedLabelStyle: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 0.2),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Tok.card2,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Tok.radiusSm),
          borderSide: const BorderSide(color: Tok.border2, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Tok.radiusSm),
          borderSide: const BorderSide(color: Tok.border2, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Tok.radiusSm),
          borderSide: const BorderSide(color: Tok.gold, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Tok.radiusSm),
          borderSide: const BorderSide(color: Tok.red, width: 1.5),
        ),
        labelStyle: const TextStyle(color: Tok.text3, fontSize: 13),
        hintStyle: const TextStyle(color: Tok.text4, fontSize: 13),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Tok.gold,
          foregroundColor: Tok.bg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 20),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.3),
          elevation: 4,
          shadowColor: const Color(0x59C8A44A),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xF50B1520),
        contentTextStyle: const TextStyle(color: Tok.text, fontSize: 12, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Tok.border2),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ─── LIGHT THEME ────────────────────────────────────────
  static ThemeData get lightTheme {
    final base = ThemeData.light();
    return base.copyWith(
      brightness: Brightness.light,
      scaffoldBackgroundColor: Tok.bgLight,
      primaryColor: Tok.gold,
      cardColor: Tok.cardLight,
      dividerColor: Tok.borderLight,
      colorScheme: const ColorScheme.light(
        primary: Tok.gold,
        secondary: Tok.teal,
        surface: Tok.cardLight,
        error: Tok.red,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Tok.textLight,
        onError: Colors.white,
      ),
      textTheme: _buildTextTheme(base.textTheme, Tok.textLight, Tok.text2Light),
      iconTheme: const IconThemeData(color: Tok.text2Light),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Tok.cardLight,
        selectedItemColor: Tok.gold,
        unselectedItemColor: Tok.text3Light,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.2),
        unselectedLabelStyle: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 0.2),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Tok.card2Light,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Tok.radiusSm),
          borderSide: const BorderSide(color: Tok.border2Light, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Tok.radiusSm),
          borderSide: const BorderSide(color: Tok.border2Light, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Tok.radiusSm),
          borderSide: const BorderSide(color: Tok.gold, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Tok.radiusSm),
          borderSide: const BorderSide(color: Tok.red, width: 1.5),
        ),
        labelStyle: const TextStyle(color: Tok.text3Light, fontSize: 13),
        hintStyle: const TextStyle(color: Tok.text4Light, fontSize: 13),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Tok.gold,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 20),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.3),
          elevation: 2,
          shadowColor: const Color(0x33C8A44A),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Tok.cardLight,
        contentTextStyle: const TextStyle(color: Tok.textLight, fontSize: 12, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Tok.borderLight),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static TextTheme _buildTextTheme(TextTheme base, Color mainColor, Color mutedColor) {
    return GoogleFonts.interTextTheme(base).copyWith(
      displayLarge: GoogleFonts.fraunces(fontSize: 28, fontWeight: FontWeight.w600, color: Tok.gold2),
      displayMedium: GoogleFonts.fraunces(fontSize: 22, fontWeight: FontWeight.w600, color: Tok.gold2, letterSpacing: 0.2),
      displaySmall: GoogleFonts.fraunces(fontSize: 18, fontWeight: FontWeight.w600, color: Tok.gold2),
      headlineLarge: GoogleFonts.fraunces(fontSize: 20, fontWeight: FontWeight.w600, color: mainColor),
      headlineMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: mainColor),
      headlineSmall: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: mainColor, letterSpacing: 0.1),
      titleLarge: GoogleFonts.fraunces(fontSize: 17, fontWeight: FontWeight.w600, color: Tok.gold2, letterSpacing: 0.3),
      titleMedium: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: mainColor, letterSpacing: 0.1),
      titleSmall: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: mutedColor),
      bodyLarge: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400, color: mainColor),
      bodyMedium: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: mutedColor),
      bodySmall: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w400, color: mutedColor),
      labelLarge: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: mainColor, letterSpacing: 0.3),
      labelMedium: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: mutedColor, letterSpacing: 0.4),
      labelSmall: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: mutedColor, letterSpacing: 0.9),
    );
  }
}
