import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/category_model.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final List<Category> categories;
  final String? selectedCategory;
  final ValueChanged<String?>? onCategoryChanged;

  const AppHeader({
    super.key,
    this.categories = const [],
    this.selectedCategory,
    this.onCategoryChanged,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.only(top: 36, left: 16, right: 16, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Brand Logo
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.movie_creation_outlined,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "CAMFLEX",
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    "Inspired by Love",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 8,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Category Dropdown Pill
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white24, width: 1),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value: selectedCategory,
                hint: const Text(
                  "ប្រភេទទាំងអស់",
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
                ),
                dropdownColor: AppColors.cardBg,
                icon: const Icon(Icons.arrow_drop_down, color: AppColors.textPrimary),
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                onChanged: onCategoryChanged,
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text("ប្រភេទទាំងអស់ (All)"),
                  ),
                  ...categories.map((cat) {
                    return DropdownMenuItem<String?>(
                      value: cat.slug,
                      child: Text(cat.name),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Language flag selector
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("🇰🇭", style: TextStyle(fontSize: 18)),
                Icon(Icons.keyboard_arrow_down, color: AppColors.textPrimary, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
