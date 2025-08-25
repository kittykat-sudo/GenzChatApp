import 'package:flutter/material.dart';
import 'package:chat_drop/core/theme/app_colors.dart';
import 'package:chat_drop/core/theme/app_text_styles.dart';

/// A reusable text field widget with a retro theme, including a drop shadow.
class RetroTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const RetroTextField({
    super.key,
    required this.controller,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryYellow,
        // Use BorderRadius.only to specify which corners are rounded
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(0),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16), // Less rounded corner
        ),
        border: Border.all(color: AppColors.border, width: 2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.border,
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, fontSize: 18),
        decoration: InputDecoration(
          hintText: hintText,
          // Remove the default border from the TextField
          border: InputBorder.none,
          // Ensure there's no underline or other borders when focused
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          // Add some internal padding
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
