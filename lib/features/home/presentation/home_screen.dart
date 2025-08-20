import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SvgPicture.asset(
                        'assets/images/logo.svg',
                        colorFilter: const ColorFilter.mode(
                          Colors.black,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'ChatDrop',
                    style: TextStyle(
                      fontFamily: 'ZillaSlab',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5FFB1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      offset: const Offset(4, 4),
                      blurRadius: 0,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: TextStyle(fontSize: 16, color: Colors.grey),
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Friends Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      'Friends',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Expanded(
                    child: ListView(
                      children: [
                        _buildChatItem(
                          name: 'Marvin McKinney',
                          message: 'Hey, have you noticed how much...',
                          avatar: '🧑🏿‍💼',
                          isOnline: true,
                          onTap: () => context.push('/chat'),
                        ),
                        _buildChatItem(
                          name: 'Wade Warren',
                          message: 'Absolutely! It\'s fascinating how p...',
                          avatar: '🧑🏼‍💼',
                          isOnline: true,
                          onTap: () => context.push('/chat'),
                        ),
                        _buildChatItem(
                          name: 'Eleanor Pena',
                          message: 'Hey, have you noticed how...',
                          avatar: '👨🏻‍💼',
                          isOnline: true,
                          unreadCount: 2,
                          onTap: () => context.push('/chat'),
                        ),
                        _buildChatItem(
                          name: 'Jane Cooper',
                          message: 'I think it\'s great. The vibrant...',
                          avatar: '👩🏽‍🎨',
                          isOnline: false,
                          unreadCount: 2,
                          onTap: () => context.push('/chat'),
                        ),
                        _buildChatItem(
                          name: 'Kristin Watson',
                          message: 'It\'s like a never-ending groove.',
                          avatar: '👩🏻‍💼',
                          isOnline: true,
                          onTap: () => context.push('/chat'),
                        ),
                        _buildChatItem(
                          name: 'Dianne Russell',
                          message: 'Speaking of which, I saw an art e...',
                          avatar: '👩🏻‍🎤',
                          isOnline: false,
                          onTap: () => context.push('/chat'),
                        ),

                        const SizedBox(height: 16),

                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(
                            'Group',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        _buildChatItem(
                          name: 'Artistic Visions',
                          message: 'Hey, have you noticed how much...',
                          avatar: '🎨',
                          isOnline: false,
                          onTap: () => context.push('/chat'),
                        ),
                        _buildChatItem(
                          name: 'Retro Renaissance',
                          message: 'Absolutely! It\'s fascinating how p...',
                          avatar: '🏛️',
                          isOnline: false,
                          onTap: () => context.push('/chat'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatItem({
    required String name,
    required String message,
    required String avatar,
    required bool isOnline,
    int? unreadCount,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(avatar, style: const TextStyle(fontSize: 24)),
                  ),
                ),
                if (isOnline)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            if (unreadCount != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
