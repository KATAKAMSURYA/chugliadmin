import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFBAC3FF),
        onPrimary: Color(0xFF08218A),
        primaryContainer: Color(0xFF3F51B5),
        onPrimaryContainer: Color(0xFFCACFFF),
        secondary: Color(0xFF50DAD1),
        onSecondary: Color(0xFF003734),
        secondaryContainer: Color(0xFF00B0A8),
        onSecondaryContainer: Color(0xFF003C39),
        error: Color(0xFFFFB4AB),
        onError: Color(0xFF690005),
        surface: Color(0xFF131313),
        onSurface: Color(0xFFE5E2E1),
        onSurfaceVariant: Color(0xFFC5C5D4),
        surfaceContainerHighest: Color(0xFF353534), // For borders/dividers
      ),
      scaffoldBackgroundColor: const Color(0xFF131313),
      cardTheme: CardThemeData(
        color: const Color(0xFF201F1F),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF353534), width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF201F1F),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF353534), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF353534), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF50DAD1), width: 2),
        ),
        labelStyle: GoogleFonts.inter(color: const Color(0xFFC5C5D4)),
        hintStyle: GoogleFonts.inter(color: const Color(0xFF8F909E)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFBAC3FF),
          foregroundColor: const Color(0xFF08218A),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF50DAD1),
          side: const BorderSide(color: Color(0xFF50DAD1)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF353534),
        thickness: 1,
        space: 1,
      ),
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.64, color: Color(0xFFE5E2E1)),
          headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: -0.24, color: Color(0xFFE5E2E1)),
          headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFFE5E2E1)),
          titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFFE5E2E1)),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFFE5E2E1)),
          titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFFE5E2E1)),
          bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFFE5E2E1)),
          bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFFE5E2E1)),
          labelLarge: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.6, color: Color(0xFFE5E2E1)),
          labelMedium: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFFE5E2E1)),
        ),
      ),
    );
  }
}
