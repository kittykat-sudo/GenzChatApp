import 'package:flutter/material.dart';
import 'package:chat_drop/core/theme/app_colors.dart';
import 'package:chat_drop/core/theme/app_text_styles.dart';

class QRScreen extends StatelessWidget {
  const QRScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: AppColors.retroBlue,
        foregroundColor: AppColors.textLight,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(40.0),
                decoration: BoxDecoration(
                  color: AppColors.accentPink,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.border,
                      offset: const Offset(6, 6),
                      blurRadius: 0,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Logo placeholder
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primaryYellow,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border, width: 2),
                      ),
                      child: const Icon(
                        Icons.chat_bubble_outline,
                        size: 40,
                        color: AppColors.textDark,
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text('ChatDrop', style: AppTextStyles.heading),

                    const SizedBox(height: 32),

                    // QR Code placeholder
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppColors.textLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border, width: 2),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.qr_code,
                          size: 120,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.textDark,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'SCAN ME',
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryYellow,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border, width: 2),
                      ),
                      child: const Text(
                        'Scan my friend\'s QR',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
