import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../data/models/product_model.dart';

/// Card hiển thị từng món ăn / thức uống theo phong cách GrabFood / BeFood:
/// - Nhãn "Bán chạy" (Best Seller) rực rỡ
/// - Điểm đánh giá sao 4.9 ⭐
/// - Định dạng giá VNĐ chuẩn mực
/// - Nút dấu "+" nổi bật thêm nhanh vào giỏ hàng
/// - Tích hợp AppNetworkImage với khung chờ Shimmer và Fallback an toàn
class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onAddToCart;
  final VoidCallback? onTap;
  final bool? isBestSeller;

  const ProductCard({
    super.key,
    required this.product,
    this.onAddToCart,
    this.onTap,
    this.isBestSeller,
  });

  bool get _effectiveBestSeller => isBestSeller ?? product.isBestSeller;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimens.r16),
          border: Border.all(color: AppColors.lightBorder, width: 0.8),
          boxShadow: [AppColors.cardShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hình ảnh món ăn với Badges phong cách GrabFood / BeFood
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppDimens.r16),
                  ),
                  child: SizedBox(
                    height: 118,
                    width: double.infinity,
                    child: AppNetworkImage(
                      imageUrl: product.imageUrl,
                      width: double.infinity,
                      height: 118,
                      fit: BoxFit.cover,
                      fallbackIcon: Icons.local_cafe_rounded,
                      cacheWidth: 400,
                    ),
                  ),
                ),

                // Nhãn "Bán chạy" (Best Seller) ở góc trên bên trái
                if (_effectiveBestSeller)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(AppDimens.r6),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF4B2B).withValues(alpha: 0.35),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 12),
                          SizedBox(width: 2),
                          Text(
                            'Bán chạy',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Badge Đánh giá sao ở góc trên bên phải
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(AppDimens.rFull),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: AppColors.rating, size: 14),
                        const SizedBox(width: 2),
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // 2. Nội dung thông tin món ăn (Tối ưu padding và Flexible chống tràn RenderFlex)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            product.name,
                            style: AppTextStyles.subtitle.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            product.description ?? product.categoryName ?? 'Cà phê & Đồ uống',
                            style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // 3. Giá tiền định dạng VNĐ và Nút (+) nổi bật
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            product.formattedPrice,
                            style: AppTextStyles.price.copyWith(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Nút (+) nổi bật chuẩn phong cách GrabFood / BeFood
                        Material(
                          color: AppColors.primary,
                          shape: const CircleBorder(),
                          elevation: 2,
                          shadowColor: AppColors.primary.withValues(alpha: 0.4),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: onAddToCart ?? onTap,
                            child: const Padding(
                              padding: EdgeInsets.all(7),
                              child: Icon(
                                Icons.add_rounded,
                                color: Colors.white,
                                size: 19,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
