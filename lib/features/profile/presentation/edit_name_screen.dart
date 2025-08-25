import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:chat_drop/core/theme/app_colors.dart';
import 'package:chat_drop/core/theme/app_text_styles.dart';
import 'package:chat_drop/core/widgets/retro_button.dart';
import 'package:chat_drop/core/widgets/retro_text_field.dart';
import 'package:chat_drop/core/widgets/retro_typing_dots.dart';
import 'package:chat_drop/core/utils/retro_snackbar.dart';

class EditNameScreen extends StatefulWidget {
  const EditNameScreen({super.key});

  @override
  State<EditNameScreen> createState() => _EditNameScreenState();
}

class _EditNameScreenState extends State<EditNameScreen> {
  final TextEditingController nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      showRetroSnackbar(
        context: context,
        message: "Error 404: Name Not Found.",
        type: SnackbarType.error,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Save the name logic here
      print('Saving name: $name');

      if (mounted) {
        showRetroSnackbar(
          context: context,
          message: "Name updated successfully!",
          type: SnackbarType.success,
        );
        context.pop(); // Return to previous screen
      }
    } catch (e) {
      if (mounted) {
        showRetroSnackbar(
          context: context,
          message: "Failed to update name: $e",
          type: SnackbarType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
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
                          const SizedBox(height: 10),

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
                          const Text(
                            'ChatDrop',
                            style: AppTextStyles.headingXL,
                          ),
                          const SizedBox(height: 60),

                          // Middle section
                          const SizedBox(
                            width: 250,
                            child: Text(
                              'Pick a new name :)',
                              style: AppTextStyles.heading,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Name input section
                          SizedBox(
                            width: 250,
                            child: RetroTextField(
                              controller: nameController,
                              hintText: 'Enter a nickname...',
                            ),
                          ),

                          const Expanded(child: SizedBox()),

                          // Save button section
                          RetroButton(
                            text: "Save >",
                            onPressed: _isLoading ? null : _saveName,
                            backgroundColor: AppColors.accentPink,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Retro Loading Overlay
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.7),
            child: const Center(
              child: RetroTypingDots(
                dotSize: 15,
                dotCount: 4,
                loadingText: 'Saving',
              ),
            ),
          ),
      ],
    );
  }
}