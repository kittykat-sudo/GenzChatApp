import 'package:flutter/material.dart';
import 'package:chat_drop/core/theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryYellow,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border, width: 2),
            ),
            child: const Icon(
              Icons.arrow_back,
              color: AppColors.textDark,
              size: 20,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'View Profile',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
            fontFamily: "ZillaSlab",
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Profile Picture
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.accentPink,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.border,
                    offset: const Offset(6, 6),
                    blurRadius: 0,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: ClipOval(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFFF6B6B),
                        Color(0xFFFFE66D),
                        Color(0xFF4ECDC4),
                        Color(0xFF45B7D1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: Text('📷', style: TextStyle(fontSize: 60)),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // User Name
            const Text(
              'Andrew Nguyen',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
                fontFamily: "ZillaSlab",
              ),
            ),

            const SizedBox(height: 40),

            // Profile Information
            _buildProfileSection('Email', 'Theeshdeawesome@outlook.com'),

            _buildProfileSection('Phone number', '0778683088'),

            _buildClickableSection('Status', ''),

            _buildClickableSection('Chat setting', ''),

            _buildClickableSection('File, Attachments', ''),

            _buildClickableSection('Link', ''),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              fontFamily: "ZillaSlab",
            ),
          ),
          const SizedBox(height: 8),
          if (value.isNotEmpty)
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textGrey,
                fontFamily: "ZillaSlab",
              ),
            ),
          const SizedBox(height: 12),
          Container(height: 2, color: AppColors.border),
        ],
      ),
    );
  }

  Widget _buildClickableSection(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      child: InkWell(
        onTap: () {
          // Handle section tap
          print('$title tapped');
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    fontFamily: "ZillaSlab",
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textGrey,
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (value.isNotEmpty)
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textGrey,
                  fontFamily: "ZillaSlab",
                ),
              ),
            const SizedBox(height: 12),
            Container(height: 2, color: AppColors.border),
          ],
        ),
      ),
    );
  }
}
