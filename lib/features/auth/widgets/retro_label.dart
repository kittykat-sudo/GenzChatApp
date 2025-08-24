import 'package:flutter/material.dart';
import 'package:chat_drop/core/theme/app_colors.dart';

class RetroLabel extends StatelessWidget {
  final String text;

  const RetroLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.textDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border, width: 2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.border,
            offset: Offset(3, 3),
            blurRadius: 0,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: AppColors.textLight,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
}
