import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:chat_drop/core/theme/app_colors.dart';
import 'package:chat_drop/core/theme/app_text_styles.dart';
import 'package:chat_drop/core/widgets/retro_button.dart';

class EditNameScreen extends StatefulWidget {
  const EditNameScreen({super.key});

  @override
  State<EditNameScreen> createState() => _EditNameScreenState();
}

class _EditNameScreenState extends State<EditNameScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveName() {
    if (_nameController.text.trim().isNotEmpty) {
      // Save the name logic here
      print('Saving name: ${_nameController.text.trim()}');
      context.pop(); // Return to previous screen
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
            color: AppColors.accentPink,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border, width: 4),
            boxShadow: [
              BoxShadow(
                color: AppColors.border,
                offset: const Offset(8, 8),
                blurRadius: 0,
                spreadRadius: 0,
              ),
            ],
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
                  decoration: BoxDecoration(
                    color: AppColors.accentPink,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border, width: 3),
                  ),
                  child: Center(
                    child: Container(
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

                const SizedBox(height: 60),

                // Pick a new name text
                const Text(
                  'Pick a new name :)',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    fontFamily: "ZillaSlab",
                  ),
                ),

                const SizedBox(height: 40),

                // Name Input Field
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryYellow,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: AppColors.border, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.border,
                        offset: const Offset(4, 4),
                        blurRadius: 0,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _nameController,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontFamily: "ZillaSlab",
                      fontSize: 16,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Enter a nickname...',
                      hintStyle: TextStyle(
                        color: AppColors.textGrey,
                        fontFamily: "ZillaSlab",
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                    onSubmitted: (_) => _saveName(),
                  ),
                ),

                const Spacer(),

                // Save Button
                RetroButton(
                  text: 'Save >',
                  onPressed: _saveName,
                  backgroundColor: AppColors.accentPink,
                  width: 120,
                  height: 50,
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}