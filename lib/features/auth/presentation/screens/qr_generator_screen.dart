import 'package:chat_drop/core/theme/app_colors.dart';
import 'package:chat_drop/core/theme/app_text_styles.dart';
import 'package:chat_drop/core/widgets/retro_button.dart';
import 'package:chat_drop/features/auth/presentation/providers/auth_providers.dart';
import 'package:chat_drop/features/auth/widgets/retro_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrGeneratorScreen extends ConsumerWidget {
  const QrGeneratorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the session provider to get the session ID
    final session = ref.watch(createSessionProvider);

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
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 60.0,
                  top: 40.0,
                  bottom: 40.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo Section
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: SvgPicture.asset(
                        'assets/images/logo.svg',
                        fit: BoxFit.contain,
                        placeholderBuilder:
                            (context) =>
                                const Icon(Icons.chat_bubble_outline, size: 24),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // App Name
                    const Text('ChatDrop', style: AppTextStyles.headingXL),
                    const SizedBox(height: 40),

                    // QR Code Section
                    Container(
                      width: 250,
                      height: 250,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.textLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border, width: 3),
                      ),
                      child: session.when(
                        loading:
                            () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                        error:
                            (err, stack) => Center(child: Text('Error: $err')),
                        data: (sessionId) {
                          // Display the QR code once the session ID is available
                          return QrImageView(
                            data: sessionId,
                            version: QrVersions.auto,
                            backgroundColor: Colors.transparent,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // "SCAN ME" Label
                    RetroLabel(text: "Scan me"),
                    const Spacer(),

                    // Bottom Button
                    RetroButton(
                      text: "Scan my friend's QR",
                      onPressed: () {
                        context.push('/qr-scanner');
                      },
                      backgroundColor: AppColors.accentPink,
                      width: 250.00,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
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
    );
  }
}
