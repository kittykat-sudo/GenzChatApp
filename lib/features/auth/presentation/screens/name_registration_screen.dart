import 'package:chat_drop/core/theme/app_colors.dart';
import 'package:chat_drop/core/theme/app_text_styles.dart';
import 'package:chat_drop/core/widgets/retro_button.dart';
import 'package:chat_drop/features/auth/widgets/retro_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class NameRegistrationScreen extends StatefulWidget {
  const NameRegistrationScreen({super.key});

  @override
  State<NameRegistrationScreen> createState() => _NameRegistrationScreenState();
}

class _NameRegistrationScreenState extends State<NameRegistrationScreen> {
  final TextEditingController nameController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

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
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    40 -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 40.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 10),
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
                      const SizedBox(height: 60),

                      // const Spacer(),
                      const SizedBox(
                        width: 250,
                        child: Text(
                          'Pick a Name to Drop In',
                          style: AppTextStyles.heading,
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 20),
                      SizedBox(
                        width: 250,
                        child: RetroTextField(
                          controller: nameController,
                          hintText: 'Enter a nickname...',
                        ),
                      ),

                      const Expanded(child: SizedBox()),
                      RetroButton(
                        text: "Join the chat  >",
                        onPressed: () {
                          // TODO: Add logic to save the name
                          context.go('/');
                        },
                        backgroundColor: AppColors.accentPink,
                        width: double.infinity,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
