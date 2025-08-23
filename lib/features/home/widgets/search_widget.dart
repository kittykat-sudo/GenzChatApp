import 'package:flutter/material.dart';
import 'package:chat_drop/core/theme/app_colors.dart';

class SearchWidget extends StatelessWidget {
  final Function(String)? onChanged;
  final String? hintText;

  const SearchWidget({super.key, this.onChanged, this.hintText});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryYellow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.border,
              offset: const Offset(4, 4),
              blurRadius: 0,
              spreadRadius: 0,
            ),
          ],
        ),
        child: TextField(
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText ?? 'Search',
            hintStyle: const TextStyle(
              fontSize: 16,
              color: AppColors.textGrey,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: AppColors.textDark,
              size: 24,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }
}
