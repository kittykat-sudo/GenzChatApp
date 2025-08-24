import 'package:flutter/material.dart';
import 'package:chat_drop/core/theme/app_text_styles.dart';
import 'package:chat_drop/features/home/widgets/contact_card_widget.dart';

class ContactListWidget extends StatelessWidget {
  const ContactListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          // Friends Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text('Friends', style: AppTextStyles.heading),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: ListView(
              children: [
                ContactCard(
                  name: 'Marvin McKinney',
                  message: 'Hey, have you noticed how much...',
                  avatar: '🧑🏿‍💼',
                  isOnline: true,
                  isRead: true,
                ),
                ContactCard(
                  name: 'Wade Warren',
                  message: 'Absolutely! It\'s fascinating how p...',
                  avatar: '🧑🏼‍💼',
                  isOnline: true,
                  isRead: true,
                ),
                ContactCard(
                  name: 'Eleanor Pena',
                  message: 'Hey, have you noticed how...',
                  avatar: '👨🏻‍💼',
                  isOnline: true,
                  unreadCount: 2,
                  isRead: false,
                ),
                ContactCard(
                  name: 'Jane Cooper',
                  message: 'I think it\'s great. The vibrant...',
                  avatar: '👩🏽‍🎨',
                  isOnline: false,
                  unreadCount: 2,
                  isRead: false,
                ),
                ContactCard(
                  name: 'Kristin Watson',
                  message: 'It\'s like a never-ending groove.',
                  avatar: '👩🏻‍💼',
                  isOnline: true,
                  isRead: true,
                ),
                ContactCard(
                  name: 'Dianne Russell',
                  message: 'Speaking of which, I saw an art e...',
                  avatar: '👩🏻‍🎤',
                  isOnline: false,
                  isRead: true,
                ),
                ContactCard(
                  name: 'Dianne Russell',
                  message: 'Speaking of which, I saw an art e...',
                  avatar: '👩🏻‍🎤',
                  isOnline: false,
                  isRead: true,
                ),
                ContactCard(
                  name: 'Dianne Russell',
                  message: 'Speaking of which, I saw an art e...',
                  avatar: '👩🏻‍🎤',
                  isOnline: false,
                  isRead: true,
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
