import 'package:flutter/material.dart';
import 'package:chat_drop/core/theme/app_colors.dart';

class RetroButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final IconData? icon;
  final Widget? child;

  const RetroButton({
    super.key,
    this.text = '',
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.icon,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Check if this is an icon-only button
    bool isIconOnly = text.isEmpty && icon != null;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.accentPink,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border, width: 3),
        boxShadow: [
          BoxShadow(
            color: AppColors.border,
            offset: const Offset(4, 4),
            blurRadius: 0,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child:
              isIconOnly
                  ? Center(
                    // Center the icon for icon-only buttons
                    child: Icon(
                      icon,
                      color: textColor ?? AppColors.textDark,
                      size: 24,
                    ),
                  )
                  : Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),

                    // Check if a child is provide
                    child:
                        child ??
                        (isIconOnly
                            ? Center(
                              child: Icon(
                                icon,
                                color: textColor ?? AppColors.textDark,
                                size: 24,
                              ),
                            )
                            : Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (icon != null) ...[
                                  Icon(
                                    icon,
                                    color: textColor ?? AppColors.textDark,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                if (text.isNotEmpty)
                                  Text(
                                    text,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: textColor ?? AppColors.textDark,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                              ],
                            )),
                  ),
        ),
      ),
    );
  }
}
