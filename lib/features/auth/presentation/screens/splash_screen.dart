import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:chat_drop/core/theme/app_colors.dart';
import 'package:chat_drop/core/theme/app_text_styles.dart';
import 'package:chat_drop/core/widgets/retro_loading_indicator.dart';
import 'package:chat_drop/features/auth/presentation/providers/auth_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    try {
      // Add small delay for better UX
      await Future.delayed(const Duration(milliseconds: 1500));

      if (!mounted) return;

      // Try auto-login
      await ref.read(authActionsProvider).autoLogin();

      if (!mounted) return;

      // Check login state and navigate accordingly
      final isLoggedIn = ref.read(isLoggedInProvider);

      if (isLoggedIn) {
        context.go('/');
      } else {
        context.go('/get-started');
      }
    } catch (e) {
      print('Error checking auth state: $e');
      if (mounted) {
        context.go('/get-started');
      }
    }
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                SizedBox(
                  width: 120,
                  height: 120,
                  child: SvgPicture.asset(
                    'assets/images/logo.svg',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),
        
                // App Name
                const Text('ChatDrop', style: AppTextStyles.headingXL),
                const SizedBox(height: 40),
        
                // Loading indicator
                const RetroLoadingIndicator(),
                const SizedBox(height: 20),
        
                const Text('Loading...', style: AppTextStyles.body),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
