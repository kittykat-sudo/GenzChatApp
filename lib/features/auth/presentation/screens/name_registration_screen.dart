import 'package:chat_drop/core/theme/app_colors.dart';
import 'package:chat_drop/core/theme/app_text_styles.dart';
import 'package:chat_drop/core/utils/retro_snackbar.dart';
import 'package:chat_drop/core/widgets/retro_button.dart';
import 'package:chat_drop/core/widgets/retro_typing_dots.dart';
import 'package:chat_drop/features/auth/presentation/providers/auth_providers.dart';
import 'package:chat_drop/features/auth/widgets/retro_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class NameRegistrationScreen extends ConsumerStatefulWidget {
  const NameRegistrationScreen({super.key});

  @override
  ConsumerState<NameRegistrationScreen> createState() =>
      _NameRegistrationScreenState();
}

class _NameRegistrationScreenState
    extends ConsumerState<NameRegistrationScreen> {
  final TextEditingController nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  // Register a new user annoymously and setting user's name
  Future<void> _registerUser() async {
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
      final authRepository = ref.read(authRepositoryProvider);
      final userCredential = await authRepository.signInAnonymously();
      await authRepository.registerUserName(name);
      print("UID: ${userCredential.user?.uid}, Name: $name");

      if (mounted) {
        showRetroSnackbar(
          context: context,
          message: "Welcome, $name!",
          type: SnackbarType.success,
        );
        context.go('/');
      }
    } catch (e) {
      // Show error if registration failed.
      if (mounted) {
        showRetroSnackbar(
          context: context,
          message: "Failed to register: $e",
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
                              'Pick a Name to Drop In',
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

                          // Register button section
                          RetroButton(
                            text: "Join the chat  >",
                            onPressed: _isLoading ? null : _registerUser,
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
              child: RetroTypingDots(dotSize: 15, dotCount: 4, loadingText: 'Loading',),
            ),
          ),
      ],
    );
  }
}
