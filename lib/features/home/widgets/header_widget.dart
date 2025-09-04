import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:chat_drop/core/theme/app_colors.dart';
import 'package:chat_drop/core/theme/app_text_styles.dart';
import 'package:chat_drop/core/widgets/retro_button.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, right: 20.0, bottom: 20.0, left: 20.0),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/images/logo.svg',
            width: 55,
            height: 55,
            fit: BoxFit.contain,
            placeholderBuilder:
                (context) => const Icon(
                  Icons.chat_bubble_outline,
                  color: Color.fromARGB(0, 51, 51, 51),
                  size: 50,
                ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('ChatDrop', style: AppTextStyles.headingXL),
          ),
          RetroButton(
            text: '',
            icon: Icons.edit,
            onPressed: () {
              context.push('/edit-name');
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
