import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFF0A0A0C);
  static const card = Color(0xFF16161A);
  static const cardAlt = Color(0xFF1F1F24);
  static const border = Color(0xFF2E2E35);
  static const red = Color(0xFFE8363C);
  static const redDark = Color(0xFF6E1216);
  static const teal = Color(0xFF1E8C8C);
  static const tealDark = Color(0xFF0C3538);
  static const muted = Color(0xFF9A9AA3);
}

ThemeData buildTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  OutlineInputBorder outline(Color c) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: c),
      );

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.red,
      secondary: AppColors.red,
      surface: AppColors.card,
    ),
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      filled: true,
      fillColor: AppColors.cardAlt,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: outline(AppColors.border),
      enabledBorder: outline(AppColors.border),
      focusedBorder: outline(AppColors.red),
      hintStyle: const TextStyle(color: AppColors.muted),
      suffixStyle: const TextStyle(color: AppColors.muted),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? AppColors.red : Colors.transparent,
      ),
      side: const BorderSide(color: AppColors.muted),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.red),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    dividerColor: AppColors.border,
  );
}
