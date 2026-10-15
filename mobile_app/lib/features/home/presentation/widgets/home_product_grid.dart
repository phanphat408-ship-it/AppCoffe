import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/product_model.dart';
import 'product_card.dart';

/// SliverGrid hiển thị danh sách các món ngon gợi ý (Products)
class HomeProductGrid extends StatelessWidget {
  final List<ProductModel> products;
  final bool isLoading;
  final void Function(ProductModel)? onAddToCart;
  final void Function(ProductModel)? onProductTap;

  const HomeProductGrid({
    super.key,
    required this.products,
    this.isLoading = false,
    this.onAddToCart,
    this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
      );
    }

    if (products.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
          alignment: Alignment.center,
          child: Column(
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 56,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 12),
              Text(
                'Chưa có món ăn phù hợp',
                style: AppTextStyles.subtitle.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                'Vui lòng thử tìm kiếm từ khóa khác hoặc chọn danh mục khác nhé.',
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.58,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final product = products[index];
            return ProductCard(
              product: product,
              onAddToCart: () => onAddToCart?.call(product),
              onTap: () => onProductTap?.call(product),
            );
          },
          childCount: products.length,
          addRepaintBoundaries: true,
        ),
      ),
    );
  }
}
