import 'package:chat_drop/features/auth/presentation/screens/get_started_screen.dart';
import 'package:chat_drop/features/auth/presentation/screens/name_registration_screen.dart';
import 'package:chat_drop/features/auth/presentation/screens/qr_generator_screen.dart';
import 'package:chat_drop/features/auth/presentation/screens/qr_scanner_screen.dart';
import 'package:chat_drop/features/home/presentation/home_screen.dart';
import 'package:chat_drop/features/chat/presentation/screens/chat_screen.dart';
import 'package:chat_drop/features/profile/presentation/friends_profile_screen.dart';
import 'package:chat_drop/features/profile/presentation/edit_name_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

CustomTransitionPage<T> _buildFadeTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Fade Transition
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOutCirc).animate(animation),
        child: child,
      );
    },
  );
}

// CustomTransitionPage<T> _buildNoAnimationTransition<T>({
//   required BuildContext context,
//   required GoRouterState state,
//   required Widget child,
// }) {
//   return CustomTransitionPage(
//     key: state.pageKey,
//     child: child,
//     transitionsBuilder: (context, animation, secondaryAnimation, child) {
//       return child;
//     },
//   );
// }

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/get-started',
    routes: [
      GoRoute(
        path: '/get-started',
        name: 'get-started',
        pageBuilder:
            (context, state) => _buildFadeTransition(
              context: context,
              state: state,
              child: const GetStartedScreen(),
            ),
      ),

      GoRoute(
        path: '/name-registration',
        name: 'name-registration',
        pageBuilder:
            (context, state) => _buildFadeTransition(
              context: context,
              state: state,
              child: const NameRegistrationScreen(),
            ),
      ),

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
        path: '/qr-generator',
        name: 'qr-generator',
        pageBuilder:
            (context, state) => _buildFadeTransition(
              context: context,
              state: state,
              child: const QrGeneratorScreen(),
            ),
      ),

      GoRoute(
        path: '/qr-scanner',
        name: 'qr-scanner',
        pageBuilder:
            (context, state) => _buildFadeTransition(
              context: context,
              state: state,
              child: const QrScannerScreen(),
            ),
      ),
      GoRoute(
        path: '/profile', // Add profile route
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/edit-name',
        name: 'edit-name',
        builder: (context, state) => const EditNameScreen(),
      ),
    ],
  );
});
