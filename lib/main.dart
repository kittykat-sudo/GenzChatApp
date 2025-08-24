import 'package:firebase_core/firebase_core.dart';
import 'package:chat_drop/core/theme/app_theme.dart';
import 'package:chat_drop/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  // Ensure that Flutter bindings are initialized before running the app.
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  await Firebase.initializeApp();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light
  ));
  runApp(const ProviderScope(child: ChatDrop()));
}

class ChatDrop extends ConsumerWidget {
  const ChatDrop({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'ChatDrop',
      routerConfig: router,
      theme: appTheme
    );
  }
}
