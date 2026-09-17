import 'package:flutter/material.dart';
import '../../features/auth/domain/entities/user_role.dart';

/// Design tokens and role-specific color systems
class AppTheme {
  AppTheme._();

  // Role Color Palettes
  static const Color adminPrimary = Color(0xFF0F172A); // Slate 900
  static const Color adminAccent = Color(0xFFD97706);  // Amber 600
  static const Color adminSurface = Color(0xFFF8FAFC);

  static const Color teacherPrimary = Color(0xFF065F46); // Emerald 800
  static const Color teacherAccent = Color(0xFF059669);  // Emerald 600
  static const Color teacherSurface = Color(0xFFF0FDF4);

  static const Color parentPrimary = Color(0xFF312E81); // Indigo 900
  static const Color parentAccent = Color(0xFF4F46E5);  // Indigo 600
  static const Color parentSurface = Color(0xFFEEF2FF);

  static const Color studentPrimary = Color(0xFF0369A1); // Sky 700
  static const Color studentAccent = Color(0xFF0284C7);  // Sky 600
  static const Color studentSurface = Color(0xFFF0F9FF);

  // Neutral Colors
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color background = Color(0xFFF8FAFC);
  static const Color cardBg = Colors.white;
  static const Color errorRed = Color(0xFFDC2626);
  static const Color successGreen = Color(0xFF16A34A);

  static Color getPrimaryColorForRole(UserRole? role) {
    switch (role) {
      case UserRole.admin:
        return adminPrimary;
      case UserRole.teacher:
        return teacherPrimary;
      case UserRole.parent:
        return parentPrimary;
      case UserRole.student:
        return studentPrimary;
      case null:
        return const Color(0xFF1E3A8A);
    }
  }

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1E3A8A),
      primary: const Color(0xFF1E3A8A),
      surface: cardBg,
      error: errorRed,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: Colors.white,
      foregroundColor: textDark,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: textDark,
      ),
    ),
    cardTheme: CardThemeData(
      color: cardBg,
      elevation: 1.5,
      shadowColor: Colors.black.withOpacity(0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorRed),
      ),
    ),
  );
}
