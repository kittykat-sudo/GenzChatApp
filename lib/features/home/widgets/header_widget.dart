import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:chat_drop/core/theme/app_colors.dart';
import 'package:chat_drop/core/theme/app_text_styles.dart';
import 'package:chat_drop/core/theme/retro_button.dart'; // Add this import

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SvgPicture.asset(
                'assets/images/logo.png',
                width: 32,
                height: 32,
                fit: BoxFit.contain,
                colorFilter: const ColorFilter.mode(
                  AppColors.textDark,
                  BlendMode.srcIn,
                ),
                placeholderBuilder:
                    (context) => const Icon(
                      Icons.chat_bubble_outline,
                      color: AppColors.textDark,
                      size: 24,
                    ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(child: Text('ChatDrop', style: AppTextStyles.heading)),
          RetroButton(
            text: '',
            icon: Icons.qr_code,
            onPressed: () {
              print('QR button pressed'); // Add this debug line
              context.push('/qr');
            },
            backgroundColor: AppColors.accentPink,
            width: 48,
            height: 48,
          ),
        ],
      ),
    );
  }
}
