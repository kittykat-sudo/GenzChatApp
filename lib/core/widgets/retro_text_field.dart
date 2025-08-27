import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chat_drop/core/theme/app_colors.dart';
import 'package:chat_drop/core/theme/app_text_styles.dart';

/// A reusable text field widget with a retro theme, including a drop shadow.
class RetroTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int? maxLength;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final bool enabled;

  const RetroTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.maxLength,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.onChanged,
    this.validator,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:
            enabled
                ? AppColors.primaryYellow
                : AppColors.primaryYellow.withOpacity(0.5),
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
        style: AppTextStyles.body.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: enabled ? AppColors.textDark : AppColors.textGrey,
        ),
        keyboardType: keyboardType,
        obscureText: obscureText,
        enabled: enabled,
        onChanged: onChanged,
        maxLength: maxLength,
        inputFormatters:
            maxLength != null
                ? [LengthLimitingTextInputFormatter(maxLength)]
                : null,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.body.copyWith(
            color: AppColors.textGrey,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
          suffixIcon: suffixIcon,
          // Remove the default border from the TextField
          border: InputBorder.none,
          // Ensure there's no underline or other borders when focused
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          // Add some internal padding
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
          // Hide the character counter that appears with maxLength
          counterText: "",
        ),
      ),
    );
  }
}
