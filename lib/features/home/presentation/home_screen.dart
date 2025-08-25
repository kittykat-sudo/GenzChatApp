import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:chat_drop/core/widgets/retro_button.dart';
import 'package:chat_drop/features/home/widgets/header_widget.dart';
import 'package:chat_drop/features/home/widgets/search_widget.dart';
import 'package:chat_drop/features/home/widgets/contact_list_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const HeaderWidget(),
            const SearchWidget(),
            const SizedBox(height: 4),
            const Expanded(child: ContactListWidget()),
          ],
        ),
      ),
      // Add QR button as floating action button in the body
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 20, right: 5),
        child: RetroButton(
          text: '',
          icon: Icons.qr_code_scanner,
          onPressed: () {
            context.push('/qr-generator');
          },
          width: 48,
          height: 48,
        ),
      ),
    );
  }
}
