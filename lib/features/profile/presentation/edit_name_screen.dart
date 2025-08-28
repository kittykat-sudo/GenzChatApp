import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_drop/core/theme/app_colors.dart';
import 'package:chat_drop/core/theme/app_text_styles.dart';
import 'package:chat_drop/core/widgets/retro_button.dart';
import 'package:chat_drop/core/widgets/retro_text_field.dart';
import 'package:chat_drop/core/widgets/retro_typing_dots.dart';
import 'package:chat_drop/core/utils/retro_snackbar.dart';
import 'package:chat_drop/features/auth/presentation/providers/auth_providers.dart';

class EditNameScreen extends ConsumerStatefulWidget {
  const EditNameScreen({super.key});

  @override
  ConsumerState<EditNameScreen> createState() => _EditNameScreenState();
}

class _EditNameScreenState extends ConsumerState<EditNameScreen> {
  final TextEditingController nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentUserName();
    });
  }

  void _loadCurrentUserName() {
    try {
      final currentUserNameAsync = ref.read(currentUserNameProvider);
      final currentName = currentUserNameAsync;
      if (mounted) {
        nameController.text = currentName as String;
      }
    } catch (e) {
      debugPrint('Error loading current user name: $e');
    }
  }

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
    if (name.length < 2) {
      showRetroSnackbar(
        context: context,
        message: "Name must be at least 2 characters long.",
        type: SnackbarType.error,
      );
      return;
    }
    if (name.length > 30) {
      showRetroSnackbar(
        context: context,
        message: "Name must be less than 30 characters.",
        type: SnackbarType.error,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authActions = ref.read(authActionsProvider);
      await authActions.updateUserName(name);

      if (mounted) {
        showRetroSnackbar(
          context: context,
          message: "Your nickname got changed!",
          type: SnackbarType.success,
        );
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) context.pop();
      }
    } catch (e) {
      if (mounted) {
        showRetroSnackbar(
          context: context,
          message: "Failed to update name: ${e.toString()}",
          type: SnackbarType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserNameAsync = ref.watch(currentUserNameStreamProvider);

    return Stack(
      // ✅ Stack wraps the whole screen
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
              child: Stack(
                children: [
                  // ✅ scrollable content
                  SingleChildScrollView(
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
                          padding: const EdgeInsets.only(
                            left: 60.0,
                            right: 20.0,
                            top: 40.0,
                            bottom: 40.0,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // logo
                              SizedBox(
                                width: 120,
                                height: 120,
                                child: SvgPicture.asset(
                                  'assets/images/logo.svg',
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 6),

                              const Text(
                                'ChatDrop',
                                style: AppTextStyles.headingXL,
                              ),
                              const SizedBox(height: 40),

                              const SizedBox(
                                width: 250,
                                child: Text(
                                  'Pick a new name :)',
                                  style: AppTextStyles.heading,
                                  textAlign: TextAlign.center,
                                ),
                              ),

                              // current name
                              currentUserNameAsync.when(
                                data: (currentName) {
                                  if (currentName != null) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        'Current: $currentName',
                                        style: AppTextStyles.body.copyWith(
                                          color: AppColors.textGrey,
                                          fontSize: 14,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                                loading: () => const SizedBox.shrink(),
                                error: (err, stack) => const SizedBox.shrink(),
                              ),

                              const SizedBox(height: 20),

                              // textfield
                              SizedBox(
                                width: 250,
                                child: RetroTextField(
                                  controller: nameController,
                                  hintText: 'Enter a nickname...',
                                  maxLength: 30,
                                  keyboardType: TextInputType.text,
                                ),
                              ),

                              const SizedBox(height: 20),

                              // char counter
                              ValueListenableBuilder<TextEditingValue>(
                                valueListenable: nameController,
                                builder: (context, value, child) {
                                  final currentLength = value.text.length;
                                  final remaining = 30 - currentLength;
                                  return Text(
                                    '$currentLength/30 characters',
                                    style: AppTextStyles.body.copyWith(
                                      color:
                                          remaining < 5
                                              ? AppColors.errorRed
                                              : AppColors.textGrey,
                                      fontSize: 12,
                                    ),
                                  );
                                },
                              ),

                              const Expanded(child: SizedBox()),

                              RetroButton(
                                text: 'Save >',
                                onPressed: _isLoading ? null : _saveName,
                                backgroundColor: AppColors.accentPink,
                                width: 150.0,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // home button
                  Positioned(
                    top: 20,
                    left: 20,
                    child: RetroButton(
                      text: '',
                      icon: Icons.home_outlined,
                      onPressed: () {
                        context.go('/');
                      },
                      backgroundColor: AppColors.accentPink,
                      width: 48,
                      height: 48,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ✅ Fullscreen loading overlay ABOVE the Scaffold
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
