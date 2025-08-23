import 'package:chat_drop/features/home/presentation/home_screen.dart';
import 'package:chat_drop/features/chat/presentation/chat_screen.dart';
import 'package:chat_drop/features/auth/presentation/qr_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (context, state) => const ChatScreen(),
      ),
      GoRoute(
        path: '/qr', // Make sure this route exists
        name: 'qr',
        builder: (context, state) => const QRScreen(),
      ),
    ],
  );
});
