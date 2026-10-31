import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../home/data/models/product_model.dart';
import '../../../home/presentation/widgets/product_customization_sheet.dart';
import '../controllers/favorites_notifier.dart';

/// BottomSheet Món ăn yêu thích của người dùng
class FavoriteProductsSheet extends ConsumerWidget {
  const FavoriteProductsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FavoriteProductsSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.r24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thanh kéo
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.lightBorder,
                    borderRadius: BorderRadius.circular(AppDimens.rFull),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Tiêu đề
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.favorite_rounded, color: AppColors.error, size: 24),
                      const SizedBox(width: 8),
                      Text('Món Yêu Thích (${favorites.length})',
                          style: AppTextStyles.h3.copyWith(fontSize: 18)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Danh sách món
              Expanded(
                child: favorites.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.favorite_border_rounded, size: 56, color: AppColors.textLight),
                            const SizedBox(height: 12),
                            Text('Chưa có món yêu thích nào', style: AppTextStyles.subtitle),
                            const SizedBox(height: 4),
                            Text('Hãy bấm thả tim các món bạn thích ở trang chủ nhé!',
                                style: AppTextStyles.caption),
                          ],
                        ),
                      )
                    : ListView.separated(
                        cacheExtent: 300,
                        addRepaintBoundaries: true,
                        itemCount: favorites.length,
                        separatorBuilder: (ctx, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = favorites[index];
                          return _buildFavoriteItem(context, ref, item);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteItem(BuildContext context, WidgetRef ref, ProductModel product) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimens.r16),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Row(
        children: [
          // Hình ảnh
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.r12),
            child: SizedBox(
              width: 72,
              height: 72,
              child: AppNetworkImage(
                imageUrl: product.imageUrl,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                cacheWidth: 150,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Thông tin món
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: AppTextStyles.subtitle.copyWith(fontSize: 14.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFB800)),
                    const SizedBox(width: 2),
                    Text('${product.rating}', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(width: 8),
                    Text(
                      product.categoryName ?? 'Món ngon',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  CurrencyFormatter.vnd(product.price),
                  style: AppTextStyles.price.copyWith(fontSize: 15, color: AppColors.primary),
                ),
              ],
            ),
          ),

          // Nút Xóa yêu thích & Nút Thêm vào giỏ
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.favorite_rounded, color: AppColors.error, size: 22),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  ref.read(favoritesProvider.notifier).removeFavorite(product.id);
                  AppSnackBar.info(context, 'Đã xóa "${product.name}" khỏi danh sách yêu thích');
                },
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  ProductCustomizationSheet.show(context, product);
                },
                borderRadius: BorderRadius.circular(AppDimens.r8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppDimens.r8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_shopping_cart_rounded, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Đặt món',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
