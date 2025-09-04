import 'package:flutter/material.dart';
import 'package:chat_drop/core/theme/app_colors.dart';
import 'package:chat_drop/core/theme/app_text_styles.dart';

class RetroPopupMenuItem {
  final String text;
  final IconData icon;
  final VoidCallback onTap;
  final Color? textColor;
  final Color? iconColor;

  const RetroPopupMenuItem({
    required this.text,
    required this.icon,
    required this.onTap,
    this.textColor,
    this.iconColor,
  });
}

class RetroPopupMenu extends StatelessWidget {
  final List<RetroPopupMenuItem> items;
  final double? width;

  const RetroPopupMenu({super.key, required this.items, this.width = 200});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: AppColors.retroMint,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.border,
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children:
            items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;

              return Column(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      item.onTap();
                    },
                    borderRadius: BorderRadius.vertical(
                      top: index == 0 ? const Radius.circular(10) : Radius.zero,
                      bottom:
                          index == items.length - 1
                              ? const Radius.circular(10)
                              : Radius.zero,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          IconTheme(
                            data: IconThemeData(
                              color: item.iconColor ?? AppColors.textDark,
                              size: 20,
                            ),
                            child: Icon(item.icon),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.text,
                              style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.w600,
                                color: item.textColor ?? AppColors.textDark,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (index < items.length - 1)
                    Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      color: AppColors.border,
                    ),
                ],
              );
            }).toList(),
      ),
    );
  }

  static void show({
    required BuildContext context,
    required List<RetroPopupMenuItem> items,
    required RelativeRect position,
    double? width,
  }) {
    showMenu(
      context: context,
      position: position,
      items: [
        PopupMenuItem(
          enabled: false,
          padding: EdgeInsets.zero,
          child: RetroPopupMenu(items: items, width: width),
        ),
      ],
      elevation: 0,
      color: Colors.transparent,
    );
  }
}
