import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:chat_drop/core/theme/app_colors.dart';
import 'package:chat_drop/core/widgets/retro_button.dart';

class QRScreen extends StatelessWidget {
  const QRScreen({super.key});

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
            color: const Color(0xFFFFEBED),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border, width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Section
                Container(
                  width: 120,
                  height: 120,

                  child: SvgPicture.asset(
                    'assets/images/logo.svg',
                    fit: BoxFit.contain,
                    placeholderBuilder:
                        (context) => const Icon(
                          Icons.chat_bubble_outline,
                          color: Color.fromARGB(0, 51, 51, 51),
                          size: 24,
                        ),
                  ),
                ),

                const SizedBox(height: 24),

                // App Name
                const Text(
                  'ChatDrop',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    fontFamily: "ZillaSlab",
                  ),
                ),

                const SizedBox(height: 40),

                // QR Code Section
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    color: AppColors.textLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border, width: 3),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.qr_code_2,
                      size: 180,
                      color: AppColors.textDark,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // "SCAN ME" Label
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.textDark,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.border,
                        offset: const Offset(3, 3),
                        blurRadius: 0,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: const Text(
                    'SCAN ME',
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      fontFamily: "ZillaSlab",
                    ),
                  ),
                ),

                const Spacer(),

                // Bottom Button
                RetroButton(
                  text: 'Scan my friend\'s QR',
                  onPressed: () {
                    // Add camera/scanner functionality here
                  },
                  backgroundColor: const Color(0xFFFFCDCA),
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
