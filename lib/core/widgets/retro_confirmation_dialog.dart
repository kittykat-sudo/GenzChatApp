import 'package:flutter/material.dart';
import 'package:chat_drop/core/theme/app_colors.dart';
import 'package:chat_drop/core/theme/app_text_styles.dart';
import 'package:chat_drop/core/widgets/retro_button.dart';

class RetroConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final Color confirmButtonColor;
  final Color cancelButtonColor;

  const RetroConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    this.onCancel,
    this.confirmText = 'Yes',
    this.cancelText = 'Cancel',
    this.confirmButtonColor = AppColors.errorRed,
    this.cancelButtonColor = AppColors.textGrey,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.retroPink,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 3),
          boxShadow: const [
            BoxShadow(
              color: AppColors.border,
              offset: Offset(6, 6),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              title,
              style: AppTextStyles.heading.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Message
            Text(
              message,
              style: AppTextStyles.body.copyWith(
                fontSize: 16,
                color: AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: RetroButton(
                    text: cancelText,
                    onPressed:
                        onCancel ?? () => Navigator.of(context).pop(false),
                    backgroundColor: cancelButtonColor,
                    textColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RetroButton(
                    text: confirmText,
                    onPressed: () {
                      Navigator.of(context).pop(true);
                      onConfirm();
                    },
                    backgroundColor: confirmButtonColor,
                    textColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
    String confirmText = 'Yes',
    String cancelText = 'Cancel',
    Color confirmButtonColor = AppColors.errorRed,
    Color cancelButtonColor = AppColors.textGrey,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder:
          (context) => RetroConfirmationDialog(
            title: title,
            message: message,
            onConfirm: onConfirm,
            onCancel: onCancel,
            confirmText: confirmText,
            cancelText: cancelText,
            confirmButtonColor: confirmButtonColor,
            cancelButtonColor: cancelButtonColor,
          ),
    );
  }
}
