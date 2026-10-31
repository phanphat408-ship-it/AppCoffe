import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/category_model.dart';

/// Dải danh mục (Categories) hiển thị dưới dạng ListView nằm ngang
class HomeCategoryList extends StatelessWidget {
  final List<CategoryModel> categories;
  final int selectedCategoryId;
  final ValueChanged<int> onSelectCategory;

  const HomeCategoryList({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelectCategory,
  });

  @override
  Widget build(BuildContext context) {
    // Thêm mục "Tất cả" (Id: 0) ở đầu danh sách
    const allItem = CategoryModel(id: 0, name: 'Tất cả');
    final displayList = [allItem, ...categories];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: displayList.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = displayList[index];
          final isSelected = selectedCategoryId == category.id;

          return GestureDetector(
            onTap: () => onSelectCategory(category.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(AppDimens.r12),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.lightBorder,
                  width: 1.0,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon hoặc thumbnail nhỏ của danh mục
                  Icon(
                    _getCategoryIcon(category.id),
                    size: 18,
                    color: isSelected ? Colors.white : AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    category.name,
                    style: AppTextStyles.subtitle.copyWith(
                      fontSize: 14,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(int categoryId) {
    switch (categoryId) {
      case 0:
        return Icons.grid_view_rounded;
      case 1:
        return Icons.local_cafe_rounded; // Cà Phê Việt
      case 2:
        return Icons.emoji_food_beverage_rounded; // Trà Trái Cây & Trà Sữa
      case 3:
        return Icons.blender_rounded; // Đá Xay & Matcha
      case 4:
        return Icons.bakery_dining_rounded; // Bánh Ngọt & Ăn Vặt
      default:
        return Icons.restaurant_rounded;
    }
  }
}
