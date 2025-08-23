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
    surface: AppColors.background,
    primary: AppColors.retroBlue,
  ),

  // AppBar Theme
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.retroBlue,
    foregroundColor: AppColors.textLight,
    elevation: 0,
    titleTextStyle: AppTextStyles.heading,
  ),

  // Text Theme
  textTheme: const TextTheme(
    displayLarge: AppTextStyles.heading,
    headlineMedium: AppTextStyles.subHeading,
    bodyMedium: AppTextStyles.body,
    labelLarge: AppTextStyles.button,
  ),

  // Input Decoration Theme (for TextFields)
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.primaryYellow,
    hintStyle: AppTextStyles.hint,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.border, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.border, width: 2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.retroBlue, width: 2),
    ),
  ),

  // Floating Action Button Theme
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.retroOrange,
    foregroundColor: AppColors.textLight,
  ),
);
