import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:chat_drop/core/widgets/retro_button.dart';
import 'package:chat_drop/features/home/widgets/header_widget.dart';
import 'package:chat_drop/features/home/widgets/search_widget.dart';
import 'package:chat_drop/features/home/widgets/contact_list_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (kDebugMode) print('🏠 HomeScreen building...');

    return Scaffold(
      backgroundColor: Colors.white,
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
