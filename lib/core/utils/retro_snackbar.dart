import 'package:flutter/material.dart';
import 'package:chat_drop/core/theme/app_colors.dart';

enum SnackbarType { success, error, info }

/// A reusable snackbar widget with a retro theme.
class RetroSnackbar extends StatelessWidget {
  final String message;
  final SnackbarType type;

  const RetroSnackbar({super.key, required this.message, required this.type});

  // Helper method to get the right color based on the type
  Color _getBackgroundColor() {
    switch (type) {
      case SnackbarType.success:
        return AppColors.retroTeal;
      case SnackbarType.error:
        return AppColors.errorRed;
      case SnackbarType.info:
        return AppColors.retroBlue;
    }
  }

  // Helper method to get the right icon based on the type
  IconData _getIcon() {
    switch (type) {
      case SnackbarType.success:
        return Icons.check_circle_outline;
      case SnackbarType.error:
        return Icons.error_outline;
      case SnackbarType.info:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border, width: 2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.border,
            offset: Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(_getIcon(), color: AppColors.textLight, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.textLight,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A helper function to show a retro-styled snackbar.
void showRetroSnackbar({
  required BuildContext context,
  required String message,
  required SnackbarType type,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: RetroSnackbar(message: message, type: type),
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
