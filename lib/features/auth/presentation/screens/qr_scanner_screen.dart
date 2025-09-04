import 'package:chat_drop/core/theme/app_colors.dart';
import 'package:chat_drop/core/theme/app_text_styles.dart';
import 'package:chat_drop/core/utils/retro_snackbar.dart';
import 'package:chat_drop/core/widgets/retro_button.dart';
import 'package:chat_drop/features/auth/presentation/providers/auth_providers.dart';
import 'package:chat_drop/features/auth/widgets/retro_label.dart';
import 'package:chat_drop/features/friends/presentation/providers/friends_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({super.key});

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen> {
  bool isProcessing = false;

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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: Stack(
                          children: [
                            MobileScanner(
                              onDetect: (capture) async {
                                if (isProcessing) return;

                                final List<Barcode> barcodes = capture.barcodes;
                                if (barcodes.isNotEmpty) {
                                  setState(() => isProcessing = true);

                                  final String qrData =
                                      barcodes.first.rawValue!;

                                  try {
                                    // Parse QR data (should contain sessionId and friendId and friendName)
                                    final qrParts = qrData.split('|');
                                    if (qrParts.length < 3) {
                                      throw Exception('Invalid QR code format');
                                    }

                                    final sessionId = qrParts[0];
                                    final friendId = qrParts[1];
                                    final friendName = qrParts[2];

                                    // 1. Join the session
                                    final authRepository = ref.read(
                                      authRepositoryProvider,
                                    );
                                    await authRepository.signInAnonymously();
                                    await authRepository.joinSession(sessionId);

                                    // 2. Add as temporary friend
                                    final friendsRepository = ref.read(
                                      friendsRepositoryProvider,
                                    );
                                    await friendsRepository.addTemporaryFriend(
                                      friendId: friendId,
                                      friendName: friendName,
                                      sessionId: sessionId,
                                    );

                                    // 3. Set session ID
                                    ref.read(sessionIdProvider.notifier).state =
                                        sessionId;

                                    // 4. Navigate to chat
                                    if (context.mounted) {
                                      context.go('/chat');
                                      showRetroSnackbar(
                                        context: context,
                                        message: 'Connected with $friendName!',
                                        type: SnackbarType.success,
                                      );
                                    }
                                  } catch (e) {
                                    setState(() => isProcessing = false);
                                    if (context.mounted) {
                                      showRetroSnackbar(
                                        context: context,
                                        message: 'Failed to connect: $e',
                                        type: SnackbarType.error,
                                      );
                                    }
                                  }
                                }
                              },
                            ),

                            // Processing overlay
                            if (isProcessing)
                              Container(
                                color: Colors.black54,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // "SCANNER" Label
                    const RetroLabel(text: "Scanner"),

                    const Spacer(),

                    // Bottom Button
                    RetroButton(
                      text: 'My QR',
                      onPressed: () {
                        context.push('/qr-generator');
                      },
                      backgroundColor: AppColors.accentPink,
                      width: 150.00,
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
