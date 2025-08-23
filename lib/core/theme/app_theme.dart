import 'package:chat_drop/core/theme/app_colors.dart';
import 'package:chat_drop/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

final appTheme = ThemeData(
  fontFamily: "ZillaSlab",
  // Core Colors
  scaffoldBackgroundColor: AppColors.background,
  primaryColor: AppColors.retroBlue,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.retroBlue,
    primary: AppColors.retroBlue,
  ),

  // AppBar Theme
  appBarTheme: const AppBarTheme(titleTextStyle: AppTextStyles.heading),

  // Text Theme
  textTheme: const TextTheme(labelLarge: AppTextStyles.button),

  // Input Decoration Theme (for TextFields)
  inputDecorationTheme: InputDecorationTheme(
    // Your existing input decoration theme
  ),

  // Elevated Button Theme - Retro Style
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.accentPink,
      foregroundColor: AppColors.textDark,
      elevation: 0,
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        fontFamily: "ZillaSlab",
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.border, width: 3),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    ).copyWith(
      shadowColor: WidgetStateProperty.all(AppColors.border),
      elevation: WidgetStateProperty.resolveWith<double>((states) {
        if (states.contains(WidgetState.pressed)) return 0;
        return 0;
      }),
    ),
  ),

  // Outlined Button Theme - Alternative Style
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      backgroundColor: AppColors.primaryYellow,
      foregroundColor: AppColors.textDark,
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        fontFamily: "ZillaSlab",
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: const BorderSide(color: AppColors.border, width: 3),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    ),
  ),

  // Floating Action Button Theme
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.retroBlue,
    foregroundColor: AppColors.textLight,
  ),
);
