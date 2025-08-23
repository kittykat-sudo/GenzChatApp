import 'package:flutter/material.dart';
import 'package:chat_drop/features/home/widgets/header_widget.dart';
import 'package:chat_drop/features/home/widgets/search_widget.dart';
import 'package:chat_drop/features/home/widgets/contact_list_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            HeaderWidget(),
            SearchWidget(),
            SizedBox(height: 24),
            ContactListWidget(),
          ],
        ),
      ),
    );
  }
}