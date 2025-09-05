import 'package:chat_drop/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:chat_drop/core/widgets/retro_button.dart';
import 'package:chat_drop/features/home/widgets/header_widget.dart';
import 'package:chat_drop/features/home/widgets/search_widget.dart';
import 'package:chat_drop/features/home/widgets/contact_list_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _searchQuery = '';

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    //if (kDebugMode) print('🏠 HomeScreen building...');

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            const HeaderWidget(),

            const SizedBox(height: 20),

            // Search widget with integrated clear button
            SearchWidget(
              onChanged: _onSearchChanged,
              hintText: 'Search friends...',
            ),

            // Contact List with search
            ContactListWidget(searchQuery: _searchQuery),
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
