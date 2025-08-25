import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:chat_drop/core/widgets/retro_button.dart';
import 'package:chat_drop/features/home/widgets/header_widget.dart';
import 'package:chat_drop/features/home/widgets/search_widget.dart';
import 'package:chat_drop/features/home/widgets/contact_list_widget.dart';
import 'package:chat_drop/features/friends/presentation/providers/friends_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) print('🏠 HomeScreen initialized');

    // Use schedulerBinding to avoid blocking initial render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFriendsDataOptimized();
    });
  }

  void _initializeFriendsDataOptimized() {
    if (!_hasInitialized && mounted) {
      _hasInitialized = true;

      if (kDebugMode)
        print('🔄 Starting optimized friends data initialization');

      // Use longer delay to ensure UI is fully rendered
      Future.delayed(const Duration(milliseconds: 500), () async {
        if (mounted) {
          try {
            await ref.read(initializeFriendsProvider.future);
            if (kDebugMode)
              print('✅ Friends initialization completed successfully');
          } catch (e) {
            if (kDebugMode) print('❌ Friends initialization error: $e');
            // Don't rethrow - this is background initialization
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
