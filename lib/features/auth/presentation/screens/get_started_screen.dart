import 'package:chat_drop/core/theme/app_colors.dart';
import 'package:chat_drop/core/theme/app_text_styles.dart';
import 'package:chat_drop/core/widgets/retro_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          margin: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: AppColors.retroPink,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border, width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 20.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 30),
                // Logo Section
                SizedBox(
                  width: 120,
                  height: 120,
                  child: SvgPicture.asset(
                    'assets/images/logo.svg',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 6),

                // App Name
                const Text('ChatDrop', style: AppTextStyles.headingXL),
                const SizedBox(height: 40),

                Expanded(
                  flex: 5,
                  child: Lottie.asset(
                    'assets/lotties/8-bit_Cat.json',
                    fit: BoxFit.contain,
                    repeat: true,
                  ),
                ),

                const SizedBox(height: 60),
                SizedBox(
                  width: 250, // set a max width you want
                  child: Text(
                    'Scan. Connect. Relive the Retro.',
                    style: AppTextStyles.heading,
                    textAlign: TextAlign.center,
                  ),
                ),
                const Spacer(),
                RetroButton(
                  text: "Get Started >",
                  onPressed: () {
                    context.push('/name-registration');
                  },
                  backgroundColor: AppColors.accentPink,
                  width: double.infinity,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
