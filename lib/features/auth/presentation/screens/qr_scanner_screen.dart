import 'package:chat_drop/core/theme/app_colors.dart';
import 'package:chat_drop/core/theme/app_text_styles.dart';
// import 'package:chat_drop/core/widgets/retro_button.dart';
import 'package:chat_drop/features/auth/presentation/providers/auth_providers.dart';
import 'package:chat_drop/features/auth/widgets/retro_home_button.dart';
import 'package:chat_drop/features/auth/widgets/retro_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerScreen extends ConsumerWidget {
  const QrScannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  left: 30.0,
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
                      ),
                    ),
                    const SizedBox(height: 6),

                    // App Name
                    const Text('ChatDrop', style: AppTextStyles.headingXL),
                    const SizedBox(height: 10),

                    // QR Scanner Section
                    Container(
                      width: 310,
                      height: 310,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border, width: 3),
                      ),
                      // ClipRRect is used to ensure the scanner preview respects the border radius
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: MobileScanner(
                          onDetect: (capture) async {
                            final List<Barcode> barcodes = capture.barcodes;
                            if (barcodes.isNotEmpty) {
                              final String sessionId = barcodes.first.rawValue!;
                              try {
                                final authRepository = ref.read(
                                  authRepositoryProvider,
                                );
                                await authRepository.signInAnonymously();
                                await authRepository.joinSession(sessionId);
                                ref.read(sessionIdProvider.notifier).state =
                                    sessionId;
                                if (context.mounted) {
                                  context.go('/chat');
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Failed to join session: $e',
                                      ),
                                    ),
                                  );
                                }
                              }
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // "SCANNER" Label
                    RetroLabel(text: "Scanner"),

                    const Spacer(),

                    // Bottom Button
                    // RetroButton(
                    //   text: 'My QR',
                    //   onPressed: () {
                    //     // Navigate back to the QrGeneratorScreen
                    //     context.pop();
                    //   },
                    //   backgroundColor: AppColors.primaryYellow,
                    //   width: double.infinity,
                    // ),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate back to the QR Generator screen
                        context.push('/qr-generator');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryYellow,
                        foregroundColor: AppColors.textDark,
                        side: const BorderSide(
                          color: AppColors.border,
                          width: 2,
                        ),
                        elevation: 4,
                        shadowColor: AppColors.border,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                      child: const Text("My QR", style: AppTextStyles.body),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              const Positioned(top: 20, left: 20, child: RetroHomeButton()),
            ],
          ),
        ),
      ),
    );
  }
}
