import 'package:flutter/material.dart';

/// QueX Customer welcome/login — clean light green brand.
class CustomerAuthColors {
  static const background = Color(0xFFF8FAF5);
  static const surface = Color(0xFFFFFFFF);
  static const primary = Color(0xFF4CAF50);
  static const primaryDark = Color(0xFF2E7D32);
  static const teal = Color(0xFF00897B);
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF6B7280);
  static const divider = Color(0xFFE5E7EB);
  static const salonTint = Color(0xFFE8F5E9);
  static const clinicTint = Color(0xFFE0F2F1);
}

class CustomerAuthTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: CustomerAuthColors.background,
      colorScheme: const ColorScheme.light(
        primary: CustomerAuthColors.primary,
        secondary: CustomerAuthColors.teal,
        surface: CustomerAuthColors.surface,
        onPrimary: Colors.white,
        onSurface: CustomerAuthColors.textPrimary,
      ),
      fontFamily: 'Roboto',
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CustomerAuthColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: CustomerAuthColors.textPrimary,
          side: const BorderSide(color: CustomerAuthColors.divider),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CustomerAuthColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: CustomerAuthColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: CustomerAuthColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: CustomerAuthColors.primary, width: 2),
        ),
      ),
    );
  }
}
